import swisseph as swe
from datetime import datetime, timedelta, timezone
from timezonefinder import TimezoneFinder
import pytz
import math

from calculations.kundli import RASHIS, RASHI_LORDS, NAKSHATRAS, NAKSHATRA_LORDS, get_julian_day

TITHI_NAMES = [
    'Pratipada', 'Dwitiya', 'Tritiya', 'Chaturthi', 'Panchami', 'Shashti', 
    'Saptami', 'Ashtami', 'Navami', 'Dashami', 'Ekadashi', 'Dwadashi', 
    'Trayodashi', 'Chaturdashi', 'Purnima'
]

YOGAS = [
    'Vishkumbha', 'Priti', 'Ayushman', 'Saubhagya', 'Shobhana', 'Atiganda', 
    'Sukarma', 'Dhriti', 'Shoola', 'Ganda', 'Vridhhi', 'Dhruva', 'Vyaghata', 
    'Harshana', 'Vajra', 'Siddhi', 'Vyatipata', 'Variyan', 'Parigha', 'Shiva', 
    'Siddha', 'Sadhya', 'Shubha', 'Shukla', 'Brahma', 'Indra', 'Vaidhriti'
]

KARANAS = [
    'Kintughna', 'Bava', 'Balava', 'Kaulava', 'Taitila', 'Gara', 'Vanija', 'Vishti',
    'Sakuni', 'Chatushpada', 'Naga'
]

VARA_NAMES = [
    'Ravivara (Sunday)', 'Somavara (Monday)', 'Mangalavara (Tuesday)', 
    'Budhavara (Wednesday)', 'Guruvara (Thursday)', 'Shukravara (Friday)', 
    'Shanivara (Saturday)'
]

HINDU_MASA_NAMES = [
    'Chaitra', 'Vaisakha', 'Jyeshtha', 'Ashadha', 'Sravana', 'Bhadrapada',
    'Ashvina', 'Kartika', 'Margashirsha', 'Pausha', 'Magha', 'Phalguni'
]

# Choghadiya orders starting from Sunrise
DAY_CHOGHADIYA_ORDER = {
    0: ['Udveg', 'Chal', 'Labh', 'Amrit', 'Kaal', 'Shubh', 'Rog', 'Udveg'],      # Sunday
    1: ['Amrit', 'Kaal', 'Shubh', 'Rog', 'Udveg', 'Chal', 'Labh', 'Amrit'],      # Monday
    2: ['Rog', 'Udveg', 'Chal', 'Labh', 'Amrit', 'Kaal', 'Shubh', 'Rog'],        # Tuesday
    3: ['Labh', 'Amrit', 'Kaal', 'Shubh', 'Rog', 'Udveg', 'Chal', 'Labh'],      # Wednesday
    4: ['Shubh', 'Rog', 'Udveg', 'Chal', 'Labh', 'Amrit', 'Kaal', 'Shubh'],      # Thursday
    5: ['Chal', 'Labh', 'Amrit', 'Kaal', 'Shubh', 'Rog', 'Udveg', 'Chal'],      # Friday
    6: ['Kaal', 'Shubh', 'Rog', 'Udveg', 'Chal', 'Labh', 'Amrit', 'Kaal']       # Saturday
}

NIGHT_CHOGHADIYA_ORDER = {
    0: ['Shubh', 'Amrit', 'Chal', 'Rog', 'Kaal', 'Labh', 'Udveg', 'Shubh'],     # Sunday
    1: ['Chal', 'Rog', 'Kaal', 'Labh', 'Udveg', 'Shubh', 'Amrit', 'Chal'],     # Monday
    2: ['Kaal', 'Labh', 'Udveg', 'Shubh', 'Amrit', 'Chal', 'Rog', 'Kaal'],     # Tuesday
    3: ['Udveg', 'Shubh', 'Amrit', 'Chal', 'Rog', 'Kaal', 'Labh', 'Udveg'],     # Wednesday
    4: ['Amrit', 'Chal', 'Rog', 'Kaal', 'Labh', 'Udveg', 'Shubh', 'Amrit'],     # Thursday
    5: ['Rog', 'Kaal', 'Labh', 'Udveg', 'Shubh', 'Amrit', 'Chal', 'Rog'],       # Friday
    6: ['Labh', 'Udveg', 'Shubh', 'Amrit', 'Chal', 'Rog', 'Kaal', 'Labh']       # Saturday
}

