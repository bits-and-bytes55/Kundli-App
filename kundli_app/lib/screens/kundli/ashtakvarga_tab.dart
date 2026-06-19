import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AshtakvargaTab extends StatelessWidget {
  final List<dynamic> ashtakvarga;

  const AshtakvargaTab({
    super.key,
    required this.ashtakvarga,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scaffoldBg,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // Banner explanation
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: const Text(
              'Sarvashtakavarga (SAV) — Displays the total bindu (points) count for each Rashi across all planets. A total score above 28 points is considered auspicious.',
              style: TextStyle(fontSize: 11, color: AppColors.textMedium, height: 1.5),
            ),
          ),

          // Table Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withOpacity(0.35)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
                  ),
                  child: Row(
                    children: const [
                      Expanded(flex: 2, child: Text('RN', textAlign: TextAlign.center, style: _hStyle)),
                      Expanded(flex: 2, child: Text('SU', textAlign: TextAlign.center, style: _hStyle)),
                      Expanded(flex: 2, child: Text('MO', textAlign: TextAlign.center, style: _hStyle)),
                      Expanded(flex: 2, child: Text('MA', textAlign: TextAlign.center, style: _hStyle)),
                      Expanded(flex: 2, child: Text('ME', textAlign: TextAlign.center, style: _hStyle)),
                      Expanded(flex: 2, child: Text('JU', textAlign: TextAlign.center, style: _hStyle)),
                      Expanded(flex: 2, child: Text('VE', textAlign: TextAlign.center, style: _hStyle)),
                      Expanded(flex: 2, child: Text('SA', textAlign: TextAlign.center, style: _hStyle)),
                      Expanded(flex: 3, child: Text('Tot', textAlign: TextAlign.center, style: _hStyle)),
                    ],
                  ),
                ),

                // Data rows
                ...List.generate(ashtakvarga.length, (index) {
                  final row = ashtakvarga[index] as Map<String, dynamic>;
                  final bg = index.isOdd ? Colors.white : const Color(0xFFFFFBF5);
                  final int rn = row['RN'] ?? (index + 1);
                  final int tot = row['Tot'] ?? 0;
                  final isAuspicious = tot >= 28;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    decoration: BoxDecoration(
                      color: bg,
                      border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                    ),
                    child: Row(
                      children: [
                        // Rashi Number
                        Expanded(
                          flex: 2,
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              '$rn',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                        ),
                        // Planet BAV scores
                        Expanded(flex: 2, child: Text('${row['Su'] ?? 0}', textAlign: TextAlign.center, style: _dStyle)),
                        Expanded(flex: 2, child: Text('${row['Mo'] ?? 0}', textAlign: TextAlign.center, style: _dStyle)),
                        Expanded(flex: 2, child: Text('${row['Ma'] ?? 0}', textAlign: TextAlign.center, style: _dStyle)),
                        Expanded(flex: 2, child: Text('${row['Me'] ?? 0}', textAlign: TextAlign.center, style: _dStyle)),
                        Expanded(flex: 2, child: Text('${row['Ju'] ?? 0}', textAlign: TextAlign.center, style: _dStyle)),
                        Expanded(flex: 2, child: Text('${row['Ve'] ?? 0}', textAlign: TextAlign.center, style: _dStyle)),
                        Expanded(flex: 2, child: Text('${row['Sa'] ?? 0}', textAlign: TextAlign.center, style: _dStyle)),
                        // Total score
                        Expanded(
                          flex: 3,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            decoration: BoxDecoration(
                              color: isAuspicious ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isAuspicious ? Colors.green.shade300 : Colors.red.shade300,
                              ),
                            ),
                            child: Text(
                              '$tot',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isAuspicious ? Colors.green.shade800 : Colors.red.shade800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static const _hStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 10,
  );

  static const _dStyle = TextStyle(
    color: AppColors.textDark,
    fontWeight: FontWeight.w600,
    fontSize: 12,
  );
}
