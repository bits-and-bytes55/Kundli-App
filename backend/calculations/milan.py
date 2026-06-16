"""
Kundli Milan - Ashtakoot 36 Gun matching
"""
import swisseph as swe
from timezonefinder import TimezoneFinder
import pytz
from datetime import datetime

RASHIS = ['Mesh','Vrishabh','Mithun','Kark','Singh','Kanya','Tula','Vrischik','Dhanu','Makar','Kumbh','Meen']
NAKSHATRAS = ['Ashwini','Bharani','Krittika','Rohini','Mrigashira','Ardra','Punarvasu','Pushya','Ashlesha',
  'Magha','P.Phalguni','U.Phalguni','Hasta','Chitra','Swati','Vishakha','Anuradha','Jyeshtha',
  'Moola','P.Ashadha','U.Ashadha','Shravana','Dhanishtha','Shatabhisha','P.Bhadra','U.Bhadra','Revati']
NAKSHATRA_LORDS = ['Ketu','Shukra','Surya','Chandra','Mangal','Rahu','Guru','Shani','Budha'] * 3

# Varna: Brahmin=4, Kshatriya=3, Vaishya=2, Shudra=1
VARNA = {
    'Mesh': 3, 'Singh': 3, 'Dhanu': 3,      # Kshatriya (Fire)
    'Vrishabh': 2, 'Kanya': 2, 'Makar': 2,  # Vaishya (Earth)
    'Mithun': 1, 'Tula': 1, 'Kumbh': 1,      # Shudra (Air)
    'Kark': 4, 'Vrischik': 4, 'Meen': 4       # Brahmin (Water)
}
VARNA_NAMES = {4: 'Brahmin', 3: 'Kshatriya', 2: 'Vaishya', 1: 'Shudra'}

# Vasya: Chatushpad, Manav, Jalachara, Vanachara, Keeta
VASYA = {
    'Mesh': 'Chatushpad', 'Vrishabh': 'Chatushpad', 'Mithun': 'Manav', 'Kark': 'Jalachara',
    'Singh': 'Vanachara', 'Kanya': 'Manav', 'Tula': 'Manav', 'Vrischik': 'Keeta',
    'Dhanu': 'Manav', # First half is Manav, but since Moola is in first half we use Manav as default
    'Makar': 'Jalachara', 'Kumbh': 'Manav', 'Meen': 'Jalachara'
}

# Vashya points matrix
VASYA_MATRIX = {
    'Chatushpad': {'Chatushpad': 2.0, 'Manav': 1.0, 'Jalachara': 1.0, 'Vanachara': 0.5, 'Keeta': 1.0},
    'Manav':      {'Chatushpad': 1.0, 'Manav': 2.0, 'Jalachara': 1.5, 'Vanachara': 0.0, 'Keeta': 1.0},
    'Jalachara':  {'Chatushpad': 1.0, 'Manav': 1.5, 'Jalachara': 2.0, 'Vanachara': 1.0, 'Keeta': 1.0},
    'Vanachara':  {'Chatushpad': 0.5, 'Manav': 0.0, 'Jalachara': 1.0, 'Vanachara': 2.0, 'Keeta': 0.0},
    'Keeta':      {'Chatushpad': 1.0, 'Manav': 1.0, 'Jalachara': 1.0, 'Vanachara': 0.0, 'Keeta': 2.0}
}

# Tara groups
TARA_GROUPS = ['Janma', 'Sampat', 'Vipat', 'Kshema', 'Pratyak', 'Sadhana', 'Vadha', 'Mitra', 'Parama Mitra']

