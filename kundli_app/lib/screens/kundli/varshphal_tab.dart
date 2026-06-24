import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/kundli_controller.dart';
import '../../theme/app_theme.dart';
import '../../theme/custom_shadows.dart';

class VarshphalTab extends StatefulWidget {
  const VarshphalTab({super.key});

  @override
  State<VarshphalTab> createState() => _VarshphalTabState();
}

class _VarshphalTabState extends State<VarshphalTab> {
  final TextEditingController _yearController = TextEditingController();
  final KundliController c = Get.find<KundliController>();

  @override
  void initState() {
    super.initState();
    // Default target year to current calendar year
    _yearController.text = DateTime.now().year.toString();
    // Fetch initial Varshphal automatically if not loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchVarshphal();
    });
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  void _fetchVarshphal() {
    final data = c.kundliData.value;
    if (data == null) return;
    
    final int? year = int.tryParse(_yearController.text);
    if (year == null || year < 1900 || year > 2100) {
      Get.snackbar(
        'Invalid Year',
        'Please enter a valid year between 1900 and 2100',
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    c.fetchVarshphal(
      data['name'] ?? 'User',
      data['date'] ?? '',
      data['time'] ?? '',
      (data['lat'] as num?)?.toDouble() ?? 28.6139,
      (data['lon'] as num?)?.toDouble() ?? 77.2090,
      year,
      gender: data['gender'] ?? 'Male',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          // Year Selection Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Target Year for Varshphal',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          boxShadow: CustomShadows.cardShadow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextFormField(
                          controller: _yearController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            isDense: true,
                            hintText: 'e.g. 2026',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _fetchVarshphal,
                        child: const Text(
                          'Get Report',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Main Body
          Expanded(
            child: Obx(() {
              if (c.isVarshphalLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final vData = c.varshphalData.value;
              if (vData == null) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'Enter target year and tap "Get Report" to calculate Varshphal predictions.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildOverviewCard(vData),
                    const SizedBox(height: 16),
                    _buildPredictionsSection(vData),
                    const SizedBox(height: 16),
                    _buildPanchadhikariCard(vData),
                    const SizedBox(height: 16),
                    _buildVarshaPlanetsCard(vData),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: CustomShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Varshphal - Year ${data['target_year']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Age: ${data['age']} Years',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          _buildInfoRow('Solar Return Moment:', '${data['varsha_time']}'),
          _buildInfoRow('Varsha Lagna:', '${data['varsha_lagna']['rashi']} (${data['varsha_lagna']['degree']}°)'),
          _buildInfoRow('Muntha Rashi / House:', '${data['muntha_rashi']} / House ${data['muntha_house']}'),
          _buildInfoRow('Varsha Swami (Year Lord):', '${data['year_lord']}', isHighlight: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isHighlight ? FontWeight.w900 : FontWeight.w700,
              color: isHighlight ? AppColors.primary : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionsSection(Map<String, dynamic> data) {
    final preds = data['predictions'] as List<dynamic>? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: preds.map((p) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
            boxShadow: CustomShadows.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${p['title_hi']} / ${p['title_en']}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 10),
              Text(
                '${p['desc_hi']}',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${p['desc_en']}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPanchadhikariCard(Map<String, dynamic> data) {
    final pa = data['panchadhikari'] as Map<String, dynamic>? ?? {};
    final String yl = data['year_lord'] ?? '';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: CustomShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tajika Panchadhikari (5 Office Bearers)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 8),
          _buildPanchadhikariRow('Varsha Lagna Lord', '${pa['varsha_lagna_lord']}', yl == pa['varsha_lagna_lord']),
          _buildPanchadhikariRow('Birth Lagna Lord', '${pa['birth_lagna_lord']}', yl == pa['birth_lagna_lord']),
          _buildPanchadhikariRow('Muntha Sign Lord', '${pa['muntha_lord']}', yl == pa['muntha_lord']),
          _buildPanchadhikariRow('Dina-Ratri Lord', '${pa['dina_ratri_lord']}', yl == pa['dina_ratri_lord']),
          _buildPanchadhikariRow('Patyamsa Lord', '${pa['patyamsa_lord']}', yl == pa['patyamsa_lord']),
        ],
      ),
    );
  }

  Widget _buildPanchadhikariRow(String label, String value, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: isSelected ? Border.all(color: AppColors.primary.withOpacity(0.3)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isSelected ? Colors.black : Colors.black54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : Colors.black,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 16),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVarshaPlanetsCard(Map<String, dynamic> data) {
    final planets = data['planets'] as Map<String, dynamic>? ?? {};
    final planetList = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: CustomShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Varsha Chart Planet Placements',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2.5),
              1: FlexColumnWidth(3),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2),
            },
            children: [
              const TableRow(
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
                children: [
                  Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Planet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                  Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Rashi (Sign)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                  Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Degree', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                  Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('House', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                ],
              ),
              ...planetList.map((p) {
                final pData = planets[p] as Map<String, dynamic>? ?? {};
                return TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5))),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        p,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '${pData['rashi'] ?? '-'}',
                        style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '${pData['degree'] != null ? '${pData['degree']}°' : '-'}',
                        style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'H${pData['house'] ?? '-'}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
