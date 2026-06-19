import swisseph as swe
from timezonefinder import TimezoneFinder
import pytz
from datetime import datetime

RASHIS = ['Mesh','Vrishabh','Mithun','Kark','Singh','Kanya','Tula','Vrischik','Dhanu','Makar','Kumbh','Meen']
RASHI_LORDS = ['Mangal','Shukra','Budha','Chandra','Surya','Budha','Shukra','Mangal','Guru','Shani','Shani','Guru']
NAKSHATRAS = ['Ashwini','Bharani','Krittika','Rohini','Mrigashira','Ardra','Punarvasu','Pushya','Ashlesha',
  'Magha','P.Phalguni','U.Phalguni','Hasta','Chitra','Swati','Vishakha','Anuradha','Jyeshtha',
  'Moola','P.Ashadha','U.Ashadha','Shravana','Dhanishtha','Shatabhisha','P.Bhadra','U.Bhadra','Revati']
NAKSHATRA_LORDS = ['Ketu','Shukra','Surya','Chandra','Mangal','Rahu','Guru','Shani','Budha'] * 3
NAKSHATRA_SYLLABLES = [
    ['चू','चे','चो','ला'],['ली','लू','ले','लो'],['आ','ई','उ','ए'],
    ['ओ','वा','वी','वू'],['वे','वो','का','की'],['कू','घ','ङ','छ'],
    ['के','को','हा','ही'],['हू','हे','हो','डा'],['डी','डू','डे','डो'],
    ['मा','मी','मू','मे'],['मो','टा','टी','टू'],['टे','टो','पा','पी'],
    ['पू','ष','ण','ठ'],['पे','पो','रा','री'],['रू','रे','रो','ता'],
    ['ती','तू','ते','तो'],['ना','नी','नू','ने'],['नो','या','यी','यू'],
    ['ये','यो','भा','भी'],['भू','धा','फा','ढा'],['भे','भो','जा','जी'],
    ['खी','खू','खे','खो'],['गा','गी','गू','गे'],['गो','सा','सी','सू'],
    ['से','सो','दा','दी'],['दू','थ','झ','ञ'],['दे','दो','चा','ची']
]

# Vimshottari Dasha periods (years)
DASHA_LORDS = ['Ketu','Shukra','Surya','Chandra','Mangal','Rahu','Guru','Shani','Budha']
DASHA_YEARS = {'Ketu':7,'Shukra':20,'Surya':6,'Chandra':10,'Mangal':7,'Rahu':18,'Guru':16,'Shani':19,'Budha':17}
TOTAL_DASHA_YEARS = 120

# Exaltation/Debilitation degrees
EXALTATION = {'Sun':10,'Moon':33,'Mars':298,'Mercury':165,'Jupiter':95,'Venus':357,'Saturn':200,'Rahu':60,'Ketu':240}
DEBILITATION = {'Sun':190,'Moon':213,'Mars':118,'Mercury':345,'Jupiter':275,'Venus':177,'Saturn':20,'Rahu':240,'Ketu':60}

def get_julian_day(date_str, time_str, lat, lon):
    dt = datetime.strptime(f"{date_str} {time_str}", "%Y-%m-%d %H:%M")
    tf = TimezoneFinder()
    tz_name = tf.timezone_at(lng=lon, lat=lat)
    if tz_name:
        tz = pytz.timezone(tz_name)
        dt = tz.localize(dt)
        dt_utc = dt.astimezone(pytz.utc)
    else:
        dt_utc = dt
    jd = swe.julday(dt_utc.year, dt_utc.month, dt_utc.day, dt_utc.hour + dt_utc.minute/60.0)
    return jd

def is_exalted(name, lon):
    if name in EXALTATION:
        return abs(lon - EXALTATION[name]) < 1
    return False

def is_debilitated(name, lon):
    if name in DEBILITATION:
        return abs(lon - DEBILITATION[name]) < 1
    return False

def get_planets(jd, ayanamsa=swe.SIDM_LAHIRI):
    swe.set_sid_mode(ayanamsa)
    planet_ids = {
        'Sun':swe.SUN,'Moon':swe.MOON,'Mars':swe.MARS,'Mercury':swe.MERCURY,
        'Jupiter':swe.JUPITER,'Venus':swe.VENUS,'Saturn':swe.SATURN,'Rahu':swe.MEAN_NODE,
        'Uranus':swe.URANUS,'Neptune':swe.NEPTUNE,'Pluto':swe.PLUTO
    }
    planets_data = {}
    for name, pid in planet_ids.items():
        res, _ = swe.calc_ut(jd, pid, swe.FLG_SIDEREAL | swe.FLG_SPEED)
        lon = res[0]
        speed = res[3]
        rashi_idx = int(lon / 30)
        nak_idx = int(lon / (360/27))
        nak_pada = int((lon % (360/27)) / (360/108)) + 1
        planets_data[name] = {
            'longitude': round(lon, 6),
            'speed': round(speed, 6),
            'is_retrograde': speed < 0 if name not in ['Sun','Moon','Rahu'] else False,
            'is_exalted': is_exalted(name, lon),
            'is_debilitated': is_debilitated(name, lon),
            'rashi': RASHIS[rashi_idx],
            'rashi_lord': RASHI_LORDS[rashi_idx],
            'rashi_num': rashi_idx + 1,
            'degree': round(lon % 30, 4),
            'nakshatra': NAKSHATRAS[nak_idx],
            'nakshatra_lord': NAKSHATRA_LORDS[nak_idx],
            'pada': nak_pada,
            'namakshar': NAKSHATRA_SYLLABLES[nak_idx][nak_pada - 1]
        }
    # Ketu
    rahu_lon = planets_data['Rahu']['longitude']
    ketu_lon = (rahu_lon + 180) % 360
    ri = int(ketu_lon / 30); ni = int(ketu_lon / (360/27))
    np_ = int((ketu_lon % (360/27)) / (360/108)) + 1
    planets_data['Ketu'] = {
        'longitude': round(ketu_lon, 6), 'speed': planets_data['Rahu']['speed'],
        'is_retrograde': False, 'is_exalted': is_exalted('Ketu', ketu_lon),
        'is_debilitated': is_debilitated('Ketu', ketu_lon),
        'rashi': RASHIS[ri], 'rashi_lord': RASHI_LORDS[ri], 'rashi_num': ri + 1,
        'degree': round(ketu_lon % 30, 4), 'nakshatra': NAKSHATRAS[ni],
        'nakshatra_lord': NAKSHATRA_LORDS[ni], 'pada': np_,
        'namakshar': NAKSHATRA_SYLLABLES[ni][np_ - 1]
    }
    return planets_data

