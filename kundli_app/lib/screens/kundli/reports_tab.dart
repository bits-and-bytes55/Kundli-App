import 'package:flutter/material.dart';
import '../../theme/custom_shadows.dart';

class ReportsTab extends StatelessWidget {
  final Map<String, dynamic> doshas, numerology;
  const ReportsTab({super.key, required this.doshas, required this.numerology});

  @override
  Widget build(BuildContext context) {
    final manglik = doshas['manglik'] as Map<String, dynamic>? ?? {};
    final sadeSati = doshas['sade_sati'] as Map<String, dynamic>? ?? {};
    final kaalSarp = doshas['kaal_sarp'] as Map<String, dynamic>? ?? {};
    return ListView(padding: const EdgeInsets.all(12), children: [
      _sectionTitle('Dosha Analysis'),
      const SizedBox(height: 8),
      _doshaCard('Manglik Dosha (कुज दोष)', manglik['is_manglik'] == true, manglik['report'] as String? ?? '', 'Mars', manglik['mars_house']),
      _doshaCard('Sade Sati (साढ़े साती)', sadeSati['in_sade_sati'] == true, sadeSati['report'] as String? ?? '', 'Saturn', null,
        extraBadge: sadeSati['phase'] as String?),
      _doshaCard('Kaal Sarp Yoga (काल सर्प)', kaalSarp['present'] == true, kaalSarp['report'] as String? ?? '', 'Rahu', null,
        extraBadge: kaalSarp['type'] as String?),
      const SizedBox(height: 16),
      _sectionTitle('Numerology (अंक ज्योतिष)'),
      const SizedBox(height: 8),
      _numerologyCard(numerology),
    ]);
  }

  Widget _sectionTitle(String t) {
    return Row(children: [
      Container(width: 4, height: 20, decoration: BoxDecoration(color: const Color(0xFFFF7E93), borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(t, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
    ]);
  }

  Widget _doshaCard(String title, bool present, String report, String planet, int? house, {String? extraBadge}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        boxShadow: CustomShadows.cardShadow,
        border: Border.all(color: present ? const Color(0xFFFF7E93) : const Color(0xFFD5F3D8), width: 1.5),
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(present ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
            color: present ? const Color(0xFFFF7E93) : Colors.green, size: 24),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)))),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: present ? const Color(0xFFFF7E93) : Colors.green,
              borderRadius: BorderRadius.circular(6)),
            child: Text(present ? 'PRESENT' : 'ABSENT',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
          if (house != null) ...[
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(color: const Color(0xFFD5F3D8), borderRadius: BorderRadius.circular(6)),
              child: Text('$planet in House $house', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF2C3E50)))),
          ],
          if (extraBadge != null && extraBadge.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.orange.shade200)),
              child: Text(extraBadge, style: TextStyle(fontSize: 10, color: Colors.orange.shade700, fontWeight: FontWeight.w600))),
          ],
        ]),
        if (report.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(report, style: const TextStyle(color: Color(0xFF34495E), fontSize: 13, height: 1.5)),
        ],
      ])),
    );
  }

  Widget _numerologyCard(Map<String, dynamic> n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        boxShadow: CustomShadows.cardShadow,
        border: Border.all(color: const Color(0xFFD5F3D8), width: 1.5),
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _numBox('Moolank\n(Radical No.)', '${n['moolank'] ?? '-'}', n['moolank_planet'] as String? ?? ''),
          Container(width: 1, height: 60, color: const Color(0xFFD5F3D8)),
          _numBox('Bhagyank\n(Destiny No.)', '${n['bhagyank'] ?? '-'}', ''),
        ]),
        const Divider(color: Color(0xFFD5F3D8), height: 24),
        Text(n['report'] as String? ?? '', style: const TextStyle(color: Color(0xFF34495E), fontSize: 13, height: 1.5)),
        if ((n['bhagyank_report'] as String? ?? '').isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(n['bhagyank_report'] as String? ?? '', style: const TextStyle(color: Color(0xFF7F8C8D), fontSize: 12, height: 1.5)),
        ],
      ])),
    );
  }

  Widget _numBox(String label, String value, String planet) {
    return Column(children: [
      Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF7F8C8D), fontSize: 12)),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFFFF7E93))),
      if (planet.isNotEmpty) Text(planet, style: const TextStyle(color: Color(0xFF27AE60), fontWeight: FontWeight.w600, fontSize: 12)),
    ]);
  }
}
