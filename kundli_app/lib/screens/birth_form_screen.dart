import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'kundli_screen.dart';
import 'premium_kundli_screen.dart';
import '../controllers/kundli_controller.dart';
import '../theme/custom_shadows.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../controllers/auth_controller.dart';

class BirthFormScreen extends StatefulWidget {
  final int initialTabIdx;
  const BirthFormScreen({super.key, this.initialTabIdx = 1});

  @override
  State<BirthFormScreen> createState() => _BirthFormScreenState();
}

class _BirthFormScreenState extends State<BirthFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final placeController = TextEditingController();
  final passcodeController = TextEditingController();
  
  // Premium Fields
  final deathDateController = TextEditingController();
  final deathTimeController = TextEditingController();
  final deathPlaceController = TextEditingController();
  final Rx<File?> signatureImage = Rx<File?>(null);
  final includeDeathDetails = false.obs;
  final includeSignature = false.obs;

  final selectedGender = "Male".obs;
  final selectedMode = "Basic".obs;

  final kundliController = Get.put(KundliController());
  final authController = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLoc = prefs.getString('last_saved_location');
    if (savedLoc != null && savedLoc.isNotEmpty) {
      placeController.text = savedLoc;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    dateController.dispose();
    timeController.dispose();
    placeController.dispose();
    passcodeController.dispose();
    deathDateController.dispose();
    deathTimeController.dispose();
    deathPlaceController.dispose();
    super.dispose();
  }

  Future<void> _pickSignature() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Get.back();
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                  if (pickedFile != null) signatureImage.value = File(pickedFile.path);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Get.back();
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) signatureImage.value = File(pickedFile.path);
                },
              ),
            ],
          ),
        );
      },
    );
  }

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
          title: const Text('Generate Kundli', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
            onPressed: () => Get.back(),
          ),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter Birth Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black),
              ),
              const SizedBox(height: 4),
              const Text(
                'Please provide accurate details for precise astrological calculations.',
                style: TextStyle(fontSize: 12, color: Color(0xFF555555), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              
              // Basic vs Premium Selector
              const Text('Select Kundli Type', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 13)),
              const SizedBox(height: 8),
              Obx(() => Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => selectedMode.value = "Basic",
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          color: selectedMode.value == "Basic" ? AppColors.primary.withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selectedMode.value == "Basic" ? AppColors.primary : AppColors.border.withOpacity(0.5),
                            width: selectedMode.value == "Basic" ? 1.5 : 1,
                          ),
                          boxShadow: CustomShadows.cardShadow,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.star_border_rounded,
                              color: selectedMode.value == "Basic" ? AppColors.primary : Colors.grey,
                              size: 22,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Basic Kundli',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: selectedMode.value == "Basic" ? AppColors.primary : Colors.black,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Standard birth chart',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 9,
                                color: selectedMode.value == "Basic" ? AppColors.primary.withOpacity(0.8) : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => selectedMode.value = "Premium",
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          color: selectedMode.value == "Premium" ? Colors.amber.withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selectedMode.value == "Premium" ? Colors.amber.shade700 : AppColors.border.withOpacity(0.5),
                            width: selectedMode.value == "Premium" ? 1.5 : 1,
                          ),
                          boxShadow: CustomShadows.cardShadow,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.workspace_premium_rounded,
                              color: selectedMode.value == "Premium" ? Colors.amber.shade800 : Colors.grey,
                              size: 22,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Premium Kundli',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: selectedMode.value == "Premium" ? Colors.amber.shade900 : Colors.black,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Advanced & Vastu',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 9,
                                color: selectedMode.value == "Premium" ? Colors.amber.shade900.withOpacity(0.8) : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )),
              const SizedBox(height: 16),
              
              // Name Field
              const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(boxShadow: CustomShadows.cardShadow, borderRadius: BorderRadius.circular(8)),
                child: TextFormField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                    hintText: 'e.g. Arjun Kumar',
                    hintStyle: TextStyle(fontSize: 12, color: AppColors.textLight),
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 16),
              
              // Date & Time Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 13)),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(boxShadow: CustomShadows.cardShadow, borderRadius: BorderRadius.circular(8)),
                          child: TextFormField(
                            controller: dateController,
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13),
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
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              isDense: true,
                              hintText: 'YYYY-MM-DD',
                              hintStyle: TextStyle(fontSize: 12, color: AppColors.textLight),
                              suffixIcon: Icon(Icons.calendar_month_rounded, color: Colors.grey, size: 18),
                            ),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Time of Birth', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 13)),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(boxShadow: CustomShadows.cardShadow, borderRadius: BorderRadius.circular(8)),
                          child: TextFormField(
                            controller: timeController,
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13),
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
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              isDense: true,
                              hintText: 'HH:MM',
                              hintStyle: TextStyle(fontSize: 12, color: AppColors.textLight),
                              suffixIcon: Icon(Icons.access_time_rounded, color: Colors.grey, size: 18),
                            ),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Gender Field
              const Text('Gender', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(boxShadow: CustomShadows.cardShadow, borderRadius: BorderRadius.circular(8)),
                child: Obx(() => DropdownButtonFormField<String>(
                  value: selectedGender.value,
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      selectedGender.value = val;
                    }
                  },
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                )),
              ),
              const SizedBox(height: 16),
              
              // Birth Place
              const Text('Birth Place', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(boxShadow: CustomShadows.cardShadow, borderRadius: BorderRadius.circular(8)),
                child: TextFormField(
                  controller: placeController,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                    hintText: 'e.g. New Delhi',
                    hintStyle: TextStyle(fontSize: 12, color: AppColors.textLight),
                    suffixIcon: Icon(Icons.location_on_rounded, color: Colors.grey, size: 18),
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ),
              
              // Premium Fields
              Obx(() {
                if (selectedMode.value == "Premium") {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text('Premium Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  const Text('Death Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  Checkbox(
                                    value: includeDeathDetails.value,
                                    activeColor: AppColors.primary,
                                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                    onChanged: (val) {
                                      if (val != null) includeDeathDetails.value = val;
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Text('Signature', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  Checkbox(
                                    value: includeSignature.value,
                                    activeColor: AppColors.primary,
                                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                    onChanged: (val) {
                                      if (val != null) includeSignature.value = val;
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (includeDeathDetails.value) ...[
                      // Death Date & Time Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Death Date', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 13)),
                                const SizedBox(height: 6),
                                Container(
                                  decoration: BoxDecoration(boxShadow: CustomShadows.cardShadow, borderRadius: BorderRadius.circular(8)),
                                  child: TextFormField(
                                    controller: deathDateController,
                                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13),
                                    readOnly: true,
                                    onTap: () async {
                                      DateTime? pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime(2100),
                                        builder: (context, child) => Theme(
                                          data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
                                          child: child!,
                                        ),
                                      );
                                      if (pickedDate != null) {
                                        deathDateController.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                      }
                                    },
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      isDense: true,
                                      hintText: 'YYYY-MM-DD',
                                      hintStyle: TextStyle(fontSize: 12, color: AppColors.textLight),
                                      suffixIcon: Icon(Icons.calendar_month_rounded, color: Colors.grey, size: 18),
                                    ),
                                    validator: (v) {
                                      if (selectedMode.value == "Premium" && (v == null || v.isEmpty)) return 'Required';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Death Time(Optional)', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 13)),
                                const SizedBox(height: 6),
                                Container(
                                  decoration: BoxDecoration(boxShadow: CustomShadows.cardShadow, borderRadius: BorderRadius.circular(8)),
                                  child: TextFormField(
                                    controller: deathTimeController,
                                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13),
                                    readOnly: true,
                                    onTap: () async {
                                      TimeOfDay? pickedTime = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                        builder: (context, child) => Theme(
                                          data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
                                          child: child!,
                                        ),
                                      );
                                      if (pickedTime != null) {
                                        deathTimeController.text = "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                                      }
                                    },
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      isDense: true,
                                      hintText: 'HH:MM',
                                      hintStyle: TextStyle(fontSize: 12, color: AppColors.textLight),
                                      suffixIcon: Icon(Icons.access_time_rounded, color: Colors.grey, size: 18),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Death Place
                      const Text('Death Place', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 13)),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(boxShadow: CustomShadows.cardShadow, borderRadius: BorderRadius.circular(8)),
                        child: TextFormField(
                          controller: deathPlaceController,
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            isDense: true,
                            hintText: 'e.g. Mumbai',
                            hintStyle: TextStyle(fontSize: 12, color: AppColors.textLight),
                            suffixIcon: Icon(Icons.location_on_rounded, color: Colors.grey, size: 18),
                          ),
                          validator: (v) {
                            if (selectedMode.value == "Premium" && (v == null || v.isEmpty)) return 'Required';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      ],

                      if (includeSignature.value) ...[
                      // Upload Signature
                      const Text('Upload Signature', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 13)),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _pickSignature,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Obx(() {
                            if (signatureImage.value != null) {
                              return Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.file(signatureImage.value!, height: 100, fit: BoxFit.contain),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text('Tap to change signature', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                const Icon(Icons.draw_rounded, size: 32, color: AppColors.textLight),
                                const SizedBox(height: 8),
                                const Text('Tap to upload or take a photo', style: TextStyle(fontSize: 13, color: AppColors.textMedium, fontWeight: FontWeight.w500)),
                              ],
                            );
                          }),
                        ),
                      ),
                      ],
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Passcode
                      const Text('Owner Passcode', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 13)),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(boxShadow: CustomShadows.cardShadow, borderRadius: BorderRadius.circular(8)),
                        child: TextFormField(
                          controller: passcodeController,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            isDense: true,
                            hintText: 'Enter owner passcode',
                            hintStyle: TextStyle(fontSize: 12, color: AppColors.textLight),
                            prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.amber, size: 18),
                          ),
                          validator: (v) {
                            if (selectedMode.value == "Premium" && (v == null || v.isEmpty)) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
              const SizedBox(height: 24),
              Obx(() => kundliController.isLoading.value 
                ? const Center(child: CircularProgressIndicator()) 
                : ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (selectedMode.value == "Premium") {
                          if (includeSignature.value && signatureImage.value == null) {
                            Get.snackbar(
                              'Missing Signature',
                              'Please upload a signature image for the Premium Kundli.',
                              backgroundColor: Colors.red.shade800,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                              margin: const EdgeInsets.all(16),
                            );
                            return;
                          }

                          final code = passcodeController.text.trim();
                          final prefs = await SharedPreferences.getInstance();
                          final loggedPhone = prefs.getString('logged_phone') ?? authController.phoneNumber.value;
                          final expectedPasscode = loggedPhone.isNotEmpty ? loggedPhone : "8171614403";

                          if (code != expectedPasscode) {
                            Get.snackbar(
                              'Passcode Error',
                              'Incorrect Owner Passcode. Please enter your registered login phone number.',
                              backgroundColor: Colors.red.shade800,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                              margin: const EdgeInsets.all(16),
                            );
                            return;
                          }
                        }

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
                          gender: selectedGender.value,
                        );
                        if (kundliController.kundliData.value != null) {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('last_saved_location', placeController.text.trim());
                          _saveToHistory(
                            nameController.text,
                            dateController.text,
                            timeController.text,
                            placeController.text,
                            lat,
                            lon,
                            selectedGender.value,
                            selectedMode.value,
                          );
                          if (selectedMode.value == "Premium") {
                            Get.to(() => const PremiumKundliScreen(), transition: Transition.fadeIn);
                          } else {
                            Get.to(() => KundliScreen(initialTabIdx: 1), transition: Transition.fadeIn);
                          }
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

  Future<void> _saveToHistory(String name, String date, String time, String place, double lat, double lon, String gender, String mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String phone = prefs.getString('logged_phone') ?? '9999999999';

      // Save to API
      try {
        final apiService = Get.find<ApiService>();
        await apiService.saveChart(
          phone: phone,
          name: name,
          date: date,
          time: time,
          lat: lat,
          lon: lon,
          gender: gender,
          place: place,
          mode: mode,
        );
      } catch (ae) {
        print("API save failed: $ae");
      }

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
          'gender': gender,
        });
        await prefs.setString('saved_charts', jsonEncode(list));
      }
    } catch (e) {
      print("Error saving to history: $e");
    }
  }
}
