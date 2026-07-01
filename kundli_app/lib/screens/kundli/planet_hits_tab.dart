import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';

class PlanetHitsTab extends StatelessWidget {
  final Map<String, dynamic> planets;
  final Map<String, dynamic> kpAscendant;

  const PlanetHitsTab({
    Key? key,
    required this.planets,
    required this.kpAscendant,
  }) : super(key: key);

  static const List<String> _planetOrder = [
    'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu'
  ];

  static const Map<String, String> _hiNames = {
    'Sun': 'सूर्य', 'Moon': 'चन्द्र', 'Mars': 'मंगल', 'Mercury': 'बुध',
    'Jupiter': 'गुरु', 'Venus': 'शुक्र', 'Saturn': 'शनि', 'Rahu': 'राहु', 'Ketu': 'केतु'
  };

  // Helper to get hit result
  String _getHitResult(double diff) {
    if (diff >= 27 && diff <= 33) return '30° Positive Hit';
    if (diff >= 42 && diff <= 48) return '45° Negative Hit';
    if (diff >= 55 && diff <= 65) return '60° Positive Hit';
    if (diff >= 85 && diff <= 95) return '90° Negative Hit';
    if (diff >= 112 && diff <= 128) return '120° Positive Hit';
    if (diff >= 140 && diff <= 160) return '150° Positive Hit';
    if (diff >= 172 && diff <= 188) return '180° Negative Hit';
    return '';
  }

  // Calculate planet compound degree
  // Absolute Longitude = pLon
  // Degree in sign = pLon % 30
  // For House Hit: Planet Compound Degree = Absolute Longitude + Degree in sign
  double _getPlanetCompoundDegreeForHouse(double absoluteLongitude) {
    double degreeInSign = absoluteLongitude % 30.0;
    return absoluteLongitude + degreeInSign;
  }

  // Get absolute longitude for a planet
  double _getAbsLon(String pname) {
    if (planets.containsKey(pname)) {
      return (planets[pname]['longitude'] as num? ?? 0.0).toDouble();
    }
    return 0.0;
  }
  
  // Get house number for a planet
  int _getHouseNum(String pname) {
    if (planets.containsKey(pname)) {
      return (planets[pname]['house'] as num? ?? 0).toInt();
    }
    return 0;
  }

  // Planet to Planet Hit Data
  List<Map<String, dynamic>> _getPlanetToPlanetHits() {
    List<Map<String, dynamic>> hits = [];
    for (int i = 0; i < _planetOrder.length; i++) {
      for (int j = i + 1; j < _planetOrder.length; j++) {
        String p1 = _planetOrder[i];
        String p2 = _planetOrder[j];
        
        double lon1 = _getAbsLon(p1);
        double lon2 = _getAbsLon(p2);
        
        double diff = (lon1 - lon2).abs();
        if (diff > 180) diff = 360 - diff; // Angular distance between two planets
        // Wait, rule says: Difference = बड़ी Compound Degree − छोटी Compound Degree
        // That is exactly (lon1 - lon2).abs(). User didn't mention shortest angle, just large - small.
        // Wait, if lon1 = 350 and lon2 = 10, large - small = 340. 340 is not in any range.
        // If user wants exact absolute difference without shortest angle logic?
        // "Difference = बड़ी Compound Degree − छोटी Compound Degree"
        // Let's stick strictly to what user said.
        double rawDiff = (lon1 > lon2) ? (lon1 - lon2) : (lon2 - lon1);
        // Wait, if rawDiff > 200? The user only specified "Difference > 200" logic for HOUSE HIT.
        // For Planet Hit: Sun 124, Mars 209 -> 209 - 124 = 85.
        // Let's just use rawDiff for planet to planet. Wait, angular distance is usually shortest path.
        // Let's keep it as rawDiff, and if > 180, see if it hits 180° Negative Hit (172-188).
        // If rawDiff > 200? There's no range above 188. So it will be 'No Hit'.
        // But what if it's 330? 360-330 = 30 Positive Hit? 
        // User didn't specify. I will add the > 200 logic just in case, similar to house.
        // User said: "यदि Difference > 200° हो तो Final Difference = Difference - 360, फिर Positive Value लें" in House hit. I will apply it here too for correctness.
        if (rawDiff > 200) {
          rawDiff = (rawDiff - 360).abs();
        }
        
        String hitResult = _getHitResult(rawDiff);
        if (hitResult.isNotEmpty) {
          hits.add({
            'p1': p1,
            'p2': p2,
            'lon1': lon1,
            'lon2': lon2,
            'diff': rawDiff,
            'result': hitResult,
            'isPositive': hitResult.contains('Positive')
          });
        }
      }
    }
    return hits;
  }

