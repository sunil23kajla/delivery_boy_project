import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/error/failure.dart';

class BaseController extends GetxController {
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  RxBool get isLoadingRx => _isLoading;

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

    // Silence authentication/session related messages
    final lowerMsg = message.toLowerCase();
    if (lowerMsg.contains('session expired') ||
        lowerMsg.contains('session_expired') ||
        lowerMsg.contains('unauthorized')) {
      debugPrint('ℹ️ [AUTH] Silent redirection handled (Auth Error)');
      return;
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

  String parseQrToken(String rawValue) {
    if (rawValue.isEmpty) return "";
    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is Map && decoded.containsKey('token')) {
        return decoded['token'].toString();
      }
    } catch (_) {
      // Not a JSON or doesn't have token, return as is
    }
    return rawValue;
  }
}