# Yoni: 14 categories mapped to 27 Nakshatras
YONI = {
    'Ashwini': 'Ashwa', 'Shatabhisha': 'Ashwa',
    'Bharani': 'Gaja', 'Revati': 'Gaja',
    'Krittika': 'Mesha', 'Pushya': 'Mesha',
    'Rohini': 'Sarpa', 'Mrigashira': 'Sarpa',
    'Ardra': 'Shwana', 'Moola': 'Shwana',
    'Punarvasu': 'Marjara', 'Ashlesha': 'Marjara',
    'Magha': 'Mushaka', 'P.Phalguni': 'Mushaka',
    'U.Phalguni': 'Gau', 'U.Bhadra': 'Gau',
    'Hasta': 'Mahisha', 'Swati': 'Mahisha',
    'Chitra': 'Vyaghra', 'Vishakha': 'Vyaghra',
    'Anuradha': 'Mriga', 'Jyeshtha': 'Mriga',
    'P.Ashadha': 'Vanara', 'Shravana': 'Vanara',
    'Dhanishtha': 'Simha', 'P.Bhadra': 'Simha',
    'U.Ashadha': 'Nakula'
}

YONI_MATRIX = {
    'Ashwa':   {'Ashwa':4, 'Gaja':2, 'Mesha':2, 'Sarpa':3, 'Shwana':2, 'Marjara':2, 'Mushaka':2, 'Gau':1, 'Mahisha':0, 'Vyaghra':1, 'Mriga':3, 'Vanara':3, 'Simha':2, 'Nakula':2},
    'Gaja':    {'Ashwa':2, 'Gaja':4, 'Mesha':3, 'Sarpa':3, 'Shwana':2, 'Marjara':2, 'Mushaka':2, 'Gau':2, 'Mahisha':3, 'Vyaghra':1, 'Mriga':2, 'Vanara':3, 'Simha':0, 'Nakula':2},
    'Mesha':   {'Ashwa':2, 'Gaja':3, 'Mesha':4, 'Sarpa':2, 'Shwana':1, 'Marjara':2, 'Mushaka':1, 'Gau':3, 'Mahisha':0, 'Vyaghra':0, 'Mriga':3, 'Vanara':2, 'Simha':1, 'Nakula':2},
    'Sarpa':   {'Ashwa':3, 'Gaja':3, 'Mesha':2, 'Sarpa':4, 'Shwana':2, 'Marjara':1, 'Mushaka':1, 'Gau':1, 'Mahisha':1, 'Vyaghra':2, 'Mriga':2, 'Vanara':2, 'Simha':2, 'Nakula':0},
    'Shwana':  {'Ashwa':2, 'Gaja':2, 'Mesha':1, 'Sarpa':2, 'Shwana':4, 'Marjara':0, 'Mushaka':2, 'Gau':1, 'Mahisha':2, 'Vyaghra':1, 'Mriga':2, 'Vanara':2, 'Simha':2, 'Nakula':1},
    'Marjara': {'Ashwa':2, 'Gaja':2, 'Mesha':2, 'Sarpa':1, 'Shwana':0, 'Marjara':4, 'Mushaka':0, 'Gau':2, 'Mahisha':2, 'Vyaghra':1, 'Mriga':2, 'Vanara':2, 'Simha':1, 'Nakula':2},
    'Mushaka': {'Ashwa':2, 'Gaja':2, 'Mesha':1, 'Sarpa':1, 'Shwana':2, 'Marjara':0, 'Mushaka':4, 'Gau':2, 'Mahisha':2, 'Vyaghra':1, 'Mriga':1, 'Vanara':2, 'Simha':1, 'Nakula':2},
    'Gau':     {'Ashwa':1, 'Gaja':2, 'Mesha':3, 'Sarpa':1, 'Shwana':1, 'Marjara':2, 'Mushaka':2, 'Gau':4, 'Mahisha':3, 'Vyaghra':0, 'Mriga':4, 'Vanara':2, 'Simha':1, 'Nakula':2},
    'Mahisha': {'Ashwa':0, 'Gaja':3, 'Mesha':0, 'Sarpa':1, 'Shwana':2, 'Marjara':2, 'Mushaka':2, 'Gau':3, 'Mahisha':4, 'Vyaghra':1, 'Mriga':2, 'Vanara':2, 'Simha':1, 'Nakula':2},
    'Vyaghra': {'Ashwa':1, 'Gaja':1, 'Mesha':0, 'Sarpa':2, 'Shwana':1, 'Marjara':1, 'Mushaka':1, 'Gau':0, 'Mahisha':1, 'Vyaghra':4, 'Mriga':1, 'Vanara':1, 'Simha':2, 'Nakula':1},
    'Mriga':   {'Ashwa':3, 'Gaja':2, 'Mesha':3, 'Sarpa':2, 'Shwana':2, 'Marjara':2, 'Mushaka':1, 'Gau':4, 'Mahisha':2, 'Vyaghra':1, 'Mriga':4, 'Vanara':2, 'Simha':1, 'Nakula':2},
    'Vanara':  {'Ashwa':3, 'Gaja':3, 'Mesha':2, 'Sarpa':2, 'Shwana':2, 'Marjara':2, 'Mushaka':2, 'Gau':2, 'Mahisha':2, 'Vyaghra':1, 'Mriga':2, 'Vanara':4, 'Simha':2, 'Nakula':2},
    'Simha':   {'Ashwa':2, 'Gaja':0, 'Mesha':1, 'Sarpa':2, 'Shwana':2, 'Marjara':1, 'Mushaka':1, 'Gau':1, 'Mahisha':1, 'Vyaghra':2, 'Mriga':1, 'Vanara':2, 'Simha':4, 'Nakula':2},
    'Nakula':  {'Ashwa':2, 'Gaja':2, 'Mesha':2, 'Sarpa':0, 'Shwana':1, 'Marjara':2, 'Mushaka':2, 'Gau':2, 'Mahisha':2, 'Vyaghra':1, 'Mriga':2, 'Vanara':2, 'Simha':2, 'Nakula':4}
}

