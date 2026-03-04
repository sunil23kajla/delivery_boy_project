import 'dart:io';

import 'package:delivery_boy/core/constants/app_routes.dart';
import 'package:delivery_boy/core/constants/app_strings.dart';
import 'package:delivery_boy/core/error/failure.dart';
import 'package:delivery_boy/core/services/session_service.dart';
import 'package:delivery_boy/data/models/order_model.dart';
import 'package:delivery_boy/data/repository/shipment_repository.dart';
import 'package:delivery_boy/presentation/controllers/base_controller.dart';
import 'package:delivery_boy/presentation/screens/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

enum DeliveryStep {
  scan,
  otp,
  options,
  recipientDetails,
  payment,
  paymentDetails,
  images
}

class DeliveryFlowController extends BaseController {
  final ShipmentRepository _shipmentRepository = Get.find<ShipmentRepository>();
  final SessionService _sessionService = Get.find<SessionService>();

  late OrderModel shipment;
  var currentStep = DeliveryStep.scan.obs;

  // Scan Step
  var scannedBarcode = "".obs;
  var isScanDone = false.obs;
  var isTorchOn = false.obs;
  var isCameraActive = false.obs;
  final scanController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  void toggleCamera() {
    isCameraActive.value = !isCameraActive.value;
  }

  void completeScan(String barcode) {
    scannedBarcode.value = barcode;
    isScanDone.value = true;
  }

  void skipScan() {
    scannedBarcode.value = "SKIPPED";
    isScanDone.value = true;
  }

  // OTP Step
  final otpController = TextEditingController();
  var otpText = "".obs;
  var isOtpVerified = false.obs;
  bool get isOtpStepValid => otpText.value.length == 6;

  // Options Step
  var selectedRecipient = "".obs; // 'customer', 'other'

  // Recipient Details Step (Step 4)
  final recipientNameController = TextEditingController();
  final recipientPhoneController = TextEditingController();
  final otherAddressController = TextEditingController();

