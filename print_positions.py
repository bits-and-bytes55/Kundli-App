import swisseph as swe

swe.set_sid_mode(swe.SIDM_LAHIRI)

for year in range(1980, 2010):
    # Search for day when Sun is closest to 163.82
    min_diff = 999.0
    best_jd = 0
    best_date = ""
    for month in [9, 10]:
        for day in range(1, 32):
            jd = swe.julday(year, month, day, 12.0)
            res_sun, _ = swe.calc_ut(jd, swe.SUN, swe.FLG_SIDEREAL)
            diff = abs(res_sun[0] - 163.82)
            if diff < min_diff:
                min_diff = diff
                best_jd = jd
                best_date = f"{year}-{month:02d}-{day:02d}"
                
    # Print other planets for this day
    res_sat, _ = swe.calc_ut(best_jd, swe.SATURN, swe.FLG_SIDEREAL)
    res_jup, _ = swe.calc_ut(best_jd, swe.JUPITER, swe.FLG_SIDEREAL)
    res_mars, _ = swe.calc_ut(best_jd, swe.MARS, swe.FLG_SIDEREAL)
    print(f"{best_date} -> Sun: {163.82:.2f}, Sat: {res_sat[0]:.2f}, Jup: {res_jup[0]:.2f}, Mars: {res_mars[0]:.2f}")
