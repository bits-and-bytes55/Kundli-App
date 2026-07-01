import os
import re

dir_path = 'lib/screens/kundli'

replacements = [
    # planets_tab
    (r"'Pla'", r"'pla'.tr"),
    (r"'Sign'", r"'sign_col'.tr"),
    (r"'Degree'", r"'degree_col'.tr"),
    (r"'Naks'", r"'naks'.tr"),
    (r"'Rel'", r"'rel'.tr"),
    (r"'Retrograde \*'", r"'retrograde_star'.tr"),
    (r"'Combust \^'", r"'combust_caret'.tr"),
    (r"'Vargottama □'", r"'vargottama_sq'.tr"),
    (r"'Exalted ↑'", r"'exalted_up'.tr"),
    (r"'Debilitated ↓'", r"'debilitated_down'.tr"),
    (r"'\* Retrograde'", r"'star_retrograde'.tr"),
    (r"'\^ Combust'", r"'caret_combust'.tr"),
    (r"'□ Vargottama'", r"'sq_vargottama'.tr"),
    (r"'↑ Exalted'", r"'up_exalted'.tr"),
    (r"'↓ Debilitated'", r"'down_debilitated'.tr"),
    (r"'House \$house'", r"'${'house'.tr} $house'"),
    (r"'Sign \(Rashi\)'", r"'sign_rashi'.tr"),
    (r"'Sign Lord'", r"'sign_lord'.tr"),
    (r"'Syllable'", r"'syllable'.tr"),
    
    # cusps_tab & planets_sub_tab
    (r"'Hos'", r"'hos'.tr"),
    (r"'SL'", r"'sl'.tr"),
    (r"'NL'", r"'nl'.tr"),
    (r"'SB'", r"'sb'.tr"),
    (r"'SS'", r"'ss'.tr"),
    (r"'Note:\\nSL - Sign Lord\\nNL - Nakshatra Lord\\nSB - Sub Lord\\nSS - Sub-Sub Lord\\n\\nCusps are calculated using KP \(Krishnamurti Paddhati\) system with Placidus house division.'", r"'kp_cusp_note'.tr"),
    
    # planet_signification & house_significators
    (r"'Planet'", r"'planet'.tr"),
    (r"'Significations'", r"'significations'.tr"),
    (r"'House'", r"'house'.tr"),
    (r"'\$planet Significations'", r"'$planet ${'significations'.tr}'"),
    (r"'House \$house Significations'", r"'${'house'.tr} $house ${'significations'.tr}'"),
]

for filename in os.listdir(dir_path):
    if filename.endswith(".dart"):
        filepath = os.path.join(dir_path, filename)
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original = content
        for old, new in replacements:
            content = re.sub(old, new, content)
            
        # Ensure import 'package:get/get.dart'; is present
        if "'.tr" in content and "import 'package:get/get.dart';" not in content:
            content = "import 'package:get/get.dart';\n" + content
            
        if content != original:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)

print("Translation script completed.")
