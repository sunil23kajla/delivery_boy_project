import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:delivery_boy/core/constants/app_routes.dart';

enum RtStep {
  details, // Column 1: Tracking/Order Info + Mark Buttons
  scan, // Column 2: Scanner + Process without scan
  otp, // Column 3: OTP Verification
  options, // Column 4: Delivered to Seller / Other
  recipient, // Column 5: Forms (Auto/Manual)
  evidence, // Column 6: Images (Front, Back, Customer)
  complete // Success Dialog
}

enum RtCancelStep { reasons, action }

enum RtCancelReason {
  cancelledBySellerContentMismatch, // -> OTP
  rescheduledBySeller, // -> Reason
  sellerUnavailable, // -> Reason
  incompleteAddress, // -> Reason
  misroute // -> Reason
}

class RtFlowController extends GetxController {
  late Map<String, dynamic> shipment;
  var currentStep = RtStep.details.obs;
  var isCancelFlow = false.obs;

  // --- Success Flow State ---

  // Scan Step
  var scannedBarcode = "".obs;
  final scanController = MobileScannerController();

  // OTP Step
  final otpController = TextEditingController();
  var otpText = "".obs;
  var isOtpVerified = false.obs;

  // Options Step
  var selectedRecipientType = "".obs; // 'seller', 'other'

  // Recipient Step
  final recipientNameController = TextEditingController();
  final recipientPhoneController = TextEditingController();
  var nameText = "".obs;
  var phoneText = "".obs;

  // Evidence Step
  var evidenceImages = <File?>[null, null, null].obs; // [Front, Back, Customer]
  final ImagePicker _picker = ImagePicker();

  // --- Cancellation Flow State ---
  var currentCancelStep = RtCancelStep.reasons.obs;
  var selectedCancelReason = Rxn<RtCancelReason>();
  var cancelOtpText = "".obs;
  var isCancelOtpVerified = false.obs;
  final cancelOtpController = TextEditingController();
  final cancelReasonDetailController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    shipment = Get.arguments ?? {};

    // Fallback static data
    if (shipment['barcode'] == null) shipment['barcode'] = "TKSH-RT-77210";
    if (shipment['orderId'] == null) shipment['orderId'] = "ORD-RT-9902";
    if (shipment['product'] == null)
      shipment['product'] = "MacBook Pro M2 Cover (Slate)";

    otpController.addListener(() => otpText.value = otpController.text);
    cancelOtpController
        .addListener(() => cancelOtpText.value = cancelOtpController.text);
    recipientNameController
        .addListener(() => nameText.value = recipientNameController.text);
    recipientPhoneController
        .addListener(() => phoneText.value = recipientPhoneController.text);
  }

  // --- Navigation Logic ---

  void nextStep() {
    if (isCancelFlow.value) {
      _handleCancelNext();
      return;
    }

    switch (currentStep.value) {
      case RtStep.details:
        currentStep.value = RtStep.scan;
        break;
      case RtStep.scan:
        if (scannedBarcode.value == "SKIPPED") {
          currentStep.value = RtStep.options;
        } else if (scannedBarcode.value.isNotEmpty) {
          currentStep.value = RtStep.otp;
        } else {
          Get.snackbar("Error", "Please scan or skip to proceed");
        }
        break;
      case RtStep.otp:
        if (otpText.value == "123456") {
          isOtpVerified.value = true;
          currentStep.value = RtStep.options;
        } else {
          Get.snackbar("Error", "Invalid OTP. Use 123456");
        }
        break;
      case RtStep.options:
        if (selectedRecipientType.value.isNotEmpty) {
          if (selectedRecipientType.value == 'seller') {
            recipientNameController.text = shipment['name'] ?? "Seller XYZ";
            recipientPhoneController.text = shipment['phone'] ?? "9876543210";
          } else {
            recipientNameController.clear();
            recipientPhoneController.clear();
          }
          currentStep.value = RtStep.recipient;
        } else {
          Get.snackbar("Error", "Please select an option");
        }
        break;
      case RtStep.recipient:
        if (nameText.value.isNotEmpty && phoneText.value.isNotEmpty) {
          currentStep.value = RtStep.evidence;
        } else {
          Get.snackbar("Error", "Please fill name and number");
        }
        break;
      case RtStep.evidence:
        if (evidenceImages[0] != null && evidenceImages[1] != null) {
          _showSuccessDialog();
        } else {
          Get.snackbar("Error", "Front and Back images are mandatory");
        }
        break;
      case RtStep.complete:
        Get.offAllNamed(AppRoutes.home);
        break;
    }
  }

  void previousStep() {
    if (isCancelFlow.value) {
      if (currentCancelStep.value == RtCancelStep.action) {
        currentCancelStep.value = RtCancelStep.reasons;
      } else {
        isCancelFlow.value = false;
      }
      return;
    }

    switch (currentStep.value) {
      case RtStep.details:
        Get.back();
        break;
      case RtStep.scan:
        currentStep.value = RtStep.details;
        break;
      case RtStep.otp:
        currentStep.value = RtStep.scan;
        break;
      case RtStep.options:
        if (scannedBarcode.value == "SKIPPED") {
          currentStep.value = RtStep.scan;
        } else {
          currentStep.value = RtStep.otp;
        }
        break;
      case RtStep.recipient:
        currentStep.value = RtStep.options;
        break;
      case RtStep.evidence:
        currentStep.value = RtStep.recipient;
        break;
      case RtStep.complete:
        break;
    }
  }

  void skipScan() {
    scannedBarcode.value = "SKIPPED";
    nextStep();
  }

  void onScan(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      scannedBarcode.value = barcodes.first.displayValue ?? "";
      nextStep();
    }
  }

  Future<void> pickImage(int index) async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      evidenceImages[index] = File(photo.path);
    }
  }

  // --- Cancellation Flow Logic ---

  void startCancelFlow() {
    isCancelFlow.value = true;
    currentCancelStep.value = RtCancelStep.reasons;
    selectedCancelReason.value = null;
    isCancelOtpVerified.value = false;
    cancelOtpController.clear();
    cancelReasonDetailController.clear();
  }

  void _handleCancelNext() {
    if (currentCancelStep.value == RtCancelStep.reasons) {
      if (selectedCancelReason.value != null) {
        currentCancelStep.value = RtCancelStep.action;
      } else {
        Get.snackbar("Error", "Please select a reason");
      }
    } else {
      if (selectedCancelReason.value ==
          RtCancelReason.cancelledBySellerContentMismatch) {
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
        message: "Click on OK to mark this RT as pending.",
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
        message: "Delivery Completed Successfully",
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
    otpController.dispose();
    recipientNameController.dispose();
    recipientPhoneController.dispose();
    cancelOtpController.dispose();
    cancelReasonDetailController.dispose();
    scanController.dispose();
    super.onClose();
  }
}
