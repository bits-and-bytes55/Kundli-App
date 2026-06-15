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

  @override
  Widget build(BuildContext context) {
    final ascendant = _showKP ? widget.kpAscendant : widget.ascendant;
    final planets = _showKP ? widget.kpPlanets : widget.planets;
    int lagnaIdx = rashiList.indexOf(ascendant['rashi'] ?? '');
    if (lagnaIdx == -1) lagnaIdx = 0;

    List<List<String>> houses = List.generate(12, (_) => []);
    planets.forEach((key, value) {
      if (abbrev.containsKey(key)) {
        int pRashiIdx = rashiList.indexOf(value['rashi'] ?? '');
        if (pRashiIdx != -1) {
          int hi = _chartStyle == 'North' ? (pRashiIdx - lagnaIdx + 12) % 12 : pRashiIdx;
          String lbl = abbrev[key]!;
          if (value['is_retrograde'] == true) lbl += 'ᴿ';
          if (value['is_exalted'] == true) lbl += '↑';
          houses[hi].add(lbl);
        }
      }
    });
    if (_chartStyle == 'South') houses[lagnaIdx].add('La');

    final northAlign = [
      const Alignment(0,-0.5), const Alignment(-0.5,-0.75), const Alignment(-0.75,-0.5),
      const Alignment(-0.5,0), const Alignment(-0.75,0.5), const Alignment(-0.5,0.75),
      const Alignment(0,0.5), const Alignment(0.5,0.75), const Alignment(0.75,0.5),
      const Alignment(0.5,0), const Alignment(0.75,-0.5), const Alignment(0.5,-0.75),
    ];
    final southAlign = [
      const Alignment(-0.5,-0.75), const Alignment(0,-0.75), const Alignment(0.5,-0.75),
      const Alignment(0.75,-0.5), const Alignment(0.75,0), const Alignment(0.75,0.5),
      const Alignment(0.5,0.75), const Alignment(0,0.75), const Alignment(-0.5,0.75),
      const Alignment(-0.75,0.5), const Alignment(-0.75,0), const Alignment(-0.75,-0.5),
    ];
    final aligns = _chartStyle == 'North' ? northAlign : southAlign;

    return Container(
      color: AppColors.scaffoldBg,
      child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Toggle row - split into 2 rows to avoid overflow
        Card(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
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
        const SizedBox(height: 12),
        // Chart box
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.width - 32,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            border: Border.all(color: AppColors.primary, width: 2),
            boxShadow: CustomShadows.cardShadow,
          ),
          child: Stack(children: [
            CustomPaint(size: Size.infinite, painter: _chartStyle == 'North' ? _NorthPainter() : _SouthPainter()),
            for (int i = 0; i < 12; i++)
              Align(alignment: aligns[i], child: Padding(
                padding: const EdgeInsets.all(2),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  if (_chartStyle == 'North')
                    Text('${(lagnaIdx + i) % 12 + 1}', style: TextStyle(fontSize: 9, color: Colors.grey.shade400)),
                  if (_chartStyle == 'South')
                    Text(rashiList[(lagnaIdx + i) % 12].substring(0, 2), style: const TextStyle(fontSize: 8, color: AppColors.primary)),
                  if (houses[i].isNotEmpty)
                    Text(houses[i].join(' '),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11,
                        color: houses[i].any((e) => e.startsWith('Mo')) ? Colors.blue : const Color(0xFF2C3E50))),
                ]),
              )),
            // Lagna label in North
            if (_chartStyle == 'North')
              Align(alignment: aligns[0], child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text('Lagna', style: TextStyle(fontSize: 8, color: AppColors.primary.withOpacity(0.7))),
              )),
          ]),
        ),
        const SizedBox(height: 10),
        // Legend
        Card(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.accentLight)),
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
              Text('ᴿ Retrograde  ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
              Text('↑ Exalted  ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
              Text('La = Lagna', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
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

  Widget _toggle(String label, String val) {
    bool sel = _chartStyle == val;
    return GestureDetector(
      onTap: () => setState(() => _chartStyle = val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? AppColors.accent : Colors.transparent,
          border: Border.all(color: sel ? AppColors.primary : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
          color: sel ? AppColors.primary : Colors.grey)),
      ),
    );
  }

  Widget _kpToggle() {
    return GestureDetector(
      onTap: () => setState(() => _showKP = !_showKP),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: _showKP ? AppColors.primary : AppColors.accentLight,
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(_showKP ? 'KP System (ON)' : 'KP System (OFF)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
          color: _showKP ? Colors.white : AppColors.primary)),
      ),
    );
  }

  Widget _infoCard(Map<String, dynamic> asc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentLight, width: 1.5),
      ),
      child: Padding(padding: const EdgeInsets.all(12), child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _infoItem('Lagna', asc['rashi'] ?? '-'),
          Container(width: 1, height: 36, color: AppColors.accentLight),
          _infoItem('Degree', '${(asc['degree'] as num? ?? 0).toStringAsFixed(1)}°'),
          Container(width: 1, height: 36, color: AppColors.accentLight),
          _infoItem('Nakshatra', asc['nakshatra'] ?? '-'),
          Container(width: 1, height: 36, color: AppColors.accentLight),
          _infoItem('Pada', '${asc['pada'] ?? '-'}'),
        ],
      )),
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
    return Wrap(spacing: 8, runSpacing: 8, children: btns.map((b) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: Border.all(color: AppColors.accent),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Text(b, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
    )).toList());
  }
}

class _NorthPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = AppColors.primary..strokeWidth = 1.5..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromLTWH(0, 0, s.width, s.height), p);
    canvas.drawLine(Offset(0,0), Offset(s.width,s.height), p);
    canvas.drawLine(Offset(s.width,0), Offset(0,s.height), p);
    canvas.drawLine(Offset(s.width/2,0), Offset(0,s.height/2), p);
    canvas.drawLine(Offset(s.width/2,0), Offset(s.width,s.height/2), p);
    canvas.drawLine(Offset(0,s.height/2), Offset(s.width/2,s.height), p);
    canvas.drawLine(Offset(s.width,s.height/2), Offset(s.width/2,s.height), p);
  }
  @override bool shouldRepaint(_) => false;
}

class _SouthPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = AppColors.primary..strokeWidth = 1.5..style = PaintingStyle.stroke;
    double w = s.width/4;
    canvas.drawRect(Rect.fromLTWH(0,0,s.width,s.height), p);
    canvas.drawLine(Offset(w,0), Offset(w,s.height), p);
    canvas.drawLine(Offset(2*w,0), Offset(2*w,w), p);
    canvas.drawLine(Offset(2*w,3*w), Offset(2*w,s.height), p);
    canvas.drawLine(Offset(3*w,0), Offset(3*w,s.height), p);
    canvas.drawLine(Offset(0,w), Offset(s.width,w), p);
    canvas.drawLine(Offset(0,2*w), Offset(w,2*w), p);
    canvas.drawLine(Offset(3*w,2*w), Offset(s.width,2*w), p);
    canvas.drawLine(Offset(0,3*w), Offset(s.width,3*w), p);
  }
  @override bool shouldRepaint(_) => false;
}
