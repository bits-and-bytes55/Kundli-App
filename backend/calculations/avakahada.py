"""
Avakahada Chakra Calculations
Standard Jyotish formulas for Paya, Varna, Yoni, Gana, Vashya, Nadi, etc.
"""

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

# ── Paya (based on Nakshatra of Moon) ──────────────────────────────────────
# Swarna=Gold, Rajat=Silver, Tamba=Copper, Loha=Iron
PAYA_MAP = {
    'Ashwini': 'Swarna (Gold)', 'Bharani': 'Rajat (Silver)', 'Krittika': 'Tamba (Copper)',
    'Rohini': 'Swarna (Gold)', 'Mrigashira': 'Rajat (Silver)', 'Ardra': 'Tamba (Copper)',
    'Punarvasu': 'Swarna (Gold)', 'Pushya': 'Rajat (Silver)', 'Ashlesha': 'Tamba (Copper)',
    'Magha': 'Loha (Iron)', 'P.Phalguni': 'Swarna (Gold)', 'U.Phalguni': 'Rajat (Silver)',
    'Hasta': 'Tamba (Copper)', 'Chitra': 'Loha (Iron)', 'Swati': 'Swarna (Gold)',
    'Vishakha': 'Rajat (Silver)', 'Anuradha': 'Tamba (Copper)', 'Jyeshtha': 'Loha (Iron)',
    'Moola': 'Swarna (Gold)', 'P.Ashadha': 'Rajat (Silver)', 'U.Ashadha': 'Tamba (Copper)',
    'Shravana': 'Loha (Iron)', 'Dhanishtha': 'Swarna (Gold)', 'Shatabhisha': 'Rajat (Silver)',
    'P.Bhadra': 'Tamba (Copper)', 'U.Bhadra': 'Loha (Iron)', 'Revati': 'Swarna (Gold)'
}

# ── Varna (Caste) based on Moon Nakshatra ──────────────────────────────────
VARNA_MAP = {
    'Ashwini': 'Vaishya', 'Bharani': 'Mleccha', 'Krittika': 'Brahman',
    'Rohini': 'Shudra', 'Mrigashira': 'Vaishya', 'Ardra': 'Mleccha',
    'Punarvasu': 'Brahman', 'Pushya': 'Kshatriya', 'Ashlesha': 'Mleccha',
    'Magha': 'Brahman', 'P.Phalguni': 'Brahman', 'U.Phalguni': 'Kshatriya',
    'Hasta': 'Vaishya', 'Chitra': 'Mleccha', 'Swati': 'Mleccha',
    'Vishakha': 'Mleccha', 'Anuradha': 'Shudra', 'Jyeshtha': 'Mleccha',
    'Moola': 'Mleccha', 'P.Ashadha': 'Brahman', 'U.Ashadha': 'Kshatriya',
    'Shravana': 'Mleccha', 'Dhanishtha': 'Mleccha', 'Shatabhisha': 'Mleccha',
    'P.Bhadra': 'Brahman', 'U.Bhadra': 'Brahman', 'Revati': 'Brahman'
}

# ── Yoni (Animal) based on Moon Nakshatra ─────────────────────────────────
YONI_MAP = {
    'Ashwini': 'Ashwa (Horse)', 'Bharani': 'Gaj (Elephant)', 'Krittika': 'Mesh (Ram)',
    'Rohini': 'Sarpa (Snake)', 'Mrigashira': 'Sarpa (Snake)', 'Ardra': 'Shwan (Dog)',
    'Punarvasu': 'Marjar (Cat)', 'Pushya': 'Mesh (Ram)', 'Ashlesha': 'Marjar (Cat)',
    'Magha': 'Mushak (Rat)', 'P.Phalguni': 'Mushak (Rat)', 'U.Phalguni': 'Gau (Cow)',
    'Hasta': 'Mahish (Buffalo)', 'Chitra': 'Vyaghra (Tiger)', 'Swati': 'Mahish (Buffalo)',
    'Vishakha': 'Vyaghra (Tiger)', 'Anuradha': 'Mrig (Deer)', 'Jyeshtha': 'Mrig (Deer)',
    'Moola': 'Shwan (Dog)', 'P.Ashadha': 'Vanar (Monkey)', 'U.Ashadha': 'Nakul (Mongoose)',
    'Shravana': 'Vanar (Monkey)', 'Dhanishtha': 'Simha (Lion)', 'Shatabhisha': 'Ashwa (Horse)',
    'P.Bhadra': 'Simha (Lion)', 'U.Bhadra': 'Gau (Cow)', 'Revati': 'Gaj (Elephant)'
}

# ── Gana (Nature) based on Moon Nakshatra ────────────────────────────────
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

