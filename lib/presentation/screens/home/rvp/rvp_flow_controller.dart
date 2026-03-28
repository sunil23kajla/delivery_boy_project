import 'dart:io';
import 'dart:convert';

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

  final RxMap<String, dynamic> shipment = <String, dynamic>{}.obs;
  final RxnString returnId = RxnString();
  var currentStep = RvpStep.details.obs;
  var isCancelFlow = false.obs;
  var isUploading = false.obs;
  var isVerifying = false.obs;

  // --- Step 1: Details ---
  final returnReasonController = TextEditingController();
  final applicationImages = <String>[].obs;
  final customerImages = <String>[].obs;
  final returnReason = "".obs;

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
  var isCameraActive = true.obs;
  var scannedBarcode = "".obs;
  final MobileScannerController scanController = MobileScannerController();

  // --- Cancellation Flow ---
  var currentCancelStep = RvpCancelStep.reasons.obs;
  var cancelReasons = <Map<String, dynamic>>[].obs;
  var selectedReason = Rxn<Map<String, dynamic>>();
  var cancelOtpText = "".obs;
  var isCancelOtpVerified = false.obs;
  final cancelOtpController = TextEditingController();
  final cancelReasonDetailController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    debugPrint("RVP onInit args: $args");

    if (args != null && args.runtimeType.toString() == 'OrderModel') {
      final order = args;
      shipment.assignAll({
        'id': order.id,
        'orderId': order.orderNumber ?? order.id?.toString(),
        'barcode': order.orderNumber,
        'product': order.items?.isNotEmpty == true
            ? order.items!.first.productName
            : "Product Details N/A",
      });
      // Extract from RVP Data in model if present
      if (order.rvpData != null) {
        returnId.value = order.rvpData?['id']?.toString() ?? 
                         order.rvpData?['return_id']?.toString();
        debugPrint("Extracted Return ID from OrderModel: ${returnId.value}");
      }
    } else if (args is Map<String, dynamic>) {
      shipment.assignAll(args);
      if (args.containsKey('return_id')) {
        returnId.value = args['return_id']?.toString();
      } else if (args.containsKey('id') && 
                 (args['order_type']?.toString().toLowerCase().contains('rvp') == true)) {
        returnId.value = args['id']?.toString();
      }
    }

    debugPrint("Initial Shipment: $shipment");
    debugPrint("Initial ReturnId: ${returnId.value}");

    fetchOrderDetails();

    cancelOtpController
        .addListener(() => cancelOtpText.value = cancelOtpController.text);
  }

  // --- Navigation ---

  void nextStep() {
    if (isUploading.value) return;

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
        if (evidenceImages.length >= 3) {
          _uploadEvidence();
        } else {
          Get.snackbar("Error", "Please capture at least 3 images");
        }
        break;
      case RvpStep.scan:
        scannedBarcode.value = ""; // Reset scan when entering/re-entering step
        break;
      case RvpStep.complete:
        Get.offAllNamed(AppRoutes.home);
        break;
    }
  }

  Future<void> _uploadEvidence() async {
    try {
      if (returnId.value == null) {
        Get.snackbar("Error", "Return ID not found");
        return;
      }
      isUploading.value = true;
      showLoading();
      final token = _sessionService.token ?? "";
      final res = await _shipmentRepository.uploadRvpMedia(
        returnId: returnId.value!,
        orderId: shipment['id'].toString(),
        photos: evidenceImages.toList(),
        token: token,
      );
      debugPrint("🚀 RVP Media Response: $res");
      hideLoading();
      isUploading.value = false;

      if (res['success'] == true || res['status'] == true) {
        currentStep.value = RvpStep.scan;
        Get.snackbar("Success", res['message'] ?? "Images uploaded",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        handleError(res['message'] ?? "Please try again");
      }
    } catch (e) {
      isUploading.value = false;
      hideLoading();
      handleError(e);
    }
  }

  Future<void> verifyQrCode() async {
    try {
      if (scannedBarcode.value.isEmpty) {
        Get.snackbar("Error", "Please scan a QR code first");
        return;
      }
      if (returnId.value == null) {
        Get.snackbar("Error", "Return ID not found");
        return;
      }

      isVerifying.value = true;
      final token = _sessionService.token ?? "";
      debugPrint("🚀 Calling verifyRvpQr API for Return ID: ${returnId.value}");
      final res = await _shipmentRepository.verifyRvpQr(
        returnId: returnId.value!,
        orderId: shipment['id'].toString(),
        qrToken: scannedBarcode.value,
        token: token,
      );
      debugPrint("🚀 RVP QR Verify Response: $res");

      if (res['success'] == true || res['status'] == true) {
        // Success! Now call the final completion API
        final completeRes = await _shipmentRepository.completeRvpPickup(
          returnId: returnId.value!,
          orderId: shipment['id'].toString(),
          token: token,
          qrToken: scannedBarcode.value,
        );
        isVerifying.value = false;

        if (completeRes['success'] == true || completeRes['status'] == true) {
          _showSuccessDialog(message: completeRes['message'] ?? res['message']);
        } else {
          handleError(completeRes['message'] ?? "Final completion failed");
        }
      } else {
        isVerifying.value = false;
        handleError(res['message'] ?? "QR Verification failed");
      }
    } catch (e) {
      isVerifying.value = false;
      handleError(e);
    }
  }

  Future<void> skipQrScan() async {
    try {
      if (returnId.value == null) {
        Get.snackbar("Error", "Return ID not found");
        return;
      }

      isVerifying.value = true;
      final token = _sessionService.token ?? "";
      debugPrint(
          "🚀 Calling skipQrScan -> completeRvpPickup. ReturnID: ${returnId.value}");
      // Hit the complete API even on skip as requested
      final res = await _shipmentRepository.completeRvpPickup(
        returnId: returnId.value!,
        orderId: shipment['id'].toString(),
        token: token,
        qrToken: null,
      );
      isVerifying.value = false;

      if (res['success'] == true || res['status'] == true) {
        _showSuccessDialog(
            message: "Pickup processed successfully (QR Skipped)");
      } else {
        handleError(res['message'] ?? "Failed to complete pickup");
      }
    } catch (e) {
      isVerifying.value = false;
      handleError(e);
    }
  }

  void _showSuccessDialog({String? message}) {
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
              Text(message ?? "Pickup Completed Successfully",
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
      if (selectedReason.value != null) {
        currentCancelStep.value = RvpCancelStep.action;
      } else {
        Get.snackbar("Error", "Please select a reason");
      }
    } else {
      if (selectedReason.value?['id'] == 1 ||
          selectedReason.value?['id'] == "1" ||
          selectedReason.value?['requires_otp'] == true ||
          selectedReason.value?['requires_otp'] == 1) {
        verifyCancelOtp();
      } else {
        _cancelOrder();
      }
    }
  }

  Future<void> _cancelOrder() async {
    try {
      if (selectedReason.value == null) return;

      showLoading();
      final token = _sessionService.token ?? "";

      final reasonId = selectedReason.value?['id'].toString() ?? "";
      final details = cancelReasonDetailController.text.trim();

      final res = await _shipmentRepository.cancelRvpOrder(
        orderId: shipment['id'].toString(),
        cancelReasonId: reasonId,
        reasonDetails: details.isEmpty ? null : details,
        token: token,
      );

      hideLoading();

      if (res['success'] == true || res['status'] == true) {
        _showActionSuccess(res['message'] ?? "Order cancelled successfully");
      } else {
        handleError(res['message'] ?? "Cancellation failed");
      }
    } catch (e) {
      hideLoading();
      handleError(e);
    }
  }

  void _showActionSuccess(String message) {
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
              Text(message, textAlign: TextAlign.center),
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

  Future<void> verifyCancelOtp() async {
    try {
      final otp = cancelOtpText.value;
      if (otp.length != 4) {
        Get.snackbar("Error", "Please enter 4-digit OTP");
        return;
      }

      showLoading();
      final token = _sessionService.token ?? "";
      final res = await _shipmentRepository.verifyRvpCancelOtp(
        orderId: shipment['id'].toString(),
        otp: otp,
        cancelReasonId: selectedReason.value?['id'].toString() ?? "",
        reasonDetails: cancelReasonDetailController.text.trim(),
        token: token,
      );
      hideLoading();

      if (res['success'] == true || res['status'] == true) {
        isCancelOtpVerified.value = true;
        _showActionSuccess(res['message'] ?? "Order cancelled with OTP");
      } else {
        handleError(res['message'] ?? "Invalid OTP");
      }
    } catch (e) {
      hideLoading();
      handleError(e);
    }
  }

  void startCancelFlow() {
    isCancelFlow.value = true;
    currentCancelStep.value = RvpCancelStep.reasons;
    selectedReason.value = null;
    isCancelOtpVerified.value = false;
    cancelOtpController.clear();
    cancelReasonDetailController.clear();
    _fetchCancelReasons();
  }

  Future<void> _fetchCancelReasons() async {
    try {
      final token = _sessionService.token ?? "";
      final res = await _shipmentRepository.getRvpCancelReasons(token: token);
      if (res != null && res['success'] == true && res['data'] != null) {
        final data = res['data'];
        if (data is List) {
          cancelReasons.assignAll(data.cast<Map<String, dynamic>>());
        } else if (data is Map && data['reasons'] is List) {
          cancelReasons.assignAll(
              (data['reasons'] as List).cast<Map<String, dynamic>>());
        }
      }
    } catch (e) {
      debugPrint("Error fetching RVP cancel reasons: $e");
    }
  }

  // --- Actions ---

  Future<void> pickEvidenceImage() async {
    if (evidenceImages.length >= 4) return;
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (photo != null) {
      evidenceImages.add(File(photo.path));
    }
  }

  void onScan(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String rawValue = barcodes.first.rawValue ?? "";
      debugPrint("🔍 Raw Scan Data: $rawValue");

      try {
        // Try parsing as JSON to extract token
        final Map<String, dynamic> data = jsonDecode(rawValue);
        if (data.containsKey('token')) {
          scannedBarcode.value = data['token'].toString();
          debugPrint("✅ Extracted Token: ${scannedBarcode.value}");
          // Manual verification only via button as requested
        } else {
          scannedBarcode.value = rawValue;
        }
      } catch (e) {
        // If not JSON, use as is
        scannedBarcode.value = rawValue;
      }
    }
  }

  void toggleCamera() {
    isCameraActive.value = !isCameraActive.value;
  }

  Future<void> fetchOrderDetails() async {
    try {
      final orderId = shipment['id']?.toString();
      if (orderId == null) return;

      showLoading();
      final token = _sessionService.token ?? "";
      final response =
          await _shipmentRepository.getOrderDetails(orderId, token);

      debugPrint("Order Details Response: $response");

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final order = data['order'] ?? {};
        final customer = data['customer'] ?? {};
        final address = data['delivery_address'] ?? {};

        final returns = data['returns'] as List?;
        final items = data['items'] as List?;
        debugPrint("🔍 [DEBUG] full returns list: $returns");
        debugPrint("🔍 [DEBUG] first item data: ${items?.isNotEmpty == true ? items!.first : 'N/A'}");
        
        Map<String, dynamic>? firstItem =
            items?.isNotEmpty == true ? items!.first : null;
        Map<String, dynamic>? rvpReturnData;

        // Update shipment map for the UI
        final Map<String, dynamic> updatedShipment = Map.from(shipment);
        updatedShipment['barcode'] = order['tracking_id'] ??
            shipment['barcode'] ??
            order['order_number'];
        updatedShipment['orderId'] =
            order['order_number'] ?? shipment['orderId'];
        updatedShipment['name'] = customer['name'] ?? "-------";

        // Build address string
        final addrParts = [
          address['address_line1'],
          address['address_line2'],
          address['landmark'],
          address['area']?['name'],
          address['city']?['name'],
          address['pincode'],
        ].where((e) => e != null && e.toString().trim().isNotEmpty).toList();
        updatedShipment['address'] =
            addrParts.isNotEmpty ? addrParts.join(', ') : "-------";

        // Extract phone and coordinates for actions
        updatedShipment['mobile'] =
            customer['mobile'] ?? customer['phone'] ?? "";
        updatedShipment['lat'] = address['latitude'];
        updatedShipment['lng'] = address['longitude'];

        if (firstItem != null) {
          // Construct rich product name
          String pName = firstItem['product_name'] ?? "-------";
          final variantAttrs = firstItem['variant_attributes'] as List?;
          if (variantAttrs != null && variantAttrs.isNotEmpty) {
            final attrs = variantAttrs
                .map((e) => e['attribute_value'])
                .where((v) => v != null)
                .join(", ");
            if (attrs.isNotEmpty) {
              pName = "$pName ($attrs)";
            }
          }
          updatedShipment['product'] = pName;
        }
        // --- Extraction Strategy for Return ID ---
        
        // 1. Check in rvp/rvp_return at top level
        final rvpTop = data['rvp'] ?? data['rvp_return'];
        if (rvpTop != null) {
          returnId.value = rvpTop['id']?.toString() ?? rvpTop['return_id']?.toString();
          debugPrint("Found Return ID in top-level rvp block: ${returnId.value}");
        }

        // 2. Check in items[0]['rvp_return'] (Existing logic)
        if (returnId.value == null && firstItem != null) {
          rvpReturnData = firstItem['rvp_return'];
          if (rvpReturnData != null) {
            returnId.value = rvpReturnData['id']?.toString();
            debugPrint("Found Return ID in first item rvp_return: ${returnId.value}");
          }
        }

        // 3. Check in returns array (Existing logic)
        if (returnId.value == null && returns != null && returns.isNotEmpty) {
          returnId.value = returns.first['id']?.toString() ??
              returns.first['return_id']?.toString();
          debugPrint("Found Return ID in returns array: ${returnId.value}");
        }

        // 4. Final Fallback: If it's an RVP order, use the order ID itself if nothing else matches
        // Some systems use the same ID or expect it as a fallback
        if (returnId.value == null) {
          final isRvpType = order['order_type']?.toString().toLowerCase().contains('rvp') == true;
          if (isRvpType) {
            returnId.value = order['id']?.toString();
            debugPrint("Fallback: Using Order ID as Return ID: ${returnId.value}");
          }
        }

        debugPrint("Final Extracted RVP Return ID: ${returnId.value}");

        shipment.assignAll(updatedShipment);

        // Update images and reason - Prefer item-level rvp_return
        if (rvpReturnData != null) {
          returnReason.value = rvpReturnData['reason'] ?? "Reason N/A";

          // Customer Images
          final custImgs = rvpReturnData['customer_uploaded_images'] as List?;
          if (custImgs != null && custImgs.isNotEmpty) {
            customerImages.assignAll(
                custImgs.map((e) => e['image_url'].toString()).toList());
          } else {
            customerImages.clear();
          }

          // Application Images (Original Product Images)
          final originalImgs =
              rvpReturnData['original_product_images'] as List?;
          if (originalImgs != null && originalImgs.isNotEmpty) {
            applicationImages.assignAll(
                originalImgs.map((e) => e['image_url'].toString()).toList());
          } else {
            // Fallback to general product images
            final prodImgs = firstItem?['product_images'] as List?;
            if (prodImgs != null && prodImgs.isNotEmpty) {
              applicationImages.assignAll(
                  prodImgs.map((e) => e['image_url'].toString()).toList());
            } else {
              applicationImages.clear();
            }
          }
        } else {
          // Fallback if no rvp_return block
          returnReason.value = "Reason N/A";
          final prodImgs = firstItem?['product_images'] as List?;
          if (prodImgs != null && prodImgs.isNotEmpty) {
            applicationImages.assignAll(
                prodImgs.map((e) => e['image_url'].toString()).toList());
          } else {
            applicationImages.clear();
          }
          customerImages.clear();
        }
      }
    } catch (e) {
      debugPrint("Error in fetchOrderDetails: $e");
      hideLoading();
      handleError(e);
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
