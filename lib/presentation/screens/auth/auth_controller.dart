import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_routes.dart';
import '../../controllers/base_controller.dart';

class AuthController extends BaseController {
  final emailPhoneController = TextEditingController();
  final otpController = TextEditingController();

  void sendOtp() async {
    if (emailPhoneController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter Email or Phone');
      return;
    }

    showLoading();
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    hideLoading();
    
    Get.toNamed(AppRoutes.otp);
  }

  void verifyOtp() async {
    if (otpController.text.length < 4) {
      Get.snackbar('Error', 'Please enter valid OTP');
      return;
    }

    showLoading();
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    hideLoading();

    Get.snackbar('Success', 'Login Successful');
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  void onClose() {
    emailPhoneController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