CHOGHADIYA_PROPERTIES = {
    'Amrit': {'type': 'Good', 'color': 'green', 'translation': 'Nectar'},
    'Shubh': {'type': 'Good', 'color': 'green', 'translation': 'Auspicious'},
    'Labh': {'type': 'Good', 'color': 'green', 'translation': 'Gain'},
    'Chal': {'type': 'Neutral', 'color': 'blue', 'translation': 'Neutral'},
    'Udveg': {'type': 'Bad', 'color': 'red', 'translation': 'Anxiety'},
    'Kaal': {'type': 'Bad', 'color': 'red', 'translation': 'Death / Time'},
    'Rog': {'type': 'Bad', 'color': 'red', 'translation': 'Disease'}
}

def get_timezone_offset_and_name(lat, lon, date_str, time_str):
    tf = TimezoneFinder()
    tz_name = tf.timezone_at(lng=lon, lat=lat) or 'Asia/Kolkata'
    tz = pytz.timezone(tz_name)
    dt = datetime.strptime(f"{date_str} {time_str}", "%Y-%m-%d %H:%M")
    localized_dt = tz.localize(dt)
    offset = localized_dt.utcoffset()
    return offset, tz_name

def jd_to_datetime(jd, tz_offset):
    # Convert Julian Day to datetime in UTC, then localize to the timezone offset
    y, m, d, h = swe.revjul(jd, swe.GREG_CAL)
    hour = int(h)
    minute = int((h - hour) * 60)
    second = int(((h - hour) * 60 - minute) * 60)
    microsecond = int(((((h - hour) * 60 - minute) * 60 - second)) * 1000000)
    if second >= 60:
        second = 59
    utc_dt = datetime(y, m, d, hour, minute, second, microsecond, tzinfo=timezone.utc)
    return utc_dt.astimezone(pytz.utc).astimezone(timezone(tz_offset))

