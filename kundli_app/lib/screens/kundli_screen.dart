import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KundliScreen extends StatelessWidget {
  const KundliScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Get.back(),
          ),
          title: const Text('Kundli'),
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
        body: const TabBarView(
          children: [
            _BasicChartTab(),
            Center(child: Text('Navamsha D9 Chart')),
            Center(child: Text('Planetary Positions')),
          ],
        ),
      ),
    );
  }
}

class _BasicChartTab extends StatelessWidget {
  const _BasicChartTab();

  @override
  Widget build(BuildContext context) {
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                ),
                child: const Text('South Indian', style: TextStyle(fontSize: 14)),
              )
            ],
          ),
          const SizedBox(height: 32),
          // Mock Chart Graphic
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFFF7E93).withOpacity(0.5), width: 2),
            ),
            child: Stack(
              children: [
                // Diagonal lines
                CustomPaint(
                  size: const Size(double.infinity, 300),
                  painter: _ChartPainter(),
                ),
                const Center(child: Text('Lagna', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Ascendant (Lagna)', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2C3E50))),
                Text('Cancer (Kark)', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2C3E50))),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF7E93).withOpacity(0.5)
      ..strokeWidth = 1
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
