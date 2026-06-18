import swisseph as swe
from datetime import datetime

swe.set_sid_mode(swe.SIDM_LAHIRI)

# Target degrees:
# Sun: 163.82528
# Sat: 298.24361
# Rah: 101.87944
# Jup: 133.00333

for month in [8, 9, 10]:
    for day in range(1, 32):
        for hour in range(24):
            jd = swe.julday(1962, month, day, hour + 0.5)
            res_sun, _ = swe.calc_ut(jd, swe.SUN, swe.FLG_SIDEREAL)
            if abs(res_sun[0] - 163.82528) < 1.5:
                res_sat, _ = swe.calc_ut(jd, swe.SATURN, swe.FLG_SIDEREAL)
                res_rah, _ = swe.calc_ut(jd, swe.MEAN_NODE, swe.FLG_SIDEREAL)
                res_jup, _ = swe.calc_ut(jd, swe.JUPITER, swe.FLG_SIDEREAL)
                print(f"Date: 1962-{month:02d}-{day:02d} {hour:02d}:00 UT -> Sun: {res_sun[0]:.2f}, Sat: {res_sat[0]:.2f}, Rahu: {res_rah[0]:.2f}, Jup: {res_jup[0]:.2f}")
