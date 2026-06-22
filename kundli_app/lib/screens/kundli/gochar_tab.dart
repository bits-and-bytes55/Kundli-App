import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class GocharTab extends StatefulWidget {
  final Map<String, dynamic>? birthAscendant;
  final Map<String, dynamic>? birthPlanets;

  const GocharTab({
    super.key,
    this.birthAscendant,
    this.birthPlanets,
  });

  @override
  State<GocharTab> createState() => _GocharTabState();
}

class _GocharTabState extends State<GocharTab> {
  static const Color _orange = AppColors.primary;
  static const Color _orangeLight = AppColors.accentLight;
  static const Color _textDark = AppColors.textDark;
  static const Color _textGrey = AppColors.textLight;

  Map<String, dynamic>? _gocharData;
  bool _isLoading = true;
  String? _error;

  // Toggle: false = Janma Lagna based, true = Moon (Chandra) Lagna based
  bool _isMoonLagna = false;

  static const List<String> rashiList = [
    'Mesh', 'Vrishabh', 'Mithun', 'Kark', 'Singh', 'Kanya',
    'Tula', 'Vrischik', 'Dhanu', 'Makar', 'Kumbh', 'Meen',
  ];

  static const Map<String, String> abbrev = {
    'Sun': 'सू', 'Moon': 'च', 'Mars': 'मं', 'Mercury': 'बु',
    'Jupiter': 'गु', 'Venus': 'शु', 'Saturn': 'श',
    'Rahu': 'रा', 'Ketu': 'के', 'Uranus': 'यू',
    'Neptune': 'ने', 'Pluto': 'प्लू',
  };

  static const Map<String, String> planetHindi = {
    'Sun': 'सूर्य', 'Moon': 'चंद्र', 'Mars': 'मंगल', 'Mercury': 'बुध',
    'Jupiter': 'गुरु', 'Venus': 'शुक्र', 'Saturn': 'शनि',
    'Rahu': 'राहु', 'Ketu': 'केतु', 'Uranus': 'यूरेनस',
    'Neptune': 'नेप्च्यून', 'Pluto': 'प्लूटो',
  };

  static const Map<String, Color> planetColors = {
    'Sun': Color(0xFFFF6B35), 'Moon': Color(0xFF4A90D9),
    'Mars': Color(0xFFE53935), 'Mercury': Color(0xFF43A047),
    'Jupiter': Color(0xFFFF8F00), 'Venus': Color(0xFF8E24AA),
    'Saturn': Color(0xFF546E7A), 'Rahu': Color(0xFF6D4C41),
    'Ketu': Color(0xFF558B2F), 'Uranus': Color(0xFF0277BD),
    'Neptune': Color(0xFF2E7D32), 'Pluto': Color(0xFF4A148C),
  };

  // Display order for the planet table
  static const List<String> _tableOrder = [
    'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter',
    'Venus', 'Saturn', 'Rahu', 'Ketu',
    'Uranus', 'Neptune', 'Pluto',
  ];

  @override
  void initState() {
    super.initState();
    _loadGochar();
  }

