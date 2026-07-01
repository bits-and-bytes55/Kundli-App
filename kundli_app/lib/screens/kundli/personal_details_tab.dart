import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';

class PersonalDetailsTab extends StatelessWidget {
  final Map<String, dynamic> personalDetails;
  final String name;
  const PersonalDetailsTab({super.key, required this.personalDetails, required this.name});

  static const Color _orangeBorder = AppColors.border;

  @override
  Widget build(BuildContext context) {
    if (personalDetails.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: Center(child: Text('loading_details'.tr, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // Section 1: Birth Info
          _buildHeader('birth_details'.tr, Icons.cake_rounded),
          _tableCard([
            _row('name'.tr, name.isNotEmpty ? name : 'User'),
            _row('gender'.tr, personalDetails['sex'] ?? 'male'.tr),
            _row('date_of_birth'.tr, personalDetails['dob'] ?? '-'),
            _row('time_of_birth'.tr, personalDetails['tob'] ?? '-'),
            _row('day_of_birth'.tr, personalDetails['day'] ?? '-'),
            _row('ishtkaal'.tr, personalDetails['ishtkaal'] ?? '-'),
          ]),

          const SizedBox(height: 16),

          // Section 2: Birth Place Info
          _buildHeader('place_time_coordinates'.tr, Icons.location_on_rounded),
          _tableCard([
            _row('place_of_birth'.tr, personalDetails['place'] ?? '-'),
            _row('latitude'.tr, personalDetails['latitude'] ?? '-'),
            _row('longitude'.tr, personalDetails['longitude'] ?? '-'),
            _row('time_zone'.tr, personalDetails['timezone'] != null ? 'GMT +${personalDetails['timezone']}' : '-'),
            _row('local_time_corr'.tr, personalDetails['local_time_corr'] ?? '00.00.00'),
            _row('war_time_corr'.tr, personalDetails['war_time_corr'] ?? '00.00.00'),
            _row('lmt_at_birth'.tr, personalDetails['lmt'] ?? '-'),
            _row('gmt_at_birth'.tr, personalDetails['gmt'] ?? '-'),
          ]),

          const SizedBox(height: 16),

          // Section 3: Astrological Birth Panchang
          _buildHeader('panchang_at_birth'.tr, Icons.brightness_high_rounded),
          _tableCard([
            _row('tithi'.tr, personalDetails['tithi'] ?? '-'),
            _row('paksha'.tr, personalDetails['paksha'] ?? '-'),
            _row('hindu_weekday'.tr, personalDetails['hindu_weekday'] ?? '-'),
          ]),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 0.3)),
        ],
      ),
    );
  }

  Widget _tableCard(List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _orangeBorder.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: rows),
    );
  }

  Widget _row(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.w700)),
          Flexible(
            child: Text(value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
