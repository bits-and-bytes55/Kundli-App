import swisseph as swe
from datetime import datetime, timedelta

# Target longitudes:
# Sun: 163.82
# Sat: 298.24
# Jup: 132.96
# Mars: 142.38

swe.set_sid_mode(swe.SIDM_LAHIRI)

start_date = datetime(1930, 1, 1)
# Search 95 years
for year in range(95):
    for month in [9, 10]: # Virgo Sun is always in Sept/Oct
        for day in range(1, 32):
            try:
                dt = datetime(start_date.year + year, month, day)
            except ValueError:
                continue
            
            jd = swe.julday(dt.year, dt.month, dt.day, 12.0)
            
            # Sun
            res_sun, _ = swe.calc_ut(jd, swe.SUN, swe.FLG_SIDEREAL)
            if abs(res_sun[0] - 163.82) < 3.0:
                # Sat
                res_sat, _ = swe.calc_ut(jd, swe.SATURN, swe.FLG_SIDEREAL)
                if abs(res_sat[0] - 298.24) < 5.0:
                    # Jup
                    res_jup, _ = swe.calc_ut(jd, swe.JUPITER, swe.FLG_SIDEREAL)
                    if abs(res_jup[0] - 132.96) < 5.0:
                        # Mars
                        res_mars, _ = swe.calc_ut(jd, swe.MARS, swe.FLG_SIDEREAL)
                        if abs(res_mars[0] - 142.38) < 5.0:
                            print(f"MATCH DATE: {dt.strftime('%Y-%m-%d')} -> Sun: {res_sun[0]:.2f}, Sat: {res_sat[0]:.2f}, Jup: {res_jup[0]:.2f}, Mars: {res_mars[0]:.2f}")
