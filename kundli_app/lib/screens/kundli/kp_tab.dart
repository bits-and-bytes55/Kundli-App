import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class KpTab extends StatelessWidget {
  final Map<String, dynamic> kpPlanets;
  final Map<String, dynamic> kpAscendant;

  const KpTab({
    super.key,
    required this.kpPlanets,
    required this.kpAscendant,
  });

  static const planetIcons = {
    'Sun': '☀️', 'Moon': '🌙', 'Mars': '♂', 'Mercury': '☿',
    'Jupiter': '♃', 'Venus': '♀', 'Saturn': '♄', 'Rahu': '☊', 'Ketu': '☋'
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
    return "${degrees.toString().padLeft(2, '0')}°${minutes.toString().padLeft(2, '0')}'";
  }

  @override
  Widget build(BuildContext context) {
    final cuspDetails = kpAscendant['cusp_details'] as List<dynamic>? ?? [];

    return Container(
      color: AppColors.scaffoldBg,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // Banner explanation
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Krishnamurti Paddhati (KP System) focuses on Star Lords (Nakshatra) and Sub Lords for highly accurate predictions.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Planets Table Section
          _sectionHeader('KP Planets Sign, Star & Sub Lords'),
          const SizedBox(height: 8),
          Container(
            decoration: _tableBoxDecoration(),
            child: Column(
              children: [
                // Header row
                _tableHeaderRow(const ['Planet', 'Sign', 'Star Lord', 'Sub Lord', 'House']),
                // Data rows
                ...planetOrder.where((p) => kpPlanets.containsKey(p)).toList().asMap().entries.map((entry) {
                  final idx = entry.key;
                  final pName = entry.value;
                  final pData = kpPlanets[pName] as Map<String, dynamic>;
                  return _tableDataRow(
                    idx,
                    [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(planetIcons[pName] ?? '★', style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(pName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textDark)),
                        ],
                      ),
                      Text(pData['rashi'] ?? '-', style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                      Text(pData['nakshatra_lord'] ?? '-', style: const TextStyle(fontSize: 11, color: Color(0xFF1E88E5), fontWeight: FontWeight.w500)),
                      Text(pData['sub_lord'] ?? '-', style: const TextStyle(fontSize: 11, color: Color(0xFF43A047), fontWeight: FontWeight.bold)),
                      Text('H${pData['house'] ?? '-'}', style: const TextStyle(fontSize: 11, color: AppColors.textDark, fontWeight: FontWeight.w600)),
                    ],
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Cusps Table Section
          _sectionHeader('KP Cusps (House boundaries)'),
          const SizedBox(height: 8),
          Container(
            decoration: _tableBoxDecoration(),
            child: Column(
              children: [
                // Header row
                _tableHeaderRow(const ['Cusp', 'Sign', 'Degree', 'Star Lord', 'Sub Lord']),
                // Data rows
                ...cuspDetails.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final cusp = entry.value as Map<String, dynamic>;
                  final houseNum = cusp['house'] ?? (idx + 1);
                  return _tableDataRow(
                    idx,
                    [
                      Text('House $houseNum', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textDark)),
                      Text(cusp['rashi'] ?? '-', style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                      Text(_formatDegree(cusp['degree']), style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                      Text(cusp['nakshatra_lord'] ?? '-', style: const TextStyle(fontSize: 11, color: Color(0xFF1E88E5), fontWeight: FontWeight.w500)),
                      Text(cusp['sub_lord'] ?? '-', style: const TextStyle(fontSize: 11, color: Color(0xFF43A047), fontWeight: FontWeight.bold)),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  BoxDecoration _tableBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.primary.withOpacity(0.35)),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
    );
  }

  Widget _tableHeaderRow(List<String> titles) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
      ),
      child: Row(
        children: titles.map((title) {
          final flexVal = (title == 'Planet' || title == 'Cusp') ? 5 : 4;
          return Expanded(
            flex: flexVal,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _tableDataRow(int index, List<Widget> cells) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: index.isOdd ? Colors.white : const Color(0xFFFFFBF5),
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: cells.asMap().entries.map((entry) {
          final cellIdx = entry.key;
          final cellWidget = entry.value;
          final flexVal = cellIdx == 0 ? 5 : 4;
          return Expanded(
            flex: flexVal,
            child: cellWidget,
          );
        }).toList(),
      ),
    );
  }
}
