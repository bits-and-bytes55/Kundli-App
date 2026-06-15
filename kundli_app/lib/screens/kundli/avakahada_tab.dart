import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AvakahadaTab extends StatelessWidget {
  final Map<String, dynamic> avakahada;
  final Map<String, dynamic> ascendant;
  const AvakahadaTab({super.key, required this.avakahada, required this.ascendant});

  static const Color _orange      = AppColors.primary;
  static const Color _orangeLight = AppColors.accentLight;
  static const Color _orangeBorder= AppColors.border;
  static const Color _textDark    = AppColors.textDark;
  static const Color _textGrey    = AppColors.textLight;

  @override
  Widget build(BuildContext context) {
    // If avakahada is empty (old cached data before server update), show prompt
    if (avakahada.isEmpty || avakahada['paya'] == null) {
      return Container(
        color: AppColors.scaffoldBg,
        child: Center(child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.refresh_rounded, size: 52, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'अवकहड़ा डेटा उपलब्ध नहीं है',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Please go back and regenerate the Kundli to load\nAvakahada Chakra data.',
              style: TextStyle(fontSize: 13, color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
          ]),
        )),
      );
    }

    return Container(
      color: AppColors.scaffoldBg,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: _orange,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('अवकहड़ा चक्र',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
          ),
          const SizedBox(height: 12),

          // Main Table
          _tableCard([
            _row('पाया (Nakshatra Aadharit)', avakahada['paya'] ?? '-'),
            _row('वर्ण', avakahada['varna'] ?? '-'),
            _row('योनी', avakahada['yoni'] ?? '-'),
            _row('गण', avakahada['gana'] ?? '-'),
            _row('वश्य', avakahada['vashya'] ?? '-'),
            _row('नाड़ी', avakahada['nadi'] ?? '-'),
          ]),

          const SizedBox(height: 10),
          _sectionLabel('दशा विवरण'),
          _tableCard([
            _row('दशा भोग्य', avakahada['dasha_bhogya'] ?? '-'),
          ]),

          const SizedBox(height: 10),
          _sectionLabel('लग्न एवं राशि'),
          _tableCard([
            _row('लग्न', avakahada['lagna'] ?? '-'),
            _row('लग्न स्वामी', avakahada['lagna_swami'] ?? '-'),
            _row('राशि', avakahada['rashi'] ?? '-'),
            _row('राशि स्वामी', avakahada['rashi_swami'] ?? '-'),
            _row('नक्षत्र-पद', avakahada['nakshatra_pad'] ?? '-'),
            _row('नक्षत्र स्वामी', avakahada['nakshatra_swami'] ?? '-'),
          ]),

          const SizedBox(height: 10),
          _sectionLabel('अन्य'),
          _tableCard([
            _row('जिलैयन दिन', '${avakahada['julian_day'] ?? '-'}'),
            _row('Moon Nakshatra', avakahada['moon_nakshatra'] ?? '-'),
            _row('Moon Pada', '${avakahada['moon_pada'] ?? '-'}'),
          ]),

          const SizedBox(height: 20),

          // Lagna info card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _orangeLight,
              border: Border.all(color: _orangeBorder, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(children: [
              Row(children: [
                const Icon(Icons.info_outline_rounded, color: _orange, size: 18),
                const SizedBox(width: 8),
                const Text('Ascendant Details', style: TextStyle(fontWeight: FontWeight.bold, color: _textDark, fontSize: 14)),
              ]),
              const SizedBox(height: 10),
              _miniRow('Lagna Rashi', ascendant['rashi'] ?? '-'),
              _miniRow('Degree', '${(ascendant['degree'] as num? ?? 0).toStringAsFixed(2)}°'),
              _miniRow('Nakshatra', ascendant['nakshatra'] ?? '-'),
              _miniRow('Nakshatra Lord', ascendant['nakshatra_lord'] ?? '-'),
              _miniRow('Pada', '${ascendant['pada'] ?? '-'}'),
            ]),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(
        fontSize: 13, fontWeight: FontWeight.bold, color: _orange, letterSpacing: 0.3)),
    );
  }

  Widget _tableCard(List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _orangeBorder.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: _orange.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(children: rows),
    );
  }

  Widget _row(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 13, color: _textGrey, fontWeight: FontWeight.w500)),
        Flexible(
          child: Text(value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }

  Widget _miniRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 12, color: _textGrey)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _textDark)),
      ]),
    );
  }
}
