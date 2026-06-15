import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'otp_screen.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController());
    final phoneController = TextEditingController();

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
        body: SafeArea(
          child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Container(
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentLight,
                ),
                child: const Icon(Icons.person_outline_rounded, size: 60, color: AppColors.primary),
              ),
              const SizedBox(height: 40),
              const Text(
                'Login / Sign Up',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Enter your mobile number to proceed',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1.5),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.phone_android_rounded, color: AppColors.primary),
                  hintText: '+91 00000 00000',
                ),
              ),
              const SizedBox(height: 32),
              Obx(() => ElevatedButton(
                onPressed: authController.isLoading.value
                    ? null
                    : () async {
                        final phone = phoneController.text.trim();
                        if (phone.length < 10) {
                          Get.snackbar(
                            'Error',
                            'Enter a valid 10-digit number',
                            backgroundColor: Colors.white.withOpacity(0.9),
                            colorText: Colors.red,
                          );
                          return;
                        }
                        final success = await authController.sendOtp(phone);
                        if (success) {
                          Get.to(() => const OtpScreen(), transition: Transition.rightToLeft);
                        }
                      },
                child: authController.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Get OTP'),
              )),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
