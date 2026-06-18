import swisseph as swe
from datetime import datetime, timedelta
import pytz

swe.set_sid_mode(swe.SIDM_LAHIRI)

# Target:
# Sun: ~163.82 (Virgo 13.82)
# Sat: ~298.24 (Capricorn 28.24)
# Rahu: ~101.88 (Cancer 11.88)
# Jupiter: ~132.96 (Leo 12.96)
# Mars: ~142.38 (Leo 22.38)
# Venus: ~125.95 (Leo 5.95)
# Mercury: ~170.90 (Virgo 20.90)

# Search September 1963
start_date = datetime(1963, 9, 1)
for day in range(30):
    dt = start_date + timedelta(days=day)
    jd = swe.julday(dt.year, dt.month, dt.day, 12.0) # noon UTC is ~5:30 PM IST
    
    res_sun, _ = swe.calc_ut(jd, swe.SUN, swe.FLG_SIDEREAL)
    res_sat, _ = swe.calc_ut(jd, swe.SATURN, swe.FLG_SIDEREAL)
    res_rahu, _ = swe.calc_ut(jd, swe.MEAN_NODE, swe.FLG_SIDEREAL)
    res_jup, _ = swe.calc_ut(jd, swe.JUPITER, swe.FLG_SIDEREAL)
    res_mars, _ = swe.calc_ut(jd, swe.MARS, swe.FLG_SIDEREAL)
    res_ven, _ = swe.calc_ut(jd, swe.VENUS, swe.FLG_SIDEREAL)
    res_mer, _ = swe.calc_ut(jd, swe.MERCURY, swe.FLG_SIDEREAL)
    
    print(f"Date: {dt.strftime('%Y-%m-%d')}")
    print(f"  Sun: {res_sun[0]:.2f}, Sat: {res_sat[0]:.2f}, Rahu: {res_rahu[0]:.2f}")
    print(f"  Jup: {res_jup[0]:.2f}, Mars: {res_mars[0]:.2f}, Ven: {res_ven[0]:.2f}, Mer: {res_mer[0]:.2f}")
    
    if abs(res_sun[0] - 163.82) < 2.0 and abs(res_sat[0] - 298.24) < 2.0:
        print("FOUND CLOSE MATCH!")
        break
