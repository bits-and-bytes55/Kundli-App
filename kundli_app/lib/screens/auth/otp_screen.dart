import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../dashboard/dashboard_screen.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'OTP Verification',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Enter the 4-digit code sent to your number',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) => _otpBox()),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Get.offAll(() => const DashboardScreen(), transition: Transition.fadeIn);
                },
                child: const Text('Verify & Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otpBox() {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: const Color(0xFFFF7E93).withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: const TextField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
        decoration: InputDecoration(
          counterText: "",
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
        ),
      ),
    );
  }
}
