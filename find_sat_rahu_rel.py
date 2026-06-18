import swisseph as swe
from datetime import datetime

swe.set_sid_mode(swe.SIDM_LAHIRI)

for year in range(1900, 2030):
    for month in range(1, 13):
        jd = swe.julday(year, month, 15, 12.0)
        res_sat, _ = swe.calc_ut(jd, swe.SATURN, swe.FLG_SIDEREAL)
        res_rah, _ = swe.calc_ut(jd, swe.MEAN_NODE, swe.FLG_SIDEREAL)
        
        diff = (res_sat[0] - res_rah[0]) % 360
        if abs(diff - 196.36) < 15.0:
            # check if Saturn is close to 298
            if abs(res_sat[0] - 298.24) < 30.0:
                print(f"Match: {year}-{month:02d} -> Sat: {res_sat[0]:.2f}, Rah: {res_rah[0]:.2f}, Diff: {diff:.2f}")
