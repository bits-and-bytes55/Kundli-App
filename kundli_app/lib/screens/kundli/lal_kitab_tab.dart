import 'package:flutter/material.dart';
import '../../theme/custom_shadows.dart';

class LalKitabTab extends StatelessWidget {
  final Map<String, dynamic> lalKitab;
  const LalKitabTab({super.key, required this.lalKitab});

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(12), children: [
      Container(padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFFF0F3), Color(0xFFD5F3D8)]),
          borderRadius: BorderRadius.circular(10)),
        child: const Row(children: [
          Icon(Icons.book_rounded, color: Color(0xFFFF7E93)),
          SizedBox(width: 8),
          Text('Lal Kitab Analysis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2C3E50))),
        ])),
      const SizedBox(height: 12),
      ...lalKitab.entries.map((e) => _card(e.key, e.value as Map<String, dynamic>? ?? {})).toList(),
    ]);
  }

  Widget _card(String planet, Map<String, dynamic> data) {
    final remedies = (data['remedies'] as List<dynamic>?)?.cast<String>() ?? [];
    final effects = data['effects'] as String? ?? '';
    final house = data['house'] as int? ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        boxShadow: CustomShadows.cardShadow,
        border: Border.all(color: const Color(0xFFD5F3D8), width: 1.5),
      ),
      child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFFF7E93).withOpacity(0.1), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(planet.substring(0, 1), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF7E93)))),
          const SizedBox(width: 10),
          Text(planet, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFFD5F3D8), borderRadius: BorderRadius.circular(6)),
            child: Text('House $house', style: const TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold, fontSize: 12))),
        ]),
        if (effects.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(effects, style: const TextStyle(color: Color(0xFF34495E), fontSize: 13, height: 1.4)),
        ],
        if (remedies.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Text('Remedies:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFFF7E93))),
          const SizedBox(height: 4),
          ...remedies.map((r) => Padding(padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [
              const Icon(Icons.fiber_manual_record, size: 8, color: Color(0xFFFF7E93)),
              const SizedBox(width: 6),
              Expanded(child: Text(r, style: const TextStyle(fontSize: 12, color: Color(0xFF2C3E50)))),
            ]))).toList(),
        ],
      ])),
    );
  }
}
