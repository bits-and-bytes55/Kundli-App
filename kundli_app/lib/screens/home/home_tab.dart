import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../birth_form_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, Arjun 👋', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            Text('Have a great day ahead!', style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D), fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Panchang Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F3), // Light pink background
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Today's Info", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                  const SizedBox(height: 16),
                  _panchangRow('Tithi', 'Shukla Paksha, Dashami'),
                  _panchangRow('Nakshatra', 'Hasta'),
                  _panchangRow('Yoga', 'Shiva'),
                  _panchangRow('Karana', 'Balava'),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7E93),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('View Panchang'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.calendar_today_rounded, color: Color(0xFFFF7E93), size: 20),
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text('Quick Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
            const SizedBox(height: 16),
            // Services Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.9,
              children: [
                _serviceItem(Icons.auto_awesome, 'Kundli', const Color(0xFFFF7E93), () => Get.to(() => BirthFormScreen())),
                _serviceItem(Icons.timelapse_rounded, 'Dasha', const Color(0xFF81C784), () {}),
                _serviceItem(Icons.favorite_rounded, 'Match', const Color(0xFFFF7E93), () {}),
                _serviceItem(Icons.calendar_month_rounded, 'Panchang', const Color(0xFFFF7E93), () {}),
                _serviceItem(Icons.stars_rounded, 'Horoscope', const Color(0xFFFF7E93), () {}),
                _serviceItem(Icons.filter_5_rounded, 'Numerology', const Color(0xFF81C784), () {}),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _panchangRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF2C3E50), fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _serviceItem(IconData icon, String title, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))
          ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withOpacity(0.1),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2C3E50))),
          ],
        ),
      ),
    );
  }
}
