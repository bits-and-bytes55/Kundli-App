import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class GrahaSthitiTab extends StatefulWidget {
  final Map<String, dynamic> planets;
  final Map<String, dynamic> ascendant;
  const GrahaSthitiTab({super.key, required this.planets, required this.ascendant});

  @override
  State<GrahaSthitiTab> createState() => _GrahaSthitiTabState();
}

class _GrahaSthitiTabState extends State<GrahaSthitiTab> {
  static const Color _orange = AppColors.primary;
  static const Color _orangeLight = AppColors.accentLight;
  static const Color _textDark = AppColors.textDark;
  static const Color _textGrey = AppColors.textLight;

  // Planet abbreviations in Hindi style for display
  static const Map<String, String> planetHindi = {
    'Lagna': 'लग्न', 'Sun': 'सूर्य', 'Moon': 'चंद्र', 'Mars': 'मंगल',
    'Mercury': 'बुध', 'Jupiter': 'गुरु', 'Venus': 'शुक्र',
    'Saturn': 'शनि', 'Rahu': 'राहु', 'Ketu': 'केतु',
    'Uranus': 'यूरे', 'Neptune': 'नेप', 'Pluto': 'प्लूटो',
  };

  static const List<String> planetOrder = [
    'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu'
  ];

  String _formatDegree(dynamic deg) {
    if (deg == null) return '-';
    final d = (deg as num).toDouble();
    final degrees = d.floor();
    final minsTotal = ((d - degrees) * 60);
    final minutes = minsTotal.floor();
    final seconds = ((minsTotal - minutes) * 60).round();
    return "${degrees.toString().padLeft(2, '0')}°${minutes.toString().padLeft(2, '0')}'${seconds.toString().padLeft(2, '0')}\"";
  }

  @override
  Widget build(BuildContext context) {
    final rows = <Map<String, dynamic>>[
      {'name': 'Lagna', ...widget.ascendant},
      ...planetOrder
          .where((p) => widget.planets.containsKey(p))
          .map((p) => {'name': p, ...widget.planets[p] as Map<String, dynamic>}),
    ];

    return Container(
      color: AppColors.scaffoldBg,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // Legend
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _orangeLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _orange.withOpacity(0.3)),
            ),
            child: Wrap(spacing: 16, runSpacing: 4, children: const [
              _LegendItem(symbol: '(व)', label: 'वक्री (Retrograde)', color: Colors.red),
              _LegendItem(symbol: '(अ)', label: 'अस्त (Combust)', color: Colors.orange),
              _LegendItem(symbol: '↑', label: 'उच्च (Exalted)', color: Colors.green),
              _LegendItem(symbol: '↓', label: 'नीच (Debilitated)', color: Colors.red),
            ]),
          ),

          // Table
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _orange.withOpacity(0.4)),
              boxShadow: [BoxShadow(color: _orange.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _orange,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: Row(children: const [
                  Expanded(flex: 5, child: Text('ग्रह', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                  Expanded(flex: 5, child: Text('राशि', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                  Expanded(flex: 6, child: Text('अंश', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                  Expanded(flex: 6, child: Text('नक्षत्र', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                  Expanded(flex: 2, child: Text('पद', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center)),
                ]),
              ),
              // Rows
              ...rows.asMap().entries.map((entry) {
                final i = entry.key;
                final row = entry.value;
                return _buildRow(row, i);
              }),
            ]),
          ),

          const SizedBox(height: 16),
          // Detail cards
          ...rows.skip(1).map((row) => _detailCard(row)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRow(Map<String, dynamic> p, int index) {
    final name = p['name'] as String;
    final isLagna = name == 'Lagna';
    final retro = p['is_retrograde'] == true;
    final exalted = p['is_exalted'] == true;
    final debil = p['is_debilitated'] == true;

    Color nameColor = _textDark;
    if (exalted) nameColor = Colors.green.shade700;
    if (debil) nameColor = Colors.red.shade600;

    String suffix = '';
    if (retro) suffix += ' (व)';
    if (exalted) suffix += ' ↑';
    if (debil) suffix += ' ↓';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isLagna
            ? const Color(0xFFFFE0B2).withOpacity(0.5)
            : index.isOdd
                ? Colors.white
                : const Color(0xFFFFFBF5),
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(children: [
        Expanded(flex: 5, child: Text(
          '${planetHindi[name] ?? name}$suffix',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: nameColor),
        )),
        Expanded(flex: 5, child: Text(p['rashi'] ?? '-',
          style: const TextStyle(fontSize: 12, color: _orange, fontWeight: FontWeight.w600))),
        Expanded(flex: 6, child: Text(_formatDegree(p['degree']),
          style: const TextStyle(fontSize: 11, color: _textDark))),
        Expanded(flex: 6, child: Text(p['nakshatra'] ?? '-',
          style: const TextStyle(fontSize: 11, color: _textGrey))),
        Expanded(flex: 2, child: Text('(${p['pada'] ?? '-'})',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: _textDark))),
      ]),
    );
  }

  Widget _detailCard(Map<String, dynamic> p) {
    final name = p['name'] as String;
    final retro = p['is_retrograde'] == true;
    final exalted = p['is_exalted'] == true;
    final debil = p['is_debilitated'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _orange.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: _orange.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Column(children: [
        // Card header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_orange.withOpacity(0.85), const Color(0xFFFFCC80)],
              begin: Alignment.centerLeft, end: Alignment.centerRight),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
          ),
          child: Row(children: [
            Text(planetHindi[name] ?? name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(width: 6),
            if (retro) _badge('वक्री', Colors.red.shade800),
            if (exalted) _badge('उच्च', Colors.green.shade700),
            if (debil) _badge('नीच', Colors.red.shade600),
            const Spacer(),
            Text('घर ${p['house'] ?? '-'}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ]),
        ),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), child: Column(children: [
          _detRow('राशि', '${p['rashi'] ?? '-'} (${p['rashi_lord'] ?? '-'})'),
          _detRow('नक्षत्र', '${p['nakshatra'] ?? '-'}  पद ${p['pada'] ?? '-'}'),
          _detRow('नक्षत्र स्वामी', p['nakshatra_lord'] ?? '-'),
          _detRow('नामाक्षर', p['namakshar'] ?? '-'),
          _detRow('अंश', _formatDegree(p['degree'])),
          _detRow('गति (Speed)', '${(p['speed'] as num? ?? 0).toStringAsFixed(4)}°/day'),
        ])),
      ]),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _detRow(String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 7), child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: _textGrey, fontSize: 12)),
        Text(value, style: const TextStyle(color: _textDark, fontWeight: FontWeight.w700, fontSize: 12)),
      ],
    ));
  }
}

class _LegendItem extends StatelessWidget {
  final String symbol, label;
  final Color color;
  const _LegendItem({required this.symbol, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(symbol, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF7F8C8D))),
    ]);
  }
}
