import swisseph as swe
from datetime import datetime

swe.set_sid_mode(swe.SIDM_LAHIRI)

# We want to find a date where:
# Sun is around 163.82 (Virgo 13.82)
# Sat is around 298.24 (Capricorn 28.24)
# Jup is around 132.96 (Leo 12.96)
# Mars is around 142.38 (Leo 22.38)

for year in range(1800, 2045):
    # Sun is at 163.82 around September 30 each year
    jd = swe.julday(year, 9, 30, 12.0)
    
    # Sat
    res_sat, _ = swe.calc_ut(jd, swe.SATURN, swe.FLG_SIDEREAL)
    if abs(res_sat[0] - 298.24) < 10.0:
        # Jup
        res_jup, _ = swe.calc_ut(jd, swe.JUPITER, swe.FLG_SIDEREAL)
        if abs(res_jup[0] - 132.96) < 15.0:
            # Let's search days in Sept/Oct of this year
            for day in range(1, 32):
                jd_day = swe.julday(year, 9, day, 12.0)
                res_sun, _ = swe.calc_ut(jd_day, swe.SUN, swe.FLG_SIDEREAL)
                if abs(res_sun[0] - 163.82) < 3.0:
                    res_mars, _ = swe.calc_ut(jd_day, swe.MARS, swe.FLG_SIDEREAL)
                    if abs(res_mars[0] - 142.38) < 5.0:
                        print(f"MATCH FOUND: {year}-09-{day} -> Sun: {res_sun[0]:.2f}, Sat: {res_sat[0]:.2f}, Jup: {res_jup[0]:.2f}, Mars: {res_mars[0]:.2f}")
