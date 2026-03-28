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

enum FmStep {
  details, // Step 1: Info + Dynamic Questions
  scan, // Step 2: Scan QR/Barcode
  images, // Step 3: 2 Images (Front/Back)
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

class FmFlowController extends BaseController {
  final ShipmentRepository _shipmentRepository = Get.find<ShipmentRepository>();
  final SessionService _sessionService = Get.find<SessionService>();

  late Map<String, dynamic> shipment;
  var currentStep = FmStep.details.obs;
  var isCancelFlow = false.obs;

  // --- Success Flow State ---

  // Details
  var product = "".obs;
  var phone = "".obs;
  var lat = 0.0.obs;
  var lng = 0.0.obs;

  // Step 1: Scan
  var scannedBarcode = "".obs;
  var isCameraActive = false.obs;
  final scanController = MobileScannerController();

  // Step 2: Images
  var evidenceImages = <File?>[null, null].obs; // [Front, Back]
  final ImagePicker _picker = ImagePicker();

  // Step 1: Checklist (Dynamic Questions)
  var questions = <Map<String, dynamic>>[].obs;
  var answers = <int, String>{}.obs; // question_id -> 'yes'/'no'
  var isQuestionsFetched = false.obs;

  // --- Cancellation Flow State ---
  var currentCancelStep = FmCancelStep.reasons.obs;
  var pendingReasons = <Map<String, dynamic>>[].obs;
  var selectedReason = Rxn<Map<String, dynamic>>();
  var cancelOtpText = "".obs;
  var isCancelOtpVerified = false.obs;
  final cancelOtpController = TextEditingController();
  final cancelReasonDetailController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    // Fetch questions when controller initializes
    _fetchQuestions();

    final args = Get.arguments;
    if (args != null && args.runtimeType.toString() == 'OrderModel') {
      final order = args;
      shipment = {
        'id': order.id,
        'orderId': order.orderNumber ?? order.id?.toString(),
        'barcode': order.orderNumber,
        'name': order.vendor?.vendorName ??
            order.vendor?.shopName ??
            order.customer?.name,
        'address': order.deliveryAddress?.addressLine1 ?? 'Pickup Address N/A',
      };
      // Extract specific details
      product.value = order.items?.isNotEmpty == true
          ? order.items!.first.productName ?? 'Product'
          : 'Product';
      phone.value = order.vendor?.mobileNumber ?? order.customer?.mobile ?? '';
      lat.value = order.deliveryAddress?.latitude ?? 0.0;
      lng.value = order.deliveryAddress?.longitude ?? 0.0;
    } else {
      shipment = args is Map<String, dynamic> ? args : {};
    }

    // Fallback static data
    if (shipment['barcode'] == null) shipment['barcode'] = "TKSH-FM-11022";
    if (shipment['orderId'] == null) shipment['orderId'] = "ORD-FM-5541";
    if (shipment['name'] == null) {
      shipment['name'] = "Seller: TechWorld Solutions";
    }
    if (shipment['address'] == null) {
      shipment['address'] = "Industrial Area, Phase 2, Delhi";
    }
    if (product.value.isEmpty) product.value = "Fragile Electronics Kit";
    if (phone.value.isEmpty) phone.value = "9876543210";
    if (lat.value == 0.0) {
      lat.value = 28.6139; // Delhi Lat
      lng.value = 77.2090; // Delhi Lng
    }

    cancelOtpController
        .addListener(() => cancelOtpText.value = cancelOtpController.text);

    _fetchPendingReasons();
  }

  void _fetchPendingReasons() async {
    try {
      final token = _sessionService.token ?? "";
      final res = await _shipmentRepository.getFmPendingReasons(token: token);
      if (res != null && res['success'] == true && res['data'] != null) {
        final data = res['data'];
        if (data is List) {
          pendingReasons.assignAll(data.cast<Map<String, dynamic>>());
        } else if (data is Map && data['reasons'] is List) {
          pendingReasons.assignAll(
              (data['reasons'] as List).cast<Map<String, dynamic>>());
        }
      }
    } catch (e) {
      debugPrint("Error fetching pending reasons: $e");
    }
  }

  // --- Navigation Logic ---

