import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/language_controller.dart';
import '../theme/app_theme.dart';
import 'dashboard/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final bool isFromProfile;
  const LanguageSelectionScreen({super.key, this.isFromProfile = false});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final languageController = Get.put(LanguageController());
  String _selectedLang = 'en';

  @override
  void initState() {
    super.initState();
    _selectedLang = languageController.currentLang.value;
  }

  void _submit() async {
    await languageController.changeLanguage(_selectedLang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('language_selected', true);
    
    if (widget.isFromProfile) {
      Get.back();
    } else {
      Get.offAll(() => const DashboardScreen(), transition: Transition.fadeIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: widget.isFromProfile ? AppBar(
        title: Text('choose_language'.tr),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ) : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!widget.isFromProfile) ...[
                const Icon(Icons.language_rounded, size: 80, color: AppColors.primary),
                const SizedBox(height: 32),
              ],
              Text(
                'choose_language'.tr,
                textAlign: TextAlign.center,
                style: GoogleFonts.hind(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Select your preferred language / अपनी पसंदीदा भाषा चुनें',
                textAlign: TextAlign.center,
                style: GoogleFonts.hind(
                  fontSize: 16,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 48),
              
              // English Option
              _buildLangCard('en', 'English', 'english'.tr),
              const SizedBox(height: 16),
              
              // Hindi Option
              _buildLangCard('hi', 'हिंदी', 'hindi'.tr),
              
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'continue'.tr,
                  style: GoogleFonts.hind(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangCard(String code, String title, String subtitle) {
    final isSelected = _selectedLang == code;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedLang = code);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 10, spreadRadius: 1)
          ] : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Text(
                code.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.hind(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.hind(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 28),
          ],
        ),
      ),
    );
  }
}
