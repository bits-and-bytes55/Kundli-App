import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../dashboard/dashboard_screen.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_theme.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late final AuthController authController;
  late final List<TextEditingController> controllers;
  late final List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    authController = Get.find<AuthController>();
    controllers = List.generate(6, (index) => TextEditingController());
    focusNodes = List.generate(6, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
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
          backgroundColor: Colors.transparent,
          elevation: 0,
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
                  'Enter the 6-digit code sent to your number',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) => _otpBox(context, controllers[index], focusNodes[index], index)),
                ),
                const SizedBox(height: 40),
                Obx(() => ElevatedButton(
                  onPressed: authController.isLoading.value
                       ? null
                       : () async {
                           final otp = controllers.map((c) => c.text.trim()).join();
                           if (otp.length < 6) {
                             Get.snackbar(
                               'Error',
                               'Please enter the 6-digit OTP',
                               backgroundColor: Colors.white.withOpacity(0.9),
                               colorText: Colors.red,
                             );
                             return;
                           }
                           await authController.verifyOtp(otp);
                         },
                   child: authController.isLoading.value
                       ? const SizedBox(
                           height: 20,
                           width: 20,
                           child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                         )
                       : const Text('Verify & Login'),
                 )),
               ],
             ),
           ),
         ),
       ),
     );
   }

   Widget _otpBox(
     BuildContext context,
     TextEditingController controller,
     FocusNode focusNode,
     int index,
   ) {
     return Container(
       width: 46,
       height: 55,
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(12),
         border: Border.all(color: Colors.grey.shade200),
         boxShadow: [
           BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
         ]
       ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.zero,
          counterText: "",
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
        ),
        onChanged: (value) {
          if (value.length > 1) {
            final cleanVal = value.replaceAll(RegExp(r'\D'), '');
            if (cleanVal.length > 1) {
              for (int i = 0; i < 6; i++) {
                if (i < cleanVal.length) {
                  controllers[i].text = cleanVal[i];
                }
              }
              final nextFocusIndex = cleanVal.length < 6 ? cleanVal.length : 5;
              FocusScope.of(context).requestFocus(focusNodes[nextFocusIndex]);
              return;
            } else {
              controller.text = cleanVal;
            }
          }
          if (value.isNotEmpty) {
            if (index < 5) {
              FocusScope.of(context).requestFocus(focusNodes[index + 1]);
            } else {
              focusNode.unfocus();
            }
          } else {
            if (index > 0) {
              FocusScope.of(context).requestFocus(focusNodes[index - 1]);
            }
          }
        },
      ),
    );
  }
}
