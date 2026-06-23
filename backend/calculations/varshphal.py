import swisseph as swe
from timezonefinder import TimezoneFinder
import pytz
from datetime import datetime
from calculations.kundli import get_julian_day, get_planets, get_ascendant, get_house_positions, RASHIS, RASHI_LORDS

def jd_to_local_datetime(jd, lat, lon):
    year, month, day, hour_fraction = swe.revjul(jd, swe.GREG_CAL)
    hour = int(hour_fraction)
    minute_fraction = (hour_fraction - hour) * 60.0
    minute = int(minute_fraction)
    second = int((minute_fraction - minute) * 60.0)
    if second >= 60:
        second = 59
    utc_dt = datetime(year, month, day, hour, minute, second, tzinfo=pytz.utc)
    
    tf = TimezoneFinder()
    tz_name = tf.timezone_at(lng=lon, lat=lat)
    if tz_name:
        tz = pytz.timezone(tz_name)
        local_dt = utc_dt.astimezone(tz)
    else:
        local_dt = utc_dt
    return local_dt

def find_solar_return_jd(birth_jd, birth_sun_lon, target_year):
    dt = swe.revjul(birth_jd, swe.GREG_CAL)
    birth_year = dt[0]
    years_diff = target_year - birth_year
    
    approx_jd = birth_jd + years_diff * 365.242199
    
    def get_sun_lon(jd):
        swe.set_sid_mode(swe.SIDM_LAHIRI)
        res, _ = swe.calc_ut(jd, swe.SUN, swe.FLG_SIDEREAL)
        return res[0]
        
    jd_current = approx_jd
    for _ in range(15):
        lon_current = get_sun_lon(jd_current)
        diff = (lon_current - birth_sun_lon + 180) % 360 - 180
        if abs(diff) < 1e-6:
            break
        jd_current -= diff / 0.985647
    return jd_current

