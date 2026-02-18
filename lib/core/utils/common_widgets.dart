import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CommonWidgets {
  static Widget loadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }

  static void showSnackBar(String title, String message) {
    // This usually needs GetX context, but we can use Get.snackbar directly
  }
}