# Gana
GANA = {
    'Ashwini':'Deva','Mrigashira':'Deva','Punarvasu':'Deva','Pushya':'Deva',
    'Hasta':'Deva','Swati':'Deva','Anuradha':'Deva','Shravana':'Deva','Revati':'Deva',
    'Bharani':'Manushya','Rohini':'Manushya','Ardra':'Manushya','P.Phalguni':'Manushya',
    'U.Phalguni':'Manushya','P.Ashadha':'Manushya','U.Ashadha':'Manushya','P.Bhadra':'Manushya','U.Bhadra':'Manushya',
    'Krittika':'Rakshasa','Ashlesha':'Rakshasa','Magha':'Rakshasa','Chitra':'Rakshasa',
    'Vishakha':'Rakshasa','Jyeshtha':'Rakshasa','Moola':'Rakshasa','Dhanishtha':'Rakshasa','Shatabhisha':'Rakshasa'
}

GANA_MATRIX = {
    'Deva':     {'Deva': 6, 'Manushya': 6, 'Rakshasa': 1},
    'Manushya': {'Deva': 5, 'Manushya': 6, 'Rakshasa': 0},
    'Rakshasa': {'Deva': 0, 'Manushya': 0, 'Rakshasa': 6}
}

# Nadi: Serpentine assignment to 27 Nakshatras
NADI = {}
for name in ['Ashwini', 'Ardra', 'Punarvasu', 'U.Phalguni', 'Hasta', 'Jyeshtha', 'Moola', 'Shatabhisha', 'P.Bhadra']:
    NADI[name] = 'Aadi'
for name in ['Bharani', 'Mrigashira', 'Pushya', 'P.Phalguni', 'Chitra', 'Anuradha', 'P.Ashadha', 'Dhanishtha', 'U.Bhadra']:
    NADI[name] = 'Madhya'
for name in ['Krittika', 'Rohini', 'Ashlesha', 'Magha', 'Swati', 'Vishakha', 'U.Ashadha', 'Shravana', 'Revati']:
    NADI[name] = 'Antya'