def calculate_panchang(date_str, time_str, lat, lon):
    # Get Julian Day for the exact time
    jd = get_julian_day(date_str, time_str, lat, lon)
    
    # Set lahiri mode
    swe.set_sid_mode(swe.SIDM_LAHIRI)
    
    # Calculate Sun and Moon positions
    res_sun, _ = swe.calc_ut(jd, swe.SUN, swe.FLG_SIDEREAL)
    res_moon, _ = swe.calc_ut(jd, swe.MOON, swe.FLG_SIDEREAL)
    
    sun_lon = res_sun[0]
    moon_lon = res_moon[0]
    
    # ── 1. Tithi ────────────────────────────────────────────────────────────
    # Tithi angle goes from 0 to 360, representing the distance between Moon and Sun
    diff = (moon_lon - sun_lon) % 360
    tithi_index = int(diff / 12) + 1  # 1 to 30
    tithi_percent = (diff % 12) / 12.0
    
    # Tithi Paksha & Name
    tithi_num = (tithi_index - 1) % 15 + 1
    paksha = "Shukla" if tithi_index <= 15 else "Krishna"
    if tithi_index == 15:
        tithi_name = "Purnima"
    elif tithi_index == 30:
        tithi_name = "Amavasya"
    else:
        tithi_name = TITHI_NAMES[tithi_num - 1]
        
    # ── 2. Nakshatra ────────────────────────────────────────────────────────
    # Moon's position in the 27 Nakshatras
    nak_index = int(moon_lon / (360.0 / 27.0))  # 0 to 26
    nak_percent = (moon_lon % (360.0 / 27.0)) / (360.0 / 27.0)
    nak_name = NAKSHATRAS[nak_index]
    nak_lord = NAKSHATRA_LORDS[nak_index]
    nak_pada = int(nak_percent * 4) + 1
    
    # ── 3. Yoga ─────────────────────────────────────────────────────────────
    # Sum of Sun and Moon position in the 27 Yogas
    yoga_sum = (sun_lon + moon_lon) % 360
    yoga_index = int(yoga_sum / (360.0 / 27.0))  # 0 to 26
    yoga_percent = (yoga_sum % (360.0 / 27.0)) / (360.0 / 27.0)
    yoga_name = YOGAS[yoga_index]
    
    # ── 4. Karana ───────────────────────────────────────────────────────────
    # Half of a Tithi (6 degrees)
    karana_index = int(diff / 6.0) + 1  # 1 to 60
    if karana_index == 1:
        karana_name = "Kintughna"
    elif 2 <= karana_index <= 57:
        repeating_karanas = ['Bava', 'Balava', 'Kaulava', 'Taitila', 'Gara', 'Vanija', 'Vishti']
        karana_name = repeating_karanas[(karana_index - 2) % 7]
    elif karana_index == 58:
        karana_name = "Sakuni"
    elif karana_index == 59:
        karana_name = "Chatushpada"
    else:
        karana_name = "Naga"
        
    # Bhadra check: Vishti Karana is called Bhadra (inauspicious time)
    is_bhadra = (karana_name == 'Vishti')

    # ── 5. Vara (Weekday) ───────────────────────────────────────────────────
    # We find local time offset first
    tz_offset, tz_name = get_timezone_offset_and_name(lat, lon, date_str, time_str)
    
    # Calculate sunrise for the given day to determine the astrological weekday
    local_dt = datetime.strptime(f"{date_str} {time_str}", "%Y-%m-%d %H:%M")
    local_midnight = datetime(local_dt.year, local_dt.month, local_dt.day, 0, 0, 0)
    utc_midnight = local_midnight - tz_offset
    jd_utc_midnight = swe.julday(utc_midnight.year, utc_midnight.month, utc_midnight.day, 
                                 utc_midnight.hour + utc_midnight.minute/60.0)
    
    flg = getattr(swe, 'FLG_SWIEPH', 2)
    geopos = [lon, lat, 0.0]
    
    # Sunrise & Sunset
    _, res_rise = swe.rise_trans(jd_utc_midnight, swe.SUN, swe.CALC_RISE, geopos, 1013.25, 15.0, flg)
    _, res_set = swe.rise_trans(jd_utc_midnight, swe.SUN, swe.CALC_SET, geopos, 1013.25, 15.0, flg)
    
    sunrise_dt = jd_to_datetime(res_rise[0], tz_offset)
    sunset_dt = jd_to_datetime(res_set[0], tz_offset)
    
    # Weekday index (0 = Sunday, 1 = Monday, ..., 6 = Saturday)
    # Note: Sunday in python datetime weekday() is 6, Monday is 0. We map it so Sunday=0, Monday=1, ..., Saturday=6
    weekday_standard = (local_dt.weekday() + 1) % 7
    
    # Astrological day starts at Sunrise
    # If the current time is before Sunrise, the astrological day is the previous day
    local_localized_dt = local_dt.replace(tzinfo=timezone(tz_offset))
    is_before_sunrise = local_localized_dt < sunrise_dt
    
    astro_weekday_idx = weekday_standard
    if is_before_sunrise:
        astro_weekday_idx = (weekday_standard - 1) % 7
        
    astro_vara = VARA_NAMES[astro_weekday_idx]
    calendar_vara = VARA_NAMES[weekday_standard]

    # ── Moonrise & Moonset ──────────────────────────────────────────────────
    # Note: Sometimes moonrise or moonset doesn't occur on a specific day (returns -2)
    try:
        ret_mr, res_mr = swe.rise_trans(jd_utc_midnight, swe.MOON, swe.CALC_RISE, geopos, 1013.25, 15.0, flg)
        moonrise_dt = jd_to_datetime(res_mr[0], tz_offset) if ret_mr == 0 else None
    except Exception:
        moonrise_dt = None
        
    try:
        ret_ms, res_ms = swe.rise_trans(jd_utc_midnight, swe.MOON, swe.CALC_SET, geopos, 1013.25, 15.0, flg)
        moonset_dt = jd_to_datetime(res_ms[0], tz_offset) if ret_ms == 0 else None
    except Exception:
        moonset_dt = None

    # ── Sun Rashi and Moon Rashi ────────────────────────────────────────────
    sun_rashi_idx = int(sun_lon / 30)
    moon_rashi_idx = int(moon_lon / 30)
    
    sun_rashi = RASHIS[sun_rashi_idx]
    moon_rashi = RASHIS[moon_rashi_idx]
    
    # ── 6. Hindu Calendar Year (Samvat) and Month (Masa) ────────────────────
    # Solar Month approximation based on Sun's Rashi (Mesha = Chaitra, etc.)
    hindu_masa = HINDU_MASA_NAMES[sun_rashi_idx]
    
    # Vikram / Saka Samvat
    # In Vedic calendar, the new year starts at Chaitra Shukla Pratipada (generally mid-March to April)
    # If Sun is in Pisces (Meen) or Aquarius (Kumbh) etc. before Mesha Sankranti, it's the old year
    if local_dt.month < 3 or (local_dt.month == 3 and sun_rashi_idx == 11):
        vikram_samvat = local_dt.year + 56
        saka_samvat = local_dt.year - 79
    else:
        vikram_samvat = local_dt.year + 57
        saka_samvat = local_dt.year - 78

    # ── 7. Auspicious and Inauspicious Times ────────────────────────────────
    day_length = sunset_dt - sunrise_dt
    part_length = day_length / 8.0
    
    # Rahu, Yamaganda, Gulika depend on the calendar weekday (standard weekday)
    # Rahu Kaal parts (1-indexed): Sunday=8, Monday=2, Tuesday=7, Wednesday=5, Thursday=6, Friday=4, Saturday=3
    rahu_parts = {0: 8, 1: 2, 2: 7, 3: 5, 4: 6, 5: 4, 6: 3}
    rahu_part = rahu_parts[weekday_standard]
    rahu_start = sunrise_dt + (rahu_part - 1) * part_length
    rahu_end = sunrise_dt + rahu_part * part_length
    
    # Yamaganda parts: Sunday=5, Monday=4, Tuesday=3, Wednesday=2, Thursday=1, Friday=8, Saturday=7
    yamaganda_parts = {0: 5, 1: 4, 2: 3, 3: 2, 4: 1, 5: 8, 6: 7}
    yamaganda_part = yamaganda_parts[weekday_standard]
    yamaganda_start = sunrise_dt + (yamaganda_part - 1) * part_length
    yamaganda_end = sunrise_dt + yamaganda_part * part_length
    
    # Gulika parts: Sunday=7, Monday=6, Tuesday=5, Wednesday=4, Thursday=3, Friday=2, Saturday=1
    gulika_parts = {0: 7, 1: 6, 2: 5, 3: 4, 4: 3, 5: 2, 6: 1}
    gulika_part = gulika_parts[weekday_standard]
    gulika_start = sunrise_dt + (gulika_part - 1) * part_length
    gulika_end = sunrise_dt + gulika_part * part_length

    # Abhijit Muhurta: 8th Muhurta of the day (1/15th of daytime)
    midday = sunrise_dt + day_length / 2.0
    muhurta_duration = day_length / 15.0
    abhijit_start = midday - (muhurta_duration / 2.0)
    abhijit_end = midday + (muhurta_duration / 2.0)
    
    # Dur Muhurtam timings
    # Sunday: 14th Muhurta
    # Monday: 9th & 12th
    # Tuesday: 2nd & 12th
    # Wednesday: 7th
    # Thursday: 6th & 13th
    # Friday: 4th & 9th
    # Saturday: 1st
    dur_muhurtam_list = []
    dur_muhurta_map = {
        0: [14],
        1: [9, 12],
        2: [2, 12],
        3: [7],
        4: [6, 13],
        5: [4, 9],
        6: [1]
    }
    for m_idx in dur_muhurta_map.get(weekday_standard, []):
        d_start = sunrise_dt + (m_idx - 1) * muhurta_duration
        d_end = sunrise_dt + m_idx * muhurta_duration
        dur_muhurtam_list.append({
            'name': f'Dur Muhurtam (Muhurta {m_idx})',
            'start': d_start.strftime('%I:%M %p'),
            'end': d_end.strftime('%I:%M %p')
        })

    # ── 8. Choghadiya (Day and Night) ───────────────────────────────────────
    # Day Choghadiya (Sunrise to Sunset)
    day_choghadiyas = []
    day_chog_names = DAY_CHOGHADIYA_ORDER[weekday_standard]
    day_part_len = day_length / 8.0
    for idx, name in enumerate(day_chog_names):
        c_start = sunrise_dt + idx * day_part_len
        c_end = sunrise_dt + (idx + 1) * day_part_len
        prop = CHOGHADIYA_PROPERTIES[name]
        day_choghadiyas.append({
            'period': idx + 1,
            'name': name,
            'translation': prop['translation'],
            'type': prop['type'],
            'color': prop['color'],
            'start': c_start.strftime('%I:%M %p'),
            'end': c_end.strftime('%I:%M %p')
        })
        
    # Night Choghadiya (Sunset to Sunrise of the next day)
    # Find next day sunrise
    next_day_utc_midnight = utc_midnight + timedelta(days=1)
    jd_next_utc_midnight = swe.julday(next_day_utc_midnight.year, next_day_utc_midnight.month, next_day_utc_midnight.day, 
                                      next_day_utc_midnight.hour + next_day_utc_midnight.minute/60.0)
    _, res_next_rise = swe.rise_trans(jd_next_utc_midnight, swe.SUN, swe.CALC_RISE, geopos, 1013.25, 15.0, flg)
    next_sunrise_dt = jd_to_datetime(res_next_rise[0], tz_offset)
    
    night_length = next_sunrise_dt - sunset_dt
    night_part_len = night_length / 8.0
    night_choghadiyas = []
    night_chog_names = NIGHT_CHOGHADIYA_ORDER[weekday_standard]
    for idx, name in enumerate(night_chog_names):
        c_start = sunset_dt + idx * night_part_len
        c_end = sunset_dt + (idx + 1) * night_part_len
        prop = CHOGHADIYA_PROPERTIES[name]
        night_choghadiyas.append({
            'period': idx + 1,
            'name': name,
            'translation': prop['translation'],
            'type': prop['type'],
            'color': prop['color'],
            'start': c_start.strftime('%I:%M %p'),
            'end': c_end.strftime('%I:%M %p')
        })

    # Ayanamsha degree
    ayan_deg = swe.get_ayanamsa_ut(jd)
    ayan_str = f"{int(ayan_deg)}° {int((ayan_deg - int(ayan_deg)) * 60)}' {round(((ayan_deg - int(ayan_deg)) * 60 - int((ayan_deg - int(ayan_deg)) * 60)) * 60, 2)}\""

    # Ritu (Season) calculation (based on Sun's degree / date)
    # Vasanta (Spring): Mar 20 to May 20, Grishma (Summer): May 20 to Jul 20, Varsha (Monsoon): Jul 20 to Sep 20
    # Sharad (Autumn): Sep 20 to Nov 20, Hemanta (Pre-winter): Nov 20 to Jan 20, Shishir (Winter): Jan 20 to Mar 20
    day_of_year = local_dt.timetuple().tm_yday
    if 79 <= day_of_year < 140:
        ritu = "Vasanta (Spring)"
    elif 140 <= day_of_year < 201:
        ritu = "Grishma (Summer)"
    elif 201 <= day_of_year < 263:
        ritu = "Varsha (Monsoon)"
    elif 263 <= day_of_year < 324:
        ritu = "Sharad (Autumn)"
    elif 324 <= day_of_year < 20:
        ritu = "Hemanta (Late Autumn)"
    else:
        ritu = "Shishir (Winter)"

    return {
        'date': date_str,
        'time': time_str,
        'lat': lat,
        'lon': lon,
        'timezone': tz_name,
        'tithi': {
            'index': tithi_index,
            'name': tithi_name,
            'paksha': paksha,
            'percent_elapsed': round(tithi_percent * 100, 2)
        },
        'nakshatra': {
            'index': nak_index + 1,
            'name': nak_name,
            'lord': nak_lord,
            'pada': nak_pada,
            'percent_elapsed': round(nak_percent * 100, 2)
        },
        'yoga': {
            'index': yoga_index + 1,
            'name': yoga_name,
            'percent_elapsed': round(yoga_percent * 100, 2)
        },
        'karana': {
            'index': karana_index,
            'name': karana_name,
            'is_bhadra': is_bhadra
        },
        'vara': {
            'astrological': astro_vara,
            'calendar': calendar_vara,
            'is_before_sunrise': is_before_sunrise
        },
        'astrological_details': {
            'sun_rashi': sun_rashi,
            'moon_rashi': moon_rashi,
            'ritu': ritu,
            'ayanamsha': ayan_str
        },
        'sun_moon_timings': {
            'sunrise': sunrise_dt.strftime('%I:%M %p'),
            'sunset': sunset_dt.strftime('%I:%M %p'),
            'moonrise': moonrise_dt.strftime('%I:%M %p') if moonrise_dt else 'No Rise',
            'moonset': moonset_dt.strftime('%I:%M %p') if moonset_dt else 'No Set'
        },
        'samvat': {
            'vikram': vikram_samvat,
            'saka': saka_samvat,
            'masa': hindu_masa
        },
        'auspicious_timings': {
            'abhijit': {
                'start': abhijit_start.strftime('%I:%M %p'),
                'end': abhijit_end.strftime('%I:%M %p')
            }
        },
        'inauspicious_timings': {
            'rahu_kaal': {
                'start': rahu_start.strftime('%I:%M %p'),
                'end': rahu_end.strftime('%I:%M %p')
            },
            'yamaganda': {
                'start': yamaganda_start.strftime('%I:%M %p'),
                'end': yamaganda_end.strftime('%I:%M %p')
            },
            'gulika': {
                'start': gulika_start.strftime('%I:%M %p'),
                'end': gulika_end.strftime('%I:%M %p')
            },
            'dur_muhurtam': dur_muhurtam_list
        },
        'choghadiya': {
            'day': day_choghadiyas,
            'night': night_choghadiyas
        }
    }
