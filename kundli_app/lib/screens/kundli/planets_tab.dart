import 'package:flutter/material.dart';
import '../../theme/custom_shadows.dart';

class PlanetsTab extends StatelessWidget {
  final Map<String, dynamic> planets, ascendant;
  const PlanetsTab({super.key, required this.planets, required this.ascendant});

  static const planetIcons = {
    'Sun': '☀️', 'Moon': '🌙', 'Mars': '♂', 'Mercury': '☿',
    'Jupiter': '♃', 'Venus': '♀', 'Saturn': '♄', 'Rahu': '☊', 'Ketu': '☋'
  };

  @override
  Widget build(BuildContext context) {
    final allPlanets = {'Lagna': ascendant, ...planets};
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Header table
        Card(
          color: const Color(0xFFFF7E93),
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(children: const [
              Expanded(flex: 3, child: Text('Planet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
              Expanded(flex: 3, child: Text('Rashi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
              Expanded(flex: 3, child: Text('Nakshatra', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
              Expanded(flex: 2, child: Text('Deg', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
            ])),
        ),
        ...allPlanets.entries.map((e) => _planetRow(e.key, e.value)).toList(),
        const SizedBox(height: 16),
        ...planets.entries.map((e) => _planetCard(e.key, e.value)).toList(),
      ],
    );
  }

  Widget _planetRow(String name, Map<String, dynamic> p) {
    bool retro = p['is_retrograde'] == true;
    bool exalt = p['is_exalted'] == true;
    bool debil = p['is_debilitated'] == true;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: name == 'Lagna' ? const Color(0xFFD5F3D8).withOpacity(0.5) : Colors.white.withOpacity(0.9),
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(children: [
        Expanded(flex: 3, child: Row(children: [
          Text(planetIcons[name] ?? '★', style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Flexible(child: Text(name + (retro ? 'ᴿ' : '') + (exalt ? '↑' : '') + (debil ? '↓' : ''),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12,
              color: exalt ? Colors.green : debil ? Colors.red : const Color(0xFF2C3E50)))),
        ])),
        Expanded(flex: 3, child: Text(p['rashi'] ?? '-', style: const TextStyle(fontSize: 12, color: Color(0xFFFF7E93)))),
        Expanded(flex: 3, child: Text('${p['nakshatra'] ?? '-'} P${p['pada'] ?? ''}', style: const TextStyle(fontSize: 11, color: Color(0xFF7F8C8D)))),
        Expanded(flex: 2, child: Text('${(p['degree'] as num? ?? 0).toStringAsFixed(1)}°', style: const TextStyle(fontSize: 11))),
      ]),
    );
  }

  Widget _planetCard(String name, Map<String, dynamic> p) {
    bool retro = p['is_retrograde'] == true;
    bool exalt = p['is_exalted'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        boxShadow: CustomShadows.cardShadow,
        border: Border.all(color: const Color(0xFFD5F3D8), width: 1.5),
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [const Color(0xFFD5F3D8), const Color(0xFFFFF0F3)]),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(children: [
            Text(planetIcons[name] ?? '★', style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
            if (retro) Container(margin: const EdgeInsets.only(left: 8), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(4)),
              child: const Text('Retrograde', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold))),
            if (exalt) Container(margin: const EdgeInsets.only(left: 8), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(4)),
              child: const Text('Exalted', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold))),
            const Spacer(),
            Text('H${p['house'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF7E93), fontSize: 14)),
          ]),
        ),
        Padding(padding: const EdgeInsets.all(14), child: Column(children: [
          _row('Rashi', '${p['rashi']} (${p['rashi_lord']})'),
          _row('Nakshatra', '${p['nakshatra']} Pada ${p['pada']}'),
          _row('Nakshatra Lord', '${p['nakshatra_lord']}'),
          _row('Namakshar', '${p['namakshar']}'),
          _row('Degree', '${(p['degree'] as num? ?? 0).toStringAsFixed(4)}°'),
        ])),
      ]),
    );
  }

  Widget _row(String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF7F8C8D), fontSize: 13)),
        Text(value, style: const TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    ));
  }
}
