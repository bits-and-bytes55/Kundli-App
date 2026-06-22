import swisseph as swe
from datetime import datetime, timedelta

RASHIS = ['Mesh','Vrishabh','Mithun','Kark','Singh','Kanya','Tula','Vrischik','Dhanu','Makar','Kumbh','Meen']

SAVYA_SIGNS = {1, 2, 3, 7, 8, 9}  # Aries, Taurus, Gemini, Libra, Scorpio, Sagittarius
APASAVYA_SIGNS = {4, 5, 6, 10, 11, 12}  # Cancer, Leo, Virgo, Capricorn, Aquarius, Pisces

# Standard lords for Char Dasha duration calculations (1-indexed rashi)
STANDARD_LORDS = {
    1: 'Mars',      # Aries -> Mars
    2: 'Venus',     # Taurus -> Venus
    3: 'Mercury',   # Gemini -> Mercury
    4: 'Moon',      # Cancer -> Moon
    5: 'Sun',       # Leo -> Sun
    6: 'Mercury',   # Virgo -> Mercury
    7: 'Venus',     # Libra -> Venus
    8: 'Mars',      # Scorpio -> Mars / Ketu
    9: 'Jupiter',   # Sagittarius -> Jupiter
    10: 'Saturn',   # Capricorn -> Saturn
    11: 'Saturn',   # Aquarius -> Saturn / Rahu
    12: 'Jupiter'    # Pisces -> Jupiter
}

def get_scorpio_lord_pos(planets):
    mars_rashi = planets['Mars']['rashi_num']
    ketu_rashi = planets['Ketu']['rashi_num']
    if ketu_rashi == 8 and mars_rashi != 8:
        return ketu_rashi
    return mars_rashi

def get_aquarius_lord_pos(planets):
    saturn_rashi = planets['Saturn']['rashi_num']
    rahu_rashi = planets['Rahu']['rashi_num']
    if rahu_rashi == 11 and saturn_rashi != 11:
        return rahu_rashi
    return saturn_rashi

def calculate_sign_years(sign, lord_pos):
    # sign: 1-12, lord_pos: 1-12
    if sign in SAVYA_SIGNS:
        # Count forward
        dist = (lord_pos - sign) % 12 + 1
    else:
        # Count backward
        dist = (sign - lord_pos) % 12 + 1
        
    if dist == 1:
        if sign in [8, 11]:  # Scorpio or Aquarius exception for 0 years
            return 0
        return 12
    return dist - 1

def calculate_chara_dasha(planets, ascendant, jd):
    lagna_rashi_num = ascendant['rashi_num']
    
    # 9th house from Lagna: (lagna_rashi_num + 8 - 1) % 12 + 1
    ninth_house_rashi = (lagna_rashi_num + 8 - 1) % 12 + 1
    
    # Determine the order of signs
    if ninth_house_rashi in SAVYA_SIGNS:
        # Direct sequence
        sign_nums = [(lagna_rashi_num + i - 1) % 12 + 1 for i in range(12)]
    else:
        # Reverse sequence
        sign_nums = [(lagna_rashi_num - i - 1) % 12 + 1 for i in range(12)]
        
    # Get Julian Day to datetime
    dt = swe.revjul(jd, swe.GREG_CAL)
    birth_year = dt[0] + (jd - swe.julday(dt[0], dt[1], dt[2], 0)) / 365.25
    
    dasha_order_names = [RASHIS[num - 1] for num in sign_nums]
    
    chara_dashas = []
    current_year = birth_year
    
    # Generate 1 cycle of Char Dasha (12 signs)
    for sign_num in sign_nums:
        sign_name = RASHIS[sign_num - 1]
        
        # Determine lord position
        if sign_num == 8:
            lord_pos = get_scorpio_lord_pos(planets)
        elif sign_num == 11:
            lord_pos = get_aquarius_lord_pos(planets)
        else:
            lord_planet = STANDARD_LORDS[sign_num]
            lord_pos = planets[lord_planet]['rashi_num']
            
        years = calculate_sign_years(sign_num, lord_pos)
        end_year = current_year + years
        
        # Antardashas: 12 sub-periods, each of duration = years / 12
        # Starts from the sign next to the Mahadasha sign in the dasha order, ends with the Mahadasha sign.
        antars = []
        if years > 0:
            idx = dasha_order_names.index(sign_name)
            # Circular shift: start from index + 1
            antar_names = dasha_order_names[idx+1:] + dasha_order_names[:idx+1]
            antar_duration = years / 12.0
            antar_start = current_year
            for a_name in antar_names:
                a_end = antar_start + antar_duration
                antars.append({
                    'name': a_name,
                    'start_year': round(antar_start, 3),
                    'end_year': round(a_end, 3)
                })
                antar_start = a_end
                
        chara_dashas.append({
            'sign': sign_name,
            'years': years,
            'start_year': round(current_year, 3),
            'end_year': round(end_year, 3),
            'antars': antars
        })
        current_year = end_year
        
    return chara_dashas