def get_ascendant(jd, lat, lon, ayanamsa=swe.SIDM_LAHIRI, house_sys=b'W'):
    swe.set_sid_mode(ayanamsa)
    res = swe.houses_ex(jd, lat, lon, house_sys, swe.FLG_SIDEREAL)
    asc_lon = res[1][0]
    cusps = list(res[0])
    ri = int(asc_lon / 30); ni = int(asc_lon / (360/27))
    np_ = int((asc_lon % (360/27)) / (360/108)) + 1
    return {
        'longitude': round(asc_lon, 6), 'rashi': RASHIS[ri],
        'rashi_lord': RASHI_LORDS[ri], 'rashi_num': ri + 1,
        'degree': round(asc_lon % 30, 4), 'nakshatra': NAKSHATRAS[ni],
        'nakshatra_lord': NAKSHATRA_LORDS[ni], 'pada': np_,
        'namakshar': NAKSHATRA_SYLLABLES[ni][np_ - 1], 'cusps': cusps
    }

def get_house_positions(planets, ascendant):
    lagna_idx = ascendant['rashi_num'] - 1
    houses = {}
    for name, p in planets.items():
        house = (p['rashi_num'] - 1 - lagna_idx) % 12 + 1
        houses[name] = house
    return houses

def get_placidus_house_positions(planets, cusps):
    houses = {}
    for name, p in planets.items():
        lon = p['longitude']
        house = 1
        for i in range(12):
            start = cusps[i]
            end = cusps[(i + 1) % 12]
            if start < end:
                if start <= lon < end:
                    house = i + 1
                    break
            else:
                if lon >= start or lon < end:
                    house = i + 1
                    break
        houses[name] = house
    return houses

def get_kp_lords(lon):
    rashi_idx = int(lon / 30) % 12
    rashi_lord = RASHI_LORDS[rashi_idx]

    nak_span = 360.0 / 27.0
    nak_idx = int(lon / nak_span) % 27
    nakshatra = NAKSHATRAS[nak_idx]
    nakshatra_lord = NAKSHATRA_LORDS[nak_idx]

    pos_in_nak = lon % nak_span
    pos_in_nak_min = pos_in_nak * 60.0  # minutes within nakshatra

    lord_order = ['Ketu','Shukra','Surya','Chandra','Mangal','Rahu','Guru','Shani','Budha']
    dasha_years = {'Ketu':7,'Shukra':20,'Surya':6,'Chandra':10,'Mangal':7,'Rahu':18,'Guru':16,'Shani':19,'Budha':17}
    nak_total_min = 800.0  # minutes per nakshatra (13°20' = 800 arcmin)

    start_lord_idx = lord_order.index(nakshatra_lord)

    elapsed = 0.0
    sub_lord = nakshatra_lord
    sub_lord_start = 0.0
    sub_lord_span = 0.0
    for i in range(9):
        current_lord = lord_order[(start_lord_idx + i) % 9]
        span = nak_total_min * dasha_years[current_lord] / 120.0
        if elapsed <= pos_in_nak_min < (elapsed + span):
            sub_lord = current_lord
            sub_lord_start = elapsed
            sub_lord_span = span
            break
        elapsed += span

    # Sub-Sub Lord (SS): divide sub-lord span by 9 dasha proportions
    sub_start_lord_idx = lord_order.index(sub_lord)
    pos_in_sub = pos_in_nak_min - sub_lord_start
    sub_sub_lord = sub_lord
    sub_elapsed = 0.0
    for i in range(9):
        current_lord = lord_order[(sub_start_lord_idx + i) % 9]
        span = sub_lord_span * dasha_years[current_lord] / 120.0
        if sub_elapsed <= pos_in_sub < (sub_elapsed + span):
            sub_sub_lord = current_lord
            break
        sub_elapsed += span

    return rashi_lord, nakshatra, nakshatra_lord, sub_lord, sub_sub_lord


