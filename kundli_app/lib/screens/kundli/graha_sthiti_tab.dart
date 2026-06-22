import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class GrahaSthitiTab extends StatefulWidget {
  final Map<String, dynamic> planets;
  final Map<String, dynamic> ascendant;

  const GrahaSthitiTab({
    super.key,
    required this.planets,
    required this.ascendant,
  });

  @override
  State<GrahaSthitiTab> createState() => _GrahaSthitiTabState();
}

class _GrahaSthitiTabState extends State<GrahaSthitiTab> {
  static const Color _orange = AppColors.primary;
  static const Color _textDark = AppColors.textDark;
  static const Color _textGrey = AppColors.textLight;

  static const rashiList = [
    'Mesh', 'Vrishabh', 'Mithun', 'Kark', 'Singh', 'Kanya',
    'Tula', 'Vrischik', 'Dhanu', 'Makar', 'Kumbh', 'Meen'
  ];

  static const rashiHindi = {
    'Mesh': 'मेष', 'Vrishabh': 'वृषभ', 'Mithun': 'मिथुन', 'Kark': 'कर्क',
    'Singh': 'सिंह', 'Kanya': 'कन्या', 'Tula': 'तुला', 'Vrischik': 'वृश्चिक',
    'Dhanu': 'धनु', 'Makar': 'मकर', 'Kumbh': 'कुंभ', 'Meen': 'मीन'
  };