  // Observables for real-time validation feedback
  var nameText = "".obs;
  var phoneText = "".obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is OrderModel) {
      shipment = Get.arguments;
    } else {
      // Fallback for safety
      shipment = OrderModel();
      Get.snackbar('Error', 'Invalid order data provided');
    }

    otpController.addListener(() => otpText.value = otpController.text);
    recipientNameController
        .addListener(() => nameText.value = recipientNameController.text);
    recipientPhoneController
        .addListener(() => phoneText.value = recipientPhoneController.text);
  }

  bool get isOptionsStepValid => selectedRecipient.value.isNotEmpty;

  bool get isRecipientDetailsStepValid {
    return nameText.value.isNotEmpty && phoneText.value.isNotEmpty;
  }

  // Payment Step
  var selectedPaymentMethod = "".obs; // 'upi', 'cash'
  var isPaymentVerified = false.obs; // For UPI flow
  bool get isPaymentStepValid => selectedPaymentMethod.isNotEmpty;

  // Image Step
  var images = <File>[].obs;
  final ImagePicker _picker = ImagePicker();

  bool get isCod => (shipment.paymentMethod ?? '').toUpperCase() == 'COD';
  bool get isImageStepValid => images.length >= 2; // front + back required

  void nextStep() {
    if (currentStep.value == DeliveryStep.scan) {
      if (isScanDone.value) {
        if (scannedBarcode.value == "SKIPPED") {
          currentStep.value = DeliveryStep.options;
        } else {
          verifyQrCode();
        }
      }
    } else if (currentStep.value == DeliveryStep.otp) {
      if (isOtpStepValid) {
        isOtpVerified.value = true;
        Future.delayed(const Duration(seconds: 1), () {
          currentStep.value = DeliveryStep.options;
        });
      }
    } else if (currentStep.value == DeliveryStep.options) {
      if (isOptionsStepValid) {
        // Pre-fill fields if customer is selected
        if (selectedRecipient.value == 'customer') {
          recipientNameController.text = shipment.customer?.name ?? "";
          recipientPhoneController.text = shipment.customer?.mobile ?? "";
        } else {
          recipientNameController.clear();
          recipientPhoneController.clear();
        }
        currentStep.value = DeliveryStep.recipientDetails;
      }
    } else if (currentStep.value == DeliveryStep.recipientDetails) {
      if (isRecipientDetailsStepValid) {
        if (isCod) {
          currentStep.value = DeliveryStep.payment;
        } else {
          currentStep.value = DeliveryStep.images;
        }
      }
    } else if (currentStep.value == DeliveryStep.payment) {
      if (isPaymentStepValid) {
        if (selectedPaymentMethod.value == 'upi') {
          fetchPaymentDetails();
        }
        currentStep.value = DeliveryStep.paymentDetails;
      }
    } else if (currentStep.value == DeliveryStep.paymentDetails) {
      if (selectedPaymentMethod.value == 'cash') {
        currentStep.value = DeliveryStep.images;
      } else if (selectedPaymentMethod.value == 'upi' &&
          isPaymentVerified.value) {
        currentStep.value = DeliveryStep.images;
      }
    }
  }

  void previousStep() {
    if (currentStep.value == DeliveryStep.scan) {
      Get.back();
    } else if (currentStep.value == DeliveryStep.otp) {
      currentStep.value = DeliveryStep.scan;
    } else if (currentStep.value == DeliveryStep.options) {
      if (scannedBarcode.value == "SKIPPED") {
        currentStep.value = DeliveryStep.scan;
      } else {
        currentStep.value = DeliveryStep.otp;
      }
    } else if (currentStep.value == DeliveryStep.recipientDetails) {
      currentStep.value = DeliveryStep.options;
    } else if (currentStep.value == DeliveryStep.payment) {
      currentStep.value = DeliveryStep.recipientDetails;
    } else if (currentStep.value == DeliveryStep.paymentDetails) {
      currentStep.value = DeliveryStep.payment;
    } else if (currentStep.value == DeliveryStep.images) {
      if (isCod) {
        currentStep.value = DeliveryStep.paymentDetails;
      } else {
        currentStep.value = DeliveryStep.recipientDetails;
      }
    }
  }

  // --- API Integration Methods ---

  var paymentDetails = RxMap<String, dynamic>();

  Future<void> verifyQrCode() async {
    try {
      final orderId = shipment.id?.toString();
      if (orderId == null) return;

      showLoading();
      final token = _sessionService.token ?? "";
      final response = await _shipmentRepository.verifyFwdQr(
        orderId: orderId,
        qrToken: scannedBarcode.value,
        token: token,
      );

      if (response['success'] == true) {
        hideLoading();
        currentStep.value = DeliveryStep.otp;
      } else {
        hideLoading();
        Get.snackbar(
            "Error", response['message']?.toString() ?? "Failed to verify QR",
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900);
      }
    } catch (e) {
      hideLoading();
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

  Future<void> fetchPaymentDetails() async {
    try {
      final orderId = shipment.id?.toString();
      if (orderId == null) return;

      showLoading();
      final token = _sessionService.token ?? "";
      final response = await _shipmentRepository.receiveFwdPayment(
        orderId: orderId,
        paymentMode: 'upi',
        token: token,
      );

      if (response['success'] == true && response['data'] != null) {
        paymentDetails.assignAll(Map<String, dynamic>.from(response['data']));
      } else if (response['success'] == false) {
        Get.snackbar(
            "Error",
            response['message']?.toString() ??
                "Failed to receive payment details",
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900);
      }
      hideLoading();
    } catch (e) {
      hideLoading();
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

  Future<void> verifyUpiPayment() async {
    try {
      final orderId = shipment.id?.toString();
      if (orderId == null) return;

      showLoading();
      final token = _sessionService.token ?? "";

      final razorpayOrderId = paymentDetails['payment'] != null
          ? paymentDetails['payment']['razorpay_order_id']?.toString()
          : paymentDetails['razorpay_order_id']?.toString();

      final response = await _shipmentRepository.verifyFwdPayment(
        orderId: orderId,
        razorpayOrderId: razorpayOrderId ?? "",
        razorpayPaymentId: "pay_placeholder", // This should come from SDK
        razorpaySignature: "sig_placeholder", // This should come from SDK
        token: token,
      );

      if (response['success'] == true) {
        isPaymentVerified.value = true;
        Get.snackbar("Success", "Payment verified successfully!");
      } else if (response['success'] == false) {
        Get.snackbar("Error",
            response['message']?.toString() ?? "Payment verification failed",
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900);
      }
      hideLoading();
    } catch (e) {
      hideLoading();
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

  Future<void> finishDelivery() async {
    if (isLoading) return; // Prevent double calls

    if (images.length < 2) {
      Get.snackbar(AppStrings.error,
          "Please add at least 2 images (Front & Back) for proof");
      return;
    }

    try {
      final orderId = shipment.id?.toString();
      if (orderId == null) {
        Get.snackbar("Error", "Order ID not found");
        return;
      }

      showLoading();
      final token = _sessionService.token ?? "";

      final response = await _shipmentRepository.completeFwdDelivery(
        orderId: orderId,
        recipientName: recipientNameController.text,
        recipientMobile: recipientPhoneController.text,
        notes: otherAddressController.text,
        photos: images.toList(),
        token: token,
      );

      if (response['success'] == true) {
        hideLoading();
        _showResponseDialog(
            response['message'] ?? "Delivery Completed Successfully",
            isSuccess: true);
      } else {
        hideLoading();
        _showResponseDialog(
            response['message'] ?? "Failed to complete delivery",
            isSuccess: false);
      }
    } catch (e) {
      hideLoading();
      String message = e.toString();
      if (e is AppException) {
        message = e.message;
      }
      _showResponseDialog(message, isSuccess: false);
    }
  }

  Future<void> pickImage(int index) async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50, // Compress image quality to 50%
      maxWidth: 1024, // Max width to reduce file size
      maxHeight: 1024, // Max height to reduce file size
    );
    if (photo != null) {
      if (index < images.length) {
        images[index] = File(photo.path);
      } else {
        images.add(File(photo.path));
      }
    }
  }

  void _showResponseDialog(String message, {bool isSuccess = true}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 80,
              ),
              const SizedBox(height: 20),
              Text(
                isSuccess ? AppStrings.success : "Status",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offAllNamed(AppRoutes.home);
                    // Ensure Home Screen data is refreshed after delivery
                    if (Get.isRegistered<HomeController>()) {
                      Get.find<HomeController>()
                          .fetchOrders(showLoadingIndicator: true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess ? Colors.green : Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
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

  @override
  void onClose() {
    otpController.dispose();
    scanController.dispose();
    recipientNameController.dispose();
    recipientPhoneController.dispose();
    otherAddressController.dispose();
    super.onClose();
  }
}
