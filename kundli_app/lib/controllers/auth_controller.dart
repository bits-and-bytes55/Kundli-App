import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';

class AuthController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString phoneNumber = ''.obs;
  String _otpRequestToken = '';

  static const String baseUrl = 'https://numerologyapi.bitsandbytesitsolution.com/api/';
  static const String sendOtpEndpoint = 'auth/send-otp';
  static const String verifyOtpEndpoint = 'auth/verify-otp';

  // Check login status
  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      return true;
    }
    return false;
  }

  // Send OTP
  Future<bool> sendOtp(String phone) async {
    isLoading.value = true;
    try {
      final url = Uri.parse('$baseUrl$sendOtpEndpoint');
      final body = json.encode({'phone': phone});

      print('================ SEND OTP REQUEST ================');
      print('URL: $url');
      print('REQUEST BODY: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print('================ SEND OTP RESPONSE ================');
      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('===================================================');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _otpRequestToken = responseData['otpRequestToken'] ?? '';
        phoneNumber.value = phone;
        
        // Save to SharedPreferences temporarily
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('temp_phone', phone);
        await prefs.setString('temp_otp_token', _otpRequestToken);

        isLoading.value = false;
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to send OTP. Status: ${response.statusCode}',
          backgroundColor: Colors.white.withOpacity(0.9),
          colorText: Colors.red,
        );
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      print('Error sending OTP: $e');
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        backgroundColor: Colors.white.withOpacity(0.9),
        colorText: Colors.red,
      );
      isLoading.value = false;
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOtp(String otp) async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final phone = phoneNumber.value.isNotEmpty ? phoneNumber.value : (prefs.getString('temp_phone') ?? '');
      final token = _otpRequestToken.isNotEmpty ? _otpRequestToken : (prefs.getString('temp_otp_token') ?? '');

      final url = Uri.parse('$baseUrl$verifyOtpEndpoint');
      final body = json.encode({
        'phone': phone,
        'otp': otp,
        'otpRequestToken': token,
      });

      print('================ VERIFY OTP REQUEST ================');
      print('URL: $url');
      print('REQUEST BODY: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print('================ VERIFY OTP RESPONSE ================');
      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');
      print('====================================================');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        final authToken = responseData['authToken'] ??
            responseData['auth_token'] ??
            responseData['token'] ??
            '';

        if (authToken.isNotEmpty) {
          await prefs.setString('auth_token', authToken);
          await prefs.setString('logged_phone', phone);
          
          // Clear temp
          await prefs.remove('temp_phone');
          await prefs.remove('temp_otp_token');

          isLoading.value = false;
          Get.offAll(() => const DashboardScreen(), transition: Transition.fadeIn);
          return true;
        } else {
          Get.snackbar(
            'Error',
            'Authentication token not found in response.',
            backgroundColor: Colors.white.withOpacity(0.9),
            colorText: Colors.red,
          );
          isLoading.value = false;
          return false;
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to verify OTP. Status: ${response.statusCode}',
          backgroundColor: Colors.white.withOpacity(0.9),
          colorText: Colors.red,
        );
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        backgroundColor: Colors.white.withOpacity(0.9),
        colorText: Colors.red,
      );
      isLoading.value = false;
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('logged_phone');
    Get.offAll(() => const LoginScreen(), transition: Transition.fade);
  }
}
