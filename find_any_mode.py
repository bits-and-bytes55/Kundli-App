import swisseph as swe
from datetime import datetime

# Target degrees:
# Sun: 163.82528 (Virgo 13°49'31")
# Sat: 298.23750 (Capricorn 28°14'15")
# Jup: 132.95972 (Leo 12°57'35")
# Mars: 142.37806 (Leo 22°22'41")

for mode in range(45):
    try:
        swe.set_sid_mode(mode)
    except:
        continue
        
    for year in range(1930, 2025):
        # rough check on September 30
        jd = swe.julday(year, 9, 30, 12.0)
        res_sat, _ = swe.calc_ut(jd, swe.SATURN, swe.FLG_SIDEREAL)
        if abs(res_sat[0] - 298.24) < 8.0:
            res_jup, _ = swe.calc_ut(jd, swe.JUPITER, swe.FLG_SIDEREAL)
            if abs(res_jup[0] - 132.96) < 8.0:
                # search days
                for day in range(1, 32):
                    jd_day = swe.julday(year, 9, day, 12.0)
                    res_sun, _ = swe.calc_ut(jd_day, swe.SUN, swe.FLG_SIDEREAL)
                    if abs(res_sun[0] - 163.82) < 2.0:
                        res_mars, _ = swe.calc_ut(jd_day, swe.MARS, swe.FLG_SIDEREAL)
                        if abs(res_mars[0] - 142.38) < 3.0:
                            print(f"MATCH: Mode {mode}, Date {year}-09-{day} -> Sun: {res_sun[0]:.2f}, Sat: {res_sat[0]:.2f}")
                            break
