from backend.calculations.kundli import get_kp_lords

cusps = [
    101.96944, # House 1: 101°58'10"
    125.79694, # House 2: 125°47'49"
    153.55694, # House 3: 153°33'25"
    185.64694, # House 4: 185°38'49"
    219.62472, # House 5: 219°37'29"
    252.14639, # House 6: 252°08'47"
    281.96944, # House 7: 281°58'10"
    305.79694, # House 8: 305°47'49"
    333.55694, # House 9: 333°33'25"
    5.64694,   # House 10: 005°38'49"
    39.62472,  # House 11: 039°37'29"
    72.14639,  # House 12: 072°08'47"
]

print("House | Longitude | Rashi Lord | Nakshatra Lord | Sub Lord | Sub-Sub Lord")
print("-" * 75)
for i, lon in enumerate(cusps):
    rashi_lord, nakshatra, nakshatra_lord, sub_lord, sub_sub_lord = get_kp_lords(lon)
    print(f" {i+1:2d}   | {lon:9.5f} | {rashi_lord:10s} | {nakshatra_lord:14s} | {sub_lord:8s} | {sub_sub_lord:12s}")
