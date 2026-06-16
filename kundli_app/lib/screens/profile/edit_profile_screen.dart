import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../theme/custom_shadows.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final genderController = TextEditingController();
  final dobController = TextEditingController();
  final tobController = TextEditingController();
  final placeController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString('profile_name') ?? '';
      emailController.text = prefs.getString('profile_email') ?? '';
      genderController.text = prefs.getString('profile_gender') ?? 'Male';
      dobController.text = prefs.getString('profile_dob') ?? '';
      tobController.text = prefs.getString('profile_tob') ?? '';
      placeController.text = prefs.getString('profile_place') ?? '';
    });
  }

  Future<void> _saveProfileData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', nameController.text);
    await prefs.setString('profile_email', emailController.text);
    await prefs.setString('profile_gender', genderController.text);
    await prefs.setString('profile_dob', dobController.text);
    await prefs.setString('profile_tob', tobController.text);
    await prefs.setString('profile_place', placeController.text);

    setState(() => _isLoading = false);
    Get.back(result: true);
    Get.snackbar('Success', 'Profile updated successfully!', backgroundColor: Colors.green.shade100);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.scaffoldBg,
        image: DecorationImage(
          image: AssetImage('assets/images/ChatGPT Image Jun 14, 2026, 10_51_39 PM.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Edit Profile'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
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
                  'Update Profile Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50)),
                ),
                const SizedBox(height: 20),

                // Name
                const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(boxShadow: CustomShadows.cardShadow, borderRadius: BorderRadius.circular(8)),
                  child: TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(hintText: 'Enter your name'),
                    validator: (v) => v!.trim().isEmpty ? 'Please enter your name' : null,
                  ),
                ),
                const SizedBox(height: 16),

                // Email
                const Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(boxShadow: CustomShadows.cardShadow, borderRadius: BorderRadius.circular(8)),
                  child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'Enter your email'),
                    validator: (v) {
                      if (v!.trim().isEmpty) return 'Please enter your email';
                      if (!GetUtils.isEmail(v.trim())) return 'Please enter a valid email';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Gender Selection
                const Text('Gender', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: CustomShadows.cardShadow,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: genderController.text.isEmpty ? 'Male' : genderController.text,
                      isExpanded: true,
                      items: ['Male', 'Female', 'Other'].map((String val) {
                        return DropdownMenuItem<String>(value: val, child: Text(val));
                      }).toList(),
                      onChanged: (newVal) {
                        if (newVal != null) {
                          setState(() {
                            genderController.text = newVal;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Birth Date
                const Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(boxShadow: CustomShadows.cardShadow, borderRadius: BorderRadius.circular(8)),
                  child: TextFormField(
                    controller: dobController,
                    readOnly: true,
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(1995, 3, 15),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'YYYY-MM-DD',
                      suffixIcon: Icon(Icons.calendar_month_rounded, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Birth Time
                const Text('Time of Birth', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(boxShadow: CustomShadows.cardShadow, borderRadius: BorderRadius.circular(8)),
                  child: TextFormField(
                    controller: tobController,
                    readOnly: true,
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 12, minute: 0),
                      );
                      if (picked != null) {
                        tobController.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'HH:MM',
                      suffixIcon: Icon(Icons.access_time_rounded, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

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
                  ),
                ),

                const SizedBox(height: 40),
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : ElevatedButton(
                        onPressed: _saveProfileData,
                        child: const Text('Save Details'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
