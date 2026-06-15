import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../birth_form_screen.dart';
import '../milan_screen.dart';
import '../../theme/app_theme.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/images/ChatGPT Image Jun 14, 2026, 10_51_39 PM.png'), fit: BoxFit.fill)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.9),
          elevation: 0,
          title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('नमस्ते 🙏', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            Text('Kundli Jyotish', style: TextStyle(fontSize: 13, color: Color(0xFF7F8C8D), fontWeight: FontWeight.w500)),
          ]),
          actions: [IconButton(icon: const Icon(Icons.notifications_none_rounded), onPressed: () {})],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.white.withOpacity(0.95),
                  AppColors.accentLight.withOpacity(0.9),
                ]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.wb_sunny_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 6),
                  Text("Today's Panchang", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                  const Spacer(),
                  Text(_todayStr(), style: const TextStyle(fontSize: 11, color: Color(0xFF7F8C8D))),
                ]),
                const SizedBox(height: 12),
                _pRow('Tithi', 'Shukla Paksha Dashami'), _pRow('Nakshatra', 'Hasta'), _pRow('Yoga', 'Shiva'), _pRow('Karana', 'Balava'),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.all(10)),
                  onPressed: () {},
                  child: const Text('View Full Panchang'))),
              ]),
            ),
            const SizedBox(height: 20),
            const Text('Quick Services', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.88,
              children: [
                _svc(Icons.auto_awesome_rounded, 'Kundli', AppColors.primary, () => Get.to(() => BirthFormScreen())),
                _svc(Icons.favorite_rounded, 'Milan', const Color(0xFFE91E63), () => Get.to(() => const MilanScreen())),
                _svc(Icons.timelapse_rounded, 'Dasha', const Color(0xFF9C27B0), () => Get.to(() => BirthFormScreen())),
                _svc(Icons.calendar_month_rounded, 'Panchang', const Color(0xFFFF5722), () {}),
                _svc(Icons.stars_rounded, 'Horoscope', AppColors.primary, () {}),
                _svc(Icons.format_list_numbered_rounded, 'Numerology', const Color(0xFF4CAF50), () {}),
                _svc(Icons.book_rounded, 'Lal Kitab', const Color(0xFF795548), () {}),
                _svc(Icons.layers_rounded, 'Shodashvarga', const Color(0xFF607D8B), () {}),
                _svc(Icons.wb_twilight_rounded, 'Transit', const Color(0xFF2196F3), () {}),
              ],
            ),
            const SizedBox(height: 20),
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.1), AppColors.accent.withOpacity(0.5)]),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3))),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                const Expanded(child: Text('Powered by Swiss Ephemeris • Lahiri Ayanamsa • Vimshottari Dasha',
                  style: TextStyle(fontSize: 11, color: Color(0xFF7F8C8D)))),
              ]),
            ),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  Widget _pRow(String title, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, color: Color(0xFF2C3E50), fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF7F8C8D))),
      ],
    ));
  }

  Widget _svc(IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))]),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.12)),
            child: Icon(icon, color: color, size: 26)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2C3E50))),
        ]),
      ),
    );
  }
}
