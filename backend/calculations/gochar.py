"""
Gochar (Transit) Calculations
Computes current planet positions using Swiss Ephemeris (Lahiri ayanamsa).
"""
import swisseph as swe
from datetime import datetime, timezone
from calculations.kundli import RASHIS, RASHI_LORDS, NAKSHATRAS, NAKSHATRA_LORDS, NAKSHATRA_SYLLABLES


def get_current_transits():
    """
    Compute current planetary positions (Sidereal/Lahiri) for Gochar (Transit).
    """
    swe.set_sid_mode(swe.SIDM_LAHIRI)
    now_utc = datetime.now(timezone.utc)
    jd_now = swe.julday(now_utc.year, now_utc.month, now_utc.day,
                         now_utc.hour + now_utc.minute / 60.0 + now_utc.second / 3600.0)

    planet_ids = {
        'Sun': swe.SUN, 'Moon': swe.MOON, 'Mars': swe.MARS,
        'Mercury': swe.MERCURY, 'Jupiter': swe.JUPITER, 'Venus': swe.VENUS,
        'Saturn': swe.SATURN, 'Rahu': swe.MEAN_NODE,
        'Uranus': swe.URANUS, 'Neptune': swe.NEPTUNE, 'Pluto': swe.PLUTO
    }

    transits = {}
    for name, pid in planet_ids.items():
        res, _ = swe.calc_ut(jd_now, pid, swe.FLG_SIDEREAL | swe.FLG_SPEED)
        lon = res[0]
        speed = res[3]
        rashi_idx = int(lon / 30)
        nak_idx = int(lon / (360 / 27))
        nak_pada = int((lon % (360 / 27)) / (360 / 108)) + 1
        transits[name] = {
            'longitude': round(lon, 6),
            'speed': round(speed, 6),
            'degree': round(lon % 30, 4),
            'rashi': RASHIS[rashi_idx],
            'rashi_lord': RASHI_LORDS[rashi_idx],
            'rashi_num': rashi_idx + 1,
            'nakshatra': NAKSHATRAS[nak_idx],
            'nakshatra_lord': NAKSHATRA_LORDS[nak_idx],
            'pada': nak_pada,
            'is_retrograde': speed < 0 if name not in ['Sun', 'Moon', 'Rahu'] else False,
        }

    # Ketu = Rahu + 180
    rahu_lon = transits['Rahu']['longitude']
    ketu_lon = (rahu_lon + 180) % 360
    ri = int(ketu_lon / 30)
    ni = int(ketu_lon / (360 / 27))
    np_ = int((ketu_lon % (360 / 27)) / (360 / 108)) + 1
    transits['Ketu'] = {
        'longitude': round(ketu_lon, 6),
        'speed': transits['Rahu']['speed'],
        'degree': round(ketu_lon % 30, 4),
        'rashi': RASHIS[ri],
        'rashi_lord': RASHI_LORDS[ri],
        'rashi_num': ri + 1,
        'nakshatra': NAKSHATRAS[ni],
        'nakshatra_lord': NAKSHATRA_LORDS[ni],
        'pada': np_,
        'is_retrograde': False,
    }

    return {
        'transits': transits,
        'computed_at_utc': now_utc.strftime('%Y-%m-%d %H:%M UTC'),
        'jd': round(jd_now, 6),
    }
