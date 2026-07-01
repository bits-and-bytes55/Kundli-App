import os
import re

filepath = 'lib/localization/app_translations.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

en_additions = """
          // Data Table & Planet Headers
          'pla': 'Pla',
          'sign_col': 'Sign',
          'degree_col': 'Degree',
          'naks': 'Naks',
          'rel': 'Rel',
          'retrograde_star': 'Retrograde *',
          'combust_caret': 'Combust ^',
          'vargottama_sq': 'Vargottama □',
          'exalted_up': 'Exalted ↑',
          'debilitated_down': 'Debilitated ↓',
          'star_retrograde': '* Retrograde',
          'caret_combust': '^ Combust',
          'sq_vargottama': '□ Vargottama',
          'up_exalted': '↑ Exalted',
          'down_debilitated': '↓ Debilitated',
          'sign_rashi': 'Sign (Rashi)',
          'sign_lord': 'Sign Lord',
          'syllable': 'Syllable',
          'hos': 'Hos',
          'sl': 'SL',
          'nl': 'NL',
          'sb': 'SB',
          'ss': 'SS',
          'kp_cusp_note': 'Note:\\nSL - Sign Lord\\nNL - Nakshatra Lord\\nSB - Sub Lord\\nSS - Sub-Sub Lord\\n\\nCusps are calculated using KP (Krishnamurti Paddhati) system with Placidus house division.',
          'planet': 'Planet',
          'significations': 'Significations',
          
          // Tabs
          'premium': 'Premium',
          'basic': 'Basic',
          '12_rashi': '12 Rashi',
          'direction_prediction': 'Direction Prediction',
          'graha_sthiti': 'Graha Sthiti',
          'planets': 'Planets',
          'planets_sub': 'Planets-Sub',
          'cusps': 'Cusps',
          'planet_sig': 'Planet Sig.',
          'house_sig': 'House Sig.',
          'kp_system': 'KP System',
          'ashtakvarga': 'Ashtakvarga',
          'shad_bala': 'Shad Bala',
          'gochar': 'Gochar',
          'dasha': 'Dasha',
          'varshphal': 'Varshphal',
          'avakahada': 'Avakahada',
          'chalit_table': 'Chalit Table',
          'prasthara': 'Prasthara',
          'friendship': 'Friendship',
          'yogas': 'Yogas',
          'shodashvarga': 'Shodashvarga',
          'lal_kitab': 'Lal Kitab',
          'predictions': 'Predictions',
          'reports': 'Reports',
"""

hi_additions = """
          // Data Table & Planet Headers
          'pla': 'ग्रह',
          'sign_col': 'राशि',
          'degree_col': 'अंश',
          'naks': 'नक्षत्र',
          'rel': 'भाव',
          'retrograde_star': 'वक्री *',
          'combust_caret': 'अस्त ^',
          'vargottama_sq': 'वर्गोत्तम □',
          'exalted_up': 'उच्च ↑',
          'debilitated_down': 'नीच ↓',
          'star_retrograde': '* वक्री',
          'caret_combust': '^ अस्त',
          'sq_vargottama': '□ वर्गोत्तम',
          'up_exalted': '↑ उच्च',
          'down_debilitated': '↓ नीच',
          'sign_rashi': 'राशि',
          'sign_lord': 'राशि स्वामी',
          'syllable': 'नामाक्षर',
          'hos': 'भाव',
          'sl': 'SL',
          'nl': 'NL',
          'sb': 'SB',
          'ss': 'SS',
          'kp_cusp_note': 'नोट:\\nSL - राशि स्वामी\\nNL - नक्षत्र स्वामी\\nSB - उप स्वामी\\nSS - उप-उप स्वामी\\n\\nKP (कृष्णमूर्ति पद्धति) और प्लैसिडस भाव विभाजन द्वारा गणना की गई है।',
          'planet': 'ग्रह',
          'significations': 'कार्येश (Significations)',
          
          // Tabs
          'premium': 'प्रीमियम',
          'basic': 'बेसिक',
          '12_rashi': '12 राशियाँ',
          'direction_prediction': 'दिशा भविष्यवाणी',
          'graha_sthiti': 'ग्रह स्थिति',
          'planets': 'ग्रह',
          'planets_sub': 'उप-ग्रह',
          'cusps': 'भाव (Cusps)',
          'planet_sig': 'ग्रह कार्येश',
          'house_sig': 'भाव कार्येश',
          'kp_system': 'केपी प्रणाली',
          'ashtakvarga': 'अष्टकवर्ग',
          'shad_bala': 'षड्बल',
          'gochar': 'गोचर',
          'dasha': 'दशा',
          'varshphal': 'वर्षफल',
          'avakahada': 'अवकहड़ा',
          'chalit_table': 'चलित चक्र',
          'prasthara': 'प्रस्तार',
          'friendship': 'मैत्री',
          'yogas': 'योग',
          'shodashvarga': 'षोडशवर्ग',
          'lal_kitab': 'लाल किताब',
          'predictions': 'भविष्यवाणी',
          'reports': 'रिपोर्ट',
"""

# Insert into English section
en_marker = "          // Add more translations here as needed"
content = content.replace(en_marker, en_additions + "\n" + en_marker, 1)

# Insert into Hindi section (second occurrence)
content = content.replace(en_marker, hi_additions + "\n" + en_marker)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print("Added keys to app_translations.dart")
