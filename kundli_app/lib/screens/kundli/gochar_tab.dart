import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class GocharTab extends StatefulWidget {
  const GocharTab({super.key});

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

  static const rashiList = [
    'Mesh', 'Vrishabh', 'Mithun', 'Kark', 'Singh', 'Kanya',
    'Tula', 'Vrischik', 'Dhanu', 'Makar', 'Kumbh', 'Meen'
  ];

  static const Map<String, String> abbrev = {
    'Sun': 'सू', 'Moon': 'च', 'Mars': 'मं', 'Mercury': 'बु',
    'Jupiter': 'गु', 'Venus': 'शु', 'Saturn': 'श',
    'Rahu': 'रा', 'Ketu': 'के', 'Uranus': 'यू', 'Neptune': 'ने', 'Pluto': 'प्लू'
  };

  static const Map<String, String> planetHindi = {
    'Sun': 'सूर्य', 'Moon': 'चंद्र', 'Mars': 'मंगल', 'Mercury': 'बुध',
    'Jupiter': 'गुरु', 'Venus': 'शुक्र', 'Saturn': 'शनि',
    'Rahu': 'राहु', 'Ketu': 'केतु', 'Uranus': 'यूरेनस',
    'Neptune': 'नेप्च्यून', 'Pluto': 'प्लूटो'
  };

  static const Map<String, Color> planetColors = {
    'Sun': Color(0xFFFF6B35), 'Moon': Color(0xFF4A90D9),
    'Mars': Color(0xFFE53935), 'Mercury': Color(0xFF43A047),
    'Jupiter': Color(0xFFFF8F00), 'Venus': Color(0xFF8E24AA),
    'Saturn': Color(0xFF546E7A), 'Rahu': Color(0xFF6D4C41),
    'Ketu': Color(0xFF558B2F), 'Uranus': Color(0xFF0277BD),
    'Neptune': Color(0xFF2E7D32), 'Pluto': Color(0xFF4A148C),
  };

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
      setState(() {
        _gocharData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  String _formatDeg(dynamic deg) {
    if (deg == null) return '-';
    final d = (deg as num).toDouble();
    final degrees = d.floor();
    final minsTotal = ((d - degrees) * 60);
    final minutes = minsTotal.floor();
    final seconds = ((minsTotal - minutes) * 60).round();
    return "${degrees.toString().padLeft(2, '0')}°${minutes.toString().padLeft(2, '0')}'${seconds.toString().padLeft(2, '0')}\"";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFE07B20)));
    }

    // Show error / retry if data failed to load or API returned null
    if (_error != null || _gocharData == null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFFE07B20)),
        const SizedBox(height: 12),
        Text(
          _error != null ? 'Error: $_error' : 'Could not fetch transit data.\nCheck your server connection.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF7F8C8D), fontSize: 13),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _loadGochar,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retry'),
        ),
      ]));
    }

    final transits = (_gocharData!['transits'] as Map<String, dynamic>?) ?? {};
    if (transits.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.hourglass_empty_rounded, size: 48, color: Color(0xFFE07B20)),
        const SizedBox(height: 12),
        const Text('No transit data received.', style: TextStyle(color: Color(0xFF7F8C8D))),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _loadGochar,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retry'),
        ),
      ]));
    }

    final computedAt = _gocharData!['computed_at_utc'] as String? ?? '';

    // Build chart houses (North Indian, Mesh = rashi_num 1 = index 0)
    List<List<Map<String, dynamic>>> houses = List.generate(12, (_) => []);
    transits.forEach((pName, pData) {
      final rashiNum = ((pData as Map<String, dynamic>)['rashi_num'] as num? ?? 1).toInt();
      final houseIdx = (rashiNum - 1).clamp(0, 11);
      houses[houseIdx].add({'name': pName, ...pData});
    });

    final northAlign = [
      const Alignment(0, -0.55), const Alignment(-0.5, -0.78),
      const Alignment(-0.78, -0.5), const Alignment(-0.55, 0),
      const Alignment(-0.78, 0.5), const Alignment(-0.5, 0.78),
      const Alignment(0, 0.55), const Alignment(0.5, 0.78),
      const Alignment(0.78, 0.5), const Alignment(0.55, 0),
      const Alignment(0.78, -0.5), const Alignment(0.5, -0.78),
    ];

    return Container(
      color: AppColors.scaffoldBg,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _orange, borderRadius: BorderRadius.circular(10)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('गोचर (Transit)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(computedAt, style: const TextStyle(color: Colors.white70, fontSize: 10)),
            ]),
          ),
          const SizedBox(height: 12),

          // Refresh button
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
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                Icon(Icons.refresh_rounded, color: Color(0xFFE07B20), size: 16),
                SizedBox(width: 6),
                Text('Refresh Current Positions', style: TextStyle(color: Color(0xFFE07B20), fontWeight: FontWeight.w600, fontSize: 12)),
              ]),
            ),
          ),
          const SizedBox(height: 12),

          // North Indian Chart
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.width - 28,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _orange, width: 2),
              boxShadow: [BoxShadow(color: _orange.withOpacity(0.1), blurRadius: 10)],
            ),
            child: Stack(children: [
              CustomPaint(size: Size.infinite, painter: _NorthPainter(color: _orange)),
              for (int i = 0; i < 12; i++)
                Align(alignment: northAlign[i], child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(rashiList[i].substring(0, 2),
                      style: TextStyle(fontSize: 8, color: _orange.withOpacity(0.6))),
                    ...houses[i].map((p) {
                      final retro = p['is_retrograde'] == true;
                      final col = planetColors[p['name'] as String] ?? _textDark;
                      return Text('${abbrev[p['name']] ?? p['name']}${retro ? '*' : ''}',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: col));
                    }),
                  ]),
                )),
            ]),
          ),
          const SizedBox(height: 8),

          // Legend
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _orangeLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _orange.withOpacity(0.3)),
            ),
            child: const Text('* वक्री (Retrograde)',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE07B20))),
          ),
          const SizedBox(height: 14),

          // Table — all planets
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _orange.withOpacity(0.4)),
              boxShadow: [BoxShadow(color: _orange.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Column(children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _orange,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: Row(children: const [
                  Expanded(flex: 4, child: Text('ग्रह', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                  Expanded(flex: 4, child: Text('राशि', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                  Expanded(flex: 6, child: Text('अंश', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                  Expanded(flex: 5, child: Text('नक्षत्र', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                ]),
              ),
              ...transits.entries.toList().asMap().entries.map((entry) {
                final i = entry.key;
                final p = entry.value;
                final retro = p.value['is_retrograde'] == true;
                final col = planetColors[p.key] ?? _textDark;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: i.isOdd ? Colors.white : const Color(0xFFFFFBF5),
                    border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                  ),
                  child: Row(children: [
                    Expanded(flex: 4, child: Text(
                      '${planetHindi[p.key] ?? p.key}${retro ? ' *' : ''}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: col))),
                    Expanded(flex: 4, child: Text(p.value['rashi'] ?? '-',
                      style: TextStyle(fontSize: 12, color: _orange, fontWeight: FontWeight.w600))),
                    Expanded(flex: 6, child: Text(_formatDeg(p.value['degree']),
                      style: const TextStyle(fontSize: 11, color: _textDark))),
                    Expanded(flex: 5, child: Text(
                      '${p.value['nakshatra'] ?? '-'} P${p.value['pada'] ?? '-'}',
                      style: const TextStyle(fontSize: 10, color: _textGrey))),
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
}

class _NorthPainter extends CustomPainter {
  final Color color;
  const _NorthPainter({required this.color});

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color..strokeWidth = 1.5..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromLTWH(0, 0, s.width, s.height), p);
    canvas.drawLine(Offset(0, 0), Offset(s.width, s.height), p);
    canvas.drawLine(Offset(s.width, 0), Offset(0, s.height), p);
    canvas.drawLine(Offset(s.width / 2, 0), Offset(0, s.height / 2), p);
    canvas.drawLine(Offset(s.width / 2, 0), Offset(s.width, s.height / 2), p);
    canvas.drawLine(Offset(0, s.height / 2), Offset(s.width / 2, s.height), p);
    canvas.drawLine(Offset(s.width, s.height / 2), Offset(s.width / 2, s.height), p);
  }

  @override
  bool shouldRepaint(_) => false;
}
