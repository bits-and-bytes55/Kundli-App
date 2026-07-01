import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// AstroSage-style "Planets" tab
/// Columns: Pla | Sign | Degree (DMS in sign) | Naks | Rel (house)
class PlanetsTab extends StatelessWidget {
  final Map<String, dynamic> planets;
  final Map<String, dynamic> ascendant;

  const PlanetsTab({super.key, required this.planets, required this.ascendant});

  static const _planetOrder = [
    'Lagna', 'Sun', 'Moon', 'Mars', 'Mercury',
    'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu',
    'Uranus', 'Neptune', 'Pluto',
  ];

  static const _abbrev = {
    'Lagna': 'Lag', 'Sun': 'Sun', 'Moon': 'Mon', 'Mars': 'Mar',
    'Mercury': 'Mer', 'Jupiter': 'Jup', 'Venus': 'Ven',
    'Saturn': 'Sat', 'Rahu': 'Rah', 'Ketu': 'Ket',
    'Uranus': 'Ura', 'Neptune': 'Nep', 'Pluto': 'Plu',
  };

  static const _rashiAbbrev = {
    'Mesh': 'Ari', 'Vrishabh': 'Tau', 'Mithun': 'Gem', 'Kark': 'Can',
    'Singh': 'Leo', 'Kanya': 'Vir', 'Tula': 'Lib', 'Vrischik': 'Sco',
    'Dhanu': 'Sag', 'Makar': 'Cap', 'Kumbh': 'Aqu', 'Meen': 'Pis',
  };

  static const _nakshatraAbbrev = {
    'Ashwini': 'Ashwi', 'Bharani': 'Bhara', 'Krittika': 'Kriti',
    'Rohini': 'Rohin', 'Mrigashira': 'Mriga', 'Ardra': 'Ardra',
    'Punarvasu': 'Punar', 'Pushya': 'Pushya', 'Ashlesha': 'Ashle',
    'Magha': 'Magha', 'P.Phalguni': 'P.Pha', 'U.Phalguni': 'U.Pha',
    'Hasta': 'Hasta', 'Chitra': 'Chita', 'Swati': 'Swati',
    'Vishakha': 'Visha', 'Anuradha': 'Anura', 'Jyeshtha': 'Jyest',
    'Moola': 'Moola', 'P.Ashadha': 'P.Ash', 'U.Ashadha': 'U.Ash',
    'Shravana': 'Sravan', 'Dhanishtha': 'Dhani', 'Shatabhisha': 'Shata',
    'P.Bhadra': 'P.Bha', 'U.Bhadra': 'U.Bha', 'Revati': 'Revat',
  };

  String _rashiAbb(String? r) => _rashiAbbrev[r] ?? r ?? '-';
  String _naksAbb(String? n) => _nakshatraAbbrev[n] ?? n ?? '-';

  /// Format degree within sign as DD°MM'SS"
  String _formatDMS(dynamic deg) {
    if (deg == null) return '-';
    final d = (deg as num).toDouble();
    final degrees = d.floor();
    final minsTotal = (d - degrees) * 60;
    final min = minsTotal.floor();
    final sec = ((minsTotal - min) * 60).round();
    return "${degrees.toString().padLeft(2, '0')}°${min.toString().padLeft(2, '0')}'${sec.toString().padLeft(2, '0')}\"";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scaffoldBg,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Legend card (like AstroSage orange legend)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withOpacity(0.4)),
            ),
            child: Wrap(spacing: 16, runSpacing: 4, children: [
              _LegChip('star_retrograde'.tr),
              _LegChip('caret_combust'.tr),
              _LegChip('sq_vargottama'.tr),
              _LegChip('up_exalted'.tr),
              _LegChip('down_debilitated'.tr),
            ]),
          ),

          // Table container
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withOpacity(0.35)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.07),
                  blurRadius: 10, offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(children: [
              _headerRow(),
              ..._buildRows(),
            ]),
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
      child: Row(children: [
        Expanded(flex: 4, child: Text('pla'.tr,    style: _hStyle)),
        Expanded(flex: 4, child: Text('sign_col'.tr,   style: _hStyle)),
        Expanded(flex: 6, child: Text('degree_col'.tr, style: _hStyle)),
        Expanded(flex: 4, child: Text('naks'.tr,   style: _hStyle)),
        Expanded(flex: 3, child: Text('rel'.tr,    style: _hStyle, textAlign: TextAlign.center)),
      ]),
    );
  }

  List<Widget> _buildRows() {
    final rows = <Widget>[];
    int idx = 0;
    for (final pname in _planetOrder) {
      Map<String, dynamic>? p;
      int house = 0;

      if (pname == 'Lagna') {
        p = Map<String, dynamic>.from(ascendant);
        house = 1;
      } else if (planets.containsKey(pname)) {
        p = planets[pname] as Map<String, dynamic>;
        house = (p['house'] as num? ?? 0).toInt();
      }
      if (p == null) continue;

      bool retro  = p['is_retrograde'] == true;
      if (pname == 'Rahu' || pname == 'Ketu') retro = true;
      final exalt  = p['is_exalted'] == true;
      final debil  = p['is_debilitated'] == true;
      final comb   = p['is_combust'] == true;
      final pLon = (p['longitude'] as num? ?? 0.0).toDouble();
      int d1Sign = (pLon / 30.0).floor() % 12;
      int d9Sign = (pLon / (360.0 / 108.0)).floor() % 12;
      final varg = (pname != 'Lagna' && d1Sign == d9Sign);
      final isLagna = pname == 'Lagna';

      String suffix = '';
      if (retro)  suffix += ' *';
      if (comb)   suffix += ' ^';
      if (varg)   suffix += ' □';

      Color nameColor = AppColors.textDark;
      if (exalt) nameColor = const Color(0xFF2E7D32);
      if (debil) nameColor = const Color(0xFFC62828);

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
          Expanded(flex: 4, child: Text(
            '${_abbrev[pname] ?? pname}$suffix${exalt ? ' ↑' : ''}${debil ? ' ↓' : ''}',
            style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: nameColor,
            ),
          )),
          Expanded(flex: 4, child: Text(
            _rashiAbb(p['rashi']?.toString()),
            style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
          )),
          Expanded(flex: 6, child: Text(
            _formatDMS(p['degree']),
            style: const TextStyle(fontSize: 11, color: AppColors.textDark),
          )),
          Expanded(flex: 4, child: Text(
            _naksAbb(p['nakshatra']?.toString()),
            style: const TextStyle(fontSize: 11, color: AppColors.textMedium),
          )),
          Expanded(flex: 3, child: Text(
            p['pada'] != null ? '(${p['pada']})' : '-',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
          )),
        ]),
      ));
      idx++;
    }
    return rows;
  }



  Widget _badge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4))),
      child: Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _detRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
      ]),
    );
  }

  static const _hStyle = TextStyle(
    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12,
  );
}

class _LegChip extends StatelessWidget {
  final String text;
  const _LegChip(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark));
  }
}
