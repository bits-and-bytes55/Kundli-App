"""
Gochar (Transit) Calculations
Computes current planet positions using Swiss Ephemeris (Lahiri ayanamsa).
Matches AstroSage-style transit chart logic — fully dynamic, no static data.
"""
import swisseph as swe
from datetime import datetime, timezone
from calculations.kundli import (
    RASHIS, RASHI_LORDS, NAKSHATRAS, NAKSHATRA_LORDS,
    NAKSHATRA_SYLLABLES, EXALTATION, DEBILITATION
)

# Default observer location for current-time Lagna (New Delhi)
DEFAULT_LAT = 28.6139
DEFAULT_LON = 77.2090


def _lon_to_planet_data(name: str, lon: float, speed: float) -> dict:
    """Convert a sidereal longitude + speed into full planet data dict."""
    rashi_idx = int(lon / 30) % 12
    nak_idx = int(lon / (360.0 / 27.0)) % 27
    nak_pada = int((lon % (360.0 / 27.0)) / (360.0 / 108.0)) + 1

    # Retrograde: true when speed < 0 (Sun/Moon/Rahu never retrograde)
    is_retrograde = (speed < 0) if name not in ('Sun', 'Moon', 'Rahu', 'Ketu') else False

    # Exaltation / Debilitation check (within ±1 degree of exact point)
    is_exalted = False
    is_debilitated = False
    if name in EXALTATION:
        diff_ex = abs(lon - EXALTATION[name])
        diff_ex = min(diff_ex, 360 - diff_ex)
        is_exalted = diff_ex < 1.0
    if name in DEBILITATION:
        diff_db = abs(lon - DEBILITATION[name])
        diff_db = min(diff_db, 360 - diff_db)
        is_debilitated = diff_db < 1.0

    return {
        'longitude': round(lon, 6),
        'speed': round(speed, 6),
        'degree': round(lon % 30, 4),
        'rashi': RASHIS[rashi_idx],
        'rashi_lord': RASHI_LORDS[rashi_idx],
        'rashi_num': rashi_idx + 1,
        'nakshatra': NAKSHATRAS[nak_idx],
        'nakshatra_lord': NAKSHATRA_LORDS[nak_idx],
        'pada': nak_pada,
        'namakshar': NAKSHATRA_SYLLABLES[nak_idx][nak_pada - 1],
        'is_retrograde': is_retrograde,
        'is_exalted': is_exalted,
        'is_debilitated': is_debilitated,
    }


def get_current_transits(obs_lat: float = DEFAULT_LAT, obs_lon: float = DEFAULT_LON) -> dict:
    """
    Compute current planetary positions (Sidereal / Lahiri) for Gochar (Transit).

    Returns:
        transits       — dict of planet data (Sun … Ketu)
        current_lagna  — dict with rashi + rashi_num of the current ascendant
        computed_at_utc — human-readable UTC timestamp string
        jd             — Julian Day of computation
    """
    swe.set_sid_mode(swe.SIDM_LAHIRI)

    now_utc = datetime.now(timezone.utc)
    ut_hours = now_utc.hour + now_utc.minute / 60.0 + now_utc.second / 3600.0
    jd_now = swe.julday(now_utc.year, now_utc.month, now_utc.day, ut_hours)

    # ── Planet positions ──────────────────────────────────────────────────────
    planet_ids = {
        'Sun':     swe.SUN,
        'Moon':    swe.MOON,
        'Mars':    swe.MARS,
        'Mercury': swe.MERCURY,
        'Jupiter': swe.JUPITER,
        'Venus':   swe.VENUS,
        'Saturn':  swe.SATURN,
        'Rahu':    swe.MEAN_NODE,   # True mean node (Rahu)
        'Uranus':  swe.URANUS,
        'Neptune': swe.NEPTUNE,
        'Pluto':   swe.PLUTO,
    }

    transits: dict = {}
    for name, pid in planet_ids.items():
        res, _ = swe.calc_ut(jd_now, pid, swe.FLG_SIDEREAL | swe.FLG_SPEED)
        lon   = res[0]
        speed = res[3]
        transits[name] = _lon_to_planet_data(name, lon, speed)

    # Ketu = Rahu + 180°
    rahu_lon = transits['Rahu']['longitude']
    ketu_lon = (rahu_lon + 180.0) % 360.0
    ketu_data = _lon_to_planet_data('Ketu', ketu_lon, transits['Rahu']['speed'])
    ketu_data['is_retrograde'] = False          # Ketu is always listed as direct
    transits['Ketu'] = ketu_data

    # ── Current Lagna (ascendant at this moment for the observer) ─────────────
    # Uses Whole-Sign houses so house 1 = lagna rashi, exactly as AstroSage does
    try:
        houses_res = swe.houses_ex(jd_now, obs_lat, obs_lon, b'W', swe.FLG_SIDEREAL)
        asc_lon = houses_res[1][0]              # ASCMC[0] = Ascendant
    except Exception:
        asc_lon = 0.0

    asc_rashi_idx = int(asc_lon / 30) % 12
    asc_nak_idx   = int(asc_lon / (360.0 / 27.0)) % 27
    asc_pada      = int((asc_lon % (360.0 / 27.0)) / (360.0 / 108.0)) + 1

    current_lagna = {
        'longitude':    round(asc_lon, 6),
        'degree':       round(asc_lon % 30, 4),
        'rashi':        RASHIS[asc_rashi_idx],
        'rashi_lord':   RASHI_LORDS[asc_rashi_idx],
        'rashi_num':    asc_rashi_idx + 1,
        'nakshatra':    NAKSHATRAS[asc_nak_idx],
        'nakshatra_lord': NAKSHATRA_LORDS[asc_nak_idx],
        'pada':         asc_pada,
    }

    return {
        'transits':        transits,
        'current_lagna':   current_lagna,
        'computed_at_utc': now_utc.strftime('%Y-%m-%d %H:%M UTC'),
        'jd':              round(jd_now, 6),
    }
