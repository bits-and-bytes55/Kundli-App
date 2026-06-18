import swisseph as swe
from datetime import datetime

# Target degrees:
# Sun: 163.82528
# Sat: 298.23750
# Jup: 132.95972
# Mars: 142.37806

for year in range(1930, 2025):
    jd = swe.julday(year, 9, 10, 12.0)
    # Sat
    res_sat, _ = swe.calc_ut(jd, swe.SATURN, swe.FLG_SWIEPH)
    if abs(res_sat[0] - 298.24) < 10.0:
        res_jup, _ = swe.calc_ut(jd, swe.JUPITER, swe.FLG_SWIEPH)
        if abs(res_jup[0] - 132.96) < 15.0:
            for day in range(1, 32):
                jd_day = swe.julday(year, 9, day, 12.0)
                res_sun, _ = swe.calc_ut(jd_day, swe.SUN, swe.FLG_SWIEPH)
                if abs(res_sun[0] - 163.82) < 2.0:
                    res_mars, _ = swe.calc_ut(jd_day, swe.MARS, swe.FLG_SWIEPH)
                    if abs(res_mars[0] - 142.38) < 3.0:
                        print(f"TROPICAL MATCH: {year}-09-{day} -> Sun: {res_sun[0]:.2f}, Sat: {res_sat[0]:.2f}")
                        break
