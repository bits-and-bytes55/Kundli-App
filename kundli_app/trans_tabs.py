import os
import re

filepath = 'lib/screens/premium_kundli_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

tabs = [
    'Premium', 'Basic', '12 Rashi', 'Direction Prediction', 'Graha Sthiti', 
    'Planets', 'Planets-Sub', 'Cusps', 'Planet Sig.', 'House Sig.', 
    'KP System', 'Ashtakvarga', 'Shad Bala', 'Gochar', 'Dasha', 
    'Varshphal', 'Avakahada', 'Chalit Table', 'Prasthara', 'Friendship', 
    'Yogas', 'Shodashvarga', 'Lal Kitab', 'Predictions', 'Reports'
]

for tab in tabs:
    # Match exactly Tab(text: 'TabName')
    old_str = f"Tab(text: '{tab}')"
    # Convert tab name to key (e.g., 'Planet Sig.' -> 'planet_sig')
    key = tab.lower().replace(' ', '_').replace('.', '').replace('-', '_')
    new_str = f"Tab(text: '{key}'.tr)"
    content = content.replace(old_str, new_str)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print("Tabs translated in premium_kundli_screen.dart")
