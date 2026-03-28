import 'dart:convert';
import 'dart:io';

import 'package:delivery_boy/core/constants/app_routes.dart';
import 'package:delivery_boy/core/services/session_service.dart';
import 'package:delivery_boy/data/repository/shipment_repository.dart';
import 'package:delivery_boy/presentation/controllers/base_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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

class RtFlowController extends BaseController {
  final ShipmentRepository _shipmentRepository = Get.find<ShipmentRepository>();
  final SessionService _sessionService = Get.find<SessionService>();

  final RxMap<String, dynamic> shipment = <String, dynamic>{}.obs;
  var currentStep = RtStep.details.obs;
  var isCancelFlow = false.obs;

  // --- Success Flow State ---

  // Scan Step
  var scannedBarcode = "".obs;
  var isCameraActive = false.obs;
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
  var selectedCancelReasonId = "".obs;
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

      // Build address string
      String addressText = '';
      final addr = order.deliveryAddress;
      if (addr != null) {
        final parts = [
          addr.addressLine1,
          addr.addressLine2,
          addr.area?.name,
          addr.city?.name,
          addr.state?.name,
          addr.pincode,
        ].where((e) => e != null && e.toString().isNotEmpty).toList();
        addressText = parts.join(', ');
      }

      shipment.assignAll({
        'id': order.id,
        'orderId': order.orderNumber ?? order.id?.toString(),
        'barcode': order.orderNumber ?? order.trackingId,
        'product': order.items?.isNotEmpty == true
            ? order.items!.first.productName
            : "Product Details N/A",
        'name': order.customer?.name,
        'phone': order.customer?.mobile,
        'address': addressText.isNotEmpty ? addressText : "Address N/A",
        'lat': order.deliveryAddress?.latitude,
        'lng': order.deliveryAddress?.longitude,
      });
    } else if (args is Map<String, dynamic>) {
      shipment.assignAll(args);
    }

    // Fallback static data if necessary
    if (shipment['barcode'] == null) shipment['barcode'] = "TKSH-RT-77210";
    if (shipment['orderId'] == null) shipment['orderId'] = "ORD-RT-9902";
    if (shipment['product'] == null) {
      shipment['product'] = "Product Details N/A";
    }

    otpController.addListener(() => otpText.value = otpController.text);
    cancelOtpController
        .addListener(() => cancelOtpText.value = cancelOtpController.text);
    recipientNameController.addListener(
        () => nameText.value = recipientNameController.text.trim());
    recipientPhoneController.addListener(
        () => phoneText.value = recipientPhoneController.text.trim());
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
          currentStep.value = RtStep.otp;
        } else {
          _verifyQr();
        }
        break;
      case RtStep.otp:
        _verifyDeliveryOtp();
        break;
      case RtStep.options:
        if (selectedRecipientType.value.isNotEmpty) {
          if (selectedRecipientType.value == 'seller') {
            recipientNameController.text = shipment['name'] ?? "Seller XYZ";
            recipientPhoneController.text = shipment['phone'] ?? "9876543210";
            // Manually trigger Rx update for immediate button enablement
            nameText.value = recipientNameController.text;
            phoneText.value = recipientPhoneController.text;
          } else {
            recipientNameController.clear();
            recipientPhoneController.clear();
            nameText.value = "";
            phoneText.value = "";
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
          _completeDelivery();
        } else {
          Get.snackbar("Error", "Front and Back images are mandatory");
        }
        break;
      case RtStep.complete:
        Get.offAllNamed(AppRoutes.home);
        break;
    }
  }

  // No longer needed as we call completeRtDelivery with all details in the next step
  /*
  Future<void> _submitRecipientDetails() async {
    ...
  }
  */

  Future<void> _completeDelivery() async {
    try {
      showLoading();
      final token = _sessionService.token ?? "";
      final nonNullImages = evidenceImages.whereType<File>().toList();

      final response = await _shipmentRepository.completeRtDelivery(
        orderId: shipment['id'].toString(),
        receiverName: recipientNameController.text,
        receiverMobile: recipientPhoneController.text,
        deliveryNotes: "",
        photos: nonNullImages,
        token: token,
      );

      hideLoading();

      if (response['success'] == true) {
        _showSuccessDialog();
      } else {
        handleError(response['message'] ?? "Failed to complete delivery");
      }
    } catch (e) {
      hideLoading();
      handleError(e);
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
        currentStep.value = RtStep.otp;
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

  void toggleCamera() {
    isCameraActive.value = !isCameraActive.value;
  }

  void onScan(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String code = barcodes.first.rawValue ?? "";
      if (code.isNotEmpty) {
        scannedBarcode.value = code;
        isCameraActive.value = false;
        // Don't auto-advance, let user click NEXT
      }
    }
  }

  Future<void> pickImage(int index) async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (photo != null) {
      final file = File(photo.path);
      if (await file.exists()) {
        final size = await file.length();
        debugPrint("📸 [RT ImagePicker] Picked index $index: ${file.path}");
        debugPrint("📸 [RT ImagePicker] File Size: ${size / 1024} KB");
      }
      evidenceImages[index] = file;
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
      // Check if this reason requires OTP or just mark undelivered
      if (selectedCancelReason.value ==
          RtCancelReason.cancelledBySellerContentMismatch) {
        verifyCancelOtp();
      } else {
        markRtUndelivered();
      }
    }
  }

  Future<void> markRtUndelivered() async {
    try {
      showLoading();
      final token = _sessionService.token ?? "";
      final response = await _shipmentRepository.markRtUndelivered(
        orderId: shipment['id'].toString(),
        undeliveryReasonId: selectedCancelReasonId.value,
        reasonDescription: cancelReasonDetailController.text.trim(),
        token: token,
      );
      hideLoading();

      if (response['success'] == true) {
        _showSuccessDialog(
            message: response['message'] ??
                "RT order marked as undelivered successfully");
      } else {
        handleError(response['message'] ?? "Failed to mark undelivered");
      }
    } catch (e) {
      hideLoading();
      handleError(e);
    }
  }

  Future<void> _verifyQr() async {
    try {
      showLoading();
      final token = _sessionService.token ?? "";

      // Improved QR token parsing
      String finalQrToken = scannedBarcode.value;
      if (finalQrToken.startsWith('{') && finalQrToken.endsWith('}')) {
        try {
          // Attempt to parse as JSON if it looks like an object
          final Map<String, dynamic> parsedJson =
              jsonDecode(finalQrToken) as Map<String, dynamic>;
          if (parsedJson.containsKey('token')) {
            finalQrToken = parsedJson['token'].toString();
          }
        } catch (e) {
          debugPrint("QR parsing error (falling back to raw): $e");
        }
      }

      final response = await _shipmentRepository.verifyRtQr(
        orderId: shipment['id'].toString(),
        qrToken: finalQrToken,
        token: token,
      );
      hideLoading();

      if (response['success'] == true) {
        currentStep.value = RtStep.otp;
      } else {
        handleError(response['message'] ?? "QR Verification Failed");
      }
    } catch (e) {
      hideLoading();
      handleError(e);
    }
  }

  Future<void> _verifyDeliveryOtp() async {
    try {
      if (otpText.value.length != 4) {
        Get.snackbar("Error", "Please enter 4-digit OTP");
        return;
      }
      showLoading();
      final token = _sessionService.token ?? "";
      final response = await _shipmentRepository.verifyRtOtp(
        orderId: shipment['id'].toString(),
        otp: otpText.value,
        token: token,
      );
      hideLoading();

      if (response['success'] == true) {
        isOtpVerified.value = true;
        currentStep.value = RtStep.options;
      } else {
        handleError(response['message'] ?? "Invalid OTP");
      }
    } catch (e) {
      hideLoading();
      handleError(e);
    }
  }

  Future<void> verifyCancelOtp() async {
    try {
      if (cancelOtpText.value.length != 4) {
        Get.snackbar("Error", "Please enter 4-digit OTP");
        return;
      }

      showLoading();
      final token = _sessionService.token ?? "";
      final response = await _shipmentRepository.verifyRtUndeliveredOtp(
        orderId: shipment['id'].toString(),
        otp: cancelOtpText.value,
        undeliveryReasonId: selectedCancelReasonId.value,
        reasonDescription: cancelReasonDetailController.text.trim(),
        token: token,
      );
      hideLoading();

      if (response['success'] == true) {
        isCancelOtpVerified.value = true;
        _showSuccessDialog(
            message: response['message'] ??
                "OTP Verified & RT order marked as undelivered.");
      } else {
        handleError(response['message'] ?? "Invalid OTP");
      }
    } catch (e) {
      hideLoading();
      handleError(e);
    }
  }

  void _showSuccessDialog({String? message}) {
    Get.dialog(
      _buildActionPopup(
        icon: Icons.check_circle,
        iconColor: Colors.green,
        title: "SUCCESS",
        message: message ?? "RT order updated successfully.",
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
