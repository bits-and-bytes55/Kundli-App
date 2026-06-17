import 'package:flutter/material.dart';
import '../../theme/custom_shadows.dart';
import '../../theme/app_theme.dart';

class ChartTab extends StatefulWidget {
  final Map<String, dynamic> ascendant, planets, kpAscendant, kpPlanets;
  const ChartTab({super.key, required this.ascendant, required this.planets, required this.kpAscendant, required this.kpPlanets});
  @override
  State<ChartTab> createState() => _ChartTabState();
}

class _ChartTabState extends State<ChartTab> {
  String _chartStyle = 'North';
  bool _showKP = false;

  static const rashiList = ['Mesh','Vrishabh','Mithun','Kark','Singh','Kanya','Tula','Vrischik','Dhanu','Makar','Kumbh','Meen'];
  static const abbrev = {'Sun':'Su','Moon':'Mo','Mars':'Ma','Mercury':'Me','Jupiter':'Ju','Venus':'Ve','Saturn':'Sa','Rahu':'Ra','Ketu':'Ke'};

  // North Indian: fixed diamond cell centers as fractions of chart size
  // Each house occupies a triangular region; we place text at the centroid
  static const northFrac = [
    [0.5, 0.22],   // H1  top-center diamond
    [0.22, 0.22],  // H2  top-left
    [0.14, 0.5],   // H3  left
    [0.22, 0.78],  // H4  bottom-left
    [0.5, 0.78],   // H5  bottom-center
    [0.78, 0.78],  // H6  bottom-right
    [0.86, 0.5],   // H7  right
    [0.78, 0.22],  // H8  top-right
    [0.62, 0.38],  // H9  inner top-right
    [0.5, 0.5],    // H10 center
    [0.38, 0.62],  // H11 inner bottom-left
    [0.38, 0.38],  // H12 inner top-left
  ];

  // South Indian: 4x4 grid, skip center 2x2
  // Row,Col of each house 1..12 (0-indexed)
  static const southGrid = [
    [0,0],[0,1],[0,2],[0,3],
    [1,3],[2,3],[3,3],[3,2],
    [3,1],[3,0],[2,0],[1,0],
  ];