def get_house_significators(kp_planets, kp_ascendant):
    planet_abbrev = {
        'Sun': 'Su', 'Moon': 'Mo', 'Mars': 'Ma', 'Mercury': 'Me',
        'Jupiter': 'Ju', 'Venus': 'Ve', 'Saturn': 'Sa', 'Rahu': 'Ra', 'Ketu': 'Ke'
    }
    planet_order = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu']
    
    # 1. House lords (cuspal lords)
    cusp_details = kp_ascendant.get('cusp_details', [])
    house_lords = {}
    for h in range(1, 13):
        cusp = cusp_details[h-1] if h-1 < len(cusp_details) else {}
        lord_name = cusp.get('rashi_lord', '')
        lord_english = {
            'Surya': 'Sun', 'Chandra': 'Moon', 'Mangal': 'Mars', 'Budha': 'Mercury',
            'Guru': 'Jupiter', 'Shukra': 'Venus', 'Shani': 'Saturn',
            'Rahu': 'Rahu', 'Ketu': 'Ketu', 'Sun': 'Sun', 'Moon': 'Moon',
            'Mars': 'Mars', 'Mercury': 'Mercury', 'Jupiter': 'Jupiter',
            'Venus': 'Venus', 'Saturn': 'Saturn'
        }.get(lord_name, lord_name)
        house_lords[h] = lord_english
        
    # 2. House occupants
    house_occupants = {h: [] for h in range(1, 13)}
    for p in planet_order:
        pdata = kp_planets.get(p, {})
        h = pdata.get('house')
        if h and 1 <= h <= 12:
            house_occupants[h].append(p)
            
    # 3. Nakshatra lords of all planets
    planet_nak_lords = {}
    for p in planet_order:
        pdata = kp_planets.get(p, {})
        nl = pdata.get('nakshatra_lord', '')
        nl_english = {
            'Surya': 'Sun', 'Chandra': 'Moon', 'Mangal': 'Mars', 'Budha': 'Mercury',
            'Guru': 'Jupiter', 'Shukra': 'Venus', 'Shani': 'Saturn',
            'Rahu': 'Rahu', 'Ketu': 'Ketu', 'Sun': 'Sun', 'Moon': 'Moon',
            'Mars': 'Mars', 'Mercury': 'Mercury', 'Jupiter': 'Jupiter',
            'Venus': 'Venus', 'Saturn': 'Saturn'
        }.get(nl, nl)
        planet_nak_lords[p] = nl_english
        
    # Compute significators for each house
    significators = {}
    for h in range(1, 13):
        # Grade B: Occupants of house H
        grade_b = house_occupants[h]
        
        # Grade A: Planets in the nakshatra of occupants of house H
        grade_a = [p for p in planet_order if planet_nak_lords.get(p) in grade_b]
        
        # Grade D: Lord of house H
        lord = house_lords.get(h)
        grade_d = [lord] if lord else []
        
        # Grade C: Planets in the nakshatra of lord of house H
        grade_c = [p for p in planet_order if lord and planet_nak_lords.get(p) == lord]
        
        # Combine all significators in standard planet order
        combined_set = set(grade_a + grade_b + grade_c + grade_d)
        sorted_sigs = [p for p in planet_order if p in combined_set]
        abbrevs = [planet_abbrev[p] for p in sorted_sigs]
        
        cusp = cusp_details[h-1] if h-1 < len(cusp_details) else {}
        
        significators[str(h)] = {
            'house': h,
            'sign': cusp.get('rashi', '-'),
            'sign_lord': house_lords.get(h, '-'),
            'sign_lord_abbrev': planet_abbrev.get(house_lords.get(h, ''), '-'),
            'occupants': grade_b,
            'occupant_abbrevs': [planet_abbrev[p] for p in grade_b],
            'star_lord_significators': grade_a,
            'star_lord_sig_abbrevs': [planet_abbrev[p] for p in grade_a],
            'nakshatra_lord': cusp.get('nakshatra_lord', '-'),
            'sub_lord': cusp.get('sub_lord', '-'),
            'significators': sorted_sigs,
            'significators_abbrevs': abbrevs,
            'significators_str': ' '.join(abbrevs)
        }
        
    # Also calculate planet signification (transpose)
    planet_significations = {}
    for p in planet_order:
        signified_houses = []
        for h in range(1, 13):
            if p in significators[str(h)]['significators']:
                signified_houses.append(h)
        planet_significations[p] = {
            'planet': p,
            'abbrev': planet_abbrev[p],
            'houses': signified_houses,
            'houses_str': ' '.join(str(h) for h in signified_houses)
        }
        
    return significators, planet_significations



def get_navamsa(lon):
    """D9 Navamsa calculation"""
    sign = int(lon / 30)
    degrees_in_sign = lon % 30
    navamsa_num = int(degrees_in_sign / (30/9))
    # Starting sign for navamsa based on rashi type
    if sign % 3 == 0:  # Movable (Char): Mesh, Kark, Tula, Makar
        start = sign
    elif sign % 3 == 1:  # Fixed (Sthir): Vrishabh, Singh, Vrischik, Kumbh
        start = (sign + 8) % 12
    else:  # Dual (Dwiswabhav): Mithun, Kanya, Dhanu, Meen
        start = (sign + 4) % 12
    navamsa_sign = (start + navamsa_num) % 12
    return {'rashi': RASHIS[navamsa_sign], 'rashi_lord': RASHI_LORDS[navamsa_sign]}

def get_divisional_chart(planets, ascendant, div):
    """Generic divisional chart D-n"""
    result = {}
    for name, p in planets.items():
        lon = p['longitude']
        sign_idx = int(lon / 30)
        deg_in_sign = lon % 30
        part = int(deg_in_sign / (30/div))
        new_sign = (sign_idx * div + part) % 12
        result[name] = {'rashi': RASHIS[new_sign], 'rashi_lord': RASHI_LORDS[new_sign], 'rashi_num': new_sign+1}
    # Ascendant
    asc_lon = ascendant['longitude']
    asc_sign_idx = int(asc_lon / 30)
    asc_deg = asc_lon % 30
    asc_part = int(asc_deg / (30/div))
    asc_new = (asc_sign_idx * div + asc_part) % 12
    result['Lagna'] = {'rashi': RASHIS[asc_new], 'rashi_lord': RASHI_LORDS[asc_new], 'rashi_num': asc_new+1}
    return result

def get_vimshottari_dasha(planets, jd):
    """Calculate Maha Dasha + Antar Dasha"""
    moon_lon = planets['Moon']['longitude']
    nak_idx = int(moon_lon / (360/27))
    nak_lord = NAKSHATRA_LORDS[nak_idx]
    
    # Balance of dasha at birth
    nak_deg = moon_lon % (360/27)
    nak_fraction_elapsed = nak_deg / (360/27)
    lord_idx = DASHA_LORDS.index(nak_lord)
    balance_years = DASHA_YEARS[nak_lord] * (1 - nak_fraction_elapsed)
    
    # Current JD to datetime
    dt = swe.revjul(jd, swe.GREG_CAL)
    birth_year = dt[0] + (jd - swe.julday(dt[0], dt[1], dt[2], 0)) / 365.25
    
    dashas = []
    current_year = birth_year
    
    for i in range(9):
        idx = (lord_idx + i) % 9
        lord = DASHA_LORDS[idx]
        years = balance_years if i == 0 else DASHA_YEARS[lord]
        end_year = current_year + years
        
        # Antar Dashas
        antars = []
        antar_start = current_year
        for j in range(9):
            a_idx = (idx + j) % 9
            a_lord = DASHA_LORDS[a_idx]
            a_years = (DASHA_YEARS[lord] * DASHA_YEARS[a_lord]) / TOTAL_DASHA_YEARS
            if i == 0 and j == 0:
                a_years = balance_years * DASHA_YEARS[a_lord] / DASHA_YEARS[lord]
            a_end = antar_start + a_years
            antars.append({
                'lord': a_lord, 'start_year': round(antar_start, 2), 'end_year': round(a_end, 2),
                'duration_months': round(a_years * 12, 1)
            })
            antar_start = a_end
        
        dashas.append({
            'lord': lord, 'start_year': round(current_year, 2), 'end_year': round(end_year, 2),
            'duration_years': round(years, 2), 'antars': antars
        })
        current_year = end_year
        if i == 0:
            balance_years = 0
    return dashas