  static const rashiLordsHindi = {
    'Mesh': 'मंगल', 'Vrishabh': 'शुक्र', 'Mithun': 'बुध', 'Kark': 'चंद्र',
    'Singh': 'सूर्य', 'Kanya': 'बुध', 'Tula': 'शुक्र', 'Vrischik': 'मंगल',
    'Dhanu': 'गुरु', 'Makar': 'शनि', 'Kumbh': 'शनि', 'Meen': 'गुरु'
  };

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
    [0.500, 0.250],
    [0.250, 0.115],
    [0.115, 0.250],
    [0.250, 0.500],
    [0.115, 0.750],
    [0.250, 0.885],
    [0.500, 0.750],
    [0.750, 0.885],
    [0.885, 0.750],
    [0.750, 0.500],
    [0.885, 0.250],
    [0.750, 0.115],
  ];

  static const northMaxW = [80.0, 70.0, 60.0, 70.0, 80.0, 70.0, 60.0, 70.0, 55.0, 60.0, 55.0, 55.0];

  // Complete mapping of Rashi -> 3 Nakshatras & Letters
  static const Map<String, List<Map<String, String>>> rashiNakshatras = {
    'Mesh': [
      {'name': 'अश्विनी', 'letters': 'चू, चे, चो, ला', 'lord': 'केतु'},
      {'name': 'भरणी', 'letters': 'ली, लू, ले, लो', 'lord': 'शुक्र'},
      {'name': 'कृत्तिका 1 चरण', 'letters': 'अ, [आ]', 'lord': 'सूर्य'},
    ],
    'Vrishabh': [
      {'name': 'कृत्तिका 3 चरण', 'letters': 'ई, उ, ए, [ऊ, ऐ]', 'lord': 'सूर्य'},
      {'name': 'रोहिणी', 'letters': 'ओ, वा, वी, वू, [औ, बा, बी, बू]', 'lord': 'चंद्र'},
      {'name': 'मृगशिरा 2 चरण', 'letters': 'वे, वो, [बे, बो]', 'lord': 'मंगल'},
    ],
    'Mithun': [
      {'name': 'मृगशिरा 2 चरण', 'letters': 'का, की', 'lord': 'मंगल'},
      {'name': 'आर्द्रा', 'letters': 'कू, घ, ङ, छ', 'lord': 'राहु'},
      {'name': 'पुनर्वसु 3 चरण', 'letters': 'के, को, हा', 'lord': 'गुरु'},
    ],
    'Kark': [
      {'name': 'पुनर्वसु 1 चरण', 'letters': 'ही', 'lord': 'गुरु'},
      {'name': 'पुष्य', 'letters': 'हू, हे, हो, डा', 'lord': 'शनि'},
      {'name': 'आश्लेषा', 'letters': 'डी, डू, डे, डो, [ढी, ढू, ढे, ढो]', 'lord': 'बुध'},
    ],
    'Singh': [
      {'name': 'मघा', 'letters': 'मा, मी, मू, मे', 'lord': 'केतु'},
      {'name': 'पूर्वाफाल्गुनी', 'letters': 'मो, टा, टी, टू', 'lord': 'शुक्र'},
      {'name': 'उत्तराफाल्गुनी 1 चरण', 'letters': 'टे', 'lord': 'सूर्य'},
    ],
    'Kanya': [
      {'name': 'उत्तराफाल्गुनी 3 चरण', 'letters': 'टो, पा, पी', 'lord': 'सूर्य'},
      {'name': 'हस्त', 'letters': 'पू, ष, ण, ठ, [ठे]', 'lord': 'चंद्र'},
      {'name': 'चित्रा 2 चरण', 'letters': 'पे, पो', 'lord': 'मंगल'},
    ],
    'Tula': [
      {'name': 'चित्रा 2 चरण', 'letters': 'रा, री', 'lord': 'मंगल'},
      {'name': 'स्वाती', 'letters': 'रू, रे, रो, ता', 'lord': 'राहु'},
      {'name': 'विशाखा 3 चरण', 'letters': 'ती, तू, ते', 'lord': 'गुरु'},
    ],
    'Vrischik': [
      {'name': 'विशाखा 1 चरण', 'letters': 'तो', 'lord': 'गुरु'},
      {'name': 'अनुराधा', 'letters': 'ना, नी, नू, ने', 'lord': 'शनि'},
      {'name': 'ज्येष्ठा', 'letters': 'नो, या, यी, यू', 'lord': 'बुध'},
    ],
    'Dhanu': [
      {'name': 'मूल', 'letters': 'ये, यो, भा, bhi', 'lord': 'केतु'},
      {'name': 'पूर्वाषाढ़ा', 'letters': 'भू, धा, फा, ढा, [धी, धू, फ़ा]', 'lord': 'शुक्र'},
      {'name': 'उत्तराषाढ़ा 1 चरण', 'letters': 'भे', 'lord': 'सूर्य'},
    ],
    'Makar': [
      {'name': 'उत्तराषाढ़ा 3 चरण', 'letters': 'भो, जा, जी', 'lord': 'सूर्य'},
      {'name': 'श्रवण', 'letters': 'खी, खू, खे, खो', 'lord': 'चंद्र'},
      {'name': 'धनिष्ठा 2 चरण', 'letters': 'गा, गी', 'lord': 'मंगल'},
    ],
    'Kumbh': [
      {'name': 'धनिष्ठा 2 चरण', 'letters': 'गू, गे', 'lord': 'मंगल'},
      {'name': 'शतभिषा', 'letters': 'गो, सा, सी, सू, [शा, शी, शू, श]', 'lord': 'राहु'},
      {'name': 'पूर्वाभाद्रपद 3 चरण', 'letters': 'से, सो, दा', 'lord': 'गुरु'},
    ],
    'Meen': [
      {'name': 'पूर्वाभाद्रपद 1 चरण', 'letters': 'दी', 'lord': 'गुरु'},
      {'name': 'उत्तराभाद्रपद', 'letters': 'दू, थ, झ, ञ, [था, थी, थू, थे, थो]', 'lord': 'शनि'},
      {'name': 'रेवती', 'letters': 'दे, दो, चा, ची', 'lord': 'बुध'},
    ],
  };

  // Check matching nakshatra helper
  bool _isMatchingNakshatra(String engNak, String hindiNak) {
    String normalizedEng = engNak.replaceAll(RegExp(r'[^a-zA-Z]'), '').toLowerCase();
    String normalizedHindi = hindiNak.replaceAll(RegExp(r'[0-9\s\-\u2014]'), '').replaceAll('चरण', '');
    
    if (normalizedEng == 'pphalguni' && normalizedHindi.contains('पूर्वाफाल्गुनी')) return true;
    if (normalizedEng == 'uphalguni' && normalizedHindi.contains('उत्तराफाल्गुनी')) return true;
    if (normalizedEng == 'pashadha' && normalizedHindi.contains('पूर्वाषाढ़ा')) return true;
    if (normalizedEng == 'uashadha' && normalizedHindi.contains('उत्तराषाढ़ा')) return true;
    if (normalizedEng == 'pbhadra' && normalizedHindi.contains('पूर्वाभाद्रपद')) return true;
    if (normalizedEng == 'ubhadra' && normalizedHindi.contains('उत्तराभाद्रपद')) return true;
    if (normalizedEng == 'moola' && normalizedHindi.contains('मूल')) return true;
    if (normalizedEng == 'swati' && normalizedHindi.contains('स्वाती')) return true;

    final Map<String, String> translation = {
      'ashwini': 'अश्विनी', 'bharani': 'भरणी', 'krittika': 'कृत्तिका',
      'rohini': 'रोहिणी', 'mrigashira': 'मृगशिरा', 'ardra': 'आर्द्रा',
      'punarvasu': 'पुनर्वसु', 'pushya': 'पुष्य', 'ashlesha': 'आश्लेषा',
      'magha': 'मघा', 'hasta': 'हस्त', 'chitra': 'चित्रा',
      'anuradha': 'अनुराधा', 'jyeshtha': 'ज्येष्ठा', 'shravana': 'श्रवण',
      'dhanishtha': 'धनिष्ठा', 'shatabhisha': 'शतभिषा', 'revati': 'रेवती'
    };

    if (translation.containsKey(normalizedEng)) {
      return normalizedHindi.contains(translation[normalizedEng]!);
    }
    return false;
  }

  String _formatDegree(dynamic deg) {
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
    // 1. Process Chart Data
    int lagnaIdx = rashiList.indexOf(widget.ascendant['rashi'] ?? '');
    if (lagnaIdx == -1) lagnaIdx = 0;

    final lagnaDeg = (widget.ascendant['degree'] as num? ?? 0).toDouble();
    final lagnaDegStr = _formatDegree(lagnaDeg);

    final List<List<_PlanetLabel>> houses = List.generate(12, (_) => []);
    widget.planets.forEach((key, value) {
      if (!abbrev.containsKey(key) || value is! Map) return;
      final pRashiIdx = rashiList.indexOf(value['rashi'] ?? '');
      if (pRashiIdx == -1) return;
      int hi = (pRashiIdx - lagnaIdx + 12) % 12;
      final deg = (value['degree'] as num? ?? 0.0).toDouble();
      final retro = value['is_retrograde'] == true;
      final exalt = value['is_exalted'] == true;
      houses[hi].add(_PlanetLabel(abbrev[key]!, deg, retro, exalt));
    });

    final double chartSize = MediaQuery.of(context).size.width - 32;

    // 2. Fetch Moon details
    final chandra = widget.planets['Moon'] as Map<String, dynamic>?;
    if (chandra == null) {
      return const Center(child: Text('Moon details not available.'));
    }

    final moonRashi = chandra['rashi'] as String? ?? 'Mesh';
    final moonRashiHindi = rashiHindi[moonRashi] ?? moonRashi;
    final moonRashiLordHindi = rashiLordsHindi[moonRashi] ?? '';
    final moonNakshatra = chandra['nakshatra'] as String? ?? '';
    final moonPada = chandra['pada'] as int? ?? 1;

    // Get syllables for all 3 Nakshatras of Moon's Rashi
    final nakList = rashiNakshatras[moonRashi] ?? [];
    
    // Find active nakshatra from list and get first letter
    String moonFirstLetter = '-';
    int activeNakIdx = -1;
    for (int idx = 0; idx < nakList.length; idx++) {
      if (_isMatchingNakshatra(moonNakshatra, nakList[idx]['name']!)) {
        activeNakIdx = idx;
        final lettersStr = nakList[idx]['letters']!;
        // Extract 1st letter
        moonFirstLetter = lettersStr.split(',').first.replaceAll('[', '').replaceAll(']', '').trim();
        break;
      }
    }

    return Container(
      color: AppColors.scaffoldBg,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── KUNDLI CHART AT TOP ───────────────────────────────────
          Center(
            child: Container(
              width: chartSize,
              height: chartSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
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
            ),
          ),
          
          const SizedBox(height: 20),

          // ── ONLY CHANDRA (MOON) DETAILS CARD ──────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _orange.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: _orange.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_orange.withOpacity(0.85), const Color(0xFFFFB0C0)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'चंद्र (Moon)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        'घर ${chandra['house'] ?? '-'}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),

                // Main Details List
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _detRow('राशि', '$moonRashiHindi ($moonRashiLordHindi)'),
                      _detRow('नक्षत्र', '$moonNakshatra पद $moonPada'),
                      _detRow('नक्षत्र स्वामी', chandra['nakshatra_lord'] ?? '-'),
                      _detRow('नामाक्षर', moonFirstLetter), // Chandra jis nakshatra m rhega uska 1st letter
                      _detRow('अंश', _formatDegree(chandra['degree'])),
                      _detRow('गति (Speed)', '${(chandra['speed'] as num? ?? 0).toStringAsFixed(4)}°/day'),
                    ],
                  ),
                ),

                // All 3 Nakshatras & Nama Aksharas Section
                Container(
                  decoration: BoxDecoration(
                    color: _orange.withOpacity(0.02),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                    border: Border(top: BorderSide(color: Colors.grey.shade100)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$moonRashiHindi राशि के सभी नक्षत्र और नामाक्षर:',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                      ),
                      const SizedBox(height: 10),
                      ...nakList.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        final isCurrent = idx == activeNakIdx;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isCurrent ? _orange.withOpacity(0.08) : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCurrent ? _orange : Colors.grey.shade200,
                              width: isCurrent ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isCurrent ? Icons.stars_rounded : Icons.radio_button_off_rounded,
                                color: isCurrent ? _orange : Colors.grey,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${item['name']} (${item['letters']}) — ${item['lord']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                    color: isCurrent ? _orange : Colors.black87,
                                  ),
                                ),
                              ),
                              if (isCurrent)
                                const Text(
                                  'सक्रिय',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _orange),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Draw North Indian style house annotations
  List<Widget> _buildNorthHouses(
      List<List<_PlanetLabel>> houses,
      int lagnaIdx,
      String lagnaDegStr,
      double chartSize) {
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

  Widget _detRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: _textGrey, fontSize: 13)),
          Text(value, style: const TextStyle(color: _textDark, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

class _PlanetLabel {
  final String label;
  final double deg;
  final bool retro, exalt;
  const _PlanetLabel(this.label, this.deg, this.retro, this.exalt);
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
