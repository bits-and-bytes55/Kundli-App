import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'kundli_screen.dart';

class BirthFormScreen extends StatelessWidget {
  BirthFormScreen({super.key});

  final nameController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final placeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Generate Kundli'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter Birth Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please provide accurate details for precise astrological calculations.',
              style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
            ),
            const SizedBox(height: 32),
            
            // Name Field
            const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'e.g. Arjun Kumar'),
            ),
            const SizedBox(height: 20),
            
            // Date & Time Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: dateController,
                        decoration: const InputDecoration(
                          hintText: 'DD/MM/YYYY',
                          suffixIcon: Icon(Icons.calendar_month_rounded, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Time of Birth', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: timeController,
                        decoration: const InputDecoration(
                          hintText: 'HH:MM AM/PM',
                          suffixIcon: Icon(Icons.access_time_rounded, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Place of Birth Field
            const Text('Place of Birth', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
            const SizedBox(height: 8),
            TextField(
              controller: placeController,
              decoration: const InputDecoration(
                hintText: 'e.g. New Delhi, India',
                suffixIcon: Icon(Icons.location_on_rounded, color: Colors.grey),
              ),
            ),
            
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                // Static Navigation directly to result (API disabled)
                Get.to(() => const KundliScreen(), transition: Transition.fadeIn);
              },
              child: const Text('Generate Kundli'),
            ),
          ],
        ),
      ),
    );
  }
}
