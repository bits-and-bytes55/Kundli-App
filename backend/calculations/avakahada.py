"""
Avakahada Chakra Calculations
Standard Jyotish formulas for Paya, Varna, Yoni, Gana, Vashya, Nadi, etc.
"""

from datetime import datetime

NAKSHATRAS = [
    'Ashwini','Bharani','Krittika','Rohini','Mrigashira','Ardra','Punarvasu','Pushya','Ashlesha',
    'Magha','P.Phalguni','U.Phalguni','Hasta','Chitra','Swati','Vishakha','Anuradha','Jyeshtha',
    'Moola','P.Ashadha','U.Ashadha','Shravana','Dhanishtha','Shatabhisha','P.Bhadra','U.Bhadra','Revati'
]
NAKSHATRA_LORDS = ['Ketu','Shukra','Surya','Chandra','Mangal','Rahu','Guru','Shani','Budha'] * 3
DASHA_YEARS = {'Ketu':7,'Shukra':20,'Surya':6,'Chandra':10,'Mangal':7,'Rahu':18,'Guru':16,'Shani':19,'Budha':17}
TOTAL_DASHA_YEARS = 120
RASHIS = ['Mesh','Vrishabh','Mithun','Kark','Singh','Kanya','Tula','Vrischik','Dhanu','Makar','Kumbh','Meen']
RASHI_LORDS = ['Mangal','Shukra','Budha','Chandra','Surya','Budha','Shukra','Mangal','Guru','Shani','Shani','Guru']

SWAMI_ABBREV = {
    'Sun': 'SUN', 'Chandra': 'MON', 'Moon': 'MON', 'Surya': 'SUN',
    'Mangal': 'MAR', 'Mars': 'MAR', 'Budha': 'MER', 'Mercury': 'MER',
    'Guru': 'JUP', 'Jupiter': 'JUP', 'Shukra': 'VEN', 'Venus': 'VEN',
    'Shani': 'SAT', 'Saturn': 'SAT', 'Rahu': 'RAH', 'Ketu': 'KET'
}

RASHIS_ENG = {
    'Mesh': 'Aries', 'Vrishabh': 'Taurus', 'Mithun': 'Gemini', 'Kark': 'Cancer',
    'Singh': 'Leo', 'Kanya': 'Virgo', 'Tula': 'Libra', 'Vrischik': 'Scorpio',
    'Dhanu': 'Sagittarius', 'Makar': 'Capricorn', 'Kumbh': 'Aquarius', 'Meen': 'Pisces'
}

RASHI_VARNA = {
    'Mesh': 'KSHATRIYA', 'Singh': 'KSHATRIYA', 'Dhanu': 'KSHATRIYA',
    'Vrishabh': 'VAISHYA', 'Kanya': 'VAISHYA', 'Makar': 'VAISHYA',
    'Mithun': 'SHUDRA', 'Tula': 'SHUDRA', 'Kumbh': 'SHUDRA',
    'Kark': 'BRAHMAN', 'Vrischik': 'BRAHMAN', 'Meen': 'BRAHMAN'
}

RASHI_VASYA = {
    'Mesh': 'Chatushpad', 'Vrishabh': 'Chatushpad',
    'Mithun': 'Dwipada', 'Kark': 'Jalchar',
    'Singh': 'Vanch', 'Kanya': 'Dwipada',
    'Tula': 'Dwipada', 'Vrischik': 'Keeta',
    'Dhanu': 'Chatushpad', 'Makar': 'Jalchar',
    'Kumbh': 'Dwipada', 'Meen': 'Jalchar'
}

