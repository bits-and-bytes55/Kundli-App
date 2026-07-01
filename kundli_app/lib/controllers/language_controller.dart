import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  final RxString currentLang = 'en'.obs;

  @override
  void onInit() {
    super.onInit();
    // We will call init() manually from main.dart to await it
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    String? lang = prefs.getString('app_lang');
    if (lang != null) {
      currentLang.value = lang;
      Get.updateLocale(Locale(lang));
    } else {
      currentLang.value = 'en';
      Get.updateLocale(const Locale('en'));
    }
  }

  Future<void> changeLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_lang', langCode);
    currentLang.value = langCode;
    Get.updateLocale(Locale(langCode));
  }
}
