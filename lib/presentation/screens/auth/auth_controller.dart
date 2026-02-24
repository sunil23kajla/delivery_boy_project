import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:delivery_boy/data/repository/auth_repository.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../controllers/base_controller.dart';

import 'package:delivery_boy/core/services/session_service.dart';

class AuthController extends BaseController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final SessionService _sessionService = Get.find<SessionService>();

  final mobileController = TextEditingController();
  final otpController = TextEditingController();

  var isMobileValid = false.obs;
  var isOtpValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    mobileController.addListener(() {
      final text = mobileController.text;
      isMobileValid.value = text.length == 10 && GetUtils.isNumericOnly(text);
    });
    otpController.addListener(() {
      isOtpValid.value = otpController.text.length == 4;
    });
  }

  void sendOtp() async {
    if (!isMobileValid.value) return;

    try {
      showLoading();
      final response = await _authRepository.sendOtp(mobileController.text);
      hideLoading();

      if (response['success'] == true) {
        Get.toNamed(AppRoutes.otp);
      } else {
        Get.snackbar(
            AppStrings.error, response['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      handleError(e);
    }
  }

  void verifyOtp() async {
    if (!isOtpValid.value) return;

    try {
      showLoading();
      final user = await _authRepository.verifyOtp(
        mobileController.text,
        otpController.text,
      );
      _sessionService.saveSession(user);
      hideLoading();

      Get.snackbar(AppStrings.success, AppStrings.loginSuccessful);
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      handleError(e);
    }
  }

  @override
  void onClose() {
    mobileController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
