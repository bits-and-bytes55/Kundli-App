import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// AstroSage-style "Cusps" tab (KP House Cusps)
/// Columns: Hos | Degree (absolute) | SL | NL | SB | SS
class CuspsTab extends StatelessWidget {
  final Map<String, dynamic> kpAscendant;

  const CuspsTab({super.key, required this.kpAscendant});

  static const _lordAbbrev = {
    'Surya': 'Su', 'Chandra': 'Mo', 'Mangal': 'Ma', 'Budha': 'Me',
    'Guru': 'Ju', 'Shukra': 'Ve', 'Shani': 'Sa', 'Rahu': 'Ra', 'Ketu': 'Ke',
    'Sun': 'Su', 'Moon': 'Mo', 'Mars': 'Ma', 'Mercury': 'Me',
    'Jupiter': 'Ju', 'Venus': 'Ve', 'Saturn': 'Sa',
  };

  String _ab(String? lord) => _lordAbbrev[lord] ?? (lord?.substring(0, 2) ?? '-');

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
    final cuspDetails = kpAscendant['cusp_details'] as List<dynamic>? ?? [];

    return Container(
      color: AppColors.scaffoldBg,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
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
              ...cuspDetails.asMap().entries.map((e) {
                final idx = e.key;
                final cusp = e.value as Map<String, dynamic>;
                return _cuspRow(idx, cusp);
              }),
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
            child: Text(
              'kp_cusp_note'.tr,
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
      child: Row(children: [
        Expanded(flex: 3, child: Text('hos'.tr,    style: _hStyle)),
        Expanded(flex: 7, child: Text('degree_col'.tr, style: _hStyle)),
        Expanded(flex: 3, child: Text('sl'.tr,     style: _hStyle)),
        Expanded(flex: 3, child: Text('nl'.tr,     style: _hStyle)),
        Expanded(flex: 3, child: Text('sb'.tr,     style: _hStyle)),
        Expanded(flex: 3, child: Text('ss'.tr,     style: _hStyle)),
      ]),
    );
  }

  Widget _cuspRow(int index, Map<String, dynamic> cusp) {
    final houseNum = cusp['house'] as int? ?? (index + 1);
    final lon = cusp['longitude'];
    final sl = _ab(cusp['rashi_lord']?.toString());
    final nl = _ab(cusp['nakshatra_lord']?.toString());
    final sb = _ab(cusp['sub_lord']?.toString());
    final ss = _ab(cusp['sub_sub_lord']?.toString());

    final bg = index.isOdd ? Colors.white : const Color(0xFFFFFBF5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(children: [
        Expanded(flex: 3, child: Text(
          '$houseNum',
          style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark,
          ),
        )),
        Expanded(flex: 7, child: Text(
          _formatAbsLon(lon),
          style: const TextStyle(fontSize: 11, color: AppColors.textDark, fontFamily: 'monospace'),
        )),
        Expanded(flex: 3, child: _lCell(sl)),
        Expanded(flex: 3, child: _lCell(nl, color: const Color(0xFF1565C0))),
        Expanded(flex: 3, child: _lCell(sb, color: const Color(0xFF2E7D32))),
        Expanded(flex: 3, child: _lCell(ss, color: const Color(0xFF6A1B9A))),
      ]),
    );
  }

  Widget _lCell(String? text, {Color color = AppColors.primary}) {
    return Text(
      text ?? '-',
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
    );
  }

  static const _hStyle = TextStyle(
    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12,
  );
}
