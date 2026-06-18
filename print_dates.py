import swisseph as swe
from datetime import datetime

swe.set_sid_mode(swe.SIDM_LAHIRI)

for year in range(1930, 2025):
    jd = swe.julday(year, 9, 15, 12.0)
    res_sat, _ = swe.calc_ut(jd, swe.SATURN, swe.FLG_SIDEREAL)
    res_jup, _ = swe.calc_ut(jd, swe.JUPITER, swe.FLG_SIDEREAL)
    
    # Check if Saturn is around 298 (Capricorn 28) and Jupiter is around 132 (Leo 12)
    if abs(res_sat[0] - 298.24) < 30.0 and abs(res_jup[0] - 132.96) < 30.0:
         print(f"Year: {year} -> Sat: {res_sat[0]:.2f}, Jup: {res_jup[0]:.2f}")
