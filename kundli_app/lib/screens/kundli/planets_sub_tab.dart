import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// AstroSage-style "Planets-Sub" tab
/// Columns: Pla | Degree (absolute) | SL | NL | SB | SS
class PlanetsSubTab extends StatelessWidget {
  final Map<String, dynamic> kpPlanets;
  final Map<String, dynamic> kpAscendant;

  const PlanetsSubTab({
    super.key,
    required this.kpPlanets,
    required this.kpAscendant,
  });

  static const _planetOrder = [
    'Lagna', 'Sun', 'Moon', 'Mars', 'Mercury',
    'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu',
  ];

  static const _abbrev = {
    'Lagna': 'Lag', 'Sun': 'Sun', 'Moon': 'Mon', 'Mars': 'Mar',
    'Mercury': 'Mer', 'Jupiter': 'Jup', 'Venus': 'Ven',
    'Saturn': 'Sat', 'Rahu': 'Rah', 'Ketu': 'Ket',
  };

  static const _lordAbbrev = {
    'Surya': 'Su', 'Chandra': 'Mo', 'Mangal': 'Ma', 'Budha': 'Me',
    'Guru': 'Ju', 'Shukra': 'Ve', 'Shani': 'Sa', 'Rahu': 'Ra', 'Ketu': 'Ke',
    'Sun': 'Su', 'Moon': 'Mo', 'Mars': 'Ma', 'Mercury': 'Me',
    'Jupiter': 'Ju', 'Venus': 'Ve', 'Saturn': 'Sa',
  };

  String _lordAbb(String? lord) => _lordAbbrev[lord] ?? (lord?.substring(0, 2) ?? '-');

  /// Format absolute longitude as DD°MM'SS"
  String _formatAbsLon(dynamic lon) {
    if (lon == null) return '-';
    final d = (lon as num).toDouble();
    final deg = d.floor();
    final minsTotal = (d - deg) * 60;
    final min = minsTotal.floor();
    final sec = ((minsTotal - min) * 60).round();
    return "${deg.toString().padLeft(3, '0')}°${min.toString().padLeft(2, '0')}'${sec.toString().padLeft(2, '0')}\"";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scaffoldBg,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // Info banner
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Wrap(spacing: 14, runSpacing: 4, children: const [
              _InfoChip('SL', 'Sign Lord'),
              _InfoChip('NL', 'Nakshatra Lord'),
              _InfoChip('SB', 'Sub Lord'),
              _InfoChip('SS', 'Sub-Sub Lord'),
            ]),
          ),

          // Table
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(children: [
              _headerRow(),
              ..._buildRows(),
            ]),
          ),

          const SizedBox(height: 20),
          // Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.accentLight),
            ),
            child: const Text(
              'Note:\nSL - Sign Lord\nNL - Nakshatra Lord\nSB - Sub Lord\nSS - Sub-Sub Lord\n(C) - Combust  (R) - Retrograde',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMedium,
                height: 1.7,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _headerRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Row(children: const [
        Expanded(flex: 5, child: Text('Pla',    style: _hStyle)),
        Expanded(flex: 7, child: Text('Degree', style: _hStyle)),
        Expanded(flex: 3, child: Text('SL',     style: _hStyle)),
        Expanded(flex: 3, child: Text('NL',     style: _hStyle)),
        Expanded(flex: 3, child: Text('SB',     style: _hStyle)),
        Expanded(flex: 3, child: Text('SS',     style: _hStyle)),
      ]),
    );
  }

  List<Widget> _buildRows() {
    final rows = <Widget>[];
    int idx = 0;
    for (final pname in _planetOrder) {
      Map<String, dynamic>? p;
      bool isRetro = false;
      bool isCombust = false;
      double? lon;
      String? sl, nl, sb, ss;

      if (pname == 'Lagna') {
        p = Map<String, dynamic>.from(kpAscendant);
        lon = (p['longitude'] as num?)?.toDouble();
        sl = _lordAbb(p['rashi_lord']?.toString());
        nl = _lordAbb(p['nakshatra_lord']?.toString());
        sb = _lordAbb(p['sub_lord']?.toString());
        ss = _lordAbb(p['sub_sub_lord']?.toString());
      } else if (kpPlanets.containsKey(pname)) {
        p = kpPlanets[pname] as Map<String, dynamic>;
        lon = (p['longitude'] as num?)?.toDouble();
        isRetro = p['is_retrograde'] == true;
        isCombust = p['is_combust'] == true;
        sl = _lordAbb(p['rashi_lord']?.toString());
        nl = _lordAbb(p['nakshatra_lord']?.toString());
        sb = _lordAbb(p['sub_lord']?.toString());
        ss = _lordAbb(p['sub_sub_lord']?.toString());
      }
      if (p == null) continue;

      String suffix = '';
      if (isRetro) suffix += ' (R)';
      if (isCombust) suffix += ' (C)';

      final isLagna = pname == 'Lagna';
      final bg = isLagna
          ? AppColors.accentLight
          : idx.isOdd ? Colors.white : const Color(0xFFFFFBF5);

      rows.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: bg,
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(children: [
          Expanded(flex: 5, child: Text(
            '${_abbrev[pname] ?? pname}$suffix',
            style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold,
              color: isRetro ? Colors.red.shade700 : AppColors.textDark,
            ),
          )),
          Expanded(flex: 7, child: Text(
            _formatAbsLon(lon),
            style: const TextStyle(fontSize: 11, color: AppColors.textDark, fontFamily: 'monospace'),
          )),
          Expanded(flex: 3, child: _lordCell(sl)),
          Expanded(flex: 3, child: _lordCell(nl, color: const Color(0xFF1565C0))),
          Expanded(flex: 3, child: _lordCell(sb, color: const Color(0xFF2E7D32))),
          Expanded(flex: 3, child: _lordCell(ss, color: const Color(0xFF6A1B9A))),
        ]),
      ));
      idx++;
    }
    return rows;
  }

  Widget _lordCell(String? text, {Color color = AppColors.primary}) {
    return Text(
      text ?? '-',
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
    );
  }

  static const _hStyle = TextStyle(
    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12,
  );
}

class _InfoChip extends StatelessWidget {
  final String code, label;
  const _InfoChip(this.code, this.label);
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(code, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMedium)),
    ]);
  }
}
