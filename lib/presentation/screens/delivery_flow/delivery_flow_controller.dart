import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';

enum DeliveryStep {
  scan,
  otp,
  options,
  recipientDetails,
  payment,
  paymentDetails,
  images
}

class DeliveryFlowController extends GetxController {
  late Map<String, dynamic> shipment;
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
    shipment = Get.arguments ?? {};
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
  bool get isCod => shipment['status'] == 'FWD' && shipment['type'] == 'COD';
  bool get isImageStepValid =>
      images.length >= 2; // front + back required, customer optional

  void nextStep() {
    if (currentStep.value == DeliveryStep.scan) {
      if (isScanDone.value) {
        if (scannedBarcode.value == "SKIPPED") {
          currentStep.value = DeliveryStep.options;
        } else {
          currentStep.value = DeliveryStep.otp;
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
          recipientNameController.text = shipment['name'] ?? "";
          recipientPhoneController.text = shipment['phone'] ?? "";
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

  Future<void> pickImage() async {
    if (images.length >= 3) return; // max 3: front, back, customer
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      images.add(File(photo.path));
    }
  }

  void finishDelivery() {
    if (images.length < 2) {
      Get.snackbar(AppStrings.error,
          "Please add at least 2 images (Front & Back) for proof");
      return;
    }

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
              Text(
                AppStrings.success,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Delivery Completed Successfully",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.home),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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
