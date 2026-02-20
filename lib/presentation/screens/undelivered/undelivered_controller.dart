import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';

enum UndeliveredStep { reasons, action }

class UndeliveredController extends GetxController {
  final shipment = Get.arguments as Map<String, dynamic>;
  final otpController = TextEditingController();
  final reasonDetailsController = TextEditingController();

  var currentStep = UndeliveredStep.reasons.obs;
  var selectedReasonIndex = (-1).obs;
  var isOtpVerified = false.obs;

  final List<String> reasons = [
    "ORDER CANCELLED BY CUSTOMER",
    "DELIVERY RESCHEDULED BY CUSTOMER",
    "CUSTOMER UNAVAILABLE",
    "INCOMPLETE NUB./ADD.",
    "CUSTOMER REFUSED TO GIVE OTP",
    "CUSTOMER WANTS OPEN DELIVERY",
    "PACKAGE OPENED & REFUSED",
    "MISROUTE",
  ];

  bool get isOtpReason => selectedReasonIndex.value == 0;

  void nextStep() {
    if (selectedReasonIndex.value == -1) {
      Get.snackbar(AppStrings.error, "Please select a reason");
      return;
    }
    currentStep.value = UndeliveredStep.action;
  }

  void previousStep() {
    currentStep.value = UndeliveredStep.reasons;
  }

  void verifyOtp() {
    if (otpController.text.length == 6) {
      isOtpVerified.value = true;
      Get.snackbar(AppStrings.success, "OTP Verified Successfully");
    } else {
      Get.snackbar(AppStrings.error, "Please enter a valid 6-digit OTP");
    }
  }

  void completeProcess() {
    if (isOtpReason && !isOtpVerified.value) {
      Get.snackbar(AppStrings.error, "Please verify OTP first");
      return;
    }

    if (!isOtpReason && reasonDetailsController.text.isEmpty) {
      Get.snackbar(AppStrings.error, "Please enter the reason details");
      return;
    }

    _showConfirmation();
  }

  void _showConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text("Success"),
        content: const Text("Order marked as undelivered successfully."),
        actions: [
          TextButton(
            onPressed: () {
              Get.offAllNamed(AppRoutes.home);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    otpController.dispose();
    reasonDetailsController.dispose();
    super.onClose();
  }
}
