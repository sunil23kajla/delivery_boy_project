import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../controllers/base_controller.dart';

class AuthController extends BaseController {
  final emailPhoneController = TextEditingController();
  final otpController = TextEditingController();
  
  var isEmailPhoneValid = false.obs;
  var isOtpValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailPhoneController.addListener(() {
      isEmailPhoneValid.value = emailPhoneController.text.isNotEmpty;
    });
    otpController.addListener(() {
      isOtpValid.value = otpController.text.length == 6;
    });
  }

  void sendOtp() async {
    if (!isEmailPhoneValid.value) return;

    showLoading();
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    hideLoading();
    
    Get.toNamed(AppRoutes.otp);
  }

  void verifyOtp() async {
    if (!isOtpValid.value) return;

    showLoading();
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    hideLoading();

    Get.snackbar(AppStrings.success, AppStrings.loginSuccessful);
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  void onClose() {
    emailPhoneController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
