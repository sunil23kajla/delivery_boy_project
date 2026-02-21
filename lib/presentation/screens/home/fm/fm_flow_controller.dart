import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:delivery_boy/core/constants/app_routes.dart';

enum FmStep {
  details, // Step 1: Info + Checklist (Product/Weight)
  images, // Step 2: 2 Images (Front/Back)
  scan, // Step 3: Scan QR/Barcode
  complete // Success Popup
}

enum FmCancelStep { reasons, action }

enum FmCancelReason {
  pickupCancelledBySeller, // -> OTP
  pickupRescheduledBySeller, // -> Reason
  sellerUnavailable, // -> Reason
  incompleteAddress, // -> Reason
  misroute // -> Reason
}

class FmFlowController extends GetxController {
  late Map<String, dynamic> shipment;
  var currentStep = FmStep.details.obs;
  var isCancelFlow = false.obs;

  // --- Success Flow State ---

  // Step 1: Checklist
  var isProductVisible = Rxn<bool>();
  var isWeightMatch = Rxn<bool>();

  // Step 2: Images
  var evidenceImages = <File?>[null, null].obs; // [Front, Back]
  final ImagePicker _picker = ImagePicker();

  // Step 3: Scan
  var scannedBarcode = "".obs;
  final scanController = MobileScannerController();

  // --- Cancellation Flow State ---
  var currentCancelStep = FmCancelStep.reasons.obs;
  var selectedCancelReason = Rxn<FmCancelReason>();
  var cancelOtpText = "".obs;
  var isCancelOtpVerified = false.obs;
  final cancelOtpController = TextEditingController();
  final cancelReasonDetailController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    shipment = Get.arguments ?? {};

    // Fallback static data
    if (shipment['barcode'] == null) shipment['barcode'] = "TKSH-FM-11022";
    if (shipment['orderId'] == null) shipment['orderId'] = "ORD-FM-5541";
    if (shipment['name'] == null)
      shipment['name'] = "Seller: TechWorld Solutions";
    if (shipment['address'] == null)
      shipment['address'] = "Industrial Area, Phase 2, Delhi";

    cancelOtpController
        .addListener(() => cancelOtpText.value = cancelOtpController.text);
  }

  // --- Navigation Logic ---

  void nextStep() {
    if (isCancelFlow.value) {
      _handleCancelNext();
      return;
    }

    switch (currentStep.value) {
      case FmStep.details:
        if (isProductVisible.value != null && isWeightMatch.value != null) {
          currentStep.value = FmStep.images;
        } else {
          Get.snackbar("Error", "Please complete the checklist");
        }
        break;
      case FmStep.images:
        if (evidenceImages[0] != null && evidenceImages[1] != null) {
          currentStep.value = FmStep.scan;
        } else {
          Get.snackbar("Error", "Front and Back images are mandatory");
        }
        break;
      case FmStep.scan:
        if (scannedBarcode.value.isNotEmpty) {
          _showSuccessDialog();
        } else {
          Get.snackbar("Error", "Please scan to complete");
        }
        break;
      case FmStep.complete:
        Get.offAllNamed(AppRoutes.home);
        break;
    }
  }

  void previousStep() {
    if (isCancelFlow.value) {
      if (currentCancelStep.value == FmCancelStep.action) {
        currentCancelStep.value = FmCancelStep.reasons;
      } else {
        isCancelFlow.value = false;
      }
      return;
    }

    switch (currentStep.value) {
      case FmStep.details:
        Get.back();
        break;
      case FmStep.images:
        currentStep.value = FmStep.details;
        break;
      case FmStep.scan:
        currentStep.value = FmStep.images;
        break;
      case FmStep.complete:
        break;
    }
  }

  Future<void> pickImage(int index) async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      evidenceImages[index] = File(photo.path);
    }
  }

  void onScan(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && scannedBarcode.value.isEmpty) {
      scannedBarcode.value = barcodes.first.displayValue ?? "";
    }
  }

  // --- Cancellation Flow Logic ---

  void startCancelFlow() {
    isCancelFlow.value = true;
    currentCancelStep.value = FmCancelStep.reasons;
    selectedCancelReason.value = null;
    isCancelOtpVerified.value = false;
    cancelOtpController.clear();
    cancelReasonDetailController.clear();
  }

  void _handleCancelNext() {
    if (currentCancelStep.value == FmCancelStep.reasons) {
      if (selectedCancelReason.value != null) {
        currentCancelStep.value = FmCancelStep.action;
      } else {
        Get.snackbar("Error", "Please select a reason");
      }
    } else {
      if (selectedCancelReason.value ==
          FmCancelReason.pickupCancelledBySeller) {
        if (isCancelOtpVerified.value) {
          _showCancelSuccess();
        } else {
          Get.snackbar("Error", "Please verify OTP first");
        }
      } else {
        if (cancelReasonDetailController.text.trim().isNotEmpty) {
          _showCancelSuccess();
        } else {
          Get.snackbar("Error", "Please enter reason details");
        }
      }
    }
  }

  void verifyCancelOtp() {
    if (cancelOtpText.value == "123456") {
      isCancelOtpVerified.value = true;
      Get.snackbar("Success", "OTP Verified");
    } else {
      Get.snackbar("Error", "Invalid OTP. Use 123456");
    }
  }

  void _showCancelSuccess() {
    Get.dialog(
      _buildActionPopup(
        icon: Icons.info,
        iconColor: Colors.orange,
        title: "MARK PENDING",
        message: "Click on OK to mark this FM as pending.",
        onOk: () => Get.offAllNamed(AppRoutes.home),
      ),
    );
  }

  void _showSuccessDialog() {
    Get.dialog(
      _buildActionPopup(
        icon: Icons.check_circle,
        iconColor: Colors.green,
        title: "SUCCESS",
        message: "Pickup Completed Successfully",
        onOk: () => Get.offAllNamed(AppRoutes.home),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildActionPopup({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required VoidCallback onOk,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 80),
            const SizedBox(height: 20),
            Text(title,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onOk,
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
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
    );
  }

  @override
  void onClose() {
    cancelOtpController.dispose();
    cancelReasonDetailController.dispose();
    scanController.dispose();
    super.onClose();
  }
}
