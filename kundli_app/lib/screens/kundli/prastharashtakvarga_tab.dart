import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PrastharashtakvargaTab extends StatefulWidget {
  final Map<String, dynamic> prastharaAshtakvarga;

  const PrastharashtakvargaTab({
    super.key,
    required this.prastharaAshtakvarga,
  });

  @override
  State<PrastharashtakvargaTab> createState() => _PrastharashtakvargaTabState();
}

class _PrastharashtakvargaTabState extends State<PrastharashtakvargaTab> {
  String _selectedPlanet = 'Sun';

  final List<String> _planets = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn'];

  @override
  Widget build(BuildContext context) {
    final List<dynamic> gridData = widget.prastharaAshtakvarga[_selectedPlanet] as List<dynamic>? ?? [];

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
            child: Text(
              'Prasthara Ashtakavarga (PAT) — Detailed grid for $_selectedPlanet showing individual contributions from the 7 planets and Lagna across all 12 Rashis.',
              style: const TextStyle(fontSize: 11, color: AppColors.textMedium, height: 1.5),
            ),
          ),

          // Planet selector chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _planets.map((planet) {
                final isSelected = _selectedPlanet == planet;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0, bottom: 12.0),
                  child: ChoiceChip(
                    label: Text(planet),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    disabledColor: Colors.grey.shade200,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedPlanet = planet;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Grid Card
          if (gridData.isNotEmpty)
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
                  // Column headers
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
                    ),
                    child: Row(
                      children: const [
                        Expanded(flex: 3, child: Text('SU', textAlign: TextAlign.center, style: _hStyle)),
                        Expanded(flex: 2, child: Text('1', textAlign: TextAlign.center, style: _hStyle)),
                        Expanded(flex: 2, child: Text('2', textAlign: TextAlign.center, style: _hStyle)),
                        Expanded(flex: 2, child: Text('3', textAlign: TextAlign.center, style: _hStyle)),
                        Expanded(flex: 2, child: Text('4', textAlign: TextAlign.center, style: _hStyle)),
                        Expanded(flex: 2, child: Text('5', textAlign: TextAlign.center, style: _hStyle)),
                        Expanded(flex: 2, child: Text('6', textAlign: TextAlign.center, style: _hStyle)),
                        Expanded(flex: 2, child: Text('7', textAlign: TextAlign.center, style: _hStyle)),
                        Expanded(flex: 2, child: Text('8', textAlign: TextAlign.center, style: _hStyle)),
                        Expanded(flex: 2, child: Text('9', textAlign: TextAlign.center, style: _hStyle)),
                        Expanded(flex: 2, child: Text('10', textAlign: TextAlign.center, style: _hStyle)),
                        Expanded(flex: 2, child: Text('11', textAlign: TextAlign.center, style: _hStyle)),
                        Expanded(flex: 2, child: Text('12', textAlign: TextAlign.center, style: _hStyle)),
                        Expanded(flex: 3, child: Text('TO', textAlign: TextAlign.center, style: _hStyle)),
                      ],
                    ),
                  ),

                  // Table Grid rows
                  ...List.generate(gridData.length, (index) {
                    final row = gridData[index] as Map<String, dynamic>;
                    final String contributor = row['contributor'] ?? '';
                    final isTotalRow = contributor == 'TO';
                    final bg = isTotalRow 
                        ? const Color(0xFFFFF3E0) 
                        : (index.isOdd ? Colors.white : const Color(0xFFFFFBF5));

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      decoration: BoxDecoration(
                        color: bg,
                        border: Border(
                          bottom: BorderSide(
                            color: isTotalRow ? AppColors.primary.withOpacity(0.3) : Colors.grey.shade100,
                            width: isTotalRow ? 1.5 : 1.0,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Contributor Name
                          Expanded(
                            flex: 3,
                            child: Text(
                              contributor,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isTotalRow ? AppColors.primary : AppColors.textDark,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          // 12 columns
                          ...List.generate(12, (rIndex) {
                            final rashiKey = (rIndex + 1).toString();
                            final val = row[rashiKey] ?? 0;
                            final hasPoint = val == 1;

                            return Expanded(
                              flex: 2,
                              child: Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: isTotalRow 
                                      ? Colors.transparent 
                                      : (hasPoint ? AppColors.primary.withOpacity(0.12) : Colors.transparent),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  isTotalRow 
                                      ? '$val' 
                                      : (hasPoint ? '1' : ''),
                                  style: TextStyle(
                                    fontWeight: isTotalRow || hasPoint ? FontWeight.bold : FontWeight.normal,
                                    color: isTotalRow 
                                        ? AppColors.primary 
                                        : (hasPoint ? AppColors.primary : Colors.grey.shade400),
                                    fontSize: isTotalRow ? 11 : 12,
                                  ),
                                ),
                              ),
                            );
                          }),
                          // Row Total
                          Expanded(
                            flex: 3,
                            child: Text(
                              '${row['TO'] ?? 0}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 12,
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
    fontSize: 9,
  );
}
