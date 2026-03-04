import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/error/failure.dart';

class BaseController extends GetxController {
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  void showLoading() => _isLoading.value = true;
  void hideLoading() => _isLoading.value = false;

  void handleError(dynamic error) {
    hideLoading();
    String message;
    if (error is AppException) {
      message = error.message;
    } else if (error is String) {
      message = error;
    } else {
      message = error.toString();
    }
    debugPrint('❌ [ERROR] $message');
    if (Get.context != null) {
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
