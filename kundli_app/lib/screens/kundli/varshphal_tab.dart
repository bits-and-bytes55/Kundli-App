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
  static const rashiList = [
    'Mesh', 'Vrishabh', 'Mithun', 'Kark', 'Singh', 'Kanya',
    'Tula', 'Vrischik', 'Dhanu', 'Makar', 'Kumbh', 'Meen'
  ];
  static const abbrev = {
    'Sun': 'Su', 'Moon': 'Mo', 'Mars': 'Ma', 'Mercury': 'Me',
    'Jupiter': 'Ju', 'Venus': 'Ve', 'Saturn': 'Sa', 'Rahu': 'Ra', 'Ketu': 'Ke'
  };
  static const rashiColors = [
    Color(0xFFE53935), Color(0xFF8E24AA), Color(0xFF1E88E5), Color(0xFF00897B),
    Color(0xFFE67E22), Color(0xFF43A047), Color(0xFF1565C0), Color(0xFFAD1457),
    Color(0xFF6D4C41), Color(0xFF546E7A), Color(0xFF00838F), Color(0xFF558B2F),
  ];
  static const northCentroids = [
    [0.500, 0.250], [0.250, 0.115], [0.115, 0.250], [0.250, 0.500],
    [0.115, 0.750], [0.250, 0.885], [0.500, 0.750], [0.750, 0.885],
    [0.885, 0.750], [0.750, 0.500], [0.885, 0.250], [0.750, 0.115],
  ];
  static const northMaxW = [80.0, 70.0, 60.0, 70.0, 80.0, 70.0, 60.0, 70.0, 55.0, 60.0, 55.0, 55.0];

  String _formatDegree(dynamic deg) {
    if (deg == null) return '-';
    final d = (deg as num).toDouble();
    final degrees = d.floor();
    final minsTotal = ((d - degrees) * 60);
    final minutes = minsTotal.floor();
    final seconds = ((minsTotal - minutes) * 60).round();
    return "${degrees.toString().padLeft(2, '0')}°${minutes.toString().padLeft(2, '0')}'${seconds.toString().padLeft(2, '0')}\"";
  }

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
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildOverviewCard(vData),
                    ),
                    const SizedBox(height: 16),
                    _buildVarshphalChart(vData),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildPredictionsSection(vData),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildPanchadhikariCard(vData),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildVarshaPlanetsCard(vData),
                    ),
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
              TableRow(
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
                children: [
                  Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('planet'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                  Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Rashi (Sign)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                  Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('degree_col'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                  Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('house'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
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

  Widget _buildVarshphalChart(Map<String, dynamic> data) {
    final vl = data['varsha_lagna'] as Map<String, dynamic>? ?? {};
    final rashiStr = vl['rashi'] as String? ?? 'Mesh';
    int lagnaIdx = rashiList.indexOf(rashiStr);
    if (lagnaIdx == -1) lagnaIdx = 0;
    final lagnaDegStr = _formatDegree(vl['degree']);

    final planets = data['planets'] as Map<String, dynamic>? ?? {};
    final sunData = planets['Sun'] as Map<String, dynamic>?;
    final double sunLon = sunData != null ? (sunData['longitude'] as num? ?? 0.0).toDouble() : 0.0;

    final List<List<_PlanetLabel>> houses = List.generate(12, (_) => []);
    planets.forEach((key, value) {
      if (!abbrev.containsKey(key) || value is! Map) return;
      final pRashiIdx = rashiList.indexOf(value['rashi'] ?? '');
      if (pRashiIdx == -1) return;
      int hi = (pRashiIdx - lagnaIdx + 12) % 12;
      final deg = (value['degree'] as num? ?? 0.0).toDouble();
      final pLon = (value['longitude'] as num? ?? 0.0).toDouble();

      bool retro = value['is_retrograde'] == true;
      if (key == 'Rahu' || key == 'Ketu') retro = true;
      final exalt = value['is_exalted'] == true;
      final debil = value['is_debilitated'] == true;
      bool combust = false;
      if (key != 'Sun' && key != 'Rahu' && key != 'Ketu') {
        double diff = (pLon - sunLon).abs();
        diff = diff > 180 ? 360 - diff : diff;
        if (key == 'Moon' && diff < 12.0) combust = true;
        else if (key == 'Mars' && diff < 17.0) combust = true;
        else if (key == 'Mercury' && diff < 14.0) combust = true;
        else if (key == 'Jupiter' && diff < 11.0) combust = true;
        else if (key == 'Venus' && diff < 10.0) combust = true;
        else if (key == 'Saturn' && diff < 15.0) combust = true;
      }
      int d1Sign = (pLon / 30.0).floor() % 12;
      int d9Sign = (pLon / (360.0 / 108.0)).floor() % 12;
      final varg = d1Sign == d9Sign;
      houses[hi].add(_PlanetLabel(abbrev[key]!, deg, retro, exalt, debil, combust, varg));
    });

    final double chartSize = MediaQuery.of(context).size.width - 64;

    return Container(
      width: chartSize,
      height: chartSize,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
        boxShadow: CustomShadows.cardShadow,
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: Size(chartSize, chartSize),
            painter: _NorthPainter(),
          ),
          ..._buildNorthHouses(houses, lagnaIdx, lagnaDegStr, chartSize),
        ],
      ),
    );
  }

  List<Widget> _buildNorthHouses(List<List<_PlanetLabel>> houses, int lagnaIdx, String lagnaDegStr, double chartSize) {
    final widgets = <Widget>[];
    for (int i = 0; i < 12; i++) {
      final cx = northCentroids[i][0] * chartSize;
      final cy = northCentroids[i][1] * chartSize;
      final w = northMaxW[i];
      int houseRashiNum = (lagnaIdx + i) % 12 + 1;
      final isLagnaHouse = (i == 0);

      widgets.add(Positioned(
        left: cx - w / 2,
        top: cy - 24,
        width: w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$houseRashiNum',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: rashiColors[(houseRashiNum - 1) % 12],
              ),
            ),
            if (isLagnaHouse)
              Text(
                'La $lagnaDegStr',
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            if (houses[i].isNotEmpty)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 2,
                runSpacing: 0,
                children: houses[i].map((p) => Text(
                  '${p.label}${p.deg.floor()}°${p.retro ? '*' : ''}${p.combust ? '^' : ''}${p.vargottama ? '□' : ''}${p.exalt ? '↑' : ''}${p.debil ? '↓' : ''}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                )).toList(),
              ),
          ],
        ),
      ));
    }
    return widgets;
  }
}

class _PlanetLabel {
  final String label;
  final double deg;
  final bool retro, exalt, debil, combust, vargottama;
  const _PlanetLabel(this.label, this.deg, this.retro, this.exalt, this.debil, this.combust, this.vargottama);
}

class _NorthPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromLTWH(0, 0, s.width, s.height), p);
    canvas.drawLine(const Offset(0, 0), Offset(s.width, s.height), p);
    canvas.drawLine(Offset(s.width, 0), Offset(0, s.height), p);
    canvas.drawLine(Offset(s.width / 2, 0), Offset(0, s.height / 2), p);
    canvas.drawLine(Offset(s.width / 2, 0), Offset(s.width, s.height / 2), p);
    canvas.drawLine(Offset(0, s.height / 2), Offset(s.width / 2, s.height), p);
    canvas.drawLine(Offset(s.width, s.height / 2), Offset(s.width / 2, s.height), p);
  }

  @override
  bool shouldRepaint(_) => false;
}
