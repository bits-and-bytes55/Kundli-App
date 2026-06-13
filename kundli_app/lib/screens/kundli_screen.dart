import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kundli_controller.dart';
import '../theme/custom_shadows.dart';

class KundliScreen extends StatelessWidget {
  const KundliScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kundliController = Get.find<KundliController>();
    final data = kundliController.kundliData.value;

    if (data == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Result')),
        body: const Center(child: Text('No Data found from API')),
      );
    }

    final ascendant = data['ascendant'];
    final planets = data['planets'] as Map<String, dynamic>;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Get.back(),
          ),
          title: Text('${data['name']}\'s Kundli'),
          actions: [
            IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
          ],
          bottom: const TabBar(
            labelColor: Color(0xFFFF7E93),
            unselectedLabelColor: Color(0xFF7F8C8D),
            indicatorColor: Color(0xFFFF7E93),
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Basic Chart'),
              Tab(text: 'Navamsha'),
              Tab(text: 'Planets'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _BasicChartTab(ascendant: ascendant, planets: planets),
            const Center(child: Text('Navamsha D9 Chart (Coming Soon)')),
            _PlanetsTab(planets: planets),
          ],
        ),
      ),
    );
  }
}

class _BasicChartTab extends StatelessWidget {
  final Map<String, dynamic> ascendant;
  final Map<String, dynamic> planets;
  
  const _BasicChartTab({required this.ascendant, required this.planets});

  @override
  Widget build(BuildContext context) {
    const rashiList = ['Mesh','Vrishabh','Mithun','Kark','Singh','Kanya','Tula','Vrischik','Dhanu','Makar','Kumbh','Meen'];
    
    int lagnaIdx = rashiList.indexOf(ascendant['rashi']);
    if (lagnaIdx == -1) lagnaIdx = 0; // fallback

    List<List<String>> houses = List.generate(12, (_) => []);
    
    // Abbreviations map
    final abbrev = {
      'Sun': 'Su', 'Moon': 'Mo', 'Mars': 'Ma', 'Mercury': 'Me', 
      'Jupiter': 'Ju', 'Venus': 'Ve', 'Saturn': 'Sa', 'Rahu': 'Ra', 'Ketu': 'Ke'
    };

    planets.forEach((key, value) {
      if (abbrev.containsKey(key)) {
        int pRashiIdx = rashiList.indexOf(value['rashi']);
        if (pRashiIdx != -1) {
          int houseIndex = (pRashiIdx - lagnaIdx) % 12;
          if (houseIndex < 0) houseIndex += 12;
          houses[houseIndex].add(abbrev[key]!);
        }
      }
    });

    final alignments = [
      const Alignment(0, -0.45),      // House 1
      const Alignment(-0.45, -0.75),  // House 2
      const Alignment(-0.75, -0.45),  // House 3
      const Alignment(-0.45, 0),      // House 4
      const Alignment(-0.75, 0.45),   // House 5
      const Alignment(-0.45, 0.75),   // House 6
      const Alignment(0, 0.45),       // House 7
      const Alignment(0.45, 0.75),    // House 8
      const Alignment(0.75, 0.45),    // House 9
      const Alignment(0.45, 0),       // House 10
      const Alignment(0.75, -0.45),   // House 11
      const Alignment(0.45, -0.75),   // House 12
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7E93),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                ),
                child: const Text('North Indian', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF7F8C8D),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                ),
                child: const Text('South Indian', style: TextStyle(fontSize: 14)),
              )
            ],
          ),
          const SizedBox(height: 32),
          
          // North Indian Chart implementation
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.width - 40, // Square aspect ratio
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFFF7E93), width: 2),
            ),
            child: Stack(
              children: [
                CustomPaint(
                  size: Size.infinite,
                  painter: _ChartPainter(),
                ),
                // Place the text inside each house
                for (int i = 0; i < 12; i++)
                  Align(
                    alignment: alignments[i],
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ((lagnaIdx + i) % 12 + 1).toString(), // Rashi Number
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.bold),
                        ),
                        if (houses[i].isNotEmpty)
                          Text(
                            houses[i].join(', '),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2C3E50)),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: CustomShadows.cardShadow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Ascendant (Lagna)', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2C3E50))),
                    Text('${ascendant['rashi']} (${ascendant['degree'].toStringAsFixed(2)}°)', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFFF7E93))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Rashi Lord', style: TextStyle(color: Color(0xFF7F8C8D))),
                    Text('${ascendant['rashi_lord'] ?? ''}', style: const TextStyle(color: Color(0xFF7F8C8D))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Nakshatra', style: TextStyle(color: Color(0xFF7F8C8D))),
                    Text('${ascendant['nakshatra']} (Pada ${ascendant['pada']})', style: const TextStyle(color: Color(0xFF7F8C8D))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Nakshatra Lord', style: TextStyle(color: Color(0xFF7F8C8D))),
                    Text('${ascendant['nakshatra_lord'] ?? ''}', style: const TextStyle(color: Color(0xFF7F8C8D))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Namakshar (Syllable)', style: TextStyle(color: Color(0xFF7F8C8D))),
                    Text('${ascendant['namakshar'] ?? ''}', style: const TextStyle(color: Color(0xFF7F8C8D), fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _PlanetsTab extends StatelessWidget {
  final Map<String, dynamic> planets;
  const _PlanetsTab({required this.planets});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20.0),
      itemCount: planets.keys.length,
      itemBuilder: (context, index) {
        String key = planets.keys.elementAt(index);
        var p = planets[key];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: CustomShadows.cardShadow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFFFF0F3),
              child: Text(key.substring(0, 1), style: const TextStyle(color: Color(0xFFFF7E93), fontWeight: FontWeight.bold)),
            ),
            title: Text(key, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
            subtitle: Text(
              '${p['rashi']} (${p['degree'].toStringAsFixed(2)}°) • Lord: ${p['rashi_lord'] ?? ''}\n'
              'Nak: ${p['nakshatra']} (Pada ${p['pada']}) • Lord: ${p['nakshatra_lord'] ?? ''}\n'
              'Syllable (Namakshar): ${p['namakshar'] ?? ''}',
              style: const TextStyle(height: 1.4),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF7E93)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
    canvas.drawLine(Offset(size.width / 2, 0), Offset(0, size.height / 2), paint);
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width, size.height / 2), paint);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width / 2, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height / 2), Offset(size.width / 2, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
