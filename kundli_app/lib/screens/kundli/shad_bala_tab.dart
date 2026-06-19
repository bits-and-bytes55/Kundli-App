import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ShadBalaTab extends StatefulWidget {
  final Map<String, dynamic> shadBala;

  const ShadBalaTab({
    super.key,
    required this.shadBala,
  });

  @override
  State<ShadBalaTab> createState() => _ShadBalaTabState();
}

class _ShadBalaTabState extends State<ShadBalaTab> {
  int _activeSegment = 0; // 0 = Shad Bala (Planets), 1 = Bhav Bala (Houses)

  @override
  Widget build(BuildContext context) {
    final List<dynamic> planetsList = widget.shadBala['shad_bala'] as List<dynamic>? ?? [];
    final List<dynamic> housesList = widget.shadBala['bhav_bala'] as List<dynamic>? ?? [];

    return Container(
      color: AppColors.scaffoldBg,
      child: Column(
        children: [
          // Segment Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeSegment = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _activeSegment == 0 ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Planets (Shad Bala)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _activeSegment == 0 ? Colors.white : AppColors.textDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeSegment = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _activeSegment == 1 ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Houses (Bhav Bala)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _activeSegment == 1 ? Colors.white : AppColors.textDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: _activeSegment == 0 
                ? _buildPlanetsList(planetsList)
                : _buildHousesList(housesList),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetsList(List<dynamic> list) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      children: [
        // Explanatory Banner
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: const Text(
            'Shad Bala — Represents the six-fold strength of planets in Rupas. Planets are ranked from 1 (strongest) to 7 (weakest).',
            style: TextStyle(fontSize: 11, color: AppColors.textMedium, height: 1.5),
          ),
        ),

        // Cards list
        ...List.generate(list.length, (index) {
          final item = list[index] as Map<String, dynamic>;
          final String planet = item['planet'] ?? '';
          final String name = item['name'] ?? '';
          final double score = (item['score'] as num?)?.toDouble() ?? 0.0;
          final int rank = (item['rank'] as num?)?.toInt() ?? 0;
          final double percentage = (item['percentage'] as num?)?.toDouble() ?? 50.0;

          // Distinct colors based on rank
          final Color barColor = rank == 1 
              ? Colors.green.shade600 
              : (rank <= 3 ? AppColors.primary : Colors.amber.shade700);

          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Planet abbreviation bubble
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: barColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: barColor, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      planet,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: barColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Strengths and progress bar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.textDark,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: barColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Rank #$rank',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: barColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              '$score Rupas',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMedium,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: barColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage / 100.0,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(barColor),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHousesList(List<dynamic> list) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      children: [
        // Explanatory Banner
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: const Text(
            'Bhav Bala — Represents the strength of each of the 12 houses based on the house lord, placements, and aspects. Houses are ranked from 1 (strongest) to 12 (weakest).',
            style: TextStyle(fontSize: 11, color: AppColors.textMedium, height: 1.5),
          ),
        ),

        // Cards list
        ...List.generate(list.length, (index) {
          final item = list[index] as Map<String, dynamic>;
          final int house = (item['house'] as num?)?.toInt() ?? 0;
          final double score = (item['score'] as num?)?.toDouble() ?? 0.0;
          final int rank = (item['rank'] as num?)?.toInt() ?? 0;
          final double percentage = (item['percentage'] as num?)?.toDouble() ?? 50.0;

          // Distinct colors based on rank
          final Color barColor = rank == 1 
              ? Colors.green.shade600 
              : (rank <= 3 ? AppColors.primary : Colors.blue.shade700);

          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // House bubble
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: barColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: barColor, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'H$house',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: barColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Strengths and progress bar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'House $house',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.textDark,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: barColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Rank #$rank',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: barColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              '$score Rupas',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMedium,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: barColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage / 100.0,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(barColor),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
