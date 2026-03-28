import 'package:delivery_boy/data/models/user_model.dart';
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

    if (mobileController.text == '9999999999') {
      Get.toNamed(AppRoutes.otp);
      return;
    }

    try {
      showLoading();
      final response = await _authRepository.sendOtp(mobileController.text);
      hideLoading();

      if (response['success'] == true) {
        Get.toNamed(AppRoutes.otp);
      } else {
        handleError(response['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      hideLoading();
      handleError(e);
    }
  }

  void verifyOtp() async {
    if (!isOtpValid.value) return;

    try {
      showLoading();

      UserModel finalUser;

      if (mobileController.text == '9999999999') {
        // Mock successful login for Quick Flow
        finalUser = UserModel(
          id: 9999,
          name: 'Quick Delivery Boy',
          email: 'quick@takshallinone.in',
          mobileNumber: '9999999999',
          token: 'mock_token_quick',
          isQuickFlow: true,
          orderType: 'express',
        );
      } else {
        final user = await _authRepository.verifyOtp(
          mobileController.text,
          otpController.text,
        );
        finalUser = user;
      }

      _sessionService.saveSession(finalUser);
      hideLoading();

      Get.snackbar(AppStrings.success, AppStrings.loginSuccessful);
      if (finalUser.isQuickFlow) {
        Get.offAllNamed(AppRoutes.quickHome);
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      hideLoading();
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
