import 'dart:io';

import 'package:delivery_boy/core/constants/app_routes.dart';
import 'package:delivery_boy/core/services/session_service.dart';
import 'package:delivery_boy/data/repository/shipment_repository.dart';
import 'package:delivery_boy/presentation/controllers/base_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

enum RvpStep {
  details, // Details + App/Customer Images
  checklist, // 7 Verification questions
  evidence, // 3-4 Pickup photos
  scan, // QR Scan on polythene
  complete // Success popup
}

enum RvpCancelStep { reasons, action }

enum RvpCancelReason {
  cancelledByCustomer,
  rescheduledByCustomer,
  customerUnavailable,
  incompleteAddress,
  refusedOtp,
  fakeProduct,
  misroute
}

class RvpFlowController extends BaseController {
  final ShipmentRepository _shipmentRepository = Get.find<ShipmentRepository>();
  final SessionService _sessionService = Get.find<SessionService>();

  late Map<String, dynamic> shipment;
  var currentStep = RvpStep.details.obs;
  var isCancelFlow = false.obs;

  // --- Step 1: Details ---
  final returnReasonController = TextEditingController();
  final List<String> applicationImages = [
    "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&q=80",
    "https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=400&q=80",
    "https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=400&q=80",
  ];
  final List<String> customerImages = [
    "https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=400&q=80",
    "https://images.unsplash.com/photo-1512374382149-433a42b6a936?w=400&q=80",
    "https://images.unsplash.com/photo-1516478177764-9fe5bd7e9717?w=400&q=80",
  ];

  // --- Step 2: Checklist ---
  final checklist =
      <bool?>[null, null, null, null, null, null, null].obs; // 7 questions
  final List<String> checklistQuestions = [
    "Does the image match with product?",
    "Does the image match with product brand?",
    "Does the description match with product?",
    "Does the return reason match?",
    "Damage product?",
    "Color match?",
    "Design match?",
  ];

  // --- Step 3: Evidence Images ---
  var evidenceImages = <File>[].obs;
  final ImagePicker _picker = ImagePicker();

  // --- Step 4: Scan ---
  var scannedBarcode = "".obs;
  final scanController = MobileScannerController();

  // --- Cancellation Flow ---
  var currentCancelStep = RvpCancelStep.reasons.obs;
  var selectedCancelReason = Rxn<RvpCancelReason>();
  var cancelOtpText = "".obs;
  var isCancelOtpVerified = false.obs;
  final cancelOtpController = TextEditingController();
  final cancelReasonDetailController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args != null && args.runtimeType.toString() == 'OrderModel') {
      final order = args;
      shipment = {
        'id': order.id,
        'orderId': order.orderNumber ?? order.id?.toString(),
        'barcode': order.orderNumber,
        'product': order.items?.isNotEmpty == true
            ? order.items!.first.productName
            : "Product Details N/A",
      };
    } else {
      shipment = args is Map<String, dynamic> ? args : {};
    }
    // Fallback static data
    if (shipment['barcode'] == null) {
      shipment['barcode'] = "TKSH-RVP-98231";
    }
    if (shipment['orderId'] == null) {
      shipment['orderId'] = "ORD-2024-XP001";
    }
    if (shipment['product'] == null) {
      shipment['product'] = "Nike Air Max 270 (Blue Edition)";
    }

    cancelOtpController
        .addListener(() => cancelOtpText.value = cancelOtpController.text);
  }

  // --- Navigation ---

  void nextStep() {
    if (isCancelFlow.value) {
      _handleCancelNext();
      return;
    }

    switch (currentStep.value) {
      case RvpStep.details:
        currentStep.value = RvpStep.evidence;
        break;
      case RvpStep.checklist:
        currentStep.value = RvpStep.evidence;
        break;
      case RvpStep.evidence:
        if (evidenceImages.isNotEmpty) {
          _completePickup();
        } else {
          Get.snackbar("Error", "Please capture at least 1 image");
        }
        break;
      case RvpStep.scan:
        break;
      case RvpStep.complete:
        Get.offAllNamed(AppRoutes.home);
        break;
    }
  }

  Future<void> _completePickup() async {
    try {
      showLoading();
      final token = _sessionService.token ?? "placeholder_token";
      await _shipmentRepository.updateOrderStatus(
        orderId: shipment['orderId'].toString(),
        status: "PICKED_UP",
        token: token,
      );
      hideLoading();
      _showSuccessDialog();
    } catch (e) {
      handleError(e);
    }
  }

  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              const Text("SUCCESS",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Pickup Completed Successfully",
                  textAlign: TextAlign.center),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.home),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("OK",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void previousStep() {
    if (isCancelFlow.value) {
      if (currentCancelStep.value == RvpCancelStep.action) {
        currentCancelStep.value = RvpCancelStep.reasons;
      } else {
        isCancelFlow.value = false;
      }
      return;
    }

    switch (currentStep.value) {
      case RvpStep.details:
        Get.back();
        break;
      case RvpStep.checklist:
        currentStep.value = RvpStep.details;
        break;
      case RvpStep.evidence:
        currentStep.value = RvpStep.details;
        break;
      case RvpStep.scan:
        currentStep.value = RvpStep.evidence;
        break;
      case RvpStep.complete:
        break;
    }
  }

  void _handleCancelNext() {
    if (currentCancelStep.value == RvpCancelStep.reasons) {
      if (selectedCancelReason.value != null) {
        currentCancelStep.value = RvpCancelStep.action;
      } else {
        Get.snackbar("Error", "Please select a reason");
      }
    } else {
      // Logic for cancellation completion
      if (selectedCancelReason.value == RvpCancelReason.cancelledByCustomer) {
        if (isCancelOtpVerified.value) {
          _markPending();
        } else {
          Get.snackbar("Error", "Please verify OTP first");
        }
      } else {
        if (cancelReasonDetailController.text.trim().isNotEmpty) {
          _markPending();
        } else {
          Get.snackbar("Error", "Please enter reason details");
        }
      }
    }
  }

  Future<void> _markPending() async {
    try {
      showLoading();
      final token = _sessionService.token ?? "placeholder_token";
      await _shipmentRepository.updateOrderStatus(
        orderId: shipment['orderId'].toString(),
        status: "PENDING",
        token: token,
      );
      hideLoading();
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      handleError(e);
    }
  }

  void verifyCancelOtp() {
    if (cancelOtpText.value == "123456") {
      isCancelOtpVerified.value = true;
      Get.snackbar("Success", "OTP Verified successfully",
          backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar("Error", "Invalid OTP. Use 123456",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void startCancelFlow() {
    isCancelFlow.value = true;
    currentCancelStep.value = RvpCancelStep.reasons;
    isCancelOtpVerified.value = false;
    cancelOtpController.clear();
    cancelReasonDetailController.clear();
  }

  // --- Actions ---

  Future<void> pickEvidenceImage() async {
    if (evidenceImages.length >= 4) return;
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      evidenceImages.add(File(photo.path));
    }
  }

  void onScan(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      scannedBarcode.value = barcodes.first.displayValue ?? "";
    }
  }

  @override
  void onClose() {
    returnReasonController.dispose();
    cancelOtpController.dispose();
    cancelReasonDetailController.dispose();
    scanController.dispose();
    super.onClose();
  }
}
