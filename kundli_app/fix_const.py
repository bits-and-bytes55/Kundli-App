import os
import re

replacements = {
    'lib/screens/premium_kundli_screen.dart': [
        (r"final List<Tab> _tabs = const \[", r"final List<Tab> _tabs = [")
    ],
    'lib/screens/kundli/planets_tab.dart': [
        (r"children: const \[", r"children: [")
    ],
    'lib/screens/kundli/planets_sub_tab.dart': [
        (r"children: const \[", r"children: [")
    ],
    'lib/screens/kundli/varshphal_tab.dart': [
        (r"const TableRow\(", r"TableRow(")
    ],
    'lib/screens/kundli/cusps_tab.dart': [
        (r"child: const Text\(", r"child: Text("),
        (r"children: const \[", r"children: [")
    ],
    'lib/screens/kundli/planet_signification_tab.dart': [
        (r"const Expanded\(flex: 3, child: Text\('planet'\.tr", r"Expanded(flex: 3, child: Text('planet'.tr"),
        (r"const Expanded\(flex: 2, child: Text\('nl'\.tr", r"Expanded(flex: 2, child: Text('nl'.tr")
    ],
    'lib/screens/kundli/kp_tab.dart': [
        (r"_tableHeaderRow\(const \[", r"_tableHeaderRow([")
    ]
}

for filepath, reps in replacements.items():
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        for old, new in reps:
            content = re.sub(old, new, content)
            
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

print("Removed const from translated widgets.")