  void nextStep() async {
    if (isCancelFlow.value) {
      _handleCancelNext();
      return;
    }

    switch (currentStep.value) {
      case FmStep.details:
        if (answers.length == questions.length) {
          if (questions.isNotEmpty) {
            await _submitAnswersAndProceed();
          } else {
            currentStep.value = FmStep.scan;
          }
        } else {
          Get.snackbar("Error", "Please answer all questions");
        }
        break;
      case FmStep.scan:
        if (scannedBarcode.value.isNotEmpty &&
            scannedBarcode.value != "SKIPPED") {
          await _verifyQrAndProceed();
        } else {
          currentStep.value = FmStep.images; // Skip scan
        }
        break;
      case FmStep.images:
        if (evidenceImages[0] != null && evidenceImages[1] != null) {
          await _uploadImagesAndComplete();
        } else {
          Get.snackbar("Error", "Front and Back images are mandatory");
        }
        break;
      case FmStep.complete:
        Get.offAllNamed(AppRoutes.home);
        break;
    }
  }

  Future<void> _verifyQrAndProceed() async {
    try {
      showLoading();
      final token = _sessionService.token ?? "";
      final res = await _shipmentRepository.verifyFmQr(
        orderId: shipment['id'].toString(),
        qrToken: parseQrToken(scannedBarcode.value),
        token: token,
      );
      hideLoading();
      if (res != null && res['success'] == false) {
        handleError(res['message']?.toString() ?? "Invalid QR");
        return;
      }
      currentStep.value = FmStep.images;
    } catch (e) {
      hideLoading();
      handleError(e);
    }
  }

  Future<void> _uploadImagesAndComplete() async {
    try {
      showLoading();
      final token = _sessionService.token ?? "";
      final nonNullImages = evidenceImages.whereType<File>().toList();
      final res = await _shipmentRepository.uploadFmImages(
        orderId: shipment['id'].toString(),
        photos: nonNullImages,
        token: token,
      );
      hideLoading();
      if (res == null || res['success'] != true) {
        _showResponseDialog(
          title: "ERROR",
          message: res != null
              ? res['message']?.toString() ?? "Image Upload Failed"
              : "Image Upload Failed",
          isSuccess: false,
          goHomeOnOk: false,
        );
        return;
      }
      await _completePickup();
    } catch (e) {
      hideLoading();
      handleError(e);
    }
  }

  Future<void> _fetchQuestions() async {
    try {
      final token = _sessionService.token ?? "";
      final res = await _shipmentRepository.getFmQuestions(token: token);
      if (res != null && res['success'] == true && res['data'] != null) {
        final data = res['data'];
        if (data is List) {
          questions.assignAll(data.cast<Map<String, dynamic>>());
        } else if (data['questions'] is List) {
          questions.assignAll(
              (data['questions'] as List).cast<Map<String, dynamic>>());
        }
      } else if (res != null && res['success'] == false) {
        Get.snackbar(
            "Error", res['message']?.toString() ?? "Failed to load questions");
      }
    } catch (e) {
      handleError(e);
    } finally {
      isQuestionsFetched.value = true;
    }
  }

  Future<void> _submitAnswersAndProceed() async {
    try {
      showLoading();
      final token = _sessionService.token ?? "";

      // Build answer array: [{"question_id": 1, "answer": "yes"}]
      final answerList = answers.entries
          .map((e) => {
                "question_id": e.key,
                "answer": e.value,
              })
          .toList();

      final answersJson = jsonEncode(answerList);

      final res = await _shipmentRepository.submitFmAnswers(
        orderId: shipment['id'].toString(),
        answersJson: answersJson,
        token: token,
      );
      hideLoading();

      if (res != null && res['success'] == false) {
        Get.snackbar(
            "Error", res['message']?.toString() ?? "Failed to save answers");
        return;
      }

      currentStep.value = FmStep.scan;
    } catch (e) {
      hideLoading();
      handleError(e);
    }
  }

