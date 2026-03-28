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

  Future<void> verifyOtp() async {
    if (otpController.text.length != 4) {
      Get.snackbar(AppStrings.error, "Please enter a valid 4-digit OTP");
      return;
    }

    try {
      showLoading();
      final token = _sessionService.token ?? "";
      final orderId = shipment.id?.toString() ?? "";

      // Determine if it's FWD or other (though the controller seems generic)
      // The user specifically asked for FWD mark undelivered OTP.
      final reasonId =
          undeliveryReasons[selectedReasonIndex.value]['id']?.toString() ?? "";

      final response = await _shipmentRepository.verifyFwdUndeliveredOtp(
        orderId: orderId,
        pendingReasonId: reasonId,
        reasonDescription: reasonDetailsController.text.trim(),
        otp: otpController.text,
        token: token,
      );

      hideLoading();
      if (response['success'] == true) {
        isOtpVerified.value = true;
        Get.snackbar(AppStrings.success,
            response['message'] ?? "OTP Verified Successfully");
      } else {
        handleError(response['message'] ?? "OTP Verification Failed");
      }
    } catch (e) {
      hideLoading();
      handleError(e);
    }
  }

  Future<void> completeProcess() async {
    final orderId = shipment.id?.toString();
    if (orderId == null) return;

    try {
      showLoading();
      final token = _sessionService.token ?? "";

      // 1. If it's an OTP reason, just call verify API and exit (as it marks undelivered too)
      if (isOtpReason) {
        if (otpController.text.length != 4) {
          hideLoading();
          Get.snackbar(AppStrings.error, "Please enter a valid 4-digit OTP");
          return;
        }

        final reasonId =
            undeliveryReasons[selectedReasonIndex.value]['id']?.toString() ??
                "";

        final otpResponse = await _shipmentRepository.verifyFwdUndeliveredOtp(
          orderId: orderId,
          pendingReasonId: reasonId,
          reasonDescription: reasonDetailsController.text.trim(),
          otp: otpController.text,
          token: token,
        );

        hideLoading();
        if (otpResponse['success'] == true) {
          isOtpVerified.value = true;
          _showConfirmation(message: otpResponse['message']);
        } else {
          handleError(otpResponse['message'] ?? "OTP Verification Failed");
        }
        return;
      }

      // 2. If not an OTP reason, proceed to standard mark undelivered
      final reasonName =
          undeliveryReasons[selectedReasonIndex.value]['reason'].toString();

      final response = await _shipmentRepository.markUndelivered(
        orderId: orderId,
        reason: reasonName,
        notes: reasonDetailsController.text.trim(),
        token: token,
      );

      hideLoading();

      if (response['success'] == false) {
        handleError(response['message'] ?? "Failed to mark undelivered");
        return;
      }

      _showConfirmation(message: response['message']);
    } catch (e) {
      hideLoading();
      handleError(e);
    }
  }

  void _showConfirmation({String? message}) {
    Get.dialog(
      AlertDialog(
        title: const Text("Success"),
        content: Text(message ?? "Order marked as undelivered successfully."),
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
