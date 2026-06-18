import 'package:flutter/material.dart';
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

  // 12 rashis in order
  static const rashiList = [
    'Mesh','Vrishabh','Mithun','Kark','Singh','Kanya',
    'Tula','Vrischik','Dhanu','Makar','Kumbh','Meen'
  ];
  static const rashiSymbols = ['♈','♉','♊','♋','♌','♍','♎','♏','♐','♑','♒','♓'];
  static const rashiEngNames = ['Aries','Taurus','Gemini','Cancer','Leo','Virgo','Libra','Scorpio','Sagittarius','Capricorn','Aquarius','Pisces'];
  // Each rashi's natural color for the sign grid
  static const rashiColors = [
    Color(0xFFE53935), Color(0xFF8E24AA), Color(0xFF1E88E5), Color(0xFF00897B),
    Color(0xFFE67E22), Color(0xFF43A047), Color(0xFF1565C0), Color(0xFFAD1457),
    Color(0xFF6D4C41), Color(0xFF546E7A), Color(0xFF00838F), Color(0xFF558B2F),
  ];

  static const abbrev = {
    'Sun':'Su','Moon':'Mo','Mars':'Ma','Mercury':'Me',
    'Jupiter':'Ju','Venus':'Ve','Saturn':'Sa','Rahu':'Ra','Ketu':'Ke'
  };

  // North Indian house centroids as fraction of chart size (i = house index 0..11)
  static const northCentroids = [
    [0.500, 0.250], // H1 top-center
    [0.250, 0.115], // H2 top-left outer
    [0.115, 0.250], // H3 far-left outer
    [0.250, 0.500], // H4 left-center
    [0.115, 0.750], // H5 left-bottom outer
    [0.250, 0.885], // H6 bottom-left outer
    [0.500, 0.750], // H7 bottom-center
    [0.750, 0.885], // H8 bottom-right outer
    [0.885, 0.750], // H9 far-right bottom outer
    [0.750, 0.500], // H10 right-center
    [0.885, 0.250], // H11 far-right top outer
    [0.750, 0.115], // H12 top-right outer
  ];
  static const northMaxW = [80.0,70.0,60.0,70.0,80.0,70.0,60.0,70.0,55.0,60.0,55.0,55.0];

  // South Indian: rashi i → [row, col] in 4×4 grid (Mesh=top-left, clockwise)
  static const rashiToCell = [
    [0,0],[0,1],[0,2],[0,3],
    [1,3],[2,3],[3,3],[3,2],
    [3,1],[3,0],[2,0],[1,0],
  ];

  List<double> _getKpCusps() {
    final raw = widget.kpAscendant['cusps'] as List<dynamic>?;
    if (raw == null) return [];
    if (raw.length == 11) {
      return [
        (widget.kpAscendant['longitude'] as num).toDouble(),
        ...raw.map((c) => (c as num).toDouble())
      ];
    }
    return raw.map((c) => (c as num).toDouble()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ascendant = _showKP ? widget.kpAscendant : widget.ascendant;
    final planets   = _showKP ? widget.kpPlanets   : widget.planets;

    // Lagna rashi index (Lahiri always governs house layout in Lahiri; KP uses cusps)
    int lagnaIdx = rashiList.indexOf(ascendant['rashi'] ?? '');
    if (lagnaIdx == -1) lagnaIdx = 0;

    // Lagna degree within sign — use ACTIVE ascendant
    final lagnaDeg = (ascendant['degree'] as num? ?? 0).toDouble();
    final lagnaDegStr = _dms(lagnaDeg);

    // Build per-house planet lists
    final List<List<_PlanetLabel>> houses = List.generate(12, (_) => []);
    planets.forEach((key, value) {
      if (!abbrev.containsKey(key) || value is! Map) return;
      final pRashiIdx = rashiList.indexOf(value['rashi'] ?? '');
      if (pRashiIdx == -1) return;

      int hi;
      if (_chartStyle == 'North') {
        if (_showKP) {
          // KP: use Placidus house number directly
          hi = (value['house'] as num? ?? 1).toInt() - 1;
          if (hi < 0 || hi > 11) hi = 0;
        } else {
          hi = (pRashiIdx - lagnaIdx + 12) % 12;
        }
      } else {
        // South: planets always go in their rashi cell
        hi = pRashiIdx;
      }

      final deg   = (value['degree'] as num? ?? 0.0).toDouble();
      final retro = value['is_retrograde'] == true;
      final exalt = value['is_exalted'] == true;
      houses[hi].add(_PlanetLabel(abbrev[key]!, deg, retro, exalt));
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

          // ── KP banner ─────────────────────────────────────────────
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
                Expanded(child: Text('KP System — Krishnamurti Paddhati (Placidus Cusps)',
                  style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600))),
              ]),
            ),

          // ── Chart ────────────────────────────────────────────────
          SizedBox(
            width: chartSize,
            height: chartSize,
            child: Stack(children: [
              CustomPaint(
                size: Size(chartSize, chartSize),
                painter: _chartStyle == 'North'
                    ? _NorthPainter()
                    : _SouthPainter()),
              if (_chartStyle == 'North')
                ..._buildNorthHouses(houses, lagnaIdx, lagnaIdx, lagnaDegStr, chartSize),
              if (_chartStyle == 'South')
                ..._buildSouthHouses(houses, lagnaIdx, lagnaDegStr, cellW),
            ]),
          ),

          const SizedBox(height: 8),

          // ── AstroSage-style legend ───────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE8D8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE8A87C))),
            child: Wrap(spacing: 18, runSpacing: 6, children: const [
              _LegItem('* Retrograde',      Color(0xFF333333)),
              _LegItem('^ Combust',         Color(0xFF333333)),
              _LegItem('\u25a1 Vargottama', Color(0xFF333333)),
              _LegItem('\u2191 Exalted',    Color(0xFF333333)),
              _LegItem('\u2193 Debilitated',Color(0xFF333333)),
            ]),
          ),
          const SizedBox(height: 10),

          // ── Info card (Lagna / Degree / Nakshatra / Pada) ─────────
          _infoCard(ascendant),
          const SizedBox(height: 12),

          // ── Rashi sign grid (colorful) ───────────────────────────
          _rashiSignGrid(lagnaIdx),
          const SizedBox(height: 12),

          // ── Planet degree summary (bottom, 3-per-row) ──────────────
          _planetDegreeGrid(ascendant, planets),
          const SizedBox(height: 16),
          _quickButtons(),
        ]),
      ),
    );
  }

  // Format degrees within sign as D°MM'SS"
  String _dms(double deg) {
    final d = deg.floor();
    final mt = (deg - d) * 60;
    final m  = mt.floor();
    final s  = ((mt - m) * 60).round();
    return "$d°${m.toString().padLeft(2,'0')}'${s.toString().padLeft(2,'0')}\"";
  }

  // ── North Indian ──────────────────────────────────────────────────
  List<Widget> _buildNorthHouses(
      List<List<_PlanetLabel>> houses,
      int lagnaIdx,
      int kpLagnaIdx,
      String lagnaDegStr,
      double chartSize) {

    final widgets = <Widget>[];

    // Get KP cusps if needed
    final kpCusps = _showKP ? _getKpCusps() : <double>[];

    for (int i = 0; i < 12; i++) {
      final cx = northCentroids[i][0] * chartSize;
      final cy = northCentroids[i][1] * chartSize;
      final w  = northMaxW[i];

      // Rashi number in this house cell
      int houseRashiNum;
      if (_showKP && kpCusps.isNotEmpty) {
        houseRashiNum = (kpCusps[i] / 30).floor() % 12 + 1;
      } else {
        houseRashiNum = (lagnaIdx + i) % 12 + 1;
      }

      // Is this house 1 (Lagna house)?
      final isLagnaHouse = (i == 0);

      widgets.add(Positioned(
        left: cx - w / 2,
        top:  cy - 24,
        width: w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('$houseRashiNum',
              style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold,
                color: rashiColors[(houseRashiNum - 1) % 12])),
            if (isLagnaHouse)
              Text('La $lagnaDegStr',
                style: TextStyle(
                  fontSize: 9, fontWeight: FontWeight.bold,
                  color: AppColors.primary)),
            if (houses[i].isNotEmpty)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 2, runSpacing: 0,
                children: houses[i].map((p) => Text(
                  '${p.label}${p.deg.floor()}°${p.retro ? '*' : ''}${p.exalt ? '↑' : ''}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                )).toList(),
              ),
          ],
        ),
      ));
    }
    return widgets;
  }

  // ── South Indian ──────────────────────────────────────────────────
  List<Widget> _buildSouthHouses(
      List<List<_PlanetLabel>> houses,
      int lagnaIdx,
      String lagnaDegStr,
      double cellW) {

    final kpCusps = _showKP ? _getKpCusps() : <double>[];
    final widgets = <Widget>[];

    for (int rashiI = 0; rashiI < 12; rashiI++) {
      final row = rashiToCell[rashiI][0];
      final col = rashiToCell[rashiI][1];
      final isLagna = rashiI == lagnaIdx;

      // House number label for this rashi cell
      String houseLabel;
      if (_showKP && kpCusps.isNotEmpty) {
        // Which house cusps fall in this rashi?
        final List<int> housesInRashi = [];
        for (int h = 0; h < kpCusps.length; h++) {
          final cuspRashiIdx = (kpCusps[h] / 30).floor() % 12;
          if (cuspRashiIdx == rashiI) housesInRashi.add(h + 1);
        }
        houseLabel = housesInRashi.isNotEmpty ? 'H${housesInRashi.join(",")}' : '';
      } else {
        final hNum = (rashiI - lagnaIdx + 12) % 12 + 1;
        houseLabel = '$hNum';
      }

      final color = rashiColors[rashiI];
      // Planets in this cell: in South, planets stay in their rashi
      final cellPlanets = houses[rashiI];

      widgets.add(Positioned(
        left: col * cellW + 2,
        top:  row * cellW + 2,
        width: cellW - 4,
        height: cellW - 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 2),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(rashiSymbols[rashiI],
                style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
              const SizedBox(width: 2),
              Text(houseLabel,
                style: TextStyle(fontSize: 15, color: color, fontWeight: FontWeight.bold)),
            ]),
            if (isLagna)
              Text('La $lagnaDegStr',
                style: TextStyle(
                  fontSize: 8, fontWeight: FontWeight.bold,
                  color: AppColors.primary)),
            if (cellPlanets.isNotEmpty)
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 1, runSpacing: 0,
                  children: cellPlanets.map((p) => Text(
                    '${p.label}${p.deg.floor()}${p.retro ? '*' : ''}${p.exalt ? '↑' : ''}',
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black87),
                  )).toList(),
                ),
              ),
          ],
        ),
      ));
    }
    return widgets;
  }

  // ── Planet degree summary ──────────────────────────────────────
  Widget _planetDegreeGrid(Map<String, dynamic> asc, Map<String, dynamic> plnts) {
    final entries = [
      _PlanetDeg('La', asc,              const Color(0xFFE07B20)),
      _PlanetDeg('Su', plnts['Sun'],     const Color(0xFFE53935)),
      _PlanetDeg('Mo', plnts['Moon'],    const Color(0xFF1565C0)),
      _PlanetDeg('Ma', plnts['Mars'],    const Color(0xFFBF360C)),
      _PlanetDeg('Me', plnts['Mercury'], const Color(0xFF2E7D32)),
      _PlanetDeg('Ju', plnts['Jupiter'], const Color(0xFF6D4C41)),
      _PlanetDeg('Ve', plnts['Venus'],   const Color(0xFF00838F)),
      _PlanetDeg('Sa', plnts['Saturn'],  const Color(0xFF37474F)),
      _PlanetDeg('Ra', plnts['Rahu'],    const Color(0xFF6A1B9A)),
      _PlanetDeg('Ke', plnts['Ketu'],    const Color(0xFF558B2F)),
    ];

    final rows = <Widget>[];
    for (int i = 0; i < entries.length; i += 3) {
      final slice = entries.sublist(i, (i + 3).clamp(0, entries.length));
      final cells = <Widget>[];
      for (final e in slice) {
        final data   = e.data as Map<String, dynamic>?;
        final deg    = (data?['degree'] as num? ?? 0).toDouble();
        final retro  = data?['is_retrograde'] == true;
        final comb   = data?['is_combust']    == true;
        final suffix = '${retro ? '*' : ''}${comb ? '^' : ''}';
        cells.add(Expanded(
          child: Row(children: [
            SizedBox(width: 26,
              child: Text('${e.abbr}$suffix',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: e.color))),
            Flexible(child: Text(_dms(deg),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: e.color),
              overflow: TextOverflow.ellipsis)),
          ]),
        ));
      }
      while (cells.length < 3) cells.add(const Expanded(child: SizedBox()));
      rows.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: cells),
      ));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accentLight)),
      child: Column(children: rows),
    );
  }

  // ── Colorful rashi sign grid ──────────────────────────────────────
  Widget _rashiSignGrid(int lagnaIdx) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text('Rashi (Signs) Reference',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
      ),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.15,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemCount: 12,
        itemBuilder: (_, i) {
          final color = rashiColors[i];
          final isLagna = i == lagnaIdx;
          return Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isLagna ? AppColors.primary : color.withOpacity(0.4),
                width: isLagna ? 2 : 1,
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(rashiSymbols[i],
                      style: TextStyle(fontSize: 16, color: color)),
                    Text('${i + 1}',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
                    Text(rashiList[i].substring(0, 4),
                      style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600)),
                    Text(rashiEngNames[i].substring(0, 3),
                      style: TextStyle(fontSize: 8, color: color.withOpacity(0.7))),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ]);
  }

  // ── Widgets ───────────────────────────────────────────────────────
  Widget _toggle(String label, String val) {
    final sel = _chartStyle == val;
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
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))]
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
          _infoItem('Degree',   '${(asc['degree'] as num? ?? 0).toStringAsFixed(1)}°'),
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
          color: Colors.white,
          border: Border.all(color: AppColors.accent),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 4)]),
        child: Text(b, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
      )).toList());
  }
}

