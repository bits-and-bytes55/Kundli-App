import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'kundli_screen.dart';
import 'premium_kundli_screen.dart';
import '../controllers/kundli_controller.dart';
import '../theme/custom_shadows.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../controllers/auth_controller.dart';

class BirthFormScreen extends StatefulWidget {
  final int initialTabIdx;
  final Map<String, dynamic>? initialChart;
  
  const BirthFormScreen({
    super.key, 
    this.initialTabIdx = 1,
    this.initialChart,
  });

  @override
  State<BirthFormScreen> createState() => _BirthFormScreenState();
}

class _BirthFormScreenState extends State<BirthFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final placeController = TextEditingController();
  TextEditingController? _autoCompleteFieldController;
  final passcodeController = TextEditingController();
  String _lastPlaceQuery = '';
  
  // Premium Fields
  final deathDateController = TextEditingController();
  final deathTimeController = TextEditingController();
  final deathPlaceController = TextEditingController();
  final Rx<File?> signatureImage = Rx<File?>(null);
  final includeDeathDetails = false.obs;
  final includeSignature = false.obs;

  final selectedGender = "Male".obs;
  final selectedMode = "Basic".obs;
  final isPremiumAllowed = false.obs;

  final kundliController = Get.put(KundliController());
  final authController = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedPhone = prefs.getString('logged_phone') ?? authController.phoneNumber.value;
    final allowedNumbers = ['9105159129', '9105115915', '9625917515', '8171614403'];
    isPremiumAllowed.value = allowedNumbers.contains(loggedPhone);

    if (!isPremiumAllowed.value) {
      selectedMode.value = "Basic";
    }

    if (widget.initialChart != null) {
      nameController.text = widget.initialChart!['name'] ?? '';
      dateController.text = widget.initialChart!['date'] ?? '';
      timeController.text = widget.initialChart!['time'] ?? '';
      placeController.text = widget.initialChart!['place'] ?? '';
      selectedGender.value = widget.initialChart!['gender'] ?? 'Male';
      
      final mode = (widget.initialChart!['mode']?.toString() ?? 'Basic').toLowerCase();
      if (mode == 'premium' && isPremiumAllowed.value) {
        selectedMode.value = 'Premium';
      } else {
        selectedMode.value = 'Basic';
      }
    } else {
      nameController.text = "ved prakash";
      final now = DateTime.now();
      dateController.text = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      timeController.text = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
      _fetchCurrentLocation();
    }
  }

  Future<void> _fetchCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String locName = "";
        if (place.locality != null && place.locality!.isNotEmpty) {
          locName = place.locality!;
        } else if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
          locName = place.subAdministrativeArea!;
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          locName += locName.isNotEmpty ? ", ${place.administrativeArea}" : place.administrativeArea!;
        }
        setState(() {
          placeController.text = locName;
          _autoCompleteFieldController?.text = locName;
        });
      }
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  Future<Iterable<String>> _getPlaces(String query) async {
    if (query.isEmpty || query.length < 2) return const [];
    
    // Debounce to prevent Nominatim 429 Too Many Requests
    _lastPlaceQuery = query;
    await Future.delayed(const Duration(milliseconds: 1000));
    if (_lastPlaceQuery != query) return const []; 
    
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$encodedQuery&format=json&limit=5&addressdetails=1');
    try {
      final response = await http.get(url, headers: {'User-Agent': 'kundli_app_suggestion'});
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((p) => p['display_name'] as String).toList();
      }
    } catch (e) {
      print('Error fetching places: $e');
    }
    return const [];
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
          title: Text('generate_kundli'.tr, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
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
              Text(
                'enter_birth_details'.tr,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black),
              ),
              const SizedBox(height: 4),
              Text(
                'provide_accurate_details'.tr,
                style: const TextStyle(fontSize: 12, color: Color(0xFF555555), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              
              // Basic vs Premium Selector
              Obx(() => isPremiumAllowed.value ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('select_kundli_type'.tr, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
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
                                  'basic_kundli'.tr,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: selectedMode.value == "Basic" ? AppColors.primary : Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'standard_birth_chart'.tr,
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
                  ),
                  const SizedBox(height: 16),
                ],
              ) : const SizedBox.shrink()),
              
              // Name Field
              Text('full_name'.tr, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(boxShadow: CustomShadows.cardShadow, borderRadius: BorderRadius.circular(8)),
                child: TextFormField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                    hintText: 'enter_name'.tr,
                    hintStyle: const TextStyle(fontSize: 12, color: AppColors.textLight),
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
                        Text('birth_date'.tr, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 13)),
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
                        Text('birth_time'.tr, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 13)),
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
                                initialTime: const TimeOfDay(hour: 10, minute: 30),
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
              Text('gender'.tr, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 13)),
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
              Text('birth_place'.tr, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(boxShadow: CustomShadows.cardShadow, borderRadius: BorderRadius.circular(8)),
                child: Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    if (textEditingValue.text == '') {
                      return const Iterable<String>.empty();
                    }
                    return await _getPlaces(textEditingValue.text);
                  },
                  onSelected: (String selection) {
                    placeController.text = selection;
                  },
                  fieldViewBuilder: (context, fieldController, focusNode, onEditingComplete) {
                    _autoCompleteFieldController = fieldController;
                    if (fieldController.text != placeController.text) {
                      fieldController.text = placeController.text;
                    }
                    fieldController.addListener(() {
                      placeController.text = fieldController.text;
                    });
                    return TextFormField(
                      controller: fieldController,
                      focusNode: focusNode,
                      onEditingComplete: onEditingComplete,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        isDense: true,
                        hintText: 'enter_birth_place'.tr,
                        hintStyle: const TextStyle(fontSize: 12, color: AppColors.textLight),
                        suffixIcon: const Icon(Icons.location_on_rounded, color: Colors.grey, size: 18),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 32,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(0),
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final String option = options.elementAt(index);
                              return ListTile(
                                title: Text(option, style: const TextStyle(fontSize: 13)),
                                onTap: () {
                                  onSelected(option);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
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
                                  Text('death_details'.tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
                                  Text('signature'.tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
                                        initialTime: const TimeOfDay(hour: 10, minute: 30),
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
                          place: placeController.text,
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
                            if (includeDeathDetails.value) {
                              double dLat = 28.6139;
                              double dLon = 77.2090;
                              try {
                                List<Location> locs = await locationFromAddress(deathPlaceController.text);
                                if (locs.isNotEmpty) {
                                  dLat = locs.first.latitude;
                                  dLon = locs.first.longitude;
                                }
                              } catch (e) {
                                print("Geocoding failed for death place: $e");
                              }
                              await kundliController.fetchDeathKundli(
                                nameController.text,
                                deathDateController.text,
                                deathTimeController.text.isNotEmpty ? deathTimeController.text : "12:00",
                                dLat,
                                dLon,
                                gender: selectedGender.value,
                                place: deathPlaceController.text,
                              );
                            } else {
                              kundliController.deathKundliData.value = null;
                            }
                            Get.to(() => PremiumKundliScreen(signatureImage: signatureImage.value), transition: Transition.fadeIn);
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
              const SizedBox(height: 24),
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

      final int timestamp = DateTime.now().millisecondsSinceEpoch;
      
      final raw = prefs.getString('saved_charts');
      List<dynamic> list = [];
      if (raw != null) {
        list = jsonDecode(raw);
      }
      final existsIdx = list.indexWhere((item) =>
          item['name'] == name &&
          item['date'] == date &&
          item['time'] == time);
      if (existsIdx != -1) {
        list.removeAt(existsIdx);
      }
      list.insert(0, {
        'name': name,
        'date': date,
        'time': time,
        'place': place,
        'lat': lat,
        'lon': lon,
        'gender': gender,
        'mode': mode,
        'timestamp': timestamp,
      });
      await prefs.setString('saved_charts', jsonEncode(list));
      
      // Also update saved_charts_all which bookmarks_tab uses
      final allRaw = prefs.getString('saved_charts_all');
      List<dynamic> allList = [];
      if (allRaw != null) {
        try {
          allList = jsonDecode(allRaw);
        } catch(e){}
      }
      final allExistsIdx = allList.indexWhere((item) =>
          item['name'] == name &&
          item['date'] == date &&
          item['time'] == time);
      if (allExistsIdx != -1) {
        allList.removeAt(allExistsIdx);
      }
      allList.insert(0, {
        'name': name,
        'date': date,
        'time': time,
        'place': place,
        'lat': lat,
        'lon': lon,
        'gender': gender,
        'mode': mode,
        'timestamp': timestamp,
      });
      await prefs.setString('saved_charts_all', jsonEncode(allList));
    } catch (e) {
      print("Error saving to history: $e");
    }
  }
}