  // Planet to House Hit Data
  List<Map<String, dynamic>> _getPlanetToHouseHits() {
    List<Map<String, dynamic>> hits = [];
    
    // Get house cusps (1 to 12)
    Map<int, double> cusps = {};
    for (int i = 1; i <= 12; i++) {
      if (kpAscendant.containsKey(i.toString())) {
        cusps[i] = (kpAscendant[i.toString()]['longitude'] as num? ?? 0.0).toDouble();
      }
    }
    
    for (String p in _planetOrder) {
      double pLon = _getAbsLon(p);
      int placedHouse = _getHouseNum(p);
      double compound = _getPlanetCompoundDegreeForHouse(pLon);
      
      for (int h = 1; h <= 12; h++) {
        if (h == placedHouse) continue; // Skip the house where planet is placed
        
        if (cusps.containsKey(h)) {
          double cuspLon = cusps[h]!;
          double diff = compound - cuspLon;
          if (diff < 0) diff = diff.abs();
          
          if (diff > 200) {
            diff = (diff - 360).abs();
          }
          
          String hitResult = _getHitResult(diff);
          if (hitResult.isNotEmpty) {
            hits.add({
              'planet': p,
              'house': h,
              'compound': compound,
              'cusp': cuspLon,
              'diff': diff,
              'result': hitResult,
              'isPositive': hitResult.contains('Positive')
            });
          }
        }
      }
    }
    return hits;
  }

  Widget _buildHitRow(String leftText, String rightText, String result, bool isPositive) {
    bool isHindi = Get.locale?.languageCode == 'hi';
    Color bgColor = isPositive ? Colors.green.shade50 : Colors.red.shade50;
    Color textColor = isPositive ? Colors.green.shade800 : Colors.red.shade800;
    IconData iconData = isPositive ? Icons.check_circle_rounded : Icons.warning_rounded;
    
    String displayResult = result;
    if (isHindi) {
      displayResult = displayResult.replaceAll('Positive Hit', 'पॉजिटिव हिट').replaceAll('Negative Hit', 'नेगेटिव हिट');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(iconData, color: textColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      leftText,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
                    ),
                    Text(
                      displayResult,
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: textColor),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  rightText,
                  style: const TextStyle(fontSize: 11, color: AppColors.textMedium),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isHindi = Get.locale?.languageCode == 'hi';
    
    final ppHits = _getPlanetToPlanetHits();
    final phHits = _getPlanetToHouseHits();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Planet to Planet Hit Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.flare_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  isHindi ? 'ग्रहों की आपस में हिट (Planet to Planet Hit)' : 'Planet to Planet Hit',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          if (ppHits.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  isHindi ? 'कोई हिट नहीं मिली।' : 'No planet to planet hits found.',
                  style: const TextStyle(color: AppColors.textMedium),
                ),
              ),
            )
          else
            ...ppHits.map((hit) {
              String p1Name = isHindi ? _hiNames[hit['p1']]! : hit['p1'];
              String p2Name = isHindi ? _hiNames[hit['p2']]! : hit['p2'];
              String leftText = '$p1Name ↔ $p2Name';
              String rightText = isHindi 
                  ? 'कंपाउंड डिग्री: ${hit['lon1'].toStringAsFixed(1)}° / ${hit['lon2'].toStringAsFixed(1)}°  •  अंतर: ${hit['diff'].toStringAsFixed(1)}°'
                  : 'Compound Degree: ${hit['lon1'].toStringAsFixed(1)}° / ${hit['lon2'].toStringAsFixed(1)}°  •  Diff: ${hit['diff'].toStringAsFixed(1)}°';
              return _buildHitRow(leftText, rightText, hit['result'], hit['isPositive']);
            }),
            
          const SizedBox(height: 24),

          // Planet to House Hit Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.9), AppColors.primary.withOpacity(0.6)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.maps_home_work_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  isHindi ? 'ग्रहों की भाव पर हिट (Planet to House Hit)' : 'Planet to House Hit',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          if (phHits.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  isHindi ? 'कोई हिट नहीं मिली।' : 'No planet to house hits found.',
                  style: const TextStyle(color: AppColors.textMedium),
                ),
              ),
            )
          else
            ...phHits.map((hit) {
              String pName = isHindi ? _hiNames[hit['planet']]! : hit['planet'];
              String houseName = isHindi ? 'भाव ${hit['house']}' : 'House ${hit['house']}';
              String leftText = '$pName → $houseName';
              String rightText = isHindi
                  ? 'कंपाउंड डिग्री: ${hit['compound'].toStringAsFixed(1)}°  •  कस्प: ${hit['cusp'].toStringAsFixed(1)}°  •  अंतर: ${hit['diff'].toStringAsFixed(1)}°'
                  : 'Compound: ${hit['compound'].toStringAsFixed(1)}°  •  Cusp: ${hit['cusp'].toStringAsFixed(1)}°  •  Diff: ${hit['diff'].toStringAsFixed(1)}°';
              return _buildHitRow(leftText, rightText, hit['result'], hit['isPositive']);
            }),
            
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