// ── Data class ───────────────────────────────────────────────────────
class _PlanetLabel {
  final String label;
  final double deg;
  final bool retro, exalt;
  const _PlanetLabel(this.label, this.deg, this.retro, this.exalt);
}

class _PlanetDeg {
  final String abbr;
  final dynamic data;
  final Color color;
  const _PlanetDeg(this.abbr, this.data, this.color);
}

// ── Legend item ──────────────────────────────────────────────────────
class _LegItem extends StatelessWidget {
  final String text;
  final Color color;
  const _LegItem(this.text, this.color);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color));
  }
}

// ── Painters ─────────────────────────────────────────────────────────
class _NorthPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = AppColors.primary..strokeWidth = 1.5..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromLTWH(0, 0, s.width, s.height), p);
    canvas.drawLine(Offset(0, 0),           Offset(s.width, s.height),   p);
    canvas.drawLine(Offset(s.width, 0),     Offset(0, s.height),         p);
    canvas.drawLine(Offset(s.width/2, 0),   Offset(0, s.height/2),       p);
    canvas.drawLine(Offset(s.width/2, 0),   Offset(s.width, s.height/2), p);
    canvas.drawLine(Offset(0, s.height/2),  Offset(s.width/2, s.height), p);
    canvas.drawLine(Offset(s.width, s.height/2), Offset(s.width/2, s.height), p);
  }
  @override bool shouldRepaint(_) => false;
}

class _SouthPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = AppColors.primary..strokeWidth = 1.5..style = PaintingStyle.stroke;
    final w = s.width / 4;
    canvas.drawRect(Rect.fromLTWH(0, 0, s.width, s.height), p);
    canvas.drawLine(Offset(w, 0),     Offset(w, s.height),     p);
    canvas.drawLine(Offset(2*w, 0),   Offset(2*w, w),          p);
    canvas.drawLine(Offset(2*w, 3*w), Offset(2*w, s.height),   p);
    canvas.drawLine(Offset(3*w, 0),   Offset(3*w, s.height),   p);
    canvas.drawLine(Offset(0, w),     Offset(s.width, w),      p);
    canvas.drawLine(Offset(0, 2*w),   Offset(w, 2*w),          p);
    canvas.drawLine(Offset(3*w, 2*w), Offset(s.width, 2*w),    p);
    canvas.drawLine(Offset(0, 3*w),   Offset(s.width, 3*w),    p);
  }
  @override bool shouldRepaint(_) => false;
}