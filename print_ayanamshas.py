import swisseph as swe

jd = swe.julday(2008, 2, 6, 11 + 37/60.0 + 40/3600.0)

# Lahiri
swe.set_sid_mode(swe.SIDM_LAHIRI)
ayan_lahiri = swe.get_ayanamsa(jd)

# Krishnamurti
swe.set_sid_mode(swe.SIDM_KRISHNAMURTI)
ayan_kp = swe.get_ayanamsa(jd)

print(f"Lahiri Ayanamsha: {ayan_lahiri:.5f}")
print(f"KP Ayanamsha:     {ayan_kp:.5f}")
print(f"Difference:       {ayan_lahiri - ayan_kp:.5f}")