# Rashi Maitri matrix (Graha Maitri)
GRAHA_MAITRI_MATRIX = {
    'Surya':   {'Surya':5.0, 'Chandra':5.0, 'Mangal':5.0, 'Budha':4.0, 'Guru':5.0, 'Shukra':0.0, 'Shani':0.0},
    'Chandra': {'Surya':5.0, 'Chandra':5.0, 'Mangal':4.0, 'Budha':5.0, 'Guru':4.0, 'Shukra':0.5, 'Shani':0.5},
    'Mangal':  {'Surya':5.0, 'Chandra':4.0, 'Mangal':5.0, 'Budha':0.5, 'Guru':5.0, 'Shukra':3.0, 'Shani':0.5},
    'Budha':   {'Surya':4.0, 'Chandra':0.5, 'Mangal':0.5, 'Budha':5.0, 'Guru':0.5, 'Shukra':5.0, 'Shani':4.0},
    'Guru':    {'Surya':5.0, 'Chandra':4.0, 'Mangal':5.0, 'Budha':0.5, 'Guru':5.0, 'Shukra':0.5, 'Shani':3.0},
    'Shukra':  {'Surya':0.0, 'Chandra':0.5, 'Mangal':3.0, 'Budha':5.0, 'Guru':0.5, 'Shukra':5.0, 'Shani':5.0},
    'Shani':   {'Surya':0.0, 'Chandra':0.5, 'Mangal':0.5, 'Budha':4.0, 'Guru':3.0, 'Shukra':5.0, 'Shani':5.0}
}

RASHI_LORDS_MAP = ['Mangal','Shukra','Budha','Chandra','Surya','Budha','Shukra','Mangal','Guru','Shani','Shani','Guru']

def get_moon_info(date_str, time_str, lat, lon):
    from calculations.kundli import get_julian_day, get_planets
    jd = get_julian_day(date_str, time_str, lat, lon)
    planets = get_planets(jd)
    moon = planets['Moon']
    nak_idx = int(moon['longitude'] / (360/27))
    return {
        'nakshatra': moon['nakshatra'],
        'rashi': moon['rashi'],
        'rashi_lord': moon['rashi_lord'],
        'nak_idx': nak_idx,
        'rashi_idx': int(moon['longitude'] / 30)
    }

def calc_varna(boy_rashi, girl_rashi):
    bv = VARNA.get(boy_rashi, 1)
    gv = VARNA.get(girl_rashi, 1)
    score = 1 if bv >= gv else 0
    return {'score': score, 'max': 1, 'boy': VARNA_NAMES.get(bv, 'Shudra'), 'girl': VARNA_NAMES.get(gv, 'Shudra')}

def calc_vasya(boy_rashi, girl_rashi):
    bv = VASYA.get(boy_rashi, 'Manav')
    gv = VASYA.get(girl_rashi, 'Manav')
    score = VASYA_MATRIX.get(bv, {}).get(gv, 0.0)
    return {'score': score, 'max': 2, 'boy': bv, 'girl': gv}

def calc_tara(boy_nak_idx, girl_nak_idx):
    c1 = (boy_nak_idx - girl_nak_idx) % 27 + 1
    t1 = c1 % 9
    c2 = (girl_nak_idx - boy_nak_idx) % 27 + 1
    t2 = c2 % 9
    
    good_taras = [2, 4, 6, 8, 0]
    p1 = 1.5 if t1 in good_taras else 0.0
    p2 = 1.5 if t2 in good_taras else 0.0
    score = p1 + p2
    
    boy_tara_label = TARA_GROUPS[t1 - 1] if t1 > 0 else 'Parama Mitra'
    girl_tara_label = TARA_GROUPS[t2 - 1] if t2 > 0 else 'Parama Mitra'
    
    return {
        'score': score, 
        'max': 3, 
        'boy_tara': boy_tara_label, 
        'girl_tara': girl_tara_label,
        'detail': f"Boy Tara: {boy_tara_label}, Girl Tara: {girl_tara_label}"
    }

def calc_yoni(boy_nak, girl_nak):
    by = YONI.get(boy_nak, 'Ashwa')
    gy = YONI.get(girl_nak, 'Ashwa')
    score = YONI_MATRIX.get(by, {}).get(gy, 0)
    return {'score': score, 'max': 4, 'boy': by, 'girl': gy}

