import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../theme/custom_shadows.dart';

class MilanResultScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const MilanResultScreen({super.key, required this.resultData});

  // Astrological descriptions for 8 Kootas
  static const Map<String, Map<String, String>> kootaDetails = {
    'Varna': {
      'hindi': 'वर्ण',
      'meaning': 'Ego & spiritual capacity matching. Measures work and intellectual compatibility.',
    },
    'Vasya': {
      'hindi': 'वश्य',
      'meaning': 'Mutual control, influence, and dominance matching between partners.',
    },
    'Tara': {
      'hindi': 'तारा',
      'meaning': 'Destiny and health matching. Represents longevity and fortune of the couple.',
    },
    'Yoni': {
      'hindi': 'योनि',
      'meaning': 'Intimacy, sexual compatibility, and biological matching.',
    },
    'Graha_Maitri': {
      'hindi': 'ग्रह मैत्री',
      'meaning': 'Mental compatibility, friendship, mutual respect, and general affection.',
    },
    'Gana': {
      'hindi': 'गण',
      'meaning': 'Temperament and behavior compatibility. Matches Devta, Manushya, or Rakshasa.',
    },
    'Bhakoot': {
      'hindi': 'भकूट',
      'meaning': 'Emotional matching, family prosperity, and general wealth harmony.',
    },
    'Nadi': {
      'hindi': 'नाड़ी',
      'meaning': 'Physiological compatibility, genetic matching, health of children, and lineage.',
    },
  };

  @override
  Widget build(BuildContext context) {
    final boyName = resultData['boy_name'] ?? 'Boy';
    final girlName = resultData['girl_name'] ?? 'Girl';
    final total = (resultData['total_score'] as num?)?.toInt() ?? 0;
    final pct = (resultData['percentage'] as num?)?.toDouble() ?? 0.0;
    final verdict = resultData['verdict'] as String? ?? 'Average Match';
    final scores = resultData['scores'] as Map<String, dynamic>? ?? {};
    final doshas = resultData['doshas'] as Map<String, dynamic>? ?? {};
    final boyInfo = resultData['boy'] as Map<String, dynamic>? ?? {};
    final girlInfo = resultData['girl'] as Map<String, dynamic>? ?? {};

    // Get color code based on score
    Color scoreColor = Colors.red;
    if (total >= 28) {
      scoreColor = Colors.green.shade600;
    } else if (total >= 21) {
      scoreColor = Colors.teal;
    } else if (total >= 18) {
      scoreColor = Colors.orange.shade800;
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.scaffoldBg,
        image: DecorationImage(
          image: AssetImage('assets/images/ChatGPT Image Jun 14, 2026, 10_51_39 PM.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.9),
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
            onPressed: () => Get.back(),
          ),
          title: Text(
            '$boyName 💑 $girlName',
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            // Fake delay for refresh animation
            await Future.delayed(const Duration(milliseconds: 800));
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Celestial Score Header Card
                _buildScoreHeader(context, total, pct, verdict, scoreColor),
                const SizedBox(height: 20),

                // 2. side-by-side Rashi/Nakshatra Grid
                _buildComparisonGrid(boyName, girlName, boyInfo, girlInfo),
                const SizedBox(height: 20),

                // 3. Dosha Warning Banner (if Nadi/Bhakoot active)
                if (doshas['nadi_dosha'] == true || doshas['bhakoot_dosha'] == true) ...[
                  _buildDoshaWarningCard(doshas),
                  const SizedBox(height: 20),
                ],

                // 4. Ashtakoot 8 Gunas List
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Text(
                    'Ashtakoot Guna Breakdown (अष्टकूट गुण विवरण)',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textDark),
                  ),
                ),
                ...scores.entries.map((entry) {
                  final kKey = entry.key;
                  final kVal = entry.value as Map<String, dynamic>;
                  return _buildKootaItemCard(kKey, kVal);
                }).toList(),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 1. SCORE HEADER WIDGET
  Widget _buildScoreHeader(BuildContext context, int total, double pct, String verdict, Color scoreColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: CustomShadows.cardShadow,
      ),
      child: Center(
        child: Column(
          children: [
            const Text(
              'MILAN COMPATIBILITY SCORE',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppColors.textLight, letterSpacing: 1.5),
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: CircularProgressIndicator(
                    value: total / 36.0,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey.shade100,
                    color: scoreColor,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$total',
                      style: TextStyle(fontSize: 38, fontWeight: FontWeight.w950, color: scoreColor),
                    ),
                    const Text(
                      'out of 36',
                      style: TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scoreColor.withOpacity(0.3)),
              ),
              child: Text(
                verdict,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: scoreColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${pct.toStringAsFixed(1)}% Guna Match Percentage',
              style: const TextStyle(fontSize: 12, color: AppColors.textMedium, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // 2. COMPARISON GRID
  Widget _buildComparisonGrid(String boyName, String girlName, Map<String, dynamic> boy, Map<String, dynamic> girl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
        boxShadow: CustomShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Graha Kundli Birth Details (जन्म कुंडली तुलना)',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textDark),
          ),
          const SizedBox(height: 12),
          Table(
            border: TableBorder.symmetric(
              inside: BorderSide(color: Colors.grey.shade200, width: 0.8),
            ),
            children: [
              // Header
              TableRow(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Parameters', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMedium, fontSize: 12)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: Text(boyName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 12)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: Text(girlName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pink, fontSize: 12)),
                    ),
                  ),
                ],
              ),
              // Moon Rashi
              _buildTableRow('Moon Sign (Rashi)', boy['rashi'] ?? '-', girl['rashi'] ?? '-'),
              // Rashi Lord
              _buildTableRow('Sign Lord (स्वामी)', boy['rashi_lord'] ?? '-', girl['rashi_lord'] ?? '-'),
              // Nakshatra
              _buildTableRow('Nakshatra (नक्षत्र)', boy['nakshatra'] ?? '-', girl['nakshatra'] ?? '-'),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String label, String bVal, String gVal) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMedium, fontWeight: FontWeight.w600)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Text(bVal, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Text(gVal, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          ),
        ),
      ],
    );
  }

  // 3. DOSHA WARNING CARD
  Widget _buildDoshaWarningCard(Map<String, dynamic> doshas) {
    final String report = doshas['report'] ?? '';
    final bool hasNadi = doshas['nadi_dosha'] == true;
    final bool hasBhakoot = doshas['bhakoot_dosha'] == true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              Text(
                'Astrological Dosha Alert!',
                style: TextStyle(fontWeight: FontWeight.w900, color: Colors.red.shade900, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            report,
            style: TextStyle(color: Colors.red.shade800, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.red, thickness: 0.5),
          const SizedBox(height: 8),
          Text(
            'Recommended Remedies (उपचार):',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade900, fontSize: 12),
          ),
          const SizedBox(height: 6),
          if (hasNadi) ...[
            _remedyItem('Perform Nadi Dosha Nivaran Puja at a temple.'),
            _remedyItem('Donate cows, grains, and clothes to priests or the needy.'),
            _remedyItem('Chant the Maha Mrityunjaya Mantra daily.'),
          ],
          if (hasBhakoot) ...[
            _remedyItem('Worship Lord Shiva regularly and perform Abhishek.'),
            _remedyItem('Fast on Thursdays or Mondays depending on planetary lords.'),
            _remedyItem('Feed green grass to cows or birds on Wednesdays.'),
          ],
        ],
      ),
    );
  }

  Widget _remedyItem(String remedy) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          Expanded(
            child: Text(
              remedy,
              style: TextStyle(color: Colors.red.shade900, fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // 4. KOOTA BREAKDOWN CARD
  Widget _buildKootaItemCard(String key, Map<String, dynamic> val) {
    final detail = kootaDetails[key] ?? {'hindi': key, 'meaning': 'Ashtakoot parameter match.'};
    final String hindi = detail['hindi'] ?? key;
    final String meaning = detail['meaning'] ?? '';
    final int got = (val['score'] as num?)?.toInt() ?? 0;
    final int max = (val['max'] as num?)?.toInt() ?? 0;
    final double ratio = max > 0 ? got / max.toDouble() : 0.0;

    // Boy and girl values
    final String boyVal = val['boy']?.toString() ?? val['boy_tara']?.toString() ?? val['boy_lord']?.toString() ?? '-';
    final String girlVal = val['girl']?.toString() ?? val['girl_tara']?.toString() ?? val['girl_lord']?.toString() ?? '-';

    Color themeColor = Colors.red;
    if (got == max) {
      themeColor = Colors.green.shade600;
    } else if (got > 0) {
      themeColor = Colors.amber.shade800;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: themeColor.withOpacity(0.25), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      key.replaceAll('_', ' '),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textDark),
                    ),
                    Text(
                      '($hindi)',
                      style: const TextStyle(fontSize: 11, color: AppColors.textLight, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$got / $max Points',
                    style: TextStyle(fontWeight: FontWeight.w900, color: themeColor, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              meaning,
              style: const TextStyle(fontSize: 11, color: AppColors.textMedium, height: 1.3),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accentLight.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.08)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _comparisonCell('Boy Value', boyVal, Colors.blue),
                  Container(height: 25, width: 0.8, color: Colors.grey.shade300),
                  _comparisonCell('Girl Value', girlVal, Colors.pink),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 5,
                backgroundColor: Colors.grey.shade100,
                color: themeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _comparisonCell(String label, String val, Color valColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textLight, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(val, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: valColor)),
      ],
    );
  }
}
