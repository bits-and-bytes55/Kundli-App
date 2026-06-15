import 'package:flutter/material.dart';
import '../../theme/custom_shadows.dart';

class YogaTab extends StatelessWidget {
  final List<dynamic> yogas;
  const YogaTab({super.key, required this.yogas});

  @override
  Widget build(BuildContext context) {
    if (yogas.isEmpty) {
      return Container(
        color: const Color(0xFFFFF5F7),
        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.info_outline_rounded, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('No significant Yogas found', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
        ])),
      );
    }
    return Container(
      color: const Color(0xFFFFF5F7),
      child: ListView(padding: const EdgeInsets.all(12), children: [
        Container(padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFD5F3D8), Color(0xFFFFF0F3)]),
            borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFF7E93)),
            const SizedBox(width: 8),
            Text('${yogas.length} Yoga(s) Found', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2C3E50))),
          ])),
        const SizedBox(height: 12),
        ...yogas.map((y) => _yogaCard(y as Map<String, dynamic>)).toList(),
      ]),
    );
  }

  Widget _yogaCard(Map<String, dynamic> yoga) {
    final name = yoga['name'] as String? ?? '';
    final desc = yoga['description'] as String? ?? '';
    bool isKaal = name.contains('Kaal Sarp');
    bool isGood = !isKaal && !name.contains('Dosha');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        boxShadow: CustomShadows.cardShadow,
        border: Border.all(color: isKaal ? Colors.red.shade200 : const Color(0xFFD5F3D8), width: 1.5),
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(isKaal ? Icons.warning_amber_rounded : Icons.star_rounded,
            color: isKaal ? Colors.red : const Color(0xFFFF7E93), size: 24),
          const SizedBox(width: 8),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isKaal ? Colors.red : const Color(0xFFFF7E93),
              borderRadius: BorderRadius.circular(6)),
            child: Text(isGood ? 'Beneficial' : 'Malefic', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 10),
        Text(desc, style: const TextStyle(color: Color(0xFF34495E), fontSize: 14, height: 1.5)),
      ])),
    );
  }
}
