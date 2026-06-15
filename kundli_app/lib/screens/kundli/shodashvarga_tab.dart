import 'package:flutter/material.dart';
import '../../theme/custom_shadows.dart';

class ShodashvargaTab extends StatefulWidget {
  final Map<String, dynamic> shodashvarga;
  const ShodashvargaTab({super.key, required this.shodashvarga});
  @override State<ShodashvargaTab> createState() => _ShodashvargaTabState();
}

class _ShodashvargaTabState extends State<ShodashvargaTab> {
  String _selected = 'D9';

  static const chartNames = {
    'D1': 'Rasi — Birth Chart', 'D2': 'Hora — Wealth',
    'D3': 'Drekkana — Siblings', 'D4': 'Chaturthamsha — Fortune',
    'D7': 'Saptamsha — Children', 'D9': 'Navamsa — Marriage/Dharma',
    'D10': 'Dashamsha — Career', 'D12': 'Dwadashamsha — Parents',
    'D16': 'Shodashamsha — Vehicle', 'D20': 'Vimshamsha — Spirituality',
    'D24': 'Chaturvimshamsha — Education', 'D27': 'Nakshatramsha — Strength',
    'D30': 'Trimshamsha — Misfortune', 'D40': 'Khavedamsha — Maternal',
    'D45': 'Akshavedamsha — Paternal', 'D60': 'Shashtiamsha — Past Life',
  };

  @override
  Widget build(BuildContext context) {
    final chart = (widget.shodashvarga[_selected] as Map<String, dynamic>?) ?? {};
    return Container(
      color: const Color(0xFFFFF5F7),
      child: Column(children: [
        Container(
          height: 48, color: Colors.white,
          child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            children: chartNames.keys.map((k) {
              bool sel = _selected == k;
              return GestureDetector(
                onTap: () => setState(() => _selected = k),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: sel ? const Color(0xFFFF7E93) : Colors.transparent,
                    border: Border.all(color: sel ? const Color(0xFFFF7E93) : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(16)),
                  alignment: Alignment.center,
                  child: Text(k, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12,
                    color: sel ? Colors.white : const Color(0xFF7F8C8D))),
                ),
              );
            }).toList()),
        ),
        Expanded(child: ListView(padding: const EdgeInsets.all(12), children: [
          Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFD5F3D8), Color(0xFFFFF0F3)]),
              borderRadius: BorderRadius.circular(10)),
            child: Text(chartNames[_selected] ?? _selected,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2C3E50)))),
          const SizedBox(height: 12),
          ...chart.entries.map((e) => _row(e.key, e.value as Map<String, dynamic>? ?? {})).toList(),
        ])),
      ]),
    );
  }

  Widget _row(String planet, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD5F3D8)),
      ),
      child: Row(children: [
        SizedBox(width: 80, child: Text(planet, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2C3E50)))),
        const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFFFF7E93)),
        const SizedBox(width: 8),
        Text(data['rashi'] as String? ?? '-', style: const TextStyle(color: Color(0xFFFF7E93), fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(width: 4),
        Text('(${data['rashi_lord'] ?? '-'})', style: const TextStyle(color: Color(0xFF7F8C8D), fontSize: 12)),
      ]),
    );
  }
}
