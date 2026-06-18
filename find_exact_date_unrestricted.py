import swisseph as swe
from datetime import datetime

swe.set_sid_mode(swe.SIDM_LAHIRI)

# We want:
# Sun in Virgo (150-180)
# Sat in Capricorn (270-300)
# Jup in Leo (120-150)

for year in range(1900, 2030):
    # Check middle of Virgo season (September 30)
    jd = swe.julday(year, 9, 30, 12.0)
    res_sat, _ = swe.calc_ut(jd, swe.SATURN, swe.FLG_SIDEREAL)
    res_jup, _ = swe.calc_ut(jd, swe.JUPITER, swe.FLG_SIDEREAL)
    
    if 270 <= res_sat[0] <= 300 and 120 <= res_jup[0] <= 150:
        print(f"Candidate Year: {year}")
        # Search every day in August, September, October of this year
        for month in [8, 9, 10]:
            for day in range(1, 32):
                for hour in range(0, 24, 2):
                    jd_day = swe.julday(year, month, day, hour)
                    
                    s, _ = swe.calc_ut(jd_day, swe.SUN, swe.FLG_SIDEREAL)
                    sa, _ = swe.calc_ut(jd_day, swe.SATURN, swe.FLG_SIDEREAL)
                    ju, _ = swe.calc_ut(jd_day, swe.JUPITER, swe.FLG_SIDEREAL)
                    ma, _ = swe.calc_ut(jd_day, swe.MARS, swe.FLG_SIDEREAL)
                    
                    # Target Sat: 298.24, Sun: 163.83, Jup: 133.00, Mars: 142.38
                    if abs(s[0] - 163.83) < 2.0 and abs(ju[0] - 133.00) < 2.0:
                        print(f"CLOSE MATCH on {year}-{month:02d}-{day:02d} {hour:02d}:00 UT:")
                        print(f"  Sun: {s[0]:.2f}, Sat: {sa[0]:.2f}, Jup: {ju[0]:.2f}, Mars: {ma[0]:.2f}")