  Future<void> _completePickup() async {
    try {
      showLoading();
      final token = _sessionService.token ?? "";
      final res = await _shipmentRepository.completeFm(
        orderId: shipment['id'].toString(),
        token: token,
      );
      hideLoading();
      final isSuccess = res != null && res['success'] == true;
      final message = res != null && res['message'] != null
          ? res['message'].toString()
          : (isSuccess
              ? "Pickup Completed Successfully"
              : "Failed to complete pickup");

      _showResponseDialog(
        title: isSuccess ? "SUCCESS" : "ERROR",
        message: message,
        isSuccess: isSuccess,
        goHomeOnOk: true,
      );
    } catch (e) {
      hideLoading();
      handleError(e);
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
      case FmStep.scan:
        currentStep.value = FmStep.details;
        break;
      case FmStep.images:
        currentStep.value = FmStep.scan;
        break;
      case FmStep.complete:
        break;
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
        debugPrint("📸 [FM ImagePicker] Picked index $index: ${file.path}");
        debugPrint("📸 [FM ImagePicker] File Size: ${size / 1024} KB");
      }
      evidenceImages[index] = file;
    }
  }

  void toggleCamera() {
    isCameraActive.value = !isCameraActive.value;
  }

  void skipScan() {
    scannedBarcode.value = "SKIPPED";
    isCameraActive.value = false;
    nextStep();
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

  // --- Cancellation Flow Logic ---

  void startCancelFlow() {
    isCancelFlow.value = true;
    currentCancelStep.value = FmCancelStep.reasons;
    selectedReason.value = null;
    isCancelOtpVerified.value = false;
    cancelOtpController.clear();
    cancelReasonDetailController.clear();
    _fetchPendingReasons();
  }

  void _handleCancelNext() {
    if (currentCancelStep.value == FmCancelStep.reasons) {
      if (selectedReason.value != null) {
        currentCancelStep.value = FmCancelStep.action;
      } else {
        Get.snackbar("Error", "Please select a reason");
      }
    } else {
      if (selectedReason.value?['requires_otp'] == true ||
          selectedReason.value?['requires_otp'] == 1 ||
          selectedReason.value?['id'] == 1 ||
          selectedReason.value?['id'] == "1" ||
          selectedReason.value?['reason']
                  .toString()
                  .toLowerCase()
                  .contains('cancelled by seller') ==
              true) {
        verifyFmPendingOtp();
      } else {
        markFmPending();
      }
    }
  }

  Future<void> markFmPending() async {
    try {
      showLoading();
      final token = _sessionService.token ?? "";
      final response = await _shipmentRepository.markFmPending(
        orderId: shipment['id'].toString(),
        pendingReasonId: selectedReason.value?['id'].toString() ?? "",
        reasonDescription: cancelReasonDetailController.text.trim(),
        token: token,
      );
      hideLoading();

      if (response['success'] == true) {
        _showResponseDialog(
          title: "SUCCESS",
          message: response['message'] ?? "Order marked as pending",
          isSuccess: true,
          goHomeOnOk: true,
        );
      } else {
        handleError(response['message'] ?? "Failed to mark pending");
      }
    } catch (e) {
      hideLoading();
      handleError(e);
    }
  }

  Future<void> verifyFmPendingOtp() async {
    try {
      if (cancelOtpText.value.length != 4) {
        Get.snackbar("Error", "Please enter 4-digit OTP");
        return;
      }

      showLoading();
      final token = _sessionService.token ?? "";
      final response = await _shipmentRepository.verifyFmPendingOtp(
        orderId: shipment['id'].toString(),
        otp: cancelOtpText.value,
        pendingReasonId: selectedReason.value?['id'].toString() ?? "",
        reasonDescription: cancelReasonDetailController.text.trim(),
        token: token,
      );
      hideLoading();

      if (response['success'] == true) {
        isCancelOtpVerified.value = true;
        _showResponseDialog(
          title: "SUCCESS",
          message: response['message'] ?? "OTP Verified & Order marked pending",
          isSuccess: true,
          goHomeOnOk: true,
        );
      } else {
        handleError(response['message'] ?? "Invalid OTP");
      }
    } catch (e) {
      hideLoading();
      handleError(e);
    }
  }

  void _showResponseDialog({
    required String title,
    required String message,
    required bool isSuccess,
    bool goHomeOnOk = true,
  }) {
    Get.dialog(
      _buildActionPopup(
        icon: isSuccess ? Icons.check_circle : Icons.error,
        iconColor: isSuccess ? Colors.green : Colors.red,
        title: title,
        message: message,
        onOk: () {
          if (goHomeOnOk) {
            Get.offAllNamed(AppRoutes.home);
          } else {
            Get.back(); // Just close dialog
          }
        },
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
