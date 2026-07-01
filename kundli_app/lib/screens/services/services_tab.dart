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
          title: Text('astrology_services'.tr),
          elevation: 0.5,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('calc_charts'.tr),
            _buildServiceItem(
              Icons.auto_awesome_rounded,
              'janam_kundli'.tr,
              'janam_kundli_desc'.tr,
              Colors.orange,
              () => Get.to(() => BirthFormScreen(initialTabIdx: 0)),
            ),
            _buildServiceItem(
              Icons.favorite_rounded,
              'kundli_milan'.tr,
              'kundli_milan_desc'.tr,
              Colors.pink,
              () => Get.to(() => const MilanScreen()),
            ),
            _buildServiceItem(
              Icons.calendar_month_rounded,
              'detailed_panchang'.tr,
              'detailed_panchang_desc'.tr,
              Colors.indigo,
              () => Get.to(() => const PanchangScreen()),
            ),
            const SizedBox(height: 16),
            _buildSectionHeader('personal_readings'.tr),
            _buildServiceItem(
              Icons.stars_rounded,
              'horoscope'.tr,
              'daily_horoscope_desc'.tr,
              Colors.purple,
              () => Get.to(() => const HoroscopeScreen()),
            ),
            _buildServiceItem(
              Icons.format_list_numbered_rounded,
              'numerology'.tr,
              'numerology_desc'.tr,
              Colors.teal,
              () => Get.to(() => BirthFormScreen(initialTabIdx: 9)),
            ),
            _buildServiceItem(
              Icons.book_rounded,
              'lal_kitab'.tr,
              'lal_kitab_desc'.tr,
              Colors.deepOrange,
              () => Get.to(() => BirthFormScreen(initialTabIdx: 8)),
            ),
            const SizedBox(height: 16),
            _buildSectionHeader('divisions_transits'.tr),
            _buildServiceItem(
              Icons.wb_twilight_rounded,
              'planet_transits'.tr,
              'planet_transits_desc'.tr,
              Colors.blue,
              () => Get.to(() => const TransitScreen()),
            ),
            _buildServiceItem(
              Icons.layers_rounded,
              'shodashvarga'.tr,
              'shodashvarga_desc'.tr,
              Colors.cyan,
              () => Get.to(() => BirthFormScreen(initialTabIdx: 7)),
            ),
            _buildServiceItem(
              Icons.timelapse_rounded,
              'vimshottari_dasha'.tr,
              'vimshottari_dasha_desc'.tr,
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
