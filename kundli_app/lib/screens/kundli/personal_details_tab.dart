import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PersonalDetailsTab extends StatelessWidget {
  final Map<String, dynamic> personalDetails;
  const PersonalDetailsTab({super.key, required this.personalDetails});

  static const Color _orange      = AppColors.primary;
  static const Color _orangeLight = AppColors.accentLight;
  static const Color _orangeBorder= AppColors.border;
  static const Color _textDark    = AppColors.textDark;
  static const Color _textGrey    = AppColors.textLight;

  @override
  Widget build(BuildContext context) {
    if (personalDetails.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: Center(child: Text('Loading details...', style: TextStyle(color: _textDark))),
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
            _row('Name', personalDetails['place'] != null ? (personalDetails['place'].toString().isNotEmpty ? personalDetails['place'].toString() : 'User') : 'User'),
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
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: _orange, size: 18),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: _orange, letterSpacing: 0.3)),
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
        boxShadow: [BoxShadow(color: _orange.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
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
          Text(label, style: const TextStyle(fontSize: 13, color: _textGrey, fontWeight: FontWeight.w500)),
          Flexible(
            child: Text(value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
