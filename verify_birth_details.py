import swisseph as swe

# Target: 101.96944 (101°58'10")
# 2008-02-06 11:37 UT -> 17:07 Local (Delhi)

lat, lon = 28.6139, 77.2090

# Let's search around that date and time for Delhi
for sec in range(0, 3600, 10):
    hour = 11.0 + (37.0 * 60.0 + sec) / 3600.0
    jd = swe.julday(2008, 2, 6, hour)
    
    # 1. Lahiri
    swe.set_sid_mode(swe.SIDM_LAHIRI)
    res_l = swe.houses_ex(jd, lat, lon, b'P', swe.FLG_SIDEREAL)
    h1_l = res_l[0][0]
    
    # 2. Krishnamurti
    swe.set_sid_mode(swe.SIDM_KRISHNAMURTI)
    res_k = swe.houses_ex(jd, lat, lon, b'P', swe.FLG_SIDEREAL)
    h1_k = res_k[0][0]
    
    if abs(h1_l - 101.96944) < 0.005:
        print(f"LAHIRI MATCH AT {sec}s: {h1_l:.5f}")
        print("Cusps:", [round(c, 5) for c in res_l[0]])
    if abs(h1_k - 101.96944) < 0.005:
        print(f"KP MATCH AT {sec}s: {h1_k:.5f}")
        print("Cusps:", [round(c, 5) for c in res_k[0]])