# ── Vashya (Control) based on Moon Rashi ─────────────────────────────────
VASHYA_MAP = {
    'Mesh': 'Chatushpad (Quadruped)', 'Vrishabh': 'Chatushpad (Quadruped)',
    'Mithun': 'Dwi-pad (Biped)', 'Kark': 'Jalchar (Aquatic)',
    'Singh': 'Chatushpad (Quadruped)', 'Kanya': 'Dwi-pad (Biped)',
    'Tula': 'Dwi-pad (Biped)', 'Vrischik': 'Keeta (Insect)',
    'Dhanu': 'Chatushpad (Quadruped)', 'Makar': 'Jalchar (Aquatic)',
    'Kumbh': 'Jalchar (Aquatic)', 'Meen': 'Jalchar (Aquatic)'
}

# ── Nadi (Physical constitution) based on Moon Nakshatra ─────────────────
NADI_MAP = {
    'Ashwini': 'Vata (Aadi)', 'Bharani': 'Pitta (Madhya)', 'Krittika': 'Kapha (Antya)',
    'Rohini': 'Kapha (Antya)', 'Mrigashira': 'Pitta (Madhya)', 'Ardra': 'Vata (Aadi)',
    'Punarvasu': 'Vata (Aadi)', 'Pushya': 'Pitta (Madhya)', 'Ashlesha': 'Kapha (Antya)',
    'Magha': 'Kapha (Antya)', 'P.Phalguni': 'Pitta (Madhya)', 'U.Phalguni': 'Vata (Aadi)',
    'Hasta': 'Vata (Aadi)', 'Chitra': 'Pitta (Madhya)', 'Swati': 'Kapha (Antya)',
    'Vishakha': 'Kapha (Antya)', 'Anuradha': 'Pitta (Madhya)', 'Jyeshtha': 'Vata (Aadi)',
    'Moola': 'Vata (Aadi)', 'P.Ashadha': 'Pitta (Madhya)', 'U.Ashadha': 'Kapha (Antya)',
    'Shravana': 'Kapha (Antya)', 'Dhanishtha': 'Pitta (Madhya)', 'Shatabhisha': 'Vata (Aadi)',
    'P.Bhadra': 'Vata (Aadi)', 'U.Bhadra': 'Pitta (Madhya)', 'Revati': 'Kapha (Antya)'
}


def get_avakahada_chakra(planets, ascendant, jd):
    """
    Returns Avakahada Chakra details based on Moon Nakshatra/Rashi + Ascendant.
    """
    moon = planets['Moon']
    moon_nak = moon['nakshatra']
    moon_rashi = moon['rashi']
    moon_lon = moon['longitude']
    moon_nak_idx = int(moon_lon / (360 / 27))
    moon_pada = moon['pada']

    # Dasha Bhogya (balance of current dasha at birth)
    nak_lord = NAKSHATRA_LORDS[moon_nak_idx]
    nak_start_lon = moon_nak_idx * (360 / 27)
    nak_elapsed = (moon_lon - nak_start_lon) / (360 / 27)
    dasha_total = DASHA_YEARS[nak_lord]
    dasha_remaining_years = dasha_total * (1 - nak_elapsed)
    dasha_rem_y = int(dasha_remaining_years)
    dasha_rem_m = int((dasha_remaining_years - dasha_rem_y) * 12)
    dasha_rem_d = int(((dasha_remaining_years - dasha_rem_y) * 12 - dasha_rem_m) * 30)

    # Lagna details from ascendant
    lagna_rashi = ascendant['rashi']
    lagna_rashi_idx = RASHIS.index(lagna_rashi)
    lagna_swami = RASHI_LORDS[lagna_rashi_idx]

    # Julian Day Number (rounded)
    julian_day = round(jd)

    return {
        'paya': PAYA_MAP.get(moon_nak, '-'),
        'varna': VARNA_MAP.get(moon_nak, '-'),
        'yoni': YONI_MAP.get(moon_nak, '-'),
        'gana': GANA_MAP.get(moon_nak, '-'),
        'vashya': VASHYA_MAP.get(moon_rashi, '-'),
        'nadi': NADI_MAP.get(moon_nak, '-'),
        'dasha_bhogya': f'{nak_lord} {dasha_rem_y} व {dasha_rem_m} मा {dasha_rem_d} दि',
        'lagna': lagna_rashi,
        'lagna_swami': lagna_swami,
        'rashi': moon_rashi,
        'rashi_swami': RASHI_LORDS[RASHIS.index(moon_rashi)],
        'nakshatra_pad': f'{moon_nak}-{moon_pada}',
        'nakshatra_swami': nak_lord,
        'julian_day': julian_day,
        'moon_nakshatra': moon_nak,
        'moon_pada': moon_pada,
    }
