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

# Varna
VARNA = {'Mesh':3,'Singh':3,'Dhanu':3, 'Vrishabh':2,'Kanya':2,'Makar':2,
         'Mithun':1,'Tula':1,'Kumbh':1, 'Kark':0,'Vrischik':0,'Meen':0}
VARNA_NAMES = {0:'Brahmin',1:'Kshatriya',2:'Vaishya',3:'Shudra'}

# Vasya
VASYA = {
    'Mesh':'Chatushpad','Vrishabh':'Chatushpad','Mithun':'Manav','Kark':'Jalachara',
    'Singh':'Vanachara','Kanya':'Manav','Tula':'Manav','Vrischik':'Keeta',
    'Dhanu':'Chatushpad','Makar':'Jalachara','Kumbh':'Manav','Meen':'Jalachara'
}

# Tara: 9 groups of 3 nakshatras
TARA_GROUPS = ['Janma','Sampat','Vipat','Kshema','Pratyak','Sadhana','Vadha','Mitra','Parama Mitra']

# Yoni
YONI = {
    'Ashwini':'Ashwa','Shatabhisha':'Ashwa','Bharani':'Gaja','Revati':'Gaja',
    'Pushya':'Mesha','Krittika':'Mesha','Rohini':'Sarpa','Mrigashira':'Sarpa',
    'Moola':'Shwana','Ardra':'Shwana','Ashlesha':'Marjara','Punarvasu':'Marjara',
    'Magha':'Mushaka','P.Phalguni':'Mushaka','U.Phalguni':'Gau','U.Bhadra':'Gau',
    'Hasta':'Mahisha','Swati':'Mahisha','Vishakha':'Vyaghra','Chitra':'Vyaghra',
    'Jyeshtha':'Mriga','Anuradha':'Mriga','P.Ashadha':'Vanara','Shravana':'Vanara',
    'P.Bhadra':'Simha','Dhanishtha':'Simha','U.Ashadha':'Nakula','Hasta':'Nakula'
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

# Nadi
NADI = {}
for i,n in enumerate(NAKSHATRAS):
    group = i % 9
    if group in [0,1,2]: NADI[n] = 'Aadi'
    elif group in [3,4,5]: NADI[n] = 'Madhya'
    else: NADI[n] = 'Antya'

# Rashi Maitri table (simplified)
RASHI_MITRA = {
    'Surya':['Chandra','Mangal','Guru'],'Chandra':['Surya','Budha'],'Mangal':['Surya','Chandra','Guru'],
    'Budha':['Surya','Shukra'],'Guru':['Surya','Chandra','Mangal'],'Shukra':['Budha','Shani'],
    'Shani':['Budha','Shukra']
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
    bv = VARNA.get(boy_rashi, 0); gv = VARNA.get(girl_rashi, 0)
    score = 1 if bv >= gv else 0
    return {'score': score, 'max': 1, 'boy': VARNA_NAMES[bv], 'girl': VARNA_NAMES[gv]}

def calc_vasya(boy_rashi, girl_rashi):
    bv = VASYA.get(boy_rashi, ''); gv = VASYA.get(girl_rashi, '')
    score = 2 if bv == gv else 1 if bv in ['Manav','Chatushpad'] and gv in ['Manav','Chatushpad'] else 0
    return {'score': score, 'max': 2, 'boy': bv, 'girl': gv}

def calc_tara(boy_nak_idx, girl_nak_idx):
    tara = (boy_nak_idx - girl_nak_idx) % 9
    good_taras = [2, 4, 6, 8]  # Sampat, Kshema, Sadhana, Parama Mitra
    score = 3 if tara in good_taras else 0
    return {'score': score, 'max': 3, 'boy_tara': TARA_GROUPS[tara], 'detail': 'Favorable' if tara in good_taras else 'Unfavorable'}

def calc_yoni(boy_nak, girl_nak):
    by = YONI.get(boy_nak, 'Unknown'); gy = YONI.get(girl_nak, 'Unknown')
    score = 4 if by == gy else 2 if by != gy else 0
    return {'score': score, 'max': 4, 'boy': by, 'girl': gy}

def calc_graha_maitri(boy_rashi_lord, girl_rashi_lord):
    bm = RASHI_MITRA.get(boy_rashi_lord, []); gm = RASHI_MITRA.get(girl_rashi_lord, [])
    mutual = boy_rashi_lord in gm and girl_rashi_lord in bm
    one_way = boy_rashi_lord in gm or girl_rashi_lord in bm
    score = 5 if mutual else 4 if one_way else 0
    return {'score': score, 'max': 5, 'boy_lord': boy_rashi_lord, 'girl_lord': girl_rashi_lord}

def calc_gana(boy_nak, girl_nak):
    bg = GANA.get(boy_nak, 'Manushya'); gg = GANA.get(girl_nak, 'Manushya')
    if bg == gg: score = 6
    elif (bg == 'Deva' and gg == 'Manushya') or (bg == 'Manushya' and gg == 'Deva'): score = 5
    elif bg == 'Deva' and gg == 'Rakshasa': score = 1
    else: score = 0
    return {'score': score, 'max': 6, 'boy': bg, 'girl': gg}

def calc_bhakoot(boy_rashi_idx, girl_rashi_idx):
    diff1 = (boy_rashi_idx - girl_rashi_idx) % 12 + 1
    diff2 = (girl_rashi_idx - boy_rashi_idx) % 12 + 1
    bad = [(2,12),(12,2),(5,9),(9,5),(6,8),(8,6)]
    score = 0 if (diff1, diff2) in bad or (diff2, diff1) in bad else 7
    return {'score': score, 'max': 7, 'boy_from_girl': diff1, 'detail': 'Favorable' if score == 7 else 'Bhakoot Dosha Present'}

def calc_nadi(boy_nak, girl_nak):
    bn = NADI.get(boy_nak, ''); gn = NADI.get(girl_nak, '')
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
