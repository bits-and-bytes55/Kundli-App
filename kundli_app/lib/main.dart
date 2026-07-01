import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/api_service.dart';
import 'localization/app_translations.dart';
import 'controllers/language_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ApiService());
  
  // Initialize LanguageController so it loads the saved language before app starts
  final langController = Get.put(LanguageController());
  await langController.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kundli App',
      theme: AppTheme.lightTheme,
      translations: AppTranslations(),
      locale: Get.find<LanguageController>().currentLang.value.isEmpty 
          ? const Locale('en') 
          : Locale(Get.find<LanguageController>().currentLang.value),
      fallbackLocale: const Locale('en'),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
