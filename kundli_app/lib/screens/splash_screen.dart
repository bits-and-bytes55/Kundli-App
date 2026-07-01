import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth/login_screen.dart';
import 'dashboard/dashboard_screen.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import 'language_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    Future.delayed(const Duration(seconds: 3), () async {
      final authController = Get.put(AuthController());
      final isLoggedIn = await authController.checkLoginStatus();
      
      final prefs = await SharedPreferences.getInstance();
      final hasSelectedLanguage = prefs.getBool('language_selected') ?? false;

      if (isLoggedIn) {
        if (hasSelectedLanguage) {
          Get.offAll(() => const DashboardScreen(), transition: Transition.fadeIn);
        } else {
          Get.offAll(() => const LanguageSelectionScreen(), transition: Transition.fadeIn);
        }
      } else {
        Get.offAll(() => const LoginScreen(), transition: Transition.fadeIn);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.scaffoldBg,
          image: DecorationImage(
            image: const AssetImage('assets/images/ChatGPT Image Jun 14, 2026, 10_51_39 PM.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.6),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 20)
                  ]
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeTransition(
              opacity: _animation,
              child: const Column(
                children: [
                  Text(
                    'Kundli',
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2C3E50),
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Guide to your destiny',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF7F8C8D),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
