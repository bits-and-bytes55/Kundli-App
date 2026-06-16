import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/custom_shadows.dart';

class HoroscopeScreen extends StatefulWidget {
  const HoroscopeScreen({super.key});

  @override
  State<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen> {
  final ApiService _api = Get.find<ApiService>();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _rashis = [
    {'name': 'Mesh', 'hindi': 'मेष', 'english': 'Aries', 'icon': Icons.star_border_purple500_rounded, 'color': Colors.red},
    {'name': 'Vrishabh', 'hindi': 'वृषभ', 'english': 'Taurus', 'icon': Icons.circle_outlined, 'color': Colors.pink},
    {'name': 'Mithun', 'hindi': 'मिथुन', 'english': 'Gemini', 'icon': Icons.people_outline_rounded, 'color': Colors.green},
    {'name': 'Kark', 'hindi': 'कर्क', 'english': 'Cancer', 'icon': Icons.waves_rounded, 'color': Colors.blue},
    {'name': 'Singh', 'hindi': 'सिंह', 'english': 'Leo', 'icon': Icons.wb_sunny_outlined, 'color': Colors.amber},
    {'name': 'Kanya', 'hindi': 'कन्या', 'english': 'Virgo', 'icon': Icons.nature_people_outlined, 'color': Colors.teal},
    {'name': 'Tula', 'hindi': 'तुला', 'english': 'Libra', 'icon': Icons.balance_rounded, 'color': Colors.indigo},
    {'name': 'Vrischik', 'hindi': 'वृश्चिक', 'english': 'Scorpio', 'icon': Icons.bug_report_outlined, 'color': Colors.redAccent},
    {'name': 'Dhanu', 'hindi': 'धनु', 'english': 'Sagittarius', 'icon': Icons.navigation_outlined, 'color': Colors.deepOrange},
    {'name': 'Makar', 'hindi': 'मकर', 'english': 'Capricorn', 'icon': Icons.terrain_outlined, 'color': Colors.brown},
    {'name': 'Kumbh', 'hindi': 'कुंभ', 'english': 'Aquarius', 'icon': Icons.opacity_outlined, 'color': Colors.cyan},
    {'name': 'Meen', 'hindi': 'मीन', 'english': 'Pisces', 'icon': Icons.sailing_outlined, 'color': Colors.purple},
  ];

  void _fetchAndShowHoroscope(String name, String hindi, String english) async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.getHoroscope(rashi: name);
      setState(() => _isLoading = false);
      if (data != null && data['horoscope'] != null) {
        _showPredictionSheet(hindi, english, data['horoscope']);
      } else {
        Get.snackbar('Error', 'Failed to fetch horoscope prediction.', backgroundColor: Colors.red.shade100);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red.shade100);
    }
  }

  void _showPredictionSheet(String hindi, String english, Map<String, dynamic> horo) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: CustomShadows.cardShadow,
        ),
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            
            // Header
            Text('$english Daily Horoscope ($hindi)', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primary)),
            const SizedBox(height: 4),
            Text('Predictions for Today', style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Divider(),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Overview Card
                  _buildSectionCard('Overview', horo['overview'] ?? '', Icons.auto_awesome_rounded, Colors.purple),
                  const SizedBox(height: 14),

                  // Lucky Metrics Row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.accentLight.withOpacity(0.4), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withOpacity(0.1))),
                          child: Column(children: [
                            const Text('LUCKY NUMBER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textLight)),
                            const SizedBox(height: 4),
                            Text('${horo['lucky_number'] ?? '-'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.black, color: AppColors.primary)),
                          ]),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.accentLight.withOpacity(0.4), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withOpacity(0.1))),
                          child: Column(children: [
                            const Text('LUCKY COLOR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textLight)),
                            const SizedBox(height: 4),
                            Text('${horo['lucky_color'] ?? '-'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.black, color: Colors.indigo)),
                          ]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Detail Cards
                  _buildSectionCard('Career & Job', horo['career'] ?? '', Icons.work_outline_rounded, Colors.blue),
                  const SizedBox(height: 12),
                  _buildSectionCard('Love & Relationships', horo['love'] ?? '', Icons.favorite_outline_rounded, Colors.pink),
                  const SizedBox(height: 12),
                  _buildSectionCard('Health & Wellness', horo['health'] ?? '', Icons.fitbit_rounded, Colors.green),
                  const SizedBox(height: 12),
                  _buildSectionCard('Finance & Wealth', horo['finance'] ?? '', Icons.savings_outlined, Colors.amber.shade800),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSectionCard(String title, String desc, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(fontSize: 13, color: AppColors.textMedium, height: 1.4)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          title: const Text('Daily Horoscope (राशिफल)'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
            onPressed: () => Get.back(),
          ),
        ),
        body: Stack(
          children: [
            GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _rashis.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                final r = _rashis[index];
                return GestureDetector(
                  onTap: () => _fetchAndShowHoroscope(r['name'], r['hindi'], r['english']),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: r['color'].withOpacity(0.2)),
                      boxShadow: CustomShadows.cardShadow,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(r['icon'], color: r['color'], size: 28),
                        const SizedBox(height: 8),
                        Text(r['english'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
                        Text(r['hindi'], style: TextStyle(fontSize: 11, color: r['color'], fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (_isLoading)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
