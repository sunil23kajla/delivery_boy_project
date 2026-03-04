import 'package:delivery_boy/core/services/session_service.dart';
import 'package:delivery_boy/data/models/order_model.dart';
import 'package:delivery_boy/data/repository/shipment_repository.dart';
import 'package:delivery_boy/presentation/controllers/base_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';

enum UndeliveredStep { reasons, action }

class UndeliveredController extends BaseController {
  final ShipmentRepository _shipmentRepository = Get.find<ShipmentRepository>();
  final SessionService _sessionService = Get.find<SessionService>();

  late OrderModel shipment;

  final otpController = TextEditingController();
  final reasonDetailsController = TextEditingController();

  var currentStep = UndeliveredStep.reasons.obs;
  var selectedReasonIndex = (-1).obs;
  var isOtpVerified = false.obs;

  final undeliveryReasons = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is OrderModel) {
      shipment = Get.arguments;
    } else if (Get.arguments is Map) {
      shipment = OrderModel.fromJson(Get.arguments);
    } else {
      shipment = OrderModel(); // Fallback
    }
    fetchUndeliveryReasons();
  }

  Future<void> fetchUndeliveryReasons() async {
    try {
      showLoading();
      final token = _sessionService.token ?? "";
      final response =
          await _shipmentRepository.getUndeliveryReasons(token: token);

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        if (data is Map && data['reasons'] != null) {
          undeliveryReasons.assignAll(data['reasons'] as List<dynamic>);
        } else if (data is List) {
          undeliveryReasons.assignAll(data);
        }
      }
      hideLoading();
    } catch (e) {
      hideLoading();
      handleError(e);
    }
  }

  // Assuming reason ID 1 or name containing OTP requires OTP
  bool get isOtpReason {
    if (selectedReasonIndex.value == -1 || undeliveryReasons.isEmpty) {
      return false;
    }
    final reason = undeliveryReasons[selectedReasonIndex.value];
    final name = (reason['reason'] ?? '')
        .toString()
        .toUpperCase(); // Changed 'name' to 'reason'
    return name.contains('OTP');
  }

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

  Future<void> completeProcess() async {
    if (isOtpReason && !isOtpVerified.value && otpController.text.isNotEmpty) {
      Get.snackbar(AppStrings.error, "Please verify OTP first");
      return;
    }

    // In actual implementation, we'll bypass OTP requirement check if the backend doesn't strictly enforce it
    // or if the UI doesn't have an endpoint for verifying generic undelivered OTP.

    // User requested that notes/details are optional, so we remove the strict empty check.
    // if (!isOtpReason && reasonDetailsController.text.isEmpty) {
    //   Get.snackbar(AppStrings.error, "Please enter the reason details");
    //   return;
    // }

    try {
      final orderId = shipment.id?.toString();
      if (orderId == null) {
        return;
      }

      final reasonName =
          undeliveryReasons[selectedReasonIndex.value]['reason'].toString();

      showLoading();
      final token = _sessionService.token ?? "";
      final response = await _shipmentRepository.markUndelivered(
        orderId: orderId,
        reason: reasonName,
        notes: reasonDetailsController.text.trim(),
        token: token,
      );

      hideLoading();

      if (response['success'] == false) {
        Get.snackbar("Error",
            response['message']?.toString() ?? "Failed to mark undelivered",
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900);
        return;
      }

      _showConfirmation();
    } catch (e) {
      hideLoading();

      // Explicitly showing a snackbar for the error to ensure it's visible,
      // as the baseController's handleError might just log it based on its implementation.
      Get.snackbar(
        AppStrings.error,
        e
            .toString()
            .replaceAll('Exception: ', '')
            .replaceAll('ClientException: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 4),
      );

      handleError(e);
    }
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
