import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PersonalDetailsTab extends StatelessWidget {
  final Map<String, dynamic> personalDetails;
  final String name;
  const PersonalDetailsTab({super.key, required this.personalDetails, required this.name});

  static const Color _orangeBorder = AppColors.border;

  @override
  Widget build(BuildContext context) {
    if (personalDetails.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: Center(child: Text('Loading details...', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // Section 1: Birth Info
          _buildHeader('Birth Details', Icons.cake_rounded),
          _tableCard([
            _row('Name', name.isNotEmpty ? name : 'User'),
            _row('Gender', personalDetails['sex'] ?? 'Male'),
            _row('Date of Birth', personalDetails['dob'] ?? '-'),
            _row('Time of Birth', personalDetails['tob'] ?? '-'),
            _row('Day of Birth', personalDetails['day'] ?? '-'),
            _row('Ishtkaal', personalDetails['ishtkaal'] ?? '-'),
          ]),

          const SizedBox(height: 16),

          // Section 2: Birth Place Info
          _buildHeader('Place & Time Coordinates', Icons.location_on_rounded),
          _tableCard([
            _row('Place of Birth', personalDetails['place'] ?? '-'),
            _row('Latitude', personalDetails['latitude'] ?? '-'),
            _row('Longitude', personalDetails['longitude'] ?? '-'),
            _row('Time Zone', personalDetails['timezone'] != null ? 'GMT +${personalDetails['timezone']}' : '-'),
            _row('Local Time Corr.', personalDetails['local_time_corr'] ?? '00.00.00'),
            _row('War Time Corr.', personalDetails['war_time_corr'] ?? '00.00.00'),
            _row('LMT at Birth', personalDetails['lmt'] ?? '-'),
            _row('GMT at Birth', personalDetails['gmt'] ?? '-'),
          ]),

          const SizedBox(height: 16),

          // Section 3: Astrological Birth Panchang
          _buildHeader('Panchang at Birth', Icons.brightness_high_rounded),
          _tableCard([
            _row('Tithi', personalDetails['tithi'] ?? '-'),
            _row('Paksha', personalDetails['paksha'] ?? '-'),
            _row('Hindu Weekday', personalDetails['hindu_weekday'] ?? '-'),
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
