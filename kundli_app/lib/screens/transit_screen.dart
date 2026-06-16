import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'kundli/gochar_tab.dart';
import '../theme/app_theme.dart';

class TransitScreen extends StatelessWidget {
  const TransitScreen({super.key});

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
          backgroundColor: Colors.white.withOpacity(0.9),
          elevation: 0.5,
          title: const Text('Planet Transits (गोचर)'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
            onPressed: () => Get.back(),
          ),
        ),
        body: const GocharTab(),
      ),
    );
  }
}