def calculate_varshphal(birth_date_str, birth_time_str, lat, lon, name, target_year, gender='Male'):
    birth_jd = get_julian_day(birth_date_str, birth_time_str, lat, lon)
    natal_planets = get_planets(birth_jd, swe.SIDM_LAHIRI)
    natal_ascendant = get_ascendant(birth_jd, lat, lon, swe.SIDM_LAHIRI)
    
    birth_sun_lon = natal_planets['Sun']['longitude']
    birth_year = datetime.strptime(birth_date_str, "%Y-%m-%d").year
    
    return_jd = find_solar_return_jd(birth_jd, birth_sun_lon, target_year)
    return_local_dt = jd_to_local_datetime(return_jd, lat, lon)
    
    varsha_planets = get_planets(return_jd, swe.SIDM_LAHIRI)
    varsha_ascendant = get_ascendant(return_jd, lat, lon, swe.SIDM_LAHIRI)
    varsha_house_positions = get_house_positions(varsha_planets, varsha_ascendant)
    
    for pname in varsha_planets:
        varsha_planets[pname]['house'] = varsha_house_positions.get(pname, 0)
        
    birth_lagna_rashi_num = natal_ascendant['rashi_num']
    age_in_years = target_year - birth_year
    muntha_rashi_num = (birth_lagna_rashi_num - 1 + age_in_years) % 12 + 1
    muntha_rashi_name = RASHIS[muntha_rashi_num - 1]
    muntha_rashi_lord = RASHI_LORDS[muntha_rashi_num - 1]
    
    varsha_lagna_rashi_num = varsha_ascendant['rashi_num']
    muntha_house = (muntha_rashi_num - varsha_lagna_rashi_num) % 12 + 1
    
    varsha_sun_house = varsha_house_positions.get('Sun', 1)
    is_day_return = varsha_sun_house in [7, 8, 9, 10, 11, 12]
    
    dina_ratri_lord = varsha_planets['Sun']['rashi_lord'] if is_day_return else varsha_planets['Moon']['rashi_lord']
    
    lord_translation = {
        'Mangal': 'Mars', 'Shukra': 'Venus', 'Budha': 'Mercury', 'Chandra': 'Moon',
        'Surya': 'Sun', 'Guru': 'Jupiter', 'Shani': 'Saturn'
    }
    
    def translate_lord(l):
        return lord_translation.get(l, l)
        
    varsha_lagna_lord = translate_lord(varsha_ascendant['rashi_lord'])
    birth_lagna_lord = translate_lord(natal_ascendant['rashi_lord'])
    muntha_lord = translate_lord(muntha_rashi_lord)
    dina_ratri_lord = translate_lord(dina_ratri_lord)
    patyamsa_lord = varsha_lagna_lord
    
    year_lord = varsha_lagna_lord
    for cand in [muntha_lord, dina_ratri_lord, birth_lagna_lord]:
        cand_house = varsha_house_positions.get(cand, 0)
        if cand_house in [1, 3, 4, 5, 7, 9, 10, 11]:
            year_lord = cand
            break
            
    predictions = []
    
    muntha_preds = {
        1: {
            'en': 'Muntha is in the 1st house. Excellent year for health, name, fame, and new initiatives. You will feel highly energetic and optimistic.',
            'hi': 'मुंथा प्रथम भाव में है। स्वास्थ्य, मान-सम्मान और नए कार्यों के लिए श्रेष्ठ वर्ष। आप ऊर्जावान महसूस करेंगे और नए अवसर मिलेंगे।'
        },
        2: {
            'en': 'Muntha is in the 2nd house. Financial growth, acquisition of wealth, domestic comfort, and sweet speech will mark this year.',
            'hi': 'मुंथा द्वितीय भाव में है। धन वृद्धि, आर्थिक लाभ, पारिवारिक सुख और वाणी के बल पर सफलता मिलने के सुंदर योग हैं।'
        },
        3: {
            'en': 'Muntha is in the 3rd house. Your courage will rise, siblings will support you, and short travels will bring beneficial outcomes.',
            'hi': 'मुंथा तृतीय भाव में है। पराक्रम और साहस में वृद्धि होगी, भाई-बहनों का सहयोग प्राप्त होगा, छोटी यात्राएं लाभकारी रहेंगी।'
        },
        4: {
            'en': 'Muntha is in the 4th house. Drive carefully. Focus on maintaining domestic harmony. Avoid property disputes and check on mother\'s health.',
            'hi': 'मुंथा चतुर्थ भाव में है। वाहन चलाते समय सावधानी रखें। पारिवारिक कलह से बचें और माता के स्वास्थ्य का विशेष ध्यान रखें।'
        },
        5: {
            'en': 'Muntha is in the 5th house. Highly auspicious for students, creativity, and children. Opportunities for sudden financial gains or investments.',
            'hi': 'मुंथा पंचम भाव में है। विद्यार्थियों, शिक्षा और संतान पक्ष के लिए बहुत अनुकूल समय है। अचानक आर्थिक लाभ की संभावना है।'
        },
        6: {
            'en': 'Muntha is in the 6th house. Pay attention to health, avoid unnecessary debts, and resolve conflicts peacefully. Enemies will try to create hurdles.',
            'hi': 'मुंथा छठे भाव में है। स्वास्थ्य के प्रति सचेत रहें, कर्ज लेन-देन से बचें और कानूनी विवादों से दूर रहने का प्रयास करें।'
        },
        7: {
            'en': 'Muntha is in the 7th house. Business partnerships require caution. Keep communication clear with your spouse. Avoid fatiguing travels.',
            'hi': 'मुंथा सप्तम भाव में है। साझेदारी के कार्यों में सावधानी बरतें। जीवनसाथी के साथ सामंजस्य बनाए रखें, यात्राओं में थकावट रह सकती है।'
        },
        8: {
            'en': 'Muntha is in the 8th house. Challenging year. Be cautious regarding health, unexpected expenses, and avoid speculative risks.',
            'hi': 'मुंथा अष्टम भाव में है। स्वास्थ्य के प्रति अतिरिक्त सावधानी रखें, अचानक खर्चों की अधिकता रहेगी, जोखिम भरे निवेशों से दूर रहें।'
        },
        9: {
            'en': 'Muntha is in the 9th house. Fortune is on your side. Long-distance travels, spiritual interests, and guidance from mentors will bring joy.',
            'hi': 'मुंथा नवम भाव में है। भाग्य का भरपूर सहयोग मिलेगा। धार्मिक यात्राएं, गुरुजनों का आशीर्वाद और अध्यात्म में रुचि बढ़ेगी।'
        },
        10: {
            'en': 'Muntha is in the 10th house. Superb year for career. Promotion, recognition from superiors, professional growth, and new status are indicated.',
            'hi': 'मुंथा दशम भाव में है। करियर के लिए उत्तम वर्ष। पदोन्नति, अधिकारियों से सहयोग, व्यापार में विस्तार और प्रतिष्ठा में वृद्धि होगी।'
        },
        11: {
            'en': 'Muntha is in the 11th house. Great financial gains, expansion of social circle, fulfillment of long-held desires, and profits from business.',
            'hi': 'मुंथा एकादश भाव में है। शानदार धन लाभ, सामाजिक दायरा बढ़ेगा, महत्वाकांक्षाओं की पूर्ति होगी और आय के नए स्रोत बनेंगे।'
        },
        12: {
            'en': 'Muntha is in the 12th house. Expenses could be high. Guard your health, stay away from useless travels, and practice spiritual meditation.',
            'hi': 'मुंथा द्वादश भाव में है। अत्यधिक खर्चों से बजट प्रभावित हो सकता है। स्वास्थ्य का ध्यान रखें और व्यर्थ की यात्राओं से बचें।'
        }
    }
    
    m_p = muntha_preds.get(muntha_house, {
        'en': 'Muntha placement indicates a mixed period with balanced outcomes.',
        'hi': 'मुंथा की स्थिति मध्यम फल देने वाली है, मिश्रित परिणाम प्राप्त होंगे।'
    })
    predictions.append({
        'title_en': f'Muntha in House {muntha_house} Analysis',
        'title_hi': f'मुंथा भाव {muntha_house} का फल',
        'desc_en': m_p['en'],
        'desc_hi': m_p['hi']
    })
    
    lagna_preds = {
        'Mesh': {
            'en': 'Aries Varsha Lagna: A dynamic year filled with new goals. Watch your temper and avoid impulsive career changes.',
            'hi': 'मेष वर्ष लग्न: नए लक्ष्यों से भरा गतिशील वर्ष। अपने गुस्से पर नियंत्रण रखें और जल्दबाजी में करियर संबंधी निर्णय न लें।'
        },
        'Vrishabh': {
            'en': 'Taurus Varsha Lagna: Steady growth in finance. Family comforts will improve. Focus on steady efforts.',
            'hi': 'वृषभ वर्ष लग्न: आर्थिक मामलों में क्रमिक सुधार। पारिवारिक सुख-सुविधाओं में वृद्धि। धैर्य के साथ काम करें।'
        },
        'Mithun': {
            'en': 'Gemini Varsha Lagna: Favorable for communications, media, and learning. Excellent year for networking.',
            'hi': 'मिथुन वर्ष लग्न: संचार, लेखन और विद्या के लिए अनुकूल। नए लोगों से संपर्क बढ़ाने के लिए बहुत अच्छा वर्ष।'
        },
        'Kark': {
            'en': 'Cancer Varsha Lagna: Family and domestic life will take center stage. Pay attention to emotional well-being.',
            'hi': 'कर्क वर्ष लग्न: पारिवारिक और घरेलू जीवन मुख्य केंद्र रहेगा। मानसिक शांति और स्वास्थ्य पर ध्यान दें।'
        },
        'Singh': {
            'en': 'Leo Varsha Lagna: You will rise in status. Good support from government authorities. Focus on leadership opportunities.',
            'hi': 'सिंह वर्ष लग्न: सामाजिक प्रतिष्ठा में वृद्धि होगी। सरकारी क्षेत्र से लाभ। नेतृत्व करने के अवसर मिलेंगे।'
        },
        'Kanya': {
            'en': 'Virgo Varsha Lagna: Focus on details, service, and resolving conflicts. Old health issues will heal.',
            'hi': 'कन्या वर्ष लग्न: बारीकियों, सेवा और पुराने विवादों को सुलझाने पर ध्यान रहेगा। स्वास्थ्य में सुधार होगा।'
        },
        'Tula': {
            'en': 'Libra Varsha Lagna: Marriage, partnership, and social engagements will bring happiness. Good period for harmony.',
            'hi': 'तुला वर्ष लग्न: विवाह, साझेदारी और सामाजिक उत्सवों से प्रसन्नता। संबंधों में मधुरता रहेगी।'
        },
        'Vrischik': {
            'en': 'Scorpio Varsha Lagna: Year of deep transition, intuition, and research. Avoid secrecy and resolve doubts.',
            'hi': 'वृश्चिक वर्ष लग्न: गहन बदलाव, अंतर्ज्ञान और अनुसंधान का वर्ष। संशय से बचें और स्पष्ट रहें।'
        },
        'Dhanu': {
            'en': 'Sagittarius Varsha Lagna: Spiritual, travel-oriented, and lucky year. You will find supportive guides.',
            'hi': 'धनु वर्ष लग्न: आध्यात्मिक उन्नति, शुभ यात्राएं और भाग्य का साथ। गुरुओं का मार्गदर्शन फलदायी होगा।'
        },
        'Makar': {
            'en': 'Capricorn Varsha Lagna: Demands hard work and persistent efforts. Success will come through patience and structure.',
            'hi': 'मकर वर्ष लग्न: कठिन परिश्रम का समय, कार्यक्षेत्र में जिम्मेदारी बढ़ेगा, धीमी किंतु स्थिर प्रगति।'
        },
        'Kumbh': {
            'en': 'Aquarius Varsha Lagna: High gains, fulfillment of financial desires, and group success. Technology benefits.',
            'hi': 'कुंभ वर्ष लग्न: प्रचुर लाभ, आर्थिक आकांक्षाओं की पूर्ति और मित्रों का सहयोग। तकनीक से लाभ।'
        },
        'Meen': {
            'en': 'Pisces Varsha Lagna: Excellent for foreign travel, hospital recovery, and charity work. Practice meditation.',
            'hi': 'मीन वर्ष लग्न: विदेश यात्रा, धार्मिक कार्यों और दान-पुण्य के लिए उत्कृष्ट वर्ष। ध्यान व योग अपनाएं।'
        }
    }
    
    l_p = lagna_preds.get(varsha_ascendant['rashi'], {
        'en': 'The Varsha Lagna suggests a balanced year with standard progress.',
        'hi': 'वर्ष लग्न आपके जीवन में सामान्य और संतुलित प्रगति को दर्शाता है।'
    })
    predictions.append({
        'title_en': f'Varsha Lagna ({varsha_ascendant["rashi"]}) Outlook',
        'title_hi': f'वर्ष लग्न ({varsha_ascendant["rashi"]}) का फलादेश',
        'desc_en': l_p['en'],
        'desc_hi': l_p['hi']
    })
    
    yl_preds = {
        'Sun': {
            'en': 'Sun is the Year Lord. Blesses you with professional authority, public respect, and high energy. Focus on your goals.',
            'hi': 'सूर्य वर्षेश है। यह आपको कार्यक्षेत्र में अधिकार, सामाजिक प्रतिष्ठा और प्रचुर ऊर्जा प्रदान करेगा। लक्ष्यों के प्रति समर्पित रहें।'
        },
        'Moon': {
            'en': 'Moon is the Year Lord. Emotional peace, support from females, travel near water bodies, and creativity are highlighted.',
            'hi': 'चंद्रमा वर्षेश है। मानसिक शांति, महिलाओं से सहयोग, जल यात्राओं के योग और रचनात्मक कार्यों में सफलता मिलेगी।'
        },
        'Mars': {
            'en': 'Mars is the Year Lord. Fills you with courage, victory over opponents, and land-property gains. Control impulsiveness.',
            'hi': 'मंगल वर्षेश है। यह आपको साहस, विरोधियों पर विजय और भूमि-भवन से लाभ देगा। क्रोध और जल्दबाजी पर संयम रखें।'
        },
        'Mercury': {
            'en': 'Mercury is the Year Lord. Brilliant for trade, education, writing, and communication. New financial skills will be learned.',
            'hi': 'बुध वर्षेश है। व्यापार, शिक्षा, लेखन और संचार के कार्यों के लिए श्रेष्ठ समय। व्यापारिक योजनाओं में सफलता मिलेगी।'
        },
        'Jupiter': {
            'en': 'Jupiter is the Year Lord. Most auspicious placement. Blesses you with wisdom, marital harmony, birth in family, and luck.',
            'hi': 'गुरु वर्षेश है। सबसे शुभ समय। ज्ञान में वृद्धि, दांपत्य जीवन में मधुरता, परिवार में मांगलिक कार्य और भाग्य उदय होगा।'
        },
        'Venus': {
            'en': 'Venus is the Year Lord. Brings comfort, romance, luxury items, vehicle purchase, and success in creative arts.',
            'hi': 'शुक्र वर्षेश है। यह सुख-सुविधाओं, प्रेम संबंधों, वाहन या आभूषण की खरीद और कला के क्षेत्र में सफलता प्रदान करेगा।'
        },
        'Saturn': {
            'en': 'Saturn is the Year Lord. Teaches patience, discipline, and hard work. Success will be delayed but highly stable and permanent.',
            'hi': 'शनि वर्षेश है। यह आपको धैर्य, अनुशासन और कठिन परिश्रम सिखाएगा। सफलता थोड़ी देरी से मिलेगी लेकिन चिरस्थायी होगी।'
        }
    }
    
    y_p = yl_preds.get(year_lord, {
        'en': 'The Year Lord placement promises steady growth and protection.',
        'hi': 'वर्षेश की स्थिति आपके जीवन में स्थिर प्रगति और सुरक्षा का आश्वासन देती है।'
    })
    predictions.append({
        'title_en': f'Year Lord ({year_lord}) Influence',
        'title_hi': f'वर्षेश ({year_lord}) का प्रभाव',
        'desc_en': y_p['en'],
        'desc_hi': y_p['hi']
    })
    
    health_ok = 'favorable' if muntha_house in [1, 2, 3, 5, 9, 10, 11] else 'demanding care'
    career_ok = 'excellent' if muntha_house in [1, 10, 11] or year_lord in ['Sun', 'Jupiter', 'Mercury'] else 'stable with challenges'
    
    if health_ok == 'favorable':
        h_en = 'Your physical health will remain robust. Vitality will be high.'
        h_hi = 'आपका शारीरिक स्वास्थ्य उत्तम रहेगा। रोग प्रतिरोधक क्षमता बढ़ेगी।'
    else:
        h_en = 'Pay attention to dietary habits and physical exhaustion. Minor illness needs prompt care.'
        h_hi = 'खान-पान का विशेष ध्यान रखें और अत्यधिक परिश्रम से बचें। छोटी बीमारियों में भी डॉक्टर की सलाह लें।'
        
    if career_ok == 'excellent':
        c_en = 'Professional opportunities will match your ambition. Promotions or business expansion are likely.'
        c_hi = 'व्यावसायिक अवसर आपकी महत्वाकांक्षाओं के अनुरूप होंगे। पदोन्नति या व्यवसाय में विस्तार संभव है।'
    else:
        c_en = 'Maintain steady effort. Avoid major risks or disputes with superiors. Success will come through consistency.'
        c_hi = 'निरंतर प्रयास जारी रखें। कार्यस्थल पर सहकर्मियों या वरिष्ठों से विवादों से बचें। सफलता संयम से ही संभव है।'
        
    predictions.append({
        'title_en': 'Annual Health Overview',
        'title_hi': 'वार्षिक स्वास्थ्य फलादेश',
        'desc_en': h_en,
        'desc_hi': h_hi
    })
    predictions.append({
        'title_en': 'Annual Career & Wealth Overview',
        'title_hi': 'वार्षिक करियर और आर्थिक फलादेश',
        'desc_en': c_en,
        'desc_hi': c_hi
    })
    
    varsha_local_time_str = return_local_dt.strftime("%Y-%m-%d %I:%M %p")
    
    return {
        'target_year': target_year,
        'birth_year': birth_year,
        'age': age_in_years,
        'varsha_time': varsha_local_time_str,
        'muntha_rashi': muntha_rashi_name,
        'muntha_rashi_lord': muntha_rashi_lord,
        'muntha_house': muntha_house,
        'year_lord': year_lord,
        'varsha_lagna': {
            'rashi': varsha_ascendant['rashi'],
            'rashi_lord': varsha_ascendant['rashi_lord'],
            'degree': varsha_ascendant['degree'],
            'longitude': varsha_ascendant['longitude'],
            'nakshatra': varsha_ascendant['nakshatra'],
            'nakshatra_lord': varsha_ascendant['nakshatra_lord'],
            'pada': varsha_ascendant['pada']
        },
        'panchadhikari': {
            'varsha_lagna_lord': varsha_lagna_lord,
            'birth_lagna_lord': birth_lagna_lord,
            'muntha_lord': muntha_lord,
            'dina_ratri_lord': dina_ratri_lord,
            'patyamsa_lord': patyamsa_lord
        },
        'planets': varsha_planets,
        'predictions': predictions
    }