def calculate_yogini_dasha(planets, jd):
    moon_lon = planets['Moon']['longitude']
    nak_idx = int(moon_lon / (360/27))
    nak_num = nak_idx + 1
    
    start_idx = (nak_num + 3) % 8
    # remainder 1 -> Mangala, ..., 0 -> Sankata
    idx = (start_idx - 1) % 8
    
    nak_deg = moon_lon % (360/27)
    nak_fraction_elapsed = nak_deg / (360/27)
    
    yogini_names = ["Mangala", "Pingala", "Dhanya", "Bhramari", "Bhadrika", "Ulka", "Siddha", "Sankata"]
    yogini_hindi = ["मंगला", "पिङ्गला", "धान्या", "भ्रामरी", "भद्रिका", "उल्का", "सिद्धा", "संकटा"]
    yogini_years = [1, 2, 3, 4, 5, 6, 7, 8]
    
    start_yogini_years = yogini_years[idx]
    balance_years = start_yogini_years * (1 - nak_fraction_elapsed)
    
    dt = swe.revjul(jd, swe.GREG_CAL)
    birth_year = dt[0] + (jd - swe.julday(dt[0], dt[1], dt[2], 0)) / 365.25
    
    yoginis_list = []
    current_year = birth_year
    
    # Generate 3 cycles of 36 years to cover a lifetime (~108 years)
    for cycle in range(3):
        for step in range(8):
            curr_idx = (idx + step) % 8
            name = yogini_names[curr_idx]
            hindi = yogini_hindi[curr_idx]
            years = balance_years if (cycle == 0 and step == 0) else yogini_years[curr_idx]
            end_year = current_year + years
            
            # Antardashas: 8 sub-periods
            antars = []
            if years > 0:
                antar_start = current_year
                for a_step in range(8):
                    a_idx = (curr_idx + a_step) % 8
                    a_years = (yogini_years[curr_idx] * yogini_years[a_idx]) / 36.0
                    if cycle == 0 and step == 0:
                        a_years = balance_years * yogini_years[a_idx] / yogini_years[curr_idx]
                    a_end = antar_start + a_years
                    antars.append({
                        "name": yogini_names[a_idx],
                        "hindi": yogini_hindi[a_idx],
                        "start_year": round(antar_start, 3),
                        "end_year": round(a_end, 3)
                    })
                    antar_start = a_end
                    
            yoginis_list.append({
                "name": name,
                "hindi": hindi,
                "start_year": round(current_year, 3),
                "end_year": round(end_year, 3),
                "duration_years": round(years, 2),
                "antars": antars
            })
            current_year = end_year
            if cycle == 0 and step == 0:
                balance_years = 0
                
    return yoginis_list