YONI_MAP = {
    'Ashwini': 'Ashwa', 'Bharani': 'Gaj', 'Krittika': 'Mesh',
    'Rohini': 'Sarpa', 'Mrigashira': 'Sarpa', 'Ardra': 'Shwan',
    'Punarvasu': 'Marjar', 'Pushya': 'Mesh', 'Ashlesha': 'Marjar',
    'Magha': 'Mushak', 'P.Phalguni': 'Mushak', 'U.Phalguni': 'Gau',
    'Hasta': 'Mahish', 'Chitra': 'Vyaghra', 'Swati': 'Mahish',
    'Vishakha': 'Vyaghra', 'Anuradha': 'Mrig', 'Jyeshtha': 'Mrig',
    'Moola': 'Shwan', 'P.Ashadha': 'Vanar', 'U.Ashadha': 'Nakul',
    'Shravana': 'Vanar', 'Dhanishtha': 'Simha', 'Shatabhisha': 'Ashwa',
    'P.Bhadra': 'Simha', 'U.Bhadra': 'Gau', 'Revati': 'Gaj'
}

GANA_MAP = {
    'Ashwini': 'Dev', 'Bharani': 'Manushya', 'Krittika': 'Rakshasa',
    'Rohini': 'Manushya', 'Mrigashira': 'Dev', 'Ardra': 'Manushya',
    'Punarvasu': 'Dev', 'Pushya': 'Dev', 'Ashlesha': 'Rakshasa',
    'Magha': 'Rakshasa', 'P.Phalguni': 'Manushya', 'U.Phalguni': 'Manushya',
    'Hasta': 'Dev', 'Chitra': 'Rakshasa', 'Swati': 'Dev',
    'Vishakha': 'Rakshasa', 'Anuradha': 'Dev', 'Jyeshtha': 'Rakshasa',
    'Moola': 'Rakshasa', 'P.Ashadha': 'Manushya', 'U.Ashadha': 'Manushya',
    'Shravana': 'Dev', 'Dhanishtha': 'Rakshasa', 'Shatabhisha': 'Rakshasa',
    'P.Bhadra': 'Manushya', 'U.Bhadra': 'Manushya', 'Revati': 'Dev'
}

NADI_MAP = {
    'Ashwini': 'Aadi', 'Bharani': 'Madhya', 'Krittika': 'Antya',
    'Rohini': 'Antya', 'Mrigashira': 'Madhya', 'Ardra': 'Aadi',
    'Punarvasu': 'Aadi', 'Pushya': 'Madhya', 'Ashlesha': 'Antya',
    'Magha': 'Antya', 'P.Phalguni': 'Madhya', 'U.Phalguni': 'Aadi',
    'Hasta': 'Aadi', 'Chitra': 'Madhya', 'Swati': 'Antya',
    'Vishakha': 'Antya', 'Anuradha': 'Madhya', 'Jyeshtha': 'Aadi',
    'Moola': 'Aadi', 'P.Ashadha': 'Madhya', 'U.Ashadha': 'Antya',
    'Shravana': 'Antya', 'Dhanishtha': 'Madhya', 'Shatabhisha': 'Aadi',
    'P.Bhadra': 'Aadi', 'U.Bhadra': 'Madhya', 'Revati': 'Antya'
}

def get_western_sun_sign(dt):
    m = dt.month
    d = dt.day
    if m == 3: return "Aries" if d >= 21 else "Pisces"
    elif m == 4: return "Taurus" if d >= 20 else "Aries"
    elif m == 5: return "Gemini" if d >= 21 else "Taurus"
    elif m == 6: return "Cancer" if d >= 21 else "Gemini"
    elif m == 7: return "Leo" if d >= 23 else "Cancer"
    elif m == 8: return "Virgo" if d >= 23 else "Leo"
    elif m == 9: return "Libra" if d >= 23 else "Virgo"
    elif m == 10: return "Scorpio" if d >= 23 else "Libra"
    elif m == 11: return "Sagittarius" if d >= 22 else "Scorpio"
    elif m == 12: return "Capricorn" if d >= 22 else "Sagittarius"
    elif m == 1: return "Aquarius" if d >= 20 else "Capricorn"
    elif m == 2: return "Pisces" if d >= 19 else "Aquarius"
    return "Aries"

