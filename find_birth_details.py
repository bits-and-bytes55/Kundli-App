import swisseph as swe
from datetime import datetime

# Target cusps:
# H1: 101.96944 (Cancer 11°58'10")
# H4: 185.64694 (Libra 5°38'49")
# H10: 5.64694 (Aries 5°38'49")

lat, lon = 28.6139, 77.2090 # Delhi

for year in range(1980, 2010):
    for month in range(1, 13):
        # We can narrow down: Sun is in Leo/Virgo (around Aug/Sept)
        # Let's search all months to be safe
        for day in range(1, 29, 5): # rough search
            for hour in range(24):
                jd = swe.julday(year, month, day, hour + 0.5)
                # Test Lahiri
                swe.set_sid_mode(swe.SIDM_LAHIRI)
                res = swe.houses_ex(jd, lat, lon, b'P', swe.FLG_SIDEREAL)
                h1 = res[0][0]
                if abs(h1 - 101.969) < 2.0:
                    # Let's do a finer search in minutes
                    for minute in range(60):
                        jd_fine = swe.julday(year, month, day, hour + minute/60.0)
                        res_fine = swe.houses_ex(jd_fine, lat, lon, b'P', swe.FLG_SIDEREAL)
                        if abs(res_fine[0][0] - 101.969) < 0.05:
                            print(f"LAHI MATCH: {year}-{month:02d}-{day:02d} {hour:02d}:{minute:02d} UT")
                            print("Cusps:", [round(c, 2) for c in res_fine[0]])
                
                # Test Krishnamurti
                swe.set_sid_mode(swe.SIDM_KRISHNAMURTI)
                res = swe.houses_ex(jd, lat, lon, b'P', swe.FLG_SIDEREAL)
                h1 = res[0][0]
                if abs(h1 - 101.969) < 2.0:
                    for minute in range(60):
                        jd_fine = swe.julday(year, month, day, hour + minute/60.0)
                        res_fine = swe.houses_ex(jd_fine, lat, lon, b'P', swe.FLG_SIDEREAL)
                        if abs(res_fine[0][0] - 101.969) < 0.05:
                            print(f"KP MATCH: {year}-{month:02d}-{day:02d} {hour:02d}:{minute:02d} UT")
                            print("Cusps:", [round(c, 2) for c in res_fine[0]])