def check_yogas(planets, ascendant, house_positions):
    yogas = []
    lagna_lord = ascendant['rashi_lord']
    
    # Gaja Kesari Yoga: Jupiter in kendra from Moon
    moon_house = house_positions.get('Moon', 0)
    jup_house = house_positions.get('Jupiter', 0)
    kendra_from_moon = [(moon_house + k - 1) % 12 + 1 for k in [1,4,7,10]]
    if jup_house in kendra_from_moon:
        yogas.append({'name': 'Gaja Kesari Yoga', 'present': True,
            'description': 'Jupiter in Kendra from Moon. Brings intelligence, fame and prosperity.'})
    
    # Panch Mahapurusha Yogas
    mahapurusha_planets = {'Mars': 'Ruchaka', 'Mercury': 'Bhadra', 'Jupiter': 'Hamsa', 'Venus': 'Malavya', 'Saturn': 'Shasha'}
    own_signs = {'Mars': ['Mesh','Vrischik'], 'Mercury': ['Mithun','Kanya'], 'Jupiter': ['Dhanu','Meen'],
                 'Venus': ['Vrishabh','Tula'], 'Saturn': ['Makar','Kumbh']}
    exalt_signs = {'Mars': 'Makar', 'Mercury': 'Kanya', 'Jupiter': 'Kark', 'Venus': 'Meen', 'Saturn': 'Tula'}
    for planet, yoga_name in mahapurusha_planets.items():
        p_rashi = planets[planet]['rashi']
        p_house = house_positions.get(planet, 0)
        in_own = p_rashi in own_signs.get(planet, [])
        in_exalt = p_rashi == exalt_signs.get(planet, '')
        in_kendra = p_house in [1, 4, 7, 10]
        if (in_own or in_exalt) and in_kendra:
            yogas.append({'name': yoga_name + ' Yoga', 'present': True,
                'description': f'{planet} in own/exaltation sign in Kendra. Gives extraordinary qualities.'})
    
    # Kaal Sarp Yoga
    rahu_lon = planets['Rahu']['longitude']
    ketu_lon = planets['Ketu']['longitude']
    all_between = True
    for name in ['Sun','Moon','Mars','Mercury','Jupiter','Venus','Saturn']:
        p_lon = planets[name]['longitude']
        if rahu_lon < ketu_lon:
            if not (rahu_lon <= p_lon <= ketu_lon):
                all_between = False; break
        else:
            if not (p_lon >= rahu_lon or p_lon <= ketu_lon):
                all_between = False; break
    if all_between:
        yogas.append({'name': 'Kaal Sarp Yoga', 'present': True,
            'description': 'All planets between Rahu and Ketu. Can cause delays but also intense focus.'})
    
    # Budhaditya Yoga: Sun + Mercury in same sign
    if planets['Sun']['rashi'] == planets['Mercury']['rashi']:
        yogas.append({'name': 'Budhaditya Yoga', 'present': True,
            'description': 'Sun and Mercury in same sign. Blesses with intelligence and communication.'})
    
    # Chandra-Mangal Yoga
    if planets['Moon']['rashi'] == planets['Mars']['rashi']:
        yogas.append({'name': 'Chandra-Mangal Yoga', 'present': True,
            'description': 'Moon and Mars conjunct. Gives wealth through hard work and boldness.'})
    
    return yogas

def check_manglik(planets, ascendant, house_positions):
    mars_house = house_positions.get('Mars', 0)
    is_manglik = mars_house in [1, 4, 7, 8, 12]
    # Cancellations
    cancelled = False
    cancel_reason = ''
    if planets['Mars']['rashi'] in ['Mesh', 'Vrischik']:
        cancelled = True; cancel_reason = 'Mars in own sign (Mesh/Vrischik)'
    elif planets['Mars']['rashi'] == 'Makar':
        cancelled = True; cancel_reason = 'Mars exalted in Makar'
    elif planets['Mars']['rashi'] in ['Kark', 'Meen']:  # Jupiter aspect sign
        cancelled = True; cancel_reason = 'Jupiter in Cancer/Pisces reduces Manglik'
    return {
        'is_manglik': is_manglik and not cancelled,
        'cancelled': cancelled, 'cancel_reason': cancel_reason,
        'mars_house': mars_house,
        'report': f"Manglik Dosha {'PRESENT' if (is_manglik and not cancelled) else 'ABSENT'}. Mars in House {mars_house}." +
                  (f" Cancelled: {cancel_reason}" if cancelled else '')
    }

def check_sade_sati(planets, jd):
    saturn_lon = planets['Saturn']['longitude']
    moon_lon = planets['Moon']['longitude']
    moon_rashi_idx = int(moon_lon / 30)
    saturn_rashi_idx = int(saturn_lon / 30)
    # Sade Sati: Saturn in 12th, 1st, 2nd from Moon
    diff = (saturn_rashi_idx - moon_rashi_idx) % 12
    in_sade_sati = diff in [0, 1, 11]
    in_kantaka = diff in [3, 6, 9]  # 4th, 7th, 10th from Moon
    phase = ''
    if in_sade_sati:
        if diff == 11: phase = 'Rising (12th from Moon)'
        elif diff == 0: phase = 'Peak (1st from Moon)'
        elif diff == 1: phase = 'Setting (2nd from Moon)'
    return {
        'in_sade_sati': in_sade_sati,
        'in_kantaka_shani': in_kantaka,
        'phase': phase,
        'report': f"Sade Sati {'ACTIVE' if in_sade_sati else 'NOT ACTIVE'}" +
                  (f" - {phase}" if phase else '') +
                  (". Kantaka Shani ACTIVE" if in_kantaka else '')
    }