def get_paya(moon_house):
    if moon_house in [1, 6, 11]:
        return "Gold"
    elif moon_house in [2, 5, 9]:
        return "Silver"
    elif moon_house in [3, 7, 10]:
        return "Copper"
    else:
        return "Iron"

def get_avakahada_chakra(planets, ascendant, jd):
    """
    Returns Avakahada Chakra details based on Moon Nakshatra/Rashi + Ascendant.
    """
    moon = planets['Moon']
    moon_nak = moon['nakshatra']
    moon_rashi = moon['rashi']
    moon_lon = moon['longitude']
    moon_nak_idx = NAKSHATRAS.index(moon_nak)
    moon_pada = moon['pada']

    # Dasha Bhogya
    nak_lord = NAKSHATRA_LORDS[moon_nak_idx]
    nak_start_lon = moon_nak_idx * (360 / 27)
    nak_elapsed = (moon_lon - nak_start_lon) / (360 / 27)
    dasha_total = DASHA_YEARS[nak_lord]
    dasha_remaining_years = dasha_total * (1 - nak_elapsed)
    dasha_rem_y = int(dasha_remaining_years)
    dasha_rem_m = int((dasha_remaining_years - dasha_rem_y) * 12)
    dasha_rem_d = int(((dasha_remaining_years - dasha_rem_y) * 12 - dasha_rem_m) * 30)

    # Lagna details
    lagna_rashi = ascendant['rashi']
    lagna_swami = ascendant['rashi_lord']

    # Paya based on Moon house from Lagna
    lagna_rashi_idx = RASHIS.index(lagna_rashi)
    moon_rashi_idx = RASHIS.index(moon_rashi)
    moon_house = (moon_rashi_idx - lagna_rashi_idx) % 12 + 1
    paya_val = get_paya(moon_house)

    # Western Sun Sign
    # Convert Julian Day to a date estimation for western sun sign
    import swisseph as swe
    y, m, d, _ = swe.revjul(jd, swe.GREG_CAL)
    dt_approx = datetime(y, m, d)
    western_sign = get_western_sun_sign(dt_approx)

    sun_rashi = planets['Sun']['rashi']

    # Format the names/values
    dasha_lord_abbrev = SWAMI_ABBREV.get(nak_lord, nak_lord[:3].upper())
    balance_of_dasha = f"{dasha_lord_abbrev} {dasha_rem_y} Y {dasha_rem_m} M {dasha_rem_d} D"

    # Abbreviated lords
    lagna_lord_abbrev = SWAMI_ABBREV.get(lagna_swami, lagna_swami[:3].upper())
    rasi_lord_abbrev = SWAMI_ABBREV.get(moon['rashi_lord'], moon['rashi_lord'][:3].upper())
    nak_lord_abbrev = SWAMI_ABBREV.get(nak_lord, nak_lord[:3].upper())

    # Nakshatra name in all caps (e.g. PURVAPHALGUNI)
    nak_pada_str = f"{moon_nak.replace('.', '').replace(' ', '').upper()}-{moon_pada}"

    return {
        'paya': paya_val,
        'varna': RASHI_VARNA.get(moon_rashi, '-'),
        'yoni': YONI_MAP.get(moon_nak, '-'),
        'gana': GANA_MAP.get(moon_nak, '-'),
        'vashya': RASHI_VASYA.get(moon_rashi, '-'),
        'nadi': NADI_MAP.get(moon_nak, '-').upper(),
        'dasha_bhogya': balance_of_dasha,
        'lagna': RASHIS_ENG.get(lagna_rashi, lagna_rashi),
        'lagna_swami': lagna_lord_abbrev,
        'rashi': RASHIS_ENG.get(moon_rashi, moon_rashi),
        'rashi_swami': rasi_lord_abbrev,
        'nakshatra_pad': nak_pada_str,
        'nakshatra_swami': nak_lord_abbrev,
        'julian_day': int(jd),
        'sun_sign_indian': RASHIS_ENG.get(sun_rashi, sun_rashi),
        'sun_sign_western': western_sign
    }