  Future<void> _loadGochar() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final api = Get.find<ApiService>();
      final data = await api.getGochar();
      setState(() { _gocharData = data; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  String _formatDeg(dynamic deg) {
    if (deg == null) return '-';
    final d = (deg as num).toDouble();
    final degrees = d.floor();
    final minsTotal = (d - degrees) * 60;
    final minutes = minsTotal.floor();
    final seconds = ((minsTotal - minutes) * 60).round();
    return "${degrees.toString().padLeft(2, '0')}°"
        "${minutes.toString().padLeft(2, '0')}'"
        "${seconds.toString().padLeft(2, '0')}\"";
  }

  // ── House placement logic ─────────────────────────────────────────────────
  // AstroSage Transit chart:
  //   Moon toggle  → current transit Moon rashi = house 1
  //   Lagna toggle → current transit ascendant rashi = house 1
  // House of planet = ((planet_rashi_num - ref_rashi_num) % 12) + 1

  int _refRashiNum(Map<String, dynamic> transits, Map<String, dynamic>? currentLagna) {
    if (_isMoonLagna) {
      // If birth planets are provided, use birth Moon rashi. Otherwise use current transit Moon.
      if (widget.birthPlanets != null) {
        final birthMoon = widget.birthPlanets!['Moon'] as Map<String, dynamic>?;
        if (birthMoon != null) {
          return ((birthMoon['rashi_num'] as num?)?.toInt() ?? 1);
        }
      }
      final moonData = transits['Moon'] as Map<String, dynamic>?;
      return ((moonData?['rashi_num'] as num?)?.toInt() ?? 1);
    } else {
      // If birth ascendant is provided, use birth Lagna rashi. Otherwise use current transit Lagna.
      if (widget.birthAscendant != null) {
        return ((widget.birthAscendant!['rashi_num'] as num?)?.toInt() ?? 1);
      }
      return ((currentLagna?['rashi_num'] as num?)?.toInt() ?? 1);
    }
  }

  // North-Indian chart: fixed cell layout (0-indexed, row-major 4x4 grid)
  // Cell assignments in North-Indian style (house positions in the grid):
  //   [top-mid-left, top-mid-right] → houses 12, 1
  //   going clockwise: 11,10,9,8,7,6,5,4,3,2
  // Rashi in each cell = (refRashiNum + cellHouseOffset - 2) % 12
  //
  // North Indian fixed house positions (clockwise from top-left cell):
  //  Cell order in 4x4 grid (12 border cells):
  //   index 0=top-mid-L (h12), 1=top-mid-R (h1),
  //   2=R-top (h2), 3=R-mid (h3), 4=R-bot (h4),
  //   5=bot-mid-R (h5), 6=bot-mid-L (h6),
  //   7=L-bot (h7), 8=L-mid (h8), 9=L-top (h9),
  //   10=top-L (h10), 11=top-R (h11)  ... standard NI layout
  //
  // Simpler: in North-Indian chart the HOUSE NUMBER positions are FIXED.
  // House 1 is always top-center-right, 2 right-top, … rotating clockwise.
  // We compute which RASHI falls in each fixed HOUSE cell based on ref rashi.

  /// Returns rashi index (0-based) for a given NI house number (1-based)
  int _rashiForHouse(int house, int refRashiNum) {
    // house 1 gets refRashiNum, house 2 gets refRashiNum+1, etc.
    return (refRashiNum - 1 + house - 1) % 12;
  }

  // North-Indian grid: 12 cells — FIXED positions (house 1 always top-center)
  // Rashis rotate based on lagna; positions below match standard NI layout.
  static const List<_NiCell> _niCells = [
    _NiCell(house:  1, alignment: Alignment( 0.0,  -0.55)),  // top-center
    _NiCell(house:  2, alignment: Alignment(-0.5,  -0.78)),  // top-left corner
    _NiCell(house:  3, alignment: Alignment(-0.78, -0.5 )),  // left-top
    _NiCell(house:  4, alignment: Alignment(-0.55,  0.0 )),  // left-center
    _NiCell(house:  5, alignment: Alignment(-0.78,  0.5 )),  // left-bottom
    _NiCell(house:  6, alignment: Alignment(-0.5,   0.78)),  // bottom-left corner
    _NiCell(house:  7, alignment: Alignment( 0.0,   0.55)),  // bottom-center
    _NiCell(house:  8, alignment: Alignment( 0.5,   0.78)),  // bottom-right corner
    _NiCell(house:  9, alignment: Alignment( 0.78,  0.5 )),  // right-bottom
    _NiCell(house: 10, alignment: Alignment( 0.55,  0.0 )),  // right-center
    _NiCell(house: 11, alignment: Alignment( 0.78, -0.5 )),  // right-top
    _NiCell(house: 12, alignment: Alignment( 0.5,  -0.78)),  // top-right corner
  ];

  // Build houses list: for each of 12 houses, which planets are there?
  List<List<Map<String, dynamic>>> _buildHouses(
      Map<String, dynamic> transits, int refRashiNum) {
    // houses[0] = house 1, houses[11] = house 12
    final List<List<Map<String, dynamic>>> houses =
        List.generate(12, (_) => []);

    transits.forEach((pName, pData) {
      final pd = pData as Map<String, dynamic>;
      final planetRashiNum = ((pd['rashi_num'] as num?)?.toInt() ?? 1);
      // house = ((planet_rashi - ref_rashi) % 12) + 1
      final house = ((planetRashiNum - refRashiNum) % 12) + 1;
      houses[house - 1].add({'name': pName, ...pd});
    });
    return houses;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFE07B20)));
    }

    if (_error != null || _gocharData == null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFFE07B20)),
          const SizedBox(height: 12),
          Text(
            _error != null
                ? 'Error: $_error'
                : 'Could not fetch transit data.\nCheck your server connection.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF7F8C8D), fontSize: 13),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _loadGochar,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ]),
      );
    }

    final transits =
        (_gocharData!['transits'] as Map<String, dynamic>?) ?? {};
    if (transits.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.hourglass_empty_rounded,
              size: 48, color: Color(0xFFE07B20)),
          const SizedBox(height: 12),
          const Text('No transit data received.',
              style: TextStyle(color: Color(0xFF7F8C8D))),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _loadGochar,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ]),
      );
    }

    final computedAt = _gocharData!['computed_at_utc'] as String? ?? '';
    final currentLagna = _gocharData!['current_lagna'] as Map<String, dynamic>?;
    final refRashiNum = _refRashiNum(transits, currentLagna);
    final houses = _buildHouses(transits, refRashiNum);

    return Container(
      color: AppColors.scaffoldBg,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _orange, borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('गोचर (Transit)',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Text(computedAt,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Refresh button ───────────────────────────────────────────────
          GestureDetector(
            onTap: _loadGochar,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: _orange),
                borderRadius: BorderRadius.circular(8),
                color: _orangeLight,
              ),
              alignment: Alignment.center,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_rounded,
                      color: Color(0xFFE07B20), size: 16),
                  SizedBox(width: 6),
                  Text('Refresh Current Positions',
                      style: TextStyle(
                          color: Color(0xFFE07B20),
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ── Moon / Lagna toggle (like AstroSage) ─────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _orange.withOpacity(0.4)),
            ),
            child: Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isMoonLagna = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _isMoonLagna ? _orange : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(7),
                        bottomLeft: Radius.circular(7)),
                    ),
                    alignment: Alignment.center,
                    child: Text('चंद्र (Moon)',
                        style: TextStyle(
                            color: _isMoonLagna
                                ? Colors.white
                                : _orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isMoonLagna = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !_isMoonLagna ? _orange : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(7),
                        bottomRight: Radius.circular(7)),
                    ),
                    alignment: Alignment.center,
                    child: Text('लग्न (Lagna)',
                        style: TextStyle(
                            color: !_isMoonLagna
                                ? Colors.white
                                : _orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ),
                ),
              ),
            ]),
          ),

          // Reference rashi info
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              _isMoonLagna
                  ? 'चंद्र लग्न: ${rashiList[(refRashiNum - 1).clamp(0, 11)]} (House 1)'
                  : 'जन्म लग्न: ${rashiList[(refRashiNum - 1).clamp(0, 11)]} (House 1)',
              style: TextStyle(
                  fontSize: 11,
                  color: _orange,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),

          // ── North Indian Chart ───────────────────────────────────────────
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.width - 28,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _orange, width: 2),
              boxShadow: [
                BoxShadow(
                    color: _orange.withOpacity(0.1), blurRadius: 10)
              ],
            ),
            child: Stack(children: [
              CustomPaint(
                  size: Size.infinite,
                  painter: _NorthPainter(color: _orange)),
              // Place each cell
              for (final cell in _niCells)
                _buildCell(cell, houses, refRashiNum),
            ]),
          ),
          const SizedBox(height: 8),

          // ── Legend ───────────────────────────────────────────────────────
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _orangeLight,
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: _orange.withOpacity(0.3)),
            ),
            child: const Text('* वक्री (Retrograde)',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE07B20))),
          ),

          // Current transit lagna info
          if (currentLagna != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: _orange.withOpacity(0.3)),
              ),
              child: Text(
                'वर्तमान लग्न: ${currentLagna['rashi'] ?? '-'} '
                '${_formatDeg(currentLagna['degree'])}  |  '
                '${currentLagna['nakshatra'] ?? '-'} P${currentLagna['pada'] ?? '-'}',
                style: TextStyle(
                    fontSize: 11,
                    color: _textDark,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
          const SizedBox(height: 14),

          // ── Planet Table ─────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _orange.withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                    color: _orange.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Column(children: [
              // Table header
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _orange,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10)),
                ),
                child: const Row(children: [
                  Expanded(
                      flex: 4,
                      child: Text('ग्रह',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12))),
                  Expanded(
                      flex: 4,
                      child: Text('राशि',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12))),
                  Expanded(
                      flex: 6,
                      child: Text('अंश',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12))),
                  Expanded(
                      flex: 5,
                      child: Text('नक्षत्र',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12))),
                ]),
              ),
              // Rows
              ..._tableOrder.asMap().entries.map((entry) {
                final i = entry.key;
                final pName = entry.value;
                final pData = transits[pName] as Map<String, dynamic>?;
                if (pData == null) return const SizedBox.shrink();
                final retro = pData['is_retrograde'] == true;
                final col = planetColors[pName] ?? _textDark;
                final house = ((((pData['rashi_num'] as num?)
                                    ?.toInt() ??
                                1) -
                            refRashiNum) %
                        12) +
                    1;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: i.isOdd
                        ? Colors.white
                        : const Color(0xFFFFFBF5),
                    border: Border(
                        bottom: BorderSide(
                            color: Colors.grey.shade100)),
                  ),
                  child: Row(children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        '${planetHindi[pName] ?? pName}${retro ? ' *' : ''}',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: col),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        '${pData['rashi'] ?? '-'} (H$house)',
                        style: TextStyle(
                            fontSize: 11,
                            color: _orange,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        _formatDeg(pData['degree']),
                        style: const TextStyle(
                            fontSize: 11, color: _textDark),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(
                        '${pData['nakshatra'] ?? '-'} P${pData['pada'] ?? '-'}',
                        style: const TextStyle(
                            fontSize: 10, color: _textGrey),
                      ),
                    ),
                  ]),
                );
              }),
            ]),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCell(
    _NiCell cell,
    List<List<Map<String, dynamic>>> houses,
    int refRashiNum,
  ) {
    // Rashi index (0-based) that falls in this house cell
    final rashiIdx = _rashiForHouse(cell.house, refRashiNum);
    final planetsInCell = houses[cell.house - 1];

    return Align(
      alignment: cell.alignment,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rashi number label (1 = Mesh, 2 = Vrishabh, ... 12 = Meen)
            Text(
              '${rashiIdx + 1}',
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: _orange.withOpacity(0.75)),
            ),
            // Planets
            ...planetsInCell.map((p) {
              final retro = p['is_retrograde'] == true;
              final col =
                  planetColors[p['name'] as String] ?? _textDark;
              return Text(
                '${abbrev[p['name']] ?? p['name']}${retro ? '*' : ''}',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: col),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Static data class ──────────────────────────────────────────────────────
class _NiCell {
  final int house;
  final Alignment alignment;
  const _NiCell({required this.house, required this.alignment});
}

// ── North-Indian chart painter ─────────────────────────────────────────────
class _NorthPainter extends CustomPainter {
  final Color color;
  const _NorthPainter({required this.color});

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Outer border
    canvas.drawRect(Rect.fromLTWH(0, 0, s.width, s.height), p);
    // Diagonals (corner-to-corner)
    canvas.drawLine(Offset(0, 0), Offset(s.width, s.height), p);
    canvas.drawLine(Offset(s.width, 0), Offset(0, s.height), p);
    // Mid-edge to mid-edge lines
    canvas.drawLine(
        Offset(s.width / 2, 0), Offset(0, s.height / 2), p);
    canvas.drawLine(
        Offset(s.width / 2, 0), Offset(s.width, s.height / 2), p);
    canvas.drawLine(
        Offset(0, s.height / 2), Offset(s.width / 2, s.height), p);
    canvas.drawLine(Offset(s.width, s.height / 2),
        Offset(s.width / 2, s.height), p);
  }

  @override
  bool shouldRepaint(_) => false;
}
