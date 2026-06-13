import swisseph as swe
from timezonefinder import TimezoneFinder
import pytz
from datetime import datetime

RASHIS = ['Mesh','Vrishabh','Mithun','Kark','Singh',
          'Kanya','Tula','Vrischik','Dhanu','Makar',
          'Kumbh','Meen']

NAKSHATRAS = ['Ashwini','Bharani','Krittika','Rohini',
  'Mrigashira','Ardra','Punarvasu','Pushya','Ashlesha',
  'Magha','P.Phalguni','U.Phalguni','Hasta','Chitra',
  'Swati','Vishakha','Anuradha','Jyeshtha','Moola',
  'P.Ashadha','U.Ashadha','Shravana','Dhanishtha',
  'Shatabhisha','P.Bhadra','U.Bhadra','Revati']

# Correctly assigning lords as provided
NAKSHATRA_LORDS = [
    'Ketu', 'Shukra', 'Surya', 'Chandra', 'Mangal', 'Rahu', 'Guru', 'Shani', 'Budha',
    'Ketu', 'Shukra', 'Surya', 'Chandra', 'Mangal', 'Rahu', 'Guru', 'Shani', 'Budha',
    'Ketu', 'Shukra', 'Surya', 'Chandra', 'Mangal', 'Rahu', 'Guru', 'Shani', 'Budha'
]

RASHI_LORDS = [
    'Mangal', 'Shukra', 'Budha', 'Chandra', 'Surya', 'Budha',
    'Shukra', 'Mangal', 'Guru', 'Shani', 'Shani', 'Guru'
]

NAKSHATRA_SYLLABLES = [
    ['चू', 'चे', 'चो', 'ला'], ['ली', 'लू', 'ले', 'लो'], ['आ', 'ई', 'उ', 'ए'],
    ['ओ', 'वा', 'वी', 'वू'], ['वे', 'वो', 'का', 'की'], ['कू', 'घ', 'ङ', 'छ'],
    ['के', 'को', 'हा', 'ही'], ['हू', 'हे', 'हो', 'डा'], ['डी', 'डू', 'डे', 'डो'],
    ['मा', 'मी', 'मू', 'मे'], ['मो', 'टा', 'टी', 'टू'], ['टे', 'टो', 'पा', 'पी'],
    ['पू', 'ष', 'ण', 'ठ'], ['पे', 'पो', 'रा', 'री'], ['रू', 'रे', 'रो', 'ता'],
    ['ती', 'तू', 'ते', 'तो'], ['ना', 'नी', 'नू', 'ने'], ['नो', 'या', 'यी', 'यू'],
    ['ये', 'यो', 'भा', 'भी'], ['भू', 'धा', 'फा', 'ढा'], ['भे', 'भो', 'जा', 'जी'],
    ['खी', 'खू', 'खे', 'खो'], ['गा', 'गी', 'गू', 'गे'], ['गो', 'सा', 'सी', 'सू'],
    ['से', 'सो', 'दा', 'दी'], ['दू', 'थ', 'झ', 'ञ'], ['दे', 'दो', 'चा', 'ची']
]
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
        
    year = dt_utc.year
    month = dt_utc.month
    day = dt_utc.day
    hour = dt_utc.hour + dt_utc.minute/60.0
    jd = swe.julday(year, month, day, hour)
    return jd

def get_planets(jd):
    swe.set_sid_mode(swe.SIDM_LAHIRI)
    planets_data = {}
    
    planet_ids = {
        'Sun': swe.SUN,
        'Moon': swe.MOON,
        'Mars': swe.MARS,
        'Mercury': swe.MERCURY,
        'Jupiter': swe.JUPITER,
        'Venus': swe.VENUS,
        'Saturn': swe.SATURN,
        'Rahu': swe.MEAN_NODE
    }
    
    for name, pid in planet_ids.items():
        res, ret = swe.calc_ut(jd, pid, swe.FLG_SIDEREAL)
        lon = res[0]
        rashi_idx = int(lon / 30)
        nak_idx = int(lon / (360/27))
        nak_pada = int((lon % (360/27)) / (360/108)) + 1
        
        planets_data[name] = {
            'longitude': lon,
            'rashi': RASHIS[rashi_idx],
            'rashi_lord': RASHI_LORDS[rashi_idx],
            'degree': lon % 30,
            'nakshatra': NAKSHATRAS[nak_idx],
            'nakshatra_lord': NAKSHATRA_LORDS[nak_idx],
            'pada': nak_pada,
            'namakshar': NAKSHATRA_SYLLABLES[nak_idx][nak_pada - 1]
        }
    
    # Ketu is opposite to Rahu
    rahu_lon = planets_data['Rahu']['longitude']
    ketu_lon = (rahu_lon + 180) % 360
    rashi_idx = int(ketu_lon / 30)
    nak_idx = int(ketu_lon / (360/27))
    nak_pada = int((ketu_lon % (360/27)) / (360/108)) + 1
    
    planets_data['Ketu'] = {
        'longitude': ketu_lon,
        'rashi': RASHIS[rashi_idx],
        'rashi_lord': RASHI_LORDS[rashi_idx],
        'degree': ketu_lon % 30,
        'nakshatra': NAKSHATRAS[nak_idx],
        'nakshatra_lord': NAKSHATRA_LORDS[nak_idx],
        'pada': nak_pada,
        'namakshar': NAKSHATRA_SYLLABLES[nak_idx][nak_pada - 1]
    }
    
    return planets_data

def get_ascendant(jd, lat, lon):
    swe.set_sid_mode(swe.SIDM_LAHIRI)
    res = swe.houses_ex(jd, lat, lon, b'P', swe.FLG_SIDEREAL)
    asc_lon = res[0][0]
    rashi_idx = int(asc_lon / 30)
    nak_idx = int(asc_lon / (360/27))
    nak_pada = int((asc_lon % (360/27)) / (360/108)) + 1
    
    return {
        'longitude': asc_lon,
        'rashi': RASHIS[rashi_idx],
        'rashi_lord': RASHI_LORDS[rashi_idx],
        'degree': asc_lon % 30,
        'nakshatra': NAKSHATRAS[nak_idx],
        'nakshatra_lord': NAKSHATRA_LORDS[nak_idx],
        'pada': nak_pada,
        'namakshar': NAKSHATRA_SYLLABLES[nak_idx][nak_pada - 1]
    }

def calculate_kundli(date, time, lat, lon, name):
    jd = get_julian_day(date, time, lat, lon)
    planets = get_planets(jd)
    ascendant = get_ascendant(jd, lat, lon)
    return {"name": name, "planets": planets,
            "ascendant": ascendant, "jd": jd}