def check_kaal_sarp(planets):
    rahu_lon = planets['Rahu']['longitude']
    ketu_lon = planets['Ketu']['longitude']
    # Determine which half
    all_planets_lons = [planets[p]['longitude'] for p in ['Sun','Moon','Mars','Mercury','Jupiter','Venus','Saturn']]
    
    def between_rahu_ketu(lon):
        if rahu_lon > ketu_lon:
            return ketu_lon <= lon <= rahu_lon
        else:
            return lon >= rahu_lon or lon <= ketu_lon
    
    all_between = all(between_rahu_ketu(lon) for lon in all_planets_lons)
    all_other = all(not between_rahu_ketu(lon) for lon in all_planets_lons)
    
    if all_between or all_other:
        # Identify type (1-12)
        rahu_house_idx = int(rahu_lon / 30)
        types = ['Anant','Kulik','Vasuki','Shankhapala','Padma','Mahapadma',
                 'Takshak','Karkotak','Shankhachur','Ghatak','Vishdhar','Sheshnag']
        yoga_type = types[rahu_house_idx % 12]
        return {'present': True, 'type': yoga_type,
                'report': f"Kaal Sarp Yoga ({yoga_type}) is present. All planets hemmed between Rahu and Ketu."}
    return {'present': False, 'type': None, 'report': 'Kaal Sarp Yoga is NOT present.'}

def get_lal_kitab(planets, house_positions):
    """Lal Kitab house-based analysis"""
    results = {}
    for planet, house in house_positions.items():
        remedies = []
        effects = ''
        if planet == 'Sun':
            if house == 1: effects = 'Strong personality, leadership. Serve father regularly.'
            elif house == 7: effects = 'Marital issues possible. Offer water to Sun daily.'; remedies = ['Offer water to Sun','Serve father']
        elif planet == 'Moon':
            if house == 1: effects = 'Emotional, sensitive nature. Silver helps.'; remedies = ['Wear silver']
            elif house == 6: effects = 'Health of mother concerns. Feed fish milk.'; remedies = ['Feed fish milk or rice']
        elif planet == 'Mars':
            if house in [1,4,7,8,12]: effects = 'Manglik. Offer sweet rotis to dogs.'; remedies = ['Offer rotis to dogs','Wear red coral']
        elif planet == 'Saturn':
            if house == 1: effects = 'Delays in life but eventual success.'; remedies = ['Feed crows','Donate black items on Saturday']
            elif house in [3,6,11]: effects = 'Very favorable Saturn placement.'
        elif planet == 'Rahu':
            remedies = ['Donate barley','Wear hessonite']
            effects = f'Rahu in house {house}. Can cause sudden events.'
        elif planet == 'Ketu':
            remedies = ['Donate blankets','Wear cat\'s eye']
            effects = f'Ketu in house {house}. Spirituality and detachment.'
        results[planet] = {'house': house, 'effects': effects if effects else f'{planet} in house {house}.', 'remedies': remedies}
    return results

def get_numerology(date_str):
    parts = date_str.split('-')
    year, month, day = parts[0], parts[1], parts[2]
    def reduce(n_str):
        total = sum(int(d) for d in n_str)
        while total > 9 and total not in [11, 22, 33]:
            total = sum(int(d) for d in str(total))
        return total
    moolank = reduce(day)
    bhagyank = reduce(year + month + day)
    namank = 0  # Would need name for this
    MOOLANK_DESC = {
        1: 'Sun number. Natural leader, independent, ambitious.',
        2: 'Moon number. Sensitive, intuitive, diplomatic.',
        3: 'Jupiter number. Creative, communicative, optimistic.',
        4: 'Rahu number. Practical, hardworking, disciplined.',
        5: 'Mercury number. Versatile, adventurous, freedom-loving.',
        6: 'Venus number. Nurturing, responsible, artistic.',
        7: 'Ketu number. Introspective, spiritual, analytical.',
        8: 'Saturn number. Ambitious, business-minded, powerful.',
        9: 'Mars number. Courageous, energetic, humanitarian.'
    }
    return {
        'moolank': moolank, 'bhagyank': bhagyank,
        'moolank_planet': ['','Sun','Moon','Jupiter','Rahu','Mercury','Venus','Ketu','Saturn','Mars'][moolank] if moolank <= 9 else '',
        'report': MOOLANK_DESC.get(moolank, ''),
        'bhagyank_report': MOOLANK_DESC.get(bhagyank % 9 or 9, '')
    }