  @override
  Widget build(BuildContext context) {
    final ascendant = _showKP ? widget.kpAscendant : widget.ascendant;
    final planets   = _showKP ? widget.kpPlanets   : widget.planets;

    // Debug: print keys to verify KP data is different
    debugPrint('=== CHART MODE: ${_showKP ? "KP" : "Lahiri"} ===');
    debugPrint('Ascendant rashi: ${ascendant['rashi']}');

    int lagnaIdx = rashiList.indexOf(widget.ascendant['rashi'] ?? '');
    if (lagnaIdx == -1) lagnaIdx = 0;

    // Build house planet lists
    List<List<_PlanetLabel>> houses = List.generate(12, (_) => []);
    planets.forEach((key, value) {
      if (abbrev.containsKey(key) && value is Map) {
        int pRashiIdx = rashiList.indexOf(value['rashi'] ?? '');
        if (pRashiIdx != -1) {
          int hi;
          if (_chartStyle == 'North') {
            if (_showKP) {
              hi = (value['house'] as num? ?? 1).toInt() - 1;
              if (hi < 0 || hi > 11) hi = 0;
            } else {
              hi = (pRashiIdx - lagnaIdx + 12) % 12;
            }
          } else {
            hi = pRashiIdx;
          }
          String lbl = abbrev[key]!;
          bool retro   = value['is_retrograde'] == true;
          bool exalted = value['is_exalted']    == true;
          bool isMoon  = key == 'Moon';
          houses[hi].add(_PlanetLabel(lbl, retro, exalted, isMoon));
        }
      }
    });

    final double chartSize = MediaQuery.of(context).size.width - 32;
    final double cellW = chartSize / 4;

    return Container(
      color: AppColors.scaffoldBg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // ── Toggle card ──────────────────────────────────────────
          Card(
            color: Colors.white, elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.accentLight)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _toggle('North Indian', 'North'),
                  const SizedBox(width: 10),
                  _toggle('South Indian', 'South'),
                ]),
                const SizedBox(height: 8),
                _kpToggle(),
              ]),
            ),
          ),
          const SizedBox(height: 8),

          // ── KP active banner ─────────────────────────────────────
          if (_showKP)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.3))),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.info_outline_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('KP System (Krishnamurti Paddhati) — Placidus Cusps',
                    style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
              ]),
            ),

          // ── Chart ────────────────────────────────────────────────
          SizedBox(
            width: chartSize,
            height: chartSize,
            child: Stack(children: [
              // Grid painter
              CustomPaint(
                size: Size(chartSize, chartSize),
                painter: _chartStyle == 'North'
                    ? _NorthPainter()
                    : _SouthPainter()),

              // ── North Indian houses ──────────────────────────────
              if (_chartStyle == 'North')
                ..._buildNorthHouses(houses, lagnaIdx, chartSize),

              // ── South Indian houses ──────────────────────────────
              if (_chartStyle == 'South')
                ..._buildSouthHouses(houses, lagnaIdx, cellW),
            ]),
          ),

          const SizedBox(height: 10),
          // ── Legend ───────────────────────────────────────────────
          Card(
            color: Colors.white, elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: AppColors.accentLight)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                Text('ᴿ Retrograde  ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                Text('↑ Exalted  ',    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                Text('La = Lagna',      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          _infoCard(ascendant),
          const SizedBox(height: 16),
          _quickButtons(),
        ]),
      ),
    );
  }

  // ── North Indian: use fractional positioning ───────────────────
  List<double> _getKpCusps() {
    final List<dynamic>? cuspsRaw = widget.kpAscendant['cusps'];
    if (cuspsRaw == null) return [];
    if (cuspsRaw.length == 11) {
      return [
        (widget.kpAscendant['longitude'] as num).toDouble(),
        ...cuspsRaw.map((c) => (c as num).toDouble())
      ];
    }
    return cuspsRaw.map((c) => (c as num).toDouble()).toList();
  }

  // ── North Indian: use fractional positioning ───────────────────
  List<Widget> _buildNorthHouses(
      List<List<_PlanetLabel>> houses, int lagnaIdx, double chartSize) {
    const List<List<double>> centroids = [
      [0.500, 0.250], // H1 (Top Center diamond)
      [0.250, 0.115], // H2 (Top Left outer triangle)
      [0.115, 0.250], // H3 (Far Left outer triangle)
      [0.250, 0.500], // H4 (Left Center diamond)
      [0.115, 0.750], // H5 (Left Bottom outer triangle)
      [0.250, 0.885], // H6 (Bottom Left outer triangle)
      [0.500, 0.750], // H7 (Bottom Center diamond)
      [0.750, 0.885], // H8 (Bottom Right outer triangle)
      [0.885, 0.750], // H9 (Far Right Bottom outer triangle)
      [0.750, 0.500], // H10 (Right Center diamond)
      [0.885, 0.250], // H11 (Far Right Top outer triangle)
      [0.750, 0.115], // H12 (Top Right outer triangle)
    ];

    // max text box size for each cell (triangle inscribed width approx)
    const List<double> maxW = [
      80, 70, 60, 70, 80, 70, 60, 70, 55, 60, 55, 55,
    ];

    final widgets = <Widget>[];
    for (int i = 0; i < 12; i++) {
      final cx = centroids[i][0] * chartSize;
      final cy = centroids[i][1] * chartSize;
      final w  = maxW[i];
      
      int houseRashiNum;
      if (_showKP) {
        final List<double> cusps = _getKpCusps();
        if (cusps.isNotEmpty) {
          final cuspLon = cusps[i];
          houseRashiNum = (cuspLon / 30).floor() % 12 + 1;
        } else {
          houseRashiNum = (lagnaIdx + i) % 12 + 1;
        }
      } else {
        houseRashiNum = (lagnaIdx + i) % 12 + 1;
      }

      widgets.add(Positioned(
        left: cx - w / 2,
        top:  cy - 22,   // centered vertically at centroid
        width: w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // House number (Sign/Rashi number) - Enlarged and styled clearly
            Text('$houseRashiNum',
              style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold,
                color: Color(0xFFD84315))),
            // Lagna label for house 1
            if (i == 0)
              Text('Lagna', style: TextStyle(
                fontSize: 9, color: AppColors.primary.withOpacity(0.8),
                fontWeight: FontWeight.bold)),
            // Planets
            if (houses[i].isNotEmpty)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 2, runSpacing: 0,
                children: houses[i].map((p) => Text(
                  '${p.label}${p.retro ? 'ᴿ' : ''}${p.exalted ? '↑' : ''}',
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold,
                    color: p.isMoon ? Colors.blue.shade700 : const Color(0xFF1A237E)),
                )).toList(),
              ),
          ],
        ),
      ));
    }
    return widgets;
  }

  // ── South Indian: 4×4 grid, skip center 2×2 ───────────────────
  List<Widget> _buildSouthHouses(
      List<List<_PlanetLabel>> houses, int lagnaIdx, double cellW) {

    // southGrid[i] = [row, col] for rashi i (0-indexed rashi, fixed in south)
    // House 0 = Mesh(top-left corner going clockwise)
    const List<List<int>> rashiToCell = [
      [0,0],[0,1],[0,2],[0,3],
      [1,3],[2,3],[3,3],[3,2],
      [3,1],[3,0],[2,0],[1,0],
    ];

    final widgets = <Widget>[];
    for (int rashiI = 0; rashiI < 12; rashiI++) {
      final row = rashiToCell[rashiI][0];
      final col = rashiToCell[rashiI][1];
      final isLagna  = rashiI == lagnaIdx;
      
      String houseLabel = '';
      if (_showKP) {
        final List<double> cusps = _getKpCusps();
        final List<int> housesInRashi = [];
        for (int h = 0; h < cusps.length; h++) {
          int cuspRashi = cusps[h].floor() ~/ 30 % 12;
          if (cuspRashi == rashiI) {
            housesInRashi.add(h + 1);
          }
        }
        if (housesInRashi.isNotEmpty) {
          houseLabel = ' H${housesInRashi.join(",")}';
        }
      } else {
        final houseNum = (rashiI - lagnaIdx + 12) % 12 + 1;
        houseLabel = ' $houseNum';
      }

      widgets.add(Positioned(
        left: col * cellW + 2,
        top:  row * cellW + 2,
        width: cellW - 4,
        height: cellW - 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 3),
            // Rashi abbrev + house num on same row
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(rashiList[rashiI].substring(0, 2),
                style: const TextStyle(fontSize: 8, color: AppColors.primary, fontWeight: FontWeight.bold)),
              Text(houseLabel,
                style: const TextStyle(fontSize: 8, color: Color(0xFF8D6E63), fontWeight: FontWeight.bold)),
            ]),
            if (isLagna)
              Text('Lagna', style: TextStyle(
                fontSize: 7, color: AppColors.primary.withOpacity(0.8),
                fontWeight: FontWeight.w600)),
            // Planets wrap inside cell
            if (houses[rashiI].isNotEmpty)
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 1, runSpacing: 0,
                  children: houses[rashiI].map((p) => Text(
                    '${p.label}${p.retro ? 'ᴿ' : ''}${p.exalted ? '↑' : ''}',
                    style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold,
                      color: p.isMoon ? Colors.blue.shade700 : const Color(0xFF1A237E)),
                  )).toList(),
                ),
              ),
          ],
        ),
      ));
    }
    return widgets;
  }

  Widget _toggle(String label, String val) {
    bool sel = _chartStyle == val;
    return GestureDetector(
      onTap: () => setState(() => _chartStyle = val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? AppColors.accent : Colors.transparent,
          border: Border.all(color: sel ? AppColors.primary : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600,
          color: sel ? AppColors.primary : Colors.grey)),
      ),
    );
  }

  Widget _kpToggle() {
    return GestureDetector(
      onTap: () => setState(() => _showKP = !_showKP),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: _showKP ? AppColors.primary : AppColors.accentLight,
          border: Border.all(color: AppColors.primary, width: _showKP ? 0 : 1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: _showKP
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 6, offset: const Offset(0,2))]
              : []),
        alignment: Alignment.center,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(_showKP ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
            size: 18, color: _showKP ? Colors.white : AppColors.primary),
          const SizedBox(width: 6),
          Text(_showKP ? 'KP System (ON)' : 'KP System (OFF)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
              color: _showKP ? Colors.white : AppColors.primary)),
        ]),
      ),
    );
  }

  Widget _infoCard(Map<String, dynamic> asc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentLight, width: 1.5)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _infoItem('Lagna',     asc['rashi']     ?? '-'),
          Container(width: 1, height: 36, color: AppColors.accentLight),
          _infoItem('Degree',    '${(asc['degree'] as num? ?? 0).toStringAsFixed(1)}°'),
          Container(width: 1, height: 36, color: AppColors.accentLight),
          _infoItem('Nakshatra', asc['nakshatra'] ?? '-'),
          Container(width: 1, height: 36, color: AppColors.accentLight),
          _infoItem('Pada',      '${asc['pada']   ?? '-'}'),
        ]),
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(children: [
      Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF7F8C8D))),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
    ]);
  }

  Widget _quickButtons() {
    final btns = ['Planets','Dasha','KP','Shodashvarga','Yogas','Lal Kitab','Varshphal','Raj Yoga','Transit'];
    return Wrap(spacing: 8, runSpacing: 8,
      children: btns.map((b) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          border: Border.all(color: AppColors.accent),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 4)]),
        child: Text(b, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
      )).toList());
  }
}

