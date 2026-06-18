import swisseph as swe

jd = 2451412.7813  # 1999-08-22 12:00 UTC approximately
# Let's find the ayanamsha for different modes:
modes = {
    'LAHIRI (0)': 0,
    'FAGAN_BRADLEY (1)': 1,
    'DE LUCE (2)': 2,
    'RAMAN (3)': 3,
    'USHASHASHI (4)': 4,
    'KRISHNAMURTI (5)': 5, # Wait! What is the ID of KRISHNAMURTI?
    'DJWHAL_KHUL (6)': 6,
    'YUKTESHWAR (7)': 7,
    'JNABHASA (8)': 8,
    'KUBERA (9)': 9,
    'KRISHNAMURTI_10': 10, # swe.SIDM_KRISHNAMURTI is 10
}

for name, mode_id in modes.items():
    try:
        swe.set_sid_mode(mode_id)
        aya = swe.get_ayanamsa(jd)
        print(f"{name:<20}: {aya:.6f} ({int(aya)}°{int((aya-int(aya))*60)}'{int(((aya-int(aya))*60 - int((aya-int(aya))*60))*60)}\")")
    except Exception as e:
        print(f"Error {name}: {e}")