ASHTAKVARGA_RULES = {
    'Sun': {
        'Sun': [1, 2, 4, 7, 8, 9, 10, 11],
        'Moon': [3, 6, 10, 11],
        'Mars': [1, 2, 4, 7, 8, 9, 10, 11],
        'Mercury': [3, 5, 6, 9, 10, 11, 12],
        'Jupiter': [5, 6, 9, 11],
        'Venus': [6, 7, 12],
        'Saturn': [1, 2, 4, 7, 8, 9, 10, 11],
        'Lagna': [3, 4, 6, 10, 11, 12]
    },
    'Moon': {
        'Sun': [3, 6, 7, 8, 10, 11],
        'Moon': [1, 3, 6, 7, 10, 11],
        'Mars': [2, 3, 5, 6, 9, 10, 11],
        'Mercury': [1, 3, 4, 5, 7, 8, 10, 11],
        'Jupiter': [1, 4, 7, 8, 10, 11, 12],
        'Venus': [3, 4, 5, 7, 9, 10, 11],
        'Saturn': [3, 5, 6, 11],
        'Lagna': [3, 6, 10, 11]
    },
    'Mars': {
        'Sun': [3, 5, 6, 10, 11],
        'Moon': [3, 6, 11],
        'Mars': [1, 2, 4, 7, 8, 10, 11],
        'Mercury': [3, 5, 6, 11],
        'Jupiter': [6, 10, 11, 12],
        'Venus': [6, 8, 11, 12],
        'Saturn': [1, 4, 7, 8, 9, 10, 11],
        'Lagna': [1, 3, 6, 10, 11]
    },
    'Mercury': {
        'Sun': [5, 6, 9, 11, 12],
        'Moon': [2, 4, 6, 8, 10, 11],
        'Mars': [1, 2, 4, 7, 8, 9, 10, 11],
        'Mercury': [1, 3, 5, 6, 9, 10, 11, 12],
        'Jupiter': [6, 8, 11, 12],
        'Venus': [1, 2, 3, 4, 5, 8, 9, 11],
        'Saturn': [1, 2, 4, 7, 8, 9, 10, 11],
        'Lagna': [1, 2, 4, 6, 8, 10, 11]
    },
    'Jupiter': {
        'Sun': [1, 2, 3, 4, 7, 8, 9, 10, 11],
        'Moon': [2, 5, 7, 9, 11],
        'Mars': [1, 2, 4, 7, 8, 10, 11],
        'Mercury': [1, 2, 4, 5, 6, 9, 10, 11],
        'Jupiter': [1, 2, 3, 4, 7, 8, 10, 11],
        'Venus': [2, 5, 6, 9, 10, 11],
        'Saturn': [3, 5, 6, 12],
        'Lagna': [1, 2, 4, 5, 6, 7, 9, 10, 11]
    },
    'Venus': {
        'Sun': [8, 11, 12],
        'Moon': [1, 2, 3, 4, 5, 8, 9, 11, 12],
        'Mars': [3, 5, 6, 9, 11, 12],
        'Mercury': [3, 5, 6, 9, 11],
        'Jupiter': [5, 8, 9, 10, 11],
        'Venus': [1, 2, 3, 4, 5, 8, 9, 10, 11],
        'Saturn': [3, 4, 5, 8, 9, 10, 11],
        'Lagna': [1, 2, 3, 4, 5, 8, 9, 11]
    },
    'Saturn': {
        'Sun': [1, 2, 4, 7, 8, 10, 11],
        'Moon': [3, 6, 11],
        'Mars': [3, 5, 6, 10, 11, 12],
        'Mercury': [6, 8, 9, 10, 11, 12],
        'Jupiter': [5, 6, 11, 12],
        'Venus': [6, 11, 12],
        'Saturn': [3, 5, 6, 11],
        'Lagna': [1, 3, 4, 6, 10, 11]
    }
}

def calculate_ashtakvarga(planets, ascendant):
    positions = {
        'Sun': planets['Sun']['rashi_num'],
        'Moon': planets['Moon']['rashi_num'],
        'Mars': planets['Mars']['rashi_num'],
        'Mercury': planets['Mercury']['rashi_num'],
        'Jupiter': planets['Jupiter']['rashi_num'],
        'Venus': planets['Venus']['rashi_num'],
        'Saturn': planets['Saturn']['rashi_num'],
        'Lagna': ascendant['rashi_num']
    }
    
    target_planets = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn']
    contributors = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Lagna']
    
    contrib_abbrev = {
        'Sun': 'SU', 'Moon': 'MO', 'Mars': 'MA', 'Mercury': 'ME',
        'Jupiter': 'JU', 'Venus': 'VE', 'Saturn': 'SA', 'Lagna': 'AS'
    }
    
    pat_tables = {}
    bav_tables = {}
    sav = {str(rashi): 0 for rashi in range(1, 13)}
    
    for tp in target_planets:
        rules = ASHTAKVARGA_RULES[tp]
        grid = []
        bav = {str(rashi): 0 for rashi in range(1, 13)}
        
        for c in contributors:
            natal_rashi = positions[c]
            row_points = {str(rashi): 0 for rashi in range(1, 13)}
            offsets = rules[c]
            for offset in offsets:
                abs_rashi = ((natal_rashi - 1) + (offset - 1)) % 12 + 1
                row_points[str(abs_rashi)] = 1
                bav[str(abs_rashi)] += 1
                
            row_points['TO'] = len(offsets)
            row_points['contributor'] = contrib_abbrev[c]
            grid.append(row_points)
            
        to_row = {'contributor': 'TO'}
        total_bav_sum = 0
        for rashi in range(1, 13):
            val = bav[str(rashi)]
            to_row[str(rashi)] = val
            total_bav_sum += val
            sav[str(rashi)] += val
            
        to_row['TO'] = total_bav_sum
        grid.append(to_row)
        
        pat_tables[tp] = grid
        bav_tables[tp] = bav
        
    sav_rows = []
    for rashi in range(1, 13):
        r_str = str(rashi)
        row = {
            'RN': rashi,
            'Su': bav_tables['Sun'][r_str],
            'Mo': bav_tables['Moon'][r_str],
            'Ma': bav_tables['Mars'][r_str],
            'Me': bav_tables['Mercury'][r_str],
            'Ju': bav_tables['Jupiter'][r_str],
            'Ve': bav_tables['Venus'][r_str],
            'Sa': bav_tables['Saturn'][r_str],
            'Tot': sav[r_str]
        }
        sav_rows.append(row)
        
    return {
        'sarvashtakavarga': sav_rows,
        'prasthara_ashtakavarga': pat_tables
    }

