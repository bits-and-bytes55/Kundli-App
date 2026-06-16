import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'kundli_screen.dart';
import '../controllers/kundli_controller.dart';
import '../theme/custom_shadows.dart';
import '../theme/app_theme.dart';

class BirthFormScreen extends StatelessWidget {
  final int initialTabIdx;
  BirthFormScreen({super.key, this.initialTabIdx = 0});

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final dateController = TextEditingController(text: "1995-03-15");
  final timeController = TextEditingController(text: "14:30");
  final placeController = TextEditingController(text: "New Delhi");

  final kundliController = Get.put(KundliController());

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        image: DecorationImage(
          image: const AssetImage('assets/images/ChatGPT Image Jun 14, 2026, 10_51_39 PM.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Generate Kundli'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Get.back(),
          ),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
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
              Container(
                decoration: BoxDecoration(boxShadow: CustomShadows.cardShadow, borderRadius: BorderRadius.circular(8)),
                child: TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: 'e.g. Arjun Kumar'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
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
                        Container(
                          decoration: BoxDecoration(boxShadow: CustomShadows.cardShadow, borderRadius: BorderRadius.circular(8)),
                          child: TextFormField(
                            controller: dateController,
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime(1995, 3, 15),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(primary: AppColors.primary),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (pickedDate != null) {
                                String formattedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                dateController.text = formattedDate;
                              }
                            },
                            decoration: const InputDecoration(
                              hintText: 'YYYY-MM-DD',
                              suffixIcon: Icon(Icons.calendar_month_rounded, color: Colors.grey),
                            ),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
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
                        Container(
                          decoration: BoxDecoration(boxShadow: CustomShadows.cardShadow, borderRadius: BorderRadius.circular(8)),
                          child: TextFormField(
                            controller: timeController,
                            readOnly: true,
                            onTap: () async {
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: const TimeOfDay(hour: 14, minute: 30),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(primary: AppColors.primary),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (pickedTime != null) {
                                String formattedTime = "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                                timeController.text = formattedTime;
                              }
                            },
                            decoration: const InputDecoration(
                              hintText: 'HH:MM',
                              suffixIcon: Icon(Icons.access_time_rounded, color: Colors.grey),
                            ),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Birth Place
              const Text('Birth Place', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(boxShadow: CustomShadows.cardShadow, borderRadius: BorderRadius.circular(8)),
                child: TextFormField(
                  controller: placeController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. New Delhi',
                    suffixIcon: Icon(Icons.location_on_rounded, color: Colors.grey),
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ),
              
              const SizedBox(height: 48),
              Obx(() => kundliController.isLoading.value 
                ? const Center(child: CircularProgressIndicator()) 
                : ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        double lat = 28.6139;
                        double lon = 77.2090;
                        try {
                          List<Location> locations = await locationFromAddress(placeController.text);
                          if (locations.isNotEmpty) {
                            lat = locations.first.latitude;
                            lon = locations.first.longitude;
                          }
                        } catch (e) {
                          print("Geocoding failed: $e");
                        }
                        await kundliController.fetchKundli(
                          nameController.text,
                          dateController.text,
                          timeController.text,
                          lat,
                          lon,
                        );
                        if (kundliController.kundliData.value != null) {
                          await _saveToHistory(
                            nameController.text,
                            dateController.text,
                            timeController.text,
                            placeController.text,
                            lat,
                            lon,
                          );
                          Get.to(() => KundliScreen(initialTabIdx: initialTabIdx), transition: Transition.fadeIn);
                        } else {
                          Get.snackbar('Error', 'Failed to fetch data from API');
                        }
                      }
                    },
                    child: const Text('Generate Kundli'),
                  )),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Future<void> _saveToHistory(String name, String date, String time, String place, double lat, double lon) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('saved_charts');
      List<dynamic> list = [];
      if (raw != null) {
        list = jsonDecode(raw);
      }
      final exists = list.any((item) =>
          item['name'] == name &&
          item['date'] == date &&
          item['time'] == time);
      if (!exists) {
        list.add({
          'name': name,
          'date': date,
          'time': time,
          'place': place,
          'lat': lat,
          'lon': lon,
        });
        await prefs.setString('saved_charts', jsonEncode(list));
      }
    } catch (e) {
      print("Error saving to history: $e");
    }
  }
}