# Detailed Predictions for the 9 Maha Dashas based on planet placements in houses
MAHADASHA_HOUSE_PREDICTIONS = {
    'Ketu': {
        1: "Ketu in the 1st House brings spiritual inclination, deep intuition, and a search for self-identity. You may seek solitude and feel detached from worldly pleasures during this dasha.",
        2: "Ketu in the 2nd House can bring fluctuations in speech and finances. Focus on speaking gently and managing your resources wisely to avoid unexpected expenses.",
        3: "Ketu in the 3rd House enhances courage, determination, and spiritual growth. Short journeys will bring deep inner insights and strengthen your mind.",
        4: "Ketu in the 4th House focus is on domestic peace and inner happiness. You may lean towards spiritual home settings or feel a temporary disconnect from family dynamics.",
        5: "Ketu in the 5th House activates creative and spiritual wisdom. Deep interest in mantras, ancient sciences, or meditation will bring excellent focus.",
        6: "Ketu in the 6th House helps you overcome opponents and health issues through spiritual discipline. Your immunity will be strong, and problems will resolve smoothly.",
        7: "Ketu in the 7th House highlights spiritual connections in partnerships. Relationships may require extra patience, understanding, and selfless care.",
        8: "Ketu in the 8th House brings research capabilities, interest in occult sciences, and transformation. You will dive deep into mystical studies and emerge wiser.",
        9: "Ketu in the 9th House brings a strong inclination towards religious journeys and higher spiritual knowledge. You will seek a higher truth and wisdom.",
        10: "Ketu in the 10th House indicates a path of selfless actions in career. You might prefer working in fields related to healing, research, or spirituality.",
        11: "Ketu in the 11th House brings gains through unexpected spiritual resources. Social networks will be limited but meaningful and supportive.",
        12: "Ketu in the 12th House is a highly spiritual placement. It brings dreams of higher realms, interest in liberation (Moksha), and peaceful sleep."
    },
    'Venus': {
        1: "Venus in the 1st House blesses you with charm, attractive personality, and a love for arts. You will focus on self-care, grooming, and luxury during this dasha.",
        2: "Venus in the 2nd House brings financial prosperity, sweet speech, and family harmony. You will enjoy good food and accumulate wealth easily.",
        3: "Venus in the 3rd House brings artistic communication, sweet relations with siblings, and pleasant journeys. Artistic writing or hobbies will flourish.",
        4: "Venus in the 4th House brings comfort, vehicles, beautiful home surroundings, and mother's love. You will buy luxury items for your residence.",
        5: "Venus in the 5th House enhances romance, creativity, and intellect. You will enjoy creative expression and have sweet relationships.",
        6: "Venus in the 6th House indicates success in dealing with minor daily hurdles through diplomacy and charm. Maintain a healthy lifestyle.",
        7: "Venus in the 7th House indicates a very harmonious period for marriage and partnerships. You will enjoy companionship and mutual support.",
        8: "Venus in the 8th House brings sudden financial gains, deep emotional bonds, and interest in hidden mysteries. Inheritances may bring benefits.",
        9: "Venus in the 9th House indicates long-distance travel, spiritual grace, and luck. You will meet wise mentors and enjoy visiting beautiful places.",
        10: "Venus in the 10th House brings professional fame, cooperative colleagues, and success in arts, design, or luxury business fields.",
        11: "Venus in the 11th House brings a large, supportive social circle and multi-fold financial gains. Desires and wishes will be easily fulfilled.",
        12: "Venus in the 12th House brings comfort, foreign journeys, and a love for luxury and spiritual solitude. Expenses on comfort will rise."
    },
    'Sun': {
        1: "Sun in the 1st House brings leadership qualities, self-confidence, and a strong sense of purpose. You will focus on building your social status and health.",
        2: "Sun in the 2nd House highlights financial management and authoritative speech. Speak clearly and maintain focus on family wealth accumulation.",
        3: "Sun in the 3rd House brings courage, initiative, and administrative success. Short travels will bring recognition and new opportunities.",
        4: "Sun in the 4th House focuses on family values, property management, and domestic authority. You will work hard to secure your household comforts.",
        5: "Sun in the 5th House enhances intelligence, leadership in creative fields, and education. You will take bold steps in your studies or projects.",
        6: "Sun in the 6th House brings victory over enemies, strong health, and success in competitive exams. You will perform duties with high dedication.",
        7: "Sun in the 7th House focuses on business partnerships and relationships. Working collaboratively and managing authority gracefully will bring success.",
        8: "Sun in the 8th House brings interest in research, sudden inheritance or wealth, and deep personal transformations. Avoid unnecessary arguments.",
        9: "Sun in the 9th House brings spiritual wisdom, favors from elders and father figures, and interest in philosophy. Long travels will be highly beneficial.",
        10: "Sun in the 10th House brings high career success, power, recognition from government or authority, and leadership positions at work.",
        11: "Sun in the 11th House brings influential friends, high financial gains, and fulfillment of ambitions. You will lead social groups successfully.",
        12: "Sun in the 12th House indicates spiritual solitude, foreign travel, and expenses on charitable causes. Focus on inner peace and meditation."
    },
    'Moon': {
        1: "Moon in the 1st House brings a sensitive, caring, and intuitive nature. You will focus on mental peace, home comfort, and personal wellness.",
        2: "Moon in the 2nd House brings emotional connection to family and wealth. Financial stability will be achieved through intuitive decisions.",
        3: "Moon in the 3rd House brings creative writing, emotional expressions, and frequent pleasant travels. Relations with neighbors and siblings will improve.",
        4: "Moon in the 4th House brings deep peace, mother's love, vehicle comfort, and home renovation. You will feel highly secure at home.",
        5: "Moon in the 5th House brings sharp intelligence, interest in fine arts, and a loving connection with children and creative projects.",
        6: "Moon in the 6th House highlights daily health, service, and emotional balance. Take care of diet and stay active to maintain fitness.",
        7: "Moon in the 7th House indicates sweet, cooperative relationships and partnership gains. You will enjoy a warm social life.",
        8: "Moon in the 8th House brings strong intuition, interest in mysticism, and emotional depth. Research-oriented work will yield good results.",
        9: "Moon in the 9th House brings spiritual inclinations, interest in higher studies, and lucky opportunities through long-distance journeys.",
        10: "Moon in the 10th House brings public fame, public relations success, and a caring, supportive atmosphere in your profession.",
        11: "Moon in the 11th House brings friendly social circles, gains from female friends or relatives, and fulfillment of emotional desires.",
        12: "Moon in the 12th House brings active dreams, travel to foreign places, and spiritual retreat. Spend time in meditation for inner clarity."
    },
    'Mars': {
        1: "Mars in the 1st House brings high energy, drive, and enthusiasm. You will be highly active, competitive, and focus on physical fitness.",
        2: "Mars in the 2nd House highlights energetic speech and focus on wealth creation. Manage food habits and speech to maintain harmony.",
        3: "Mars in the 3rd House brings immense courage, technical skills, and sports success. You will take bold decisions and initiate new projects.",
        4: "Mars in the 4th House focuses energy on home construction, real estate, and land. Stay patient in domestic discussions to ensure peace.",
        5: "Mars in the 5th House brings dynamic creativity, interest in sports, and analytical intelligence. You will participate in competitive studies.",
        6: "Mars in the 6th House makes you highly competitive. You will resolve debts, win disputes, and overcome health obstacles easily.",
        7: "Mars in the 7th House indicates high energy in partnerships. Business collaborations will require clarity, prompt action, and teamwork.",
        8: "Mars in the 8th House brings research interest, sudden changes, and exploration of occult secrets. Focus on safe travels.",
        9: "Mars in the 9th House brings courage in spiritual fields, travel, and adventure. You will actively support philosophical causes.",
        10: "Mars in the 10th House brings high executive authority, professional success, and leadership in engineering, defense, or management.",
        11: "Mars in the 11th House brings gains through team work, active networking, and fulfillment of financial goals through hard work.",
        12: "Mars in the 12th House indicates foreign connections, active dream state, and expenses on useful projects. Regular exercise will help channel energy."
    },
    'Rahu': {
        1: "Rahu in the 1st House makes you ambitious, unique, and focused on personal identity. You will explore new paths and seek unconventional success.",
        2: "Rahu in the 2nd House brings a strong desire for financial growth and unique speech patterns. Focus on careful resource planning.",
        3: "Rahu in the 3rd House brings excellent communication, technical skills, and success in media or internet-based projects.",
        4: "Rahu in the 4th House focuses on buying modern homes or vehicles. You will seek innovative ways to improve your domestic environment.",
        5: "Rahu in the 5th House activates unconventional intelligence, speculative gains, and deep interest in digital media or new sciences.",
        6: "Rahu in the 6th House brings success in legal matters, service, and daily work. You will handle complicated situations with ease.",
        7: "Rahu in the 7th House indicates unique or foreign partnerships. Collaboration and clear communication will ensure business growth.",
        8: "Rahu in the 8th House brings interest in hidden research, mystical secrets, and sudden changes. Meditation will bring high clarity.",
        9: "Rahu in the 9th House indicates travel to faraway or foreign lands, interest in foreign philosophies, and out-of-the-box spiritual ideas.",
        10: "Rahu in the 10th House brings sudden career rises, public influence, and success in modern fields like IT, media, or consulting.",
        11: "Rahu in the 11th House brings large networks, sudden wealth gains, and helpful connections with foreign or high-status people.",
        12: "Rahu in the 12th House indicates foreign journeys, spiritual isolation, active imagination, and expenditures on modern comforts."
    },
    'Jupiter': {
        1: "Jupiter in the 1st House blesses you with optimism, wisdom, and good health. You will act as a guide or mentor and enjoy peace.",
        2: "Jupiter in the 2nd House brings stable wealth, sweet and wise speech, and happy family life. Education and banking bring benefits.",
        3: "Jupiter in the 3rd House brings positive communication, helpful siblings, and pleasant travels that expand your spiritual knowledge.",
        4: "Jupiter in the 4th House brings a happy home environment, blessings from mother, spacious property, and high domestic comfort.",
        5: "Jupiter in the 5th House enhances intelligence, wisdom, education, and children's growth. Speculative investments bring good returns.",
        6: "Jupiter in the 6th House resolves disputes peacefully. You will offer counseling or help to others and maintain good physical health.",
        7: "Jupiter in the 7th House indicates a wise, supportive partner and highly ethical business collaborations. Public relations will be excellent.",
        8: "Jupiter in the 8th House brings long life, inheritance, deep research capabilities, and interest in yoga, astrology, and mysticism.",
        9: "Jupiter in the 9th House is highly auspicious. It brings divine grace, high education, pilgrimage, and support from noble mentors.",
        10: "Jupiter in the 10th House brings respect in career, professional authority, success in education, judiciary, or counseling roles.",
        11: "Jupiter in the 11th House brings multiple streams of income, wise friends, and easy fulfillment of major life goals.",
        12: "Jupiter in the 12th House indicates a deeply spiritual nature, foreign travel, charitable expenditures, and peaceful sleep."
    },
    'Saturn': {
        1: "Saturn in the 1st House brings discipline, patience, and a mature outlook on life. Success will come through hard work and consistency.",
        2: "Saturn in the 2nd House emphasizes family duties, careful speech, and long-term financial planning. Savings will grow slowly.",
        3: "Saturn in the 3rd House brings high determination, technical skills, and victory over challenges. Journeys require planning but bring success.",
        4: "Saturn in the 4th House focuses on land, property, and building a secure home. You will carry major family responsibilities diligently.",
        5: "Saturn in the 5th House brings deep, analytical learning, focus on technical education, and careful planning of creative projects.",
        6: "Saturn in the 6th House brings victory in competitive exams, stable daily service, and resolution of debts through discipline.",
        7: "Saturn in the 7th House indicates stable, long-term partnerships and serious commitments. Business alliances will grow slowly but securely.",
        8: "Saturn in the 8th House brings long life, inheritance benefits, research success, and deep interest in archaeology or secret sciences.",
        9: "Saturn in the 9th House indicates interest in traditional values, philosophy, and long educational journeys. Success comes through hard work.",
        10: "Saturn in the 10th House brings career stability, power, high executive status, and success in governance, industries, or administration.",
        11: "Saturn in the 11th House brings steady, long-term financial gains, reliable elder friends, and slow but sure fulfillment of desires.",
        12: "Saturn in the 12th House indicates spiritual maturity, foreign connections, and expenditures on useful long-term investments."
    },
    'Mercury': {
        1: "Mercury in the 1st House makes you talkative, intelligent, youthful, and quick-witted. You will focus on learning and communication.",
        2: "Mercury in the 2nd House brings excellent finance management, sweet speech, and success in business, writing, or accounts.",
        3: "Mercury in the 3rd House brings pleasant writing, media success, close ties with siblings, and frequent short learning travels.",
        4: "Mercury in the 4th House brings happy domestic discussions, comfortable vehicles, education success, and buying books/gadgets.",
        5: "Mercury in the 5th House enhances intelligence, analytical skills, creativity, writing, and success in calculations or programming.",
        6: "Mercury in the 6th House highlights daily analytical work, logical reasoning, and resolving service tasks with intelligence.",
        7: "Mercury in the 7th House brings clear agreements, friendly relationships, and successful trading or consulting partnerships.",
        8: "Mercury in the 8th House brings research skills, secretive investigations, inheritance benefits, and interest in mystical codes.",
        9: "Mercury in the 9th House indicates learning journeys, interest in philosophy, religious writings, and lucky opportunities.",
        10: "Mercury in the 10th House brings professional communication success, trading business growth, and positive status in career.",
        11: "Mercury in the 11th House brings a large, intellectual social circle, gains from writing/publishing, and fast learning.",
        12: "Mercury in the 12th House indicates foreign trade, active imagination, writing in solitude, and learning foreign languages."
    }
}

def get_mahadasha_phala(planets, house_positions):
    phala = []
    # Order of Vimshottari Mahadasha lords
    lords = ['Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury']
    
    for lord in lords:
        if lord in planets:
            p_data = planets[lord]
            rashi = p_data.get('rashi', '')
            house = house_positions.get(lord, 1)
            
            # Look up prediction
            desc = MAHADASHA_HOUSE_PREDICTIONS.get(lord, {}).get(house, "")
            if not desc:
                desc = f"During the {lord} Maha Dasha, placement of {lord} in the {house} house will bring major events in areas related to this house, shaping your life path."
                
            phala.append({
                'lord': lord,
                'rashi': rashi,
                'house': house,
                'prediction': desc
            })
            
    return phala