def calculate_shad_bala(planets, ascendant):
    sun_house = planets['Sun']['house']
    is_day_birth = sun_house in [7, 8, 9, 10, 11, 12]
    planet_list = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn']
    
    exaltation = {'Sun': 10, 'Moon': 33, 'Mars': 298, 'Mercury': 165, 'Jupiter': 95, 'Venus': 357, 'Saturn': 20}
    
    own_signs = {
        'Sun': ['Singh'], 'Moon': ['Kark'], 'Mars': ['Mesh', 'Vrischik'],
        'Mercury': ['Mithun', 'Kanya'], 'Jupiter': ['Dhanu', 'Meen'],
        'Venus': ['Vrishabh', 'Tula'], 'Saturn': ['Makar', 'Kumbh']
    }
    friendly_signs = {
        'Sun': ['Mesh', 'Vrishabh', 'Dhanu', 'Meen'],
        'Moon': ['Mesh', 'Vrishabh', 'Mithun', 'Kanya', 'Tula'],
        'Mars': ['Singh', 'Dhanu', 'Meen'],
        'Mercury': ['Vrishabh', 'Tula', 'Singh'],
        'Jupiter': ['Mesh', 'Kark', 'Vrischik'],
        'Venus': ['Mithun', 'Kanya', 'Makar', 'Kumbh'],
        'Saturn': ['Vrishabh', 'Mithun', 'Kanya', 'Tula']
    }
    
    natural_strength = {
        'Sun': 60, 'Moon': 51.43, 'Venus': 42.86, 'Jupiter': 34.29,
        'Mercury': 25.71, 'Mars': 17.14, 'Saturn': 8.57
    }
    
    shad_bala_scores = {}
    
    for p in planet_list:
        p_data = planets[p]
        lon = p_data['longitude']
        rashi = p_data['rashi']
        house = p_data['house']
        is_retro = p_data.get('is_retrograde', False)
        
        # 1. Sthana Bala
        ex_lon = exaltation[p]
        dist_ex = abs(lon - ex_lon)
        if dist_ex > 180:
            dist_ex = 360 - dist_ex
        sth_ex = 60 * (1 - dist_ex / 180.0)
        
        sth_rashi = 7.5
        if rashi in own_signs[p]:
            sth_rashi = 30.0
        elif rashi in friendly_signs[p]:
            sth_rashi = 15.0
        elif p == 'Sun' and rashi == 'Tula':
            sth_rashi = 0.0
        elif p == 'Moon' and rashi == 'Vrischik':
            sth_rashi = 0.0
        elif p == 'Mars' and rashi == 'Kark':
            sth_rashi = 0.0
        elif p == 'Mercury' and rashi == 'Meen':
            sth_rashi = 0.0
        elif p == 'Jupiter' and rashi == 'Makar':
            sth_rashi = 0.0
        elif p == 'Venus' and rashi == 'Kanya':
            sth_rashi = 0.0
        elif p == 'Saturn' and rashi == 'Mesh':
            sth_rashi = 0.0
            
        sthana_bala = sth_ex + sth_rashi
        
        # 2. Dik Bala
        if p in ['Sun', 'Mars']:
            dist = abs(house - 10)
            if dist > 6: dist = 12 - dist
            dik_bala = 60 * (1 - dist / 6.0)
        elif p in ['Moon', 'Venus']:
            dist = abs(house - 4)
            if dist > 6: dist = 12 - dist
            dik_bala = 60 * (1 - dist / 6.0)
        elif p in ['Mercury', 'Jupiter']:
            dist = abs(house - 1)
            if dist > 6: dist = 12 - dist
            dik_bala = 60 * (1 - dist / 6.0)
        else:
            dist = abs(house - 7)
            if dist > 6: dist = 12 - dist
            dik_bala = 60 * (1 - dist / 6.0)
            
        # 3. Kala Bala
        kala_bala = 0
        if is_day_birth:
            if p in ['Sun', 'Jupiter', 'Saturn']:
                kala_bala = 30
        else:
            if p in ['Moon', 'Mars', 'Venus']:
                kala_bala = 30
        if p == 'Mercury':
            kala_bala = 30
            
        # 4. Cheshta Bala
        cheshta_bala = 50 if is_retro else 10
        
        # 5. Naisargika Bala
        naisargika_bala = natural_strength[p]
        
        total_virupas = sthana_bala + dik_bala + kala_bala + cheshta_bala + naisargika_bala
        total_rupas = total_virupas / 60.0
        
        shad_bala_scores[p] = round(total_rupas, 2)
        
    sorted_planets = sorted(shad_bala_scores.items(), key=lambda x: x[1], reverse=True)
    ranks = {}
    for rank, (p, score) in enumerate(sorted_planets, 1):
        ranks[p] = rank
        
    p_abbrev = {
        'Sun': 'SU', 'Moon': 'MO', 'Mars': 'MA', 'Mercury': 'ME',
        'Jupiter': 'JU', 'Venus': 'VE', 'Saturn': 'SA'
    }
    
    shad_bala_result = []
    for p in planet_list:
        score = shad_bala_scores[p]
        rank = ranks[p]
        percentage = min(100.0, max(20.0, (score - 1.5) / 6.0 * 100.0))
        shad_bala_result.append({
            'planet': p_abbrev[p],
            'name': p,
            'score': score,
            'rank': rank,
            'percentage': round(percentage, 1)
        })
        
    # Bhav Bala
    bhav_bala_scores = {}
    for house in range(1, 13):
        rashi_num = (ascendant['rashi_num'] - 1 + house - 1) % 12 + 1
        lord_name = RASHI_LORDS[rashi_num - 1]
        lord_english = {
            'Mangal': 'Mars', 'Shukra': 'Venus', 'Budha': 'Mercury',
            'Chandra': 'Moon', 'Surya': 'Sun', 'Guru': 'Jupiter', 'Shani': 'Saturn'
        }[lord_name]
        
        lord_strength = shad_bala_scores[lord_english]
        score = lord_strength * 0.6
        
        lord_house = planets[lord_english]['house']
        if lord_house == house:
            score += 2.0
            
        for p in planet_list:
            if planets[p]['house'] == house:
                if p in ['Jupiter', 'Venus', 'Mercury', 'Moon']:
                    score += 1.5
                else:
                    score -= 0.8
                    
        if house in [1, 4, 7, 10]:
            score += 1.0
        elif house in [5, 9]:
            score += 0.8
        elif house in [6, 8, 12]:
            score -= 0.5
            
        bhav_bala_scores[house] = round(max(1.0, score), 2)
        
    sorted_houses = sorted(bhav_bala_scores.items(), key=lambda x: x[1], reverse=True)
    house_ranks = {}
    for rank, (h, score) in enumerate(sorted_houses, 1):
        house_ranks[h] = rank
        
    bhav_bala_result = []
    for house in range(1, 13):
        score = bhav_bala_scores[house]
        rank = house_ranks[house]
        percentage = min(100.0, max(20.0, (score - 1.0) / 7.0 * 100.0))
        bhav_bala_result.append({
            'house': house,
            'score': score,
            'rank': rank,
            'percentage': round(percentage, 1)
        })
        
    return {
        'shad_bala': shad_bala_result,
        'bhav_bala': bhav_bala_result
    }

