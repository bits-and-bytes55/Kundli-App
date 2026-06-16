import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../birth_form_screen.dart';
import '../milan_screen.dart';
import '../panchang_screen.dart';
import '../horoscope_screen.dart';
import '../transit_screen.dart';
import '../../theme/app_theme.dart';
import '../../theme/custom_shadows.dart';

class ServicesTab extends StatelessWidget {
  const ServicesTab({super.key});

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
          title: const Text('Astrology Services (सेवाएं)'),
          elevation: 0.5,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('Calculations & Charts'),
            _buildServiceItem(
              Icons.auto_awesome_rounded,
              'Janam Kundli (जन्म कुंडली)',
              'Generate detailed birth charts, planetary positions and planetary influences.',
              Colors.orange,
              () => Get.to(() => BirthFormScreen(initialTabIdx: 0)),
            ),
            _buildServiceItem(
              Icons.favorite_rounded,
              'Kundli Milan (गुण मिलान)',
              'Ashtakoot 36-Guna matching for marriage compatibility and doshas.',
              Colors.pink,
              () => Get.to(() => const MilanScreen()),
            ),
            _buildServiceItem(
              Icons.calendar_month_rounded,
              'Detailed Panchang (पंचांग)',
              'Daily Vedic calendar showing Tithi, Nakshatra, Yoga, Karana, and Muhurtas.',
              Colors.indigo,
              () => Get.to(() => const PanchangScreen()),
            ),
            const SizedBox(height: 16),
            _buildSectionHeader('Personal Readings & Predictions'),
            _buildServiceItem(
              Icons.stars_rounded,
              'Daily Horoscope (राशिफल)',
              'Personalized daily cosmic forecasts for Career, Health, Love, and Wealth.',
              Colors.purple,
              () => Get.to(() => const HoroscopeScreen()),
            ),
            _buildServiceItem(
              Icons.format_list_numbered_rounded,
              'Numerology (अंकशास्त्र)',
              'Vedic numerological reports, lucky numbers, and life path details.',
              Colors.teal,
              () => Get.to(() => BirthFormScreen(initialTabIdx: 9)),
            ),
            _buildServiceItem(
              Icons.book_rounded,
              'Lal Kitab (लाल किताब)',
              'Unique Lal Kitab planetary positions, predictions, and simple remedies.',
              Colors.deepOrange,
              () => Get.to(() => BirthFormScreen(initialTabIdx: 8)),
            ),
            const SizedBox(height: 16),
            _buildSectionHeader('Divisions & Transits'),
            _buildServiceItem(
              Icons.wb_twilight_rounded,
              'Planet Transits (गोचर)',
              'Realtime celestial transits and planetary degree movements in signs.',
              Colors.blue,
              () => Get.to(() => const TransitScreen()),
            ),
            _buildServiceItem(
              Icons.layers_rounded,
              'Shodashvarga (षोडशवर्ग)',
              '16 divisional charts including Navamsha (D9) for micro analysis.',
              Colors.cyan,
              () => Get.to(() => BirthFormScreen(initialTabIdx: 7)),
            ),
            _buildServiceItem(
              Icons.timelapse_rounded,
              'Vimshottari Dasha (महादशा)',
              'Calculate planetary periods and subperiods to forecast event timings.',
              Colors.green,
              () => Get.to(() => BirthFormScreen(initialTabIdx: 5)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textDark),
      ),
    );
  }

  Widget _buildServiceItem(IconData icon, String title, String desc, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.12), width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textDark),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            desc,
            style: const TextStyle(fontSize: 11, color: AppColors.textMedium, height: 1.3),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
