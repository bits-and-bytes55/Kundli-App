import re

with open('lib/screens/premium_kundli_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update _buildMoonHouseSignCard signature and body
moon_old = """  Widget _buildMoonHouseSignCard(Map<String, dynamic> planets, int lagnaIdx) {
    final chandra = planets['Moon'] as Map<String, dynamic>?;"""
moon_new = """  Widget _buildMoonHouseSignCard(Map<String, dynamic> planets, int lagnaIdx, [Map<String, dynamic>? planetSignificators]) {
    final chandra = planets['Moon'] as Map<String, dynamic>?;"""
content = content.replace(moon_old, moon_new)

# 2. Update _buildPremiumTab call
call_old = """_buildMoonHouseSignCard(planets, lagnaIdx),"""
call_new = """_buildMoonHouseSignCard(planets, lagnaIdx, planetSignificators),"""
content = content.replace(call_old, call_new)

# 3. Rewrite _buildMoonHouseSignCard body strings to use .tr
# It's easier to just replace the whole function block up to its end.
moon_func_start = """  Widget _buildMoonHouseSignCard(Map<String, dynamic> planets, int lagnaIdx, [Map<String, dynamic>? planetSignificators]) {"""
moon_func_end_marker = """  Widget _buildNameHouseSignCard"""
moon_func_text = content[content.find(moon_func_start):content.find(moon_func_end_marker)]

new_moon_func = """  Widget _buildMoonHouseSignCard(Map<String, dynamic> planets, int lagnaIdx, [Map<String, dynamic>? planetSignificators]) {
    final chandra = planets['Moon'] as Map<String, dynamic>?;
    if (chandra == null) return const SizedBox();

    final moonRashi = chandra['rashi'] as String? ?? 'Mesh';
    final moonRashiHindi = rashiHindi[moonRashi] ?? moonRashi;
    final moonRashiLordHindi = rashiLordsHindi[moonRashi] ?? '';
    final rashiLordEng = _getRashiLordEng(moonRashi);
    final moonNakshatra = chandra['nakshatra'] as String? ?? '';
    final moonPada = chandra['pada'] as int? ?? 1;

    final nakList = rashiNakshatras[moonRashi] ?? [];
    
    String moonFirstLetter = '-';
    int activeNakIdx = -1;
    for (int idx = 0; idx < nakList.length; idx++) {
      if (_isMatchingNakshatra(moonNakshatra, nakList[idx]['name']!)) {
        activeNakIdx = idx;
        final lettersStr = nakList[idx]['letters']!;
        moonFirstLetter = lettersStr.split(',').first.replaceAll('[', '').replaceAll(']', '').trim();
        break;
      }
    }

    final Color orange = AppColors.primary;
    
    int moonHouse = chandra['house'] as int? ?? 1;
    
    Set<int> rashiSignified = {};
    if (rashiLordEng.isNotEmpty) {
      var sigData = planetSignificators?[rashiLordEng] ?? planetSignificators?[rashiLordEng.toLowerCase()];
      if (sigData is Map && sigData.containsKey('planet_houses')) {
         List<dynamic> sigs = sigData['planet_houses'];
         rashiSignified.addAll(sigs.map((e) => int.parse(e.toString())));
      } else {
        final ownership = {
          'Sun': [4], 'Moon': [3], 'Mars': [0, 7], 'Mercury': [2, 5],
          'Jupiter': [8, 11], 'Venus': [1, 6], 'Saturn': [9, 10]
        };
        for (int rIdx in (ownership[rashiLordEng] ?? [])) {
          rashiSignified.add(((rIdx - lagnaIdx + 12) % 12) + 1);
        }
        if (planets[rashiLordEng] != null && planets[rashiLordEng]['house'] != null) {
          rashiSignified.add(planets[rashiLordEng]['house'] as int);
        }
      }
    }
    
    String rashiStr = "-";
    if (rashiSignified.isNotEmpty) {
      var l = rashiSignified.toList()..sort();
      rashiStr = l.join(', ');
    }

    Widget card = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: orange.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: orange.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [orange.withOpacity(0.85), const Color(0xFFFFB0C0)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'moon_title'.tr,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  '${'house'.tr} ${chandra['house'] ?? '-'}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _detRow('rashi'.tr, '$moonRashiHindi ($moonRashiLordHindi)'),
                _detRow('nakshatra'.tr, '$moonNakshatra पद $moonPada'),
                _detRow('nakshatra_lord'.tr, chandra['nakshatra_lord'] ?? '-'),
                _detRow('namakshar'.tr, moonFirstLetter),
                _detRow('degree'.tr, _formatDegree(chandra['degree'])),
                _detRow('speed'.tr, '${(chandra['speed'] as num? ?? 0).toStringAsFixed(4)}°/day'),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: orange.withOpacity(0.02),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$moonRashiHindi ${'rashi_all_nakshatras_namakshar'.tr}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                ...nakList.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  final isCurrent = idx == activeNakIdx;
                  
                  String nLord = item['lord']!;
                  String nLordEng = _getNakshatraLordEng(nLord);
                  
                  Set<int> nakSignified = {};
                  if (nLordEng.isNotEmpty) {
                    var sigData = planetSignificators?[nLordEng] ?? planetSignificators?[nLordEng.toLowerCase()];
                    if (sigData is Map && sigData.containsKey('planet_houses')) {
                      List<dynamic> sigs = sigData['planet_houses'];
                      nakSignified.addAll(sigs.map((e) => int.parse(e.toString())));
                    } else {
                      final ownership = {
                        'Sun': [4], 'Moon': [3], 'Mars': [0, 7], 'Mercury': [2, 5],
                        'Jupiter': [8, 11], 'Venus': [1, 6], 'Saturn': [9, 10]
                      };
                      for (int rIdx in (ownership[nLordEng] ?? [])) {
                        nakSignified.add(((rIdx - lagnaIdx + 12) % 12) + 1);
                      }
                      if (planets[nLordEng] != null && planets[nLordEng]['house'] != null) {
                        nakSignified.add(planets[nLordEng]['house'] as int);
                      }
                    }
                  }
                  
                  String nakStr = "-";
                  if (nakSignified.isNotEmpty) {
                    var l = nakSignified.toList()..sort();
                    nakStr = l.join(', ');
                  }
                  
                  Map<int, int> houseFreq = {};
                  houseFreq[moonHouse] = (houseFreq[moonHouse] ?? 0) + 1;
                  houseFreq[1] = (houseFreq[1] ?? 0) + 1;
                  for (int h in rashiSignified) houseFreq[h] = (houseFreq[h] ?? 0) + 1;
                  for (int h in nakSignified) houseFreq[h] = (houseFreq[h] ?? 0) + 1;
                  
                  List<int> sortedActive = houseFreq.keys.toList()..sort();
                  List<TextSpan> spans = [];
                  if (sortedActive.isEmpty) {
                    spans.add(const TextSpan(text: '-'));
                  } else {
                    for (int i = 0; i < sortedActive.length; i++) {
                      int h = sortedActive[i];
                      int count = houseFreq[h] ?? 1;
                      Color textColor = (h == 8 || h == 12) ? Colors.red.shade700 : Colors.green.shade800;
                      spans.add(TextSpan(
                        text: '$h',
                        style: TextStyle(
                          fontWeight: count > 1 ? FontWeight.w900 : FontWeight.w600,
                          fontSize: count > 1 ? 15 : 13,
                          color: textColor,
                        ),
                      ));
                      if (i < sortedActive.length - 1) {
                        spans.add(TextSpan(
                          text: ', ', 
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey.shade600)
                        ));
                      }
                    }
                    bool has8 = sortedActive.contains(8);
                    spans.add(TextSpan(
                      text: has8 ? ' ❌' : ' ✔️', 
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: has8 ? Colors.red.shade700 : Colors.green.shade700)
                    ));
                  }
                  
                  Widget totalActiveWidget = RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(children: spans),
                  );

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isCurrent ? orange.withOpacity(0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCurrent ? orange : Colors.grey.shade200,
                        width: isCurrent ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              isCurrent ? Icons.stars_rounded : Icons.radio_button_off_rounded,
                              color: isCurrent ? orange : Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${item['name']} (${item['letters']}) — ${item['lord']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                  color: isCurrent ? orange : Colors.black87,
                                ),
                              ),
                            ),
                            if (isCurrent)
                              Text(
                                'active'.tr,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: orange),
                              ),
                          ],
                        ),
                        if (isCurrent) ...[
                          const SizedBox(height: 12),
                          _buildSimpleRow('moon_from_lagna'.tr, '${moonHouse > 0 ? moonHouse : "-"}${'th_house'.tr}'),
                          _buildSimpleRow('moon_from_moon'.tr, '1${'th_house'.tr}'),
                          _buildSimpleRow('moon_rashi_signified'.tr, rashiStr),
                          _buildSimpleRow('moon_nak_signified'.tr, nakStr),
                          _buildSimpleRow('total_active_houses'.tr, '', customValueWidget: totalActiveWidget, isLast: true),
                        ]
                      ]
                    )
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
    
    return card;
  }

"""
content = content.replace(moon_func_text, new_moon_func)

# 4. _buildSingleRashiAnalysis strings replacement
content = content.replace("'लगन से नाम किस भाव में है'", "'name_from_lagna'.tr")
content = content.replace("'चंद्र से नाम किस भाव में है'", "'name_from_moon'.tr")
content = content.replace("'नाम राशि से Signified Houses'", "'name_rashi_signified'.tr")
content = content.replace("'नाम नक्षत्र से Signified Houses'", "'name_nak_signified'.tr")
content = content.replace("'Total Active Houses'", "'total_active_houses'.tr")
content = content.replace("'वाँ भाव'", "'th_house'.tr")
content = content.replace("'सक्रिय'", "'active'.tr")
content = content.replace("Text('नाम राशि ($name)'", "Text('${'name_rashi'.tr} ($name)'")
content = content.replace("'$nameRashiHindi राशि के सभी नक्षत्र और नामाक्षर:'", "'$nameRashiHindi ${'rashi_all_nakshatras_namakshar'.tr}'")
content = content.replace("'$rashiHindiName राशि के सभी नक्षत्र और नामाक्षर:'", "'$rashiHindiName ${'rashi_all_nakshatras_namakshar'.tr}'")


with open('lib/screens/premium_kundli_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