def calc_graha_maitri(boy_rashi_lord, girl_rashi_lord):
    score = GRAHA_MAITRI_MATRIX.get(boy_rashi_lord, {}).get(girl_rashi_lord, 0.0)
    return {'score': score, 'max': 5, 'boy_lord': boy_rashi_lord, 'girl_lord': girl_rashi_lord}

def calc_gana(boy_nak, girl_nak):
    bg = GANA.get(boy_nak, 'Manushya')
    gg = GANA.get(girl_nak, 'Manushya')
    score = GANA_MATRIX.get(bg, {}).get(gg, 0)
    return {'score': score, 'max': 6, 'boy': bg, 'girl': gg}

def calc_bhakoot(boy_rashi_idx, girl_rashi_idx):
    diff1 = (boy_rashi_idx - girl_rashi_idx) % 12 + 1
    diff2 = (girl_rashi_idx - boy_rashi_idx) % 12 + 1
    bad = [(2,12),(12,2),(5,9),(9,5),(6,8),(8,6)]
    score = 0 if (diff1, diff2) in bad or (diff2, diff1) in bad else 7
    return {'score': score, 'max': 7, 'boy_from_girl': diff1, 'detail': 'Favorable' if score == 7 else 'Bhakoot Dosha Present'}

def calc_nadi(boy_nak, girl_nak):
    bn = NADI.get(boy_nak, 'Aadi')
    gn = NADI.get(girl_nak, 'Aadi')
    score = 0 if bn == gn else 8
    return {'score': score, 'max': 8, 'boy': bn, 'girl': gn, 'dosha': bn == gn}

def calculate_milan(boy_date, boy_time, boy_lat, boy_lon, girl_date, girl_time, girl_lat, girl_lon):
    boy = get_moon_info(boy_date, boy_time, boy_lat, boy_lon)
    girl = get_moon_info(girl_date, girl_time, girl_lat, girl_lon)
    
    varna = calc_varna(boy['rashi'], girl['rashi'])
    vasya = calc_vasya(boy['rashi'], girl['rashi'])
    tara = calc_tara(boy['nak_idx'], girl['nak_idx'])
    yoni = calc_yoni(boy['nakshatra'], girl['nakshatra'])
    maitri = calc_graha_maitri(boy['rashi_lord'], girl['rashi_lord'])
    gana = calc_gana(boy['nakshatra'], girl['nakshatra'])
    bhakoot = calc_bhakoot(boy['rashi_idx'], girl['rashi_idx'])
    nadi = calc_nadi(boy['nakshatra'], girl['nakshatra'])
    
    total = varna['score'] + vasya['score'] + tara['score'] + yoni['score'] + maitri['score'] + gana['score'] + bhakoot['score'] + nadi['score']
    
    if total >= 28: verdict = 'Excellent Match ✓✓'
    elif total >= 21: verdict = 'Good Match ✓'
    elif total >= 18: verdict = 'Average Match'
    else: verdict = 'Below Average - Consider carefully'
    
    nadi_dosha = nadi['dosha']
    bhakoot_dosha = bhakoot['score'] == 0
    
    return {
        'boy': boy, 'girl': girl,
        'scores': {
            'Varna': varna, 'Vasya': vasya, 'Tara': tara, 'Yoni': yoni,
            'Graha_Maitri': maitri, 'Gana': gana, 'Bhakoot': bhakoot, 'Nadi': nadi
        },
        'total_score': total, 'max_score': 36,
        'percentage': round(total/36*100, 1), 'verdict': verdict,
        'doshas': {
            'nadi_dosha': nadi_dosha, 'bhakoot_dosha': bhakoot_dosha,
            'report': ('Nadi Dosha present - seek remedy. ' if nadi_dosha else '') +
                      ('Bhakoot Dosha present. ' if bhakoot_dosha else '')
        }
    }
