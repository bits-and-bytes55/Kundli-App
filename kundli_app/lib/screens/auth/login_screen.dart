import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'otp_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final phoneController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
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
                  color: Color(0xFFFFF0F3),
                ),
                child: const Icon(Icons.person_outline_rounded, size: 60, color: Color(0xFFFF7E93)),
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
                  prefixIcon: Icon(Icons.phone_android_rounded, color: Color(0xFFFF7E93)),
                  hintText: '+91 00000 00000',
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (phoneController.text.length >= 10 || phoneController.text.isEmpty) {
                    Get.to(() => const OtpScreen(), transition: Transition.rightToLeft);
                  } else {
                    Get.snackbar('Error', 'Enter a valid number', backgroundColor: Colors.white);
                  }
                },
                child: const Text('Get OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