def calculate_kundli(date, time, lat, lon, name, gender='Male'):
    jd = get_julian_day(date, time, lat, lon)
    
    # Lahiri (Traditional)
    planets = get_planets(jd, swe.SIDM_LAHIRI)
    ascendant = get_ascendant(jd, lat, lon, swe.SIDM_LAHIRI)
    house_positions = get_house_positions(planets, ascendant)
    
    # KP System
    kp_planets = get_planets(jd, swe.SIDM_KRISHNAMURTI)
    kp_ascendant = get_ascendant(jd, lat, lon, swe.SIDM_KRISHNAMURTI, b'P')
    
    # Navamsa (D9)
    navamsa = {}
    for pname, p in planets.items():
        navamsa[pname] = get_navamsa(p['longitude'])
    navamsa['Lagna'] = get_navamsa(ascendant['longitude'])
    
    # D1-D10 divisional charts
    shodashvarga = {
        'D1': get_divisional_chart(planets, ascendant, 1),
        'D2': get_divisional_chart(planets, ascendant, 2),
        'D3': get_divisional_chart(planets, ascendant, 3),
        'D4': get_divisional_chart(planets, ascendant, 4),
        'D7': get_divisional_chart(planets, ascendant, 7),
        'D9': get_divisional_chart(planets, ascendant, 9),
        'D10': get_divisional_chart(planets, ascendant, 10),
        'D12': get_divisional_chart(planets, ascendant, 12),
        'D16': get_divisional_chart(planets, ascendant, 16),
        'D20': get_divisional_chart(planets, ascendant, 20),
        'D24': get_divisional_chart(planets, ascendant, 24),
        'D27': get_divisional_chart(planets, ascendant, 27),
        'D30': get_divisional_chart(planets, ascendant, 30),
        'D40': get_divisional_chart(planets, ascendant, 40),
        'D45': get_divisional_chart(planets, ascendant, 45),
        'D60': get_divisional_chart(planets, ascendant, 60),
    }
    
    # Dashas
    dasha = get_vimshottari_dasha(planets, jd)
    
    # Yogas
    yogas = check_yogas(planets, ascendant, house_positions)
    
    # Doshas
    doshas = {
        'manglik': check_manglik(planets, ascendant, house_positions),
        'sade_sati': check_sade_sati(planets, jd),
        'kaal_sarp': check_kaal_sarp(planets)
    }
    
    # Lal Kitab
    lal_kitab = get_lal_kitab(planets, house_positions)
    
    # Numerology
    numerology = get_numerology(date)
    
    # Add house number to each planet
    for pname in planets:
        planets[pname]['house'] = house_positions.get(pname, 0)
        
    # KP house positions and KP lords/cusp details
    kp_house_positions = get_placidus_house_positions(kp_planets, kp_ascendant['cusps'])
    for pname in kp_planets:
        kp_planets[pname]['house'] = kp_house_positions.get(pname, 0)
        rashi_lord, nakshatra, nakshatra_lord, sub_lord, sub_sub_lord = get_kp_lords(kp_planets[pname]['longitude'])
        kp_planets[pname]['rashi_lord'] = rashi_lord
        kp_planets[pname]['nakshatra'] = nakshatra
        kp_planets[pname]['nakshatra_lord'] = nakshatra_lord
        kp_planets[pname]['sub_lord'] = sub_lord
        kp_planets[pname]['sub_sub_lord'] = sub_sub_lord

    # KP Ascendant itself specific lords
    asc_rashi_lord, asc_nakshatra, asc_nakshatra_lord, asc_sub_lord, asc_sub_sub_lord = get_kp_lords(kp_ascendant['longitude'])
    kp_ascendant['rashi_lord'] = asc_rashi_lord
    kp_ascendant['nakshatra'] = asc_nakshatra
    kp_ascendant['nakshatra_lord'] = asc_nakshatra_lord
    kp_ascendant['sub_lord'] = asc_sub_lord
    kp_ascendant['sub_sub_lord'] = asc_sub_sub_lord

    # KP Cusp details (12 houses)
    kp_cusps_details = []
    for i, cusp_lon in enumerate(kp_ascendant['cusps']):
        rashi_lord, nakshatra, nakshatra_lord, sub_lord, sub_sub_lord = get_kp_lords(cusp_lon)
        ri = int(cusp_lon / 30) % 12
        kp_cusps_details.append({
            'house': i + 1,
            'longitude': round(cusp_lon, 6),
            'rashi': RASHIS[ri],
            'degree': round(cusp_lon % 30, 4),
            'rashi_lord': rashi_lord,
            'nakshatra': nakshatra,
            'nakshatra_lord': nakshatra_lord,
            'sub_lord': sub_lord,
            'sub_sub_lord': sub_sub_lord
        })
    kp_ascendant['cusp_details'] = kp_cusps_details

    # House Significators (KP)
    house_significators, planet_significators = get_house_significators(kp_planets, kp_ascendant)
    
    # Ashtakvarga and Prastharashtakvarga
    ashtakvarga = calculate_ashtakvarga(planets, ascendant)
    
    # Shad Bala and Bhav Bala
    shad_bala_data = calculate_shad_bala(planets, ascendant)

    return {
        'name': name, 'date': date, 'time': time, 'lat': lat, 'lon': lon, 'gender': gender,
        'planets': planets, 'ascendant': ascendant, 'house_positions': house_positions,
        'kp_planets': kp_planets, 'kp_ascendant': kp_ascendant,
        'navamsa': navamsa, 'shodashvarga': shodashvarga,
        'dasha': dasha, 'yogas': yogas, 'doshas': doshas,
        'lal_kitab': lal_kitab, 'numerology': numerology, 'jd': jd,
        'house_significators': house_significators,
        'planet_significators': planet_significators,
        'ashtakvarga': ashtakvarga['sarvashtakavarga'],
        'prasthara_ashtakavarga': ashtakvarga['prasthara_ashtakavarga'],
        'shad_bala': shad_bala_data
    }
