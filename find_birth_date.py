import swisseph as swe
from datetime import datetime, timedelta

# Targets:
# Sun: ~163.82
# Moon: ~270.70
# Mars: ~142.38
# Mercury: ~170.90
# Jupiter: ~132.96
# Venus: ~125.95
# Saturn: ~298.24
# Rahu: ~101.88

swe.set_sid_mode(swe.SIDM_LAHIRI)

# Search days from 1960 to 2025
start_date = datetime(1960, 1, 1)
for day in range(365 * 65):
    dt = start_date + timedelta(days=day)
    jd = swe.julday(dt.year, dt.month, dt.day, 12.0) # noon
    
    # Check Saturn
    res_sat, _ = swe.calc_ut(jd, swe.SATURN, swe.FLG_SIDEREAL)
    sat_lon = res_sat[0]
    if abs(sat_lon - 298.24) < 5.0:
        # Check Rahu
        res_rahu, _ = swe.calc_ut(jd, swe.MEAN_NODE, swe.FLG_SIDEREAL)
        rahu_lon = res_rahu[0]
        if abs(rahu_lon - 101.88) < 5.0:
            # Check Sun
            res_sun, _ = swe.calc_ut(jd, swe.SUN, swe.FLG_SIDEREAL)
            sun_lon = res_sun[0]
            if abs(sun_lon - 163.82) < 5.0:
                print(f"Candidate Date: {dt.strftime('%Y-%m-%d')} -> Sun: {sun_lon:.2f}, Sat: {sat_lon:.2f}, Rahu: {rahu_lon:.2f}")