// ── Data class ─────────────────────────────────────────────────────
class _PlanetLabel {
  final String label;
  final bool retro, exalted, isMoon;
  const _PlanetLabel(this.label, this.retro, this.exalted, this.isMoon);
}

// ── Painters ───────────────────────────────────────────────────────
class _NorthPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = AppColors.primary..strokeWidth = 1.5..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromLTWH(0, 0, s.width, s.height), p);
    canvas.drawLine(Offset(0, 0),          Offset(s.width, s.height), p);
    canvas.drawLine(Offset(s.width, 0),    Offset(0, s.height),       p);
    canvas.drawLine(Offset(s.width/2, 0),  Offset(0, s.height/2),     p);
    canvas.drawLine(Offset(s.width/2, 0),  Offset(s.width, s.height/2), p);
    canvas.drawLine(Offset(0, s.height/2), Offset(s.width/2, s.height), p);
    canvas.drawLine(Offset(s.width, s.height/2), Offset(s.width/2, s.height), p);
  }
  @override bool shouldRepaint(_) => false;
}

class _SouthPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = AppColors.primary..strokeWidth = 1.5..style = PaintingStyle.stroke;
    double w = s.width / 4;
    canvas.drawRect(Rect.fromLTWH(0, 0, s.width, s.height), p);
    canvas.drawLine(Offset(w, 0),   Offset(w, s.height),   p);
    canvas.drawLine(Offset(2*w, 0), Offset(2*w, w),         p);
    canvas.drawLine(Offset(2*w, 3*w), Offset(2*w, s.height), p);
    canvas.drawLine(Offset(3*w, 0), Offset(3*w, s.height), p);
    canvas.drawLine(Offset(0, w),   Offset(s.width, w),    p);
    canvas.drawLine(Offset(0, 2*w), Offset(w, 2*w),        p);
    canvas.drawLine(Offset(3*w, 2*w), Offset(s.width, 2*w), p);
    canvas.drawLine(Offset(0, 3*w), Offset(s.width, 3*w),  p);
  }
  @override bool shouldRepaint(_) => false;
}