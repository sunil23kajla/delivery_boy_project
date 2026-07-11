import 'dart:convert';
import 'package:delivery_boy/core/services/session_service.dart';
import 'package:delivery_boy/data/models/user_model.dart';
import 'package:delivery_boy/data/repository/profile_repository.dart';
import 'package:delivery_boy/data/repository/shipment_repository.dart';
import 'package:delivery_boy/presentation/controllers/base_controller.dart';
import '../home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';

enum QuickStep {
  home,
  details,
  pickupVerification,
  pickupImages,
  fvdDetails,
  fvdScan,
  fvdOtp,
  fvdOptions,
  fvdRecipientDetails,
  fvdPayment,
  fvdPaymentDetails,
  fvdImages,
  markPendingReason,
  markPendingPreOtp,
  markPendingOtp,
  markPendingComment,
  markPendingRTDetails,
  markPendingRTOtp,
  markPendingRTImages,
  markPendingCustomerCancelOtp,
  markPendingCustomerCancelReasons,
  markPendingCustomerCancelDetails,
  markPendingCustomerCancelImages,
  markPendingCustomerCancelStatus,
  markPendingCustomerCancelQuestions,
  markPendingOtherReturnFailed,
  markPendingOtherImages,
  markPendingInnerReasons,
  markPendingInnerOtp,
  markPendingInnerComment,
  markDeliveredOtp,
  markDeliveredOptions,
  markDeliveredRecipientDetails,
  markDeliveredImages,
  markPendingRtSellerOtp,
  markPendingRtSellerOptions,
  markPendingRtSellerDetails,
  markPendingRtSellerImages,
  success
}

class QuickFlowController extends BaseController {
  final ProfileRepository _profileRepository = Get.find<ProfileRepository>();
  final ShipmentRepository _shipmentRepository = Get.find<ShipmentRepository>();
  final SessionService _sessionService = Get.find<SessionService>();

  var currentStep = QuickStep.home.obs;
  var orders = <Map<String, dynamic>>[].obs;
  var filteredOrders = <Map<String, dynamic>>[].obs; // For Turbo Search
  var selectedOrder = Rxn<Map<String, dynamic>>();
  var userProfile = Rxn<UserModel>();

  // Summary stats
  var totalOrders = 0.obs;
  var totalSuccess = 0.obs;
  var totalFailed = 0.obs;
  var rxQuickSummary = Rxn<Map<String, dynamic>>();

  // Navigation State
  var selectedTabIndex = 0.obs;

  void goToProfile() {
    Get.toNamed(AppRoutes.quickProfile);
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
    if (index == 0) {
      fetchOrders(); // Refresh list when going back to Product tab
    } else if (index == 1) {
      fetchQuickOrdersSummary(showLoader: true);
    }
  }

  final searchController = TextEditingController();
  var searchText = "".obs;
  var isSearchLoading = false.obs;
  Worker? _searchWorker;

  var isOuterFlowEntry = false.obs;
  var pickupVerificationData = Rxn<Map<String, dynamic>>();
  var pickupAnswers = <int, String>{}.obs; // question_id -> answer_value

  // Pickup State
  var pickupImages = <File?>[null, null].obs; // Front, Back

  // FVD Flow State (Unified Delivery)
  // Scan Step
  var fvdScannedBarcode = "".obs;
  var isFvdScanDone = false.obs;
  var isFvdCameraActive = false.obs;
  final fvdScanController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  void toggleFvdCamera() => isFvdCameraActive.value = !isFvdCameraActive.value;
  void completeFvdScan(String barcode) {
    fvdScannedBarcode.value = barcode;
    isFvdScanDone.value = true;
  }

  void skipFvdScan() {
    fvdScannedBarcode.value = "SKIPPED";
    isFvdScanDone.value = true;
  }

  // Recipient Details Step (and others)
  final fvdOtpController = TextEditingController();
  final fvdRecipientNameController = TextEditingController();
  final fvdRecipientPhoneController = TextEditingController();
  final fvdOtherAddressController = TextEditingController();
  final pendingOtpController = TextEditingController();
  final pendingPreOtpController = TextEditingController();
  final pendingCommentController = TextEditingController();
  final customerCancelOtpController = TextEditingController();
  final customerCancelCommentController = TextEditingController();
  // Inner Return State (Mark Pending)
  var selectedInnerReasonId = "".obs;
  var innerOtpText = "".obs;
  final innerOtpController = TextEditingController();
  final innerCommentController = TextEditingController();

  // RT Deliver State (Mark Delivered)
  var rtDeliverOtpText = "".obs;
  final rtDeliverOtpController = TextEditingController();
  var rtDeliverSelectedOption = "".obs; // "seller" or "other"
  var rtDeliverRecipientNameText = "".obs;
  var rtDeliverRecipientPhoneText = "".obs;
  final rtDeliverRecipientNameController = TextEditingController();
  final rtDeliverRecipientPhoneController = TextEditingController();
  var rtDeliverImages = <File?>[null, null, null].obs; // Front, Back, Customer

  var fvdOtpText = "".obs;
  var fvdNameText = "".obs;
  var fvdPhoneText = "".obs;
  var isFvdOtpVerified = false.obs;
  var fvdSelectedRecipient = "".obs; // 'customer', 'other'
  var fvdSelectedPaymentMethod = "".obs; // 'cash', 'upi'
  var isFvdPaymentVerified = false.obs;
  var fvdPaymentDetails = <String, dynamic>{}.obs;
  var fvdImages = <File?>[null, null].obs; // Front, Back

  var pendingOtpText = "".obs;
  var pendingPreOtpText = "".obs;
  var pendingRTImages = <File?>[null, null, null].obs;
  var selectedPendingReasonMap = Rxn<Map<String, dynamic>>();
  var selectedPendingReasonId = "".obs;
  var pendingReasons = <Map<String, dynamic>>[].obs;
  var isPickerActive = false.obs;
  var isDeliveryUndelivered = false.obs;

  // New RT Seller State
  final rtSellerOtpController = TextEditingController();
  final rtSellerNameController = TextEditingController();
  final rtSellerMobileController = TextEditingController();
  var rtSellerOtpText = "".obs;
  var rtSellerNameText = "".obs;
  var rtSellerMobileText = "".obs;
  var rtSellerSelectedOption = "".obs; // "seller" or "other"
  var rtSellerImages =
      <File?>[null, null, null].obs; // 3 slots for return evidence

  var selectedCustomerCancelReasonId = "".obs;
  var customerCancelOtpText = "".obs;
  var customerCancelImages = <File?>[null, null].obs;
  var customerCancelReasons = <Map<String, dynamic>>[].obs;
  var returnToFailedReasons = <Map<String, dynamic>>[].obs;
  var isOuterReasonOther = false.obs;

  final _picker = ImagePicker();
  bool _isDisposed = false;

  @override
  void onClose() {
    _isDisposed = true;
    _searchWorker?.dispose();
    fvdOtpController.dispose();
    fvdRecipientNameController.dispose();
    fvdRecipientPhoneController.dispose();
    fvdOtherAddressController.dispose();
    pendingOtpController.dispose();
    pendingPreOtpController.dispose();
    pendingCommentController.dispose();
    customerCancelOtpController.dispose();
    customerCancelCommentController.dispose();
    innerOtpController.dispose();
    innerCommentController.dispose();
    searchController.dispose();
    fvdScanController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  bool get isFvdOtpStepValid => fvdOtpText.value.length == 4;
  bool get isFvdRecipientDetailsStepValid =>
      fvdNameText.value.isNotEmpty && fvdPhoneText.value.isNotEmpty;
  bool get isFvdPaymentStepValid => fvdSelectedPaymentMethod.isNotEmpty;
  bool get isFvdImageStepValid => fvdImages[0] != null && fvdImages[1] != null;
  bool get isFvdOptionsStepValid => fvdSelectedRecipient.value.isNotEmpty;

  bool get isCod {
    final order = selectedOrder.value ?? {};
    final orderData = order['order'] ?? {};
    final paymentData = order['payment'] ?? {};

    final status = (order['payment_status'] ??
            orderData['payment_status'] ??
            paymentData['payment_status'] ??
            '')
        .toString()
        .trim()
        .toLowerCase();

    if (status == 'paid' || status == 'success' || status == 'online') {
      return false;
    }

    final method = (order['payment_method'] ??
            orderData['payment_method'] ??
            paymentData['payment_method'] ??
            '')
        .toString()
        .trim()
        .toLowerCase();

    if (method.contains('online') ||
        method.contains('razorpay') ||
        method.contains('prepaid') ||
        method.contains('upi')) {
      return false;
    }

    return method == 'cod' || method.contains('cash');
  }

  void resetState() {
    currentStep.value = QuickStep.home;
    pickupVerificationData.value = null;
    pickupAnswers.clear();
    pickupImages.assignAll([null, null]);
    if (!_isDisposed) {
      fvdOtpController.clear();
      fvdRecipientNameController.clear();
      fvdRecipientPhoneController.clear();
      fvdOtherAddressController.clear();
      pendingOtpController.clear();
      pendingPreOtpController.clear();
      pendingCommentController.clear();
      customerCancelOtpController.clear();
      customerCancelCommentController.clear();
    }
    fvdOtpText.value = "";
    fvdNameText.value = "";
    fvdPhoneText.value = "";
    fvdScannedBarcode.value = "";
    isFvdScanDone.value = false;
    isFvdCameraActive.value = false;
    isFvdOtpVerified.value = false;
    fvdSelectedRecipient.value = "";
    fvdSelectedPaymentMethod.value = "";
    isFvdPaymentVerified.value = false;
    fvdPaymentDetails.clear();
    fvdImages.assignAll([null, null]);
    pendingOtpText.value = "";
    pendingPreOtpText.value = "";
    pendingRTImages.assignAll([null, null, null]);
    selectedPendingReasonMap.value = null;
    selectedPendingReasonId.value = "";
    isPickerActive.value = false;
    selectedCustomerCancelReasonId.value = "";
    customerCancelOtpText.value = "";
    customerCancelImages.assignAll([null, null]);
    customerCancelReasons.clear();
    resetRtSellerState();
  }

  void resetRtSellerState() {
    if (!_isDisposed) {
      rtSellerOtpController.clear();
      rtSellerNameController.clear();
      rtSellerMobileController.clear();
    }
    rtSellerOtpText.value = "";
    rtSellerNameText.value = "";
    rtSellerMobileText.value = "";
    rtSellerSelectedOption.value = "";
    rtSellerImages.assignAll([null, null, null]);
  }

  final searchFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
    fetchProfile();
    _initPendingReasons();

    _searchWorker = debounce(searchText, (String? value) {
      if (value == null) return;
      if (value.length >= 1) {
        // More aggressive search
        fetchOrders(search: value);
      } else if (value.isEmpty) {
        fetchOrders(); // Reset to all orders
      }
    }, time: const Duration(milliseconds: 500));

    searchController.addListener(() {
      searchText.value = searchController.text.trim();
      _applyLocalFilter(); // Instant local search
    });

    fvdOtpController
        .addListener(() => fvdOtpText.value = fvdOtpController.text);
    fvdRecipientNameController
        .addListener(() => fvdNameText.value = fvdRecipientNameController.text);
    fvdRecipientPhoneController.addListener(
        () => fvdPhoneText.value = fvdRecipientPhoneController.text);
    pendingOtpController
        .addListener(() => pendingOtpText.value = pendingOtpController.text);
    pendingPreOtpController.addListener(
        () => pendingPreOtpText.value = pendingPreOtpController.text);
    customerCancelOtpController.addListener(
        () => customerCancelOtpText.value = customerCancelOtpController.text);
    rtSellerOtpController
        .addListener(() => rtSellerOtpText.value = rtSellerOtpController.text);
    rtSellerNameController.addListener(
        () => rtSellerNameText.value = rtSellerNameController.text);
    rtSellerMobileController.addListener(
        () => rtSellerMobileText.value = rtSellerMobileController.text);
    rtDeliverOtpController.addListener(
        () => rtDeliverOtpText.value = rtDeliverOtpController.text);
    rtDeliverRecipientNameController.addListener(() =>
        rtDeliverRecipientNameText.value =
            rtDeliverRecipientNameController.text);
    rtDeliverRecipientPhoneController.addListener(() =>
        rtDeliverRecipientPhoneText.value =
            rtDeliverRecipientPhoneController.text);
  }

  Map<String, dynamic> _mergeOrderData(
      Map<String, dynamic> original, Map<String, dynamic> detailData) {
    final Map<String, dynamic> merged = Map<String, dynamic>.from(detailData);

    // ALWAYS prioritize top-level fields from home list for payment
    if (original.containsKey('payment_status') &&
        original['payment_status'] != null) {
      merged['payment_status'] = original['payment_status'];
    }
    if (original.containsKey('payment_method') &&
        original['payment_method'] != null) {
      merged['payment_method'] = original['payment_method'];
    }

    // Also force it inside 'order' object to be safe
    if (merged['order'] != null && merged['order'] is Map) {
      final Map<String, dynamic> orderMap =
          Map<String, dynamic>.from(merged['order']);
      if (original.containsKey('payment_status') &&
          original['payment_status'] != null) {
        orderMap['payment_status'] = original['payment_status'];
      }
      if (original.containsKey('payment_method') &&
          original['payment_method'] != null) {
        orderMap['payment_method'] = original['payment_method'];
      }
      merged['order'] = orderMap;
    }

    return merged;
  }

  Future<void> fetchProfile() async {
    try {
      final token = _sessionService.token;
      if (token != null) {
        final profile = await _profileRepository.getProfile(token);
        userProfile.value = profile;
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    }
  }

  Future<void> updateProfilePicture() async {
    if (isPickerActive.value) return;
    isPickerActive.value = true;

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (photo != null) {
        showLoading();
        final token = _sessionService.token;
        if (token != null) {
          await _profileRepository.updateProfilePicture(
            File(photo.path),
            token,
          );
          await fetchProfile(); // Refresh full profile after partial update
          Get.snackbar("Success", "Profile picture updated successfully");
        }
        hideLoading();
      }
    } catch (e) {
      hideLoading();
      handleError(e);
    } finally {
      isPickerActive.value = false;
    }
  }

  void _initPendingReasons({bool isPickup = true}) {
    // Legacy hardcoded reasons removed in favor of API-driven reasons
  }

  Future<void> fetchQuickPickupCancelReasons(String orderId) async {
    try {
      showLoading();
      final token = _sessionService.token;
      if (token != null) {
        final response = await _shipmentRepository.getQuickPickupCancelReasons(
          orderId: orderId,
          token: token,
        );
        if (response['success'] == true) {
          final List<dynamic> reasons = response['data']?['reasons'] ?? [];
          pendingReasons.assignAll(
              reasons.map((e) => e as Map<String, dynamic>).toList());
        }
      }
    } catch (e) {
      debugPrint("Error fetching pickup cancel reasons: $e");
    } finally {
      hideLoading();
    }
  }

  Future<void> fetchOrders({String? search}) async {
    try {
      if (search != null) {
        isSearchLoading.value = true;
      } else {
        showLoading();
      }

      final token = _sessionService.token;
      if (token == null) return;

      final response = await _shipmentRepository.getQuickOrders(
        token: token,
        search: search,
      );

      if (response['success'] == true) {
        final data = response['data'] ?? {};
        final List<dynamic> ordersList = data['orders'] ?? [];
        orders.assignAll(
            ordersList.map((e) => e as Map<String, dynamic>).toList());
        _applyLocalFilter();

        // Update summary
        final summary = data['summary'];
        if (summary != null) {
          totalOrders.value = (summary['total_orders'] ?? 0).toInt();
          totalSuccess.value = (summary['total_success'] ?? 0).toInt();
          totalFailed.value = (summary['total_failed'] ?? 0).toInt();
        }
      } else {
        // Explicitly handle failure from API
        Get.snackbar(
            "Info", response['message'] ?? "No tasks assigned to you.");
      }
    } catch (e) {
      debugPrint("Error fetching quick orders: $e");
      Get.snackbar("Error", "failedToLoad".tr);
    } finally {
      if (search == null) {
        fetchQuickOrdersSummary();
      }
      if (search != null) {
        isSearchLoading.value = false;
      } else {
        hideLoading();
      }
    }
  }

  Future<void> fetchQuickOrdersSummary({bool showLoader = false}) async {
    try {
      if (showLoader) showLoading();
      final token = _sessionService.token;
      if (token == null) return;

      final response = await _shipmentRepository.getQuickOrdersSummary(
        token: token,
      );

      if (response['success'] == true) {
        final data = response['data'] ?? {};
        rxQuickSummary.value = data;

        // Note: We no longer overwrite totalOrders, etc. from here
        // because the Product tab wants the main API stats (total_orders, total_success).
      }
    } catch (e) {
      debugPrint("Error fetching quick summary: $e");
    } finally {
      if (showLoader) hideLoading();
    }
  }

  void goToDetails(Map<String, dynamic> order) async {
    try {
      showLoading();
      final token = _sessionService.token;
      if (token != null) {
        final response = await _shipmentRepository.getQuickOrderDetails(
          orderId: order['order_id'].toString(),
          token: token,
        );
        if (response['success'] == true) {
          selectedOrder.value = _mergeOrderData(order, response['data']);
          currentStep.value = QuickStep.details;
          Get.toNamed(AppRoutes.quickOrderDetails);
        }
      }
    } catch (e) {
      debugPrint("Error fetching order details: $e");
    } finally {
      hideLoading();
    }
  }

  void startTask() {
    getPickupVerificationDetails();
  }

  void nextStepFromDetails() {
    // Force Pickup flow only, ignoring statusValue
    getPickupVerificationDetails();
  }

  Future<void> getPickupVerificationDetails() async {
    final order = selectedOrder.value;
    if (order == null) return;

    try {
      showLoading();
      // Partial reset instead of full resetState() to preserve data during transitions
      pickupAnswers.clear();
      pickupImages.assignAll([null, null]);

      final token = _sessionService.token;
      if (token != null) {
        dynamic rawId = order['order_id'] ?? order['id'];
        if (rawId == null && order['order'] != null) {
          rawId = order['order']?['id'] ?? order['order']?['order_id'];
        }

        final String orderId =
            (rawId is num) ? rawId.toInt().toString() : rawId.toString();

        final response = await _shipmentRepository.getQuickPickupVerification(
          orderId: orderId,
          token: token,
        );

        if (response['success'] == true) {
          pickupVerificationData.value = response['data'];
          pickupAnswers.clear();

          currentStep.value = QuickStep.pickupVerification;
          Get.toNamed(AppRoutes.quickPickup);
        } else {
          Get.snackbar("Error",
              response['message'] ?? "Failed to fetch verification data");
        }
      }
    } catch (e) {
      debugPrint("Error fetching pickup verification: $e");
      Get.snackbar(
          "Error", "Something went wrong while fetching verification data");
    } finally {
      hideLoading();
    }
  }

  void nextPickupStep() async {
    if (currentStep.value == QuickStep.pickupVerification) {
      final questions =
          pickupVerificationData.value?['verification_questions'] as List? ??
              [];
      if (pickupAnswers.length < questions.length) {
        Get.snackbar("Error", "Please answer all verification questions");
        return;
      }

      try {
        showLoading();
        final token = _sessionService.token;
        if (token != null) {
          final order = selectedOrder.value;

          dynamic rawId = order?['order_id'] ?? order?['id'];
          if (rawId == null && order?['order'] != null) {
            rawId = order?['order']?['id'] ?? order?['order']?['order_id'];
          }

          final String orderId =
              (rawId is num) ? rawId.toInt().toString() : rawId.toString();

          if (orderId == "null" || orderId.isEmpty) {
            Get.snackbar("Error", "Order ID not found in local state");
            return;
          }

          final answersList = pickupAnswers.entries
              .map((e) => {'question_id': e.key, 'answer': e.value})
              .toList();

          final response = await _shipmentRepository.submitQuickPickupAnswers(
            orderId: orderId,
            answersJson: jsonEncode(answersList),
            token: token,
          );

          if (response['success'] == true) {
            currentStep.value = QuickStep.pickupImages;
          } else {
            Get.snackbar(
                "Error", response['message'] ?? "Failed to save answers");
          }
        }
      } catch (e) {
        debugPrint("Error submitting pickup answers: $e");
        Get.snackbar("Error", "Failed to submit answers");
      } finally {
        hideLoading();
      }
    } else if (currentStep.value == QuickStep.pickupImages) {
      if (pickupImages[0] == null || pickupImages[1] == null) {
        Get.snackbar("Error", "Please take both images");
        return;
      }
      try {
        showLoading();
        final token = _sessionService.token;
        if (token != null) {
          final order = selectedOrder.value;

          dynamic rawId = order?['order_id'] ?? order?['id'];
          if (rawId == null && order?['order'] != null) {
            rawId = order?['order']?['id'] ?? order?['order']?['order_id'];
          }

          final String orderId =
              (rawId is num) ? rawId.toInt().toString() : rawId.toString();

          final List<File> validImages =
              pickupImages.where((img) => img != null).cast<File>().toList();

          final response = await _shipmentRepository.submitQuickPickupPhotos(
            orderId: orderId,
            photos: validImages,
            token: token,
          );

          if (response['success'] == true) {
            hideLoading();

            Get.dialog(
              Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Colors.green, size: 80),
                      const SizedBox(height: 20),
                      const Text(
                        "Pickup Successful!",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        response['message'] ??
                            "The order has been picked up from the vendor successfully.",
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            Get.back();

                            showLoading();
                            final token = _sessionService.token;
                            if (token != null) {
                              final refreshResponse = await _shipmentRepository
                                  .getQuickOrderDetails(
                                orderId: orderId,
                                token: token,
                              );
                              if (refreshResponse['success'] == true) {
                                final currentOrder = selectedOrder.value ?? {};
                                resetState();
                                selectedOrder.value = _mergeOrderData(
                                    currentOrder, refreshResponse['data']);
                                currentStep.value = QuickStep.fvdDetails;
                                // Use offNamed to prevent going back to pickup verification
                                Get.offNamed(AppRoutes.quickFvd);
                              } else {
                                resetState();
                                await fetchOrders();
                                Get.offAllNamed(AppRoutes.quickHome);
                              }
                            }
                            hideLoading();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "OK",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              barrierDismissible: false,
            );
          } else {
            Get.snackbar(
                "Error", response['message'] ?? "Failed to upload photos");
          }
        }
      } catch (e) {
        Get.snackbar("Error", "An unexpected error occurred: $e");
      } finally {
        hideLoading();
      }
    }
  }

  Future<void> goToMarkPending({bool isPickup = false}) async {
    try {
      showLoading();
      isDeliveryUndelivered.value = !isPickup;
      final order = selectedOrder.value;
      dynamic rawId = order?['order_id'] ?? order?['id'];
      if (rawId == null && order?['order'] != null) {
        rawId = order?['order']?['id'] ?? order?['order']?['order_id'];
      }
      final String orderId =
          (rawId is num) ? rawId.toInt().toString() : rawId.toString();

      if (isPickup) {
        await fetchQuickPickupCancelReasons(orderId);
        isDeliveryUndelivered.value = false;
        currentStep.value = QuickStep.markPendingReason;
        hideLoading();
        Get.toNamed(AppRoutes.quickMarkPending);
      } else {
        await fetchCustomerCancelReasons();
        isDeliveryUndelivered.value = true;
        isOuterFlowEntry.value = true;
        currentStep.value = QuickStep.markPendingCustomerCancelReasons;
        hideLoading();
        Get.toNamed(AppRoutes.quickMarkUndelivered);
      }
    } catch (e) {
      hideLoading();
      debugPrint("Error in goToMarkPending: $e");
      Get.snackbar("Error", "Could not open cancellation screen: $e");
    }
  }

  void goBack() {
    if (currentStep.value == QuickStep.fvdDetails) {
      // If we are in FVD Details (Delivery) after a pickup,
      // back should go to Home and refresh
      resetState();
      fetchOrders();
      Get.offAllNamed(AppRoutes.quickHome);
    } else {
      Get.back();
    }
  }

  void selectMarkPendingReason(Map<String, dynamic> reason) {
    selectedPendingReasonMap.value = reason;
    selectedPendingReasonId.value = reason['id'].toString();
  }

  Future<void> nextMarkPendingStep() async {
    switch (currentStep.value) {
      case QuickStep.markPendingReason:
        final reason = selectedPendingReasonMap.value;
        if (reason != null) {
          // Identify Reason 1 (Seller Cancel / First Reason)
          final firstReasonId = pendingReasons.isNotEmpty
              ? pendingReasons[0]['id'].toString()
              : "";
          if (reason['id'].toString() == firstReasonId) {
            final success = await sendPickupCancelOtp();
            if (success) currentStep.value = QuickStep.markPendingOtp;
          } else {
            currentStep.value = QuickStep.markPendingComment;
          }
        } else {
          Get.snackbar("Error", "Please select a reason");
        }
        break;

      case QuickStep.markPendingOtp:
        if (pendingOtpText.value.length == 4) {
          verifyPickupCancelOtp();
        } else {
          Get.snackbar("Error", "Please enter 4-digit OTP");
        }
        break;

      case QuickStep.markPendingComment:
        submitPickupCancel();
        break;

      case QuickStep.markPendingCustomerCancelReasons:
        final firstReasonId = customerCancelReasons.isNotEmpty
            ? customerCancelReasons[0]['id'].toString()
            : "";
        isOuterReasonOther.value =
            selectedCustomerCancelReasonId.value != firstReasonId;

        // Call the API for ALL reasons first
        final success = await submitCustomerCancelReasons();
        if (success) {
          isOuterFlowEntry.value = true;
          if (!isOuterReasonOther.value) {
            // Reason 1: Move to OTP [Step 2/6]
            if (!_isDisposed) {
              rtDeliverOtpController.clear();
            }
            rtDeliverOtpText.value = "";
            currentStep.value = QuickStep.markDeliveredOtp;
          } else {
            // Others: Skip OTP -> Jump to Details [Hub]
            final orderId = _getOrderId();
            if (orderId != null) {
              final fetchSuccess = await _fetchOrderDetails(orderId);
              if (fetchSuccess) {
                currentStep.value = QuickStep.markPendingCustomerCancelDetails;
              }
            }
          }
        }
        break;

      case QuickStep.markPendingCustomerCancelDetails:
        // Clicking "MARK UNDELIVERED" on the Hub now goes to Inner Reasons
        // We must fetch the reasons first!
        await fetchReturnToFailedReasons();
        if (returnToFailedReasons.isNotEmpty) {
          currentStep.value = QuickStep.markPendingInnerReasons;
        }
        break;

      case QuickStep.markPendingRtSellerOtp:
        if (rtSellerOtpText.value.length == 4) {
          verifyRtSellerOtp();
        } else {
          Get.snackbar("Error", "Please enter 4-digit OTP");
        }
        break;
      case QuickStep.markPendingRtSellerOptions:
        if (rtSellerSelectedOption.value.isNotEmpty) {
          if (rtSellerSelectedOption.value == 'seller') {
            // Auto-fill from vendor data
            final vendor = selectedOrder.value?['vendor'] ?? {};
            rtSellerNameController.text = vendor['vendor_name']?.toString() ??
                vendor['shop_name']?.toString() ??
                "";
            rtSellerMobileController.text =
                vendor['mobile_number']?.toString() ?? "";
          } else {
            // Clear for manual entry
            rtSellerNameController.clear();
            rtSellerMobileController.clear();
          }
          currentStep.value = QuickStep.markPendingRtSellerDetails;
        } else {
          Get.snackbar("Error", "Please select an option to proceed");
        }
        break;

      case QuickStep.markPendingRtSellerDetails:
        if (rtSellerNameText.value.isNotEmpty &&
            rtSellerMobileText.value.length == 10) {
          submitRtSellerDetails();
        } else {
          Get.snackbar(
              "Error", "Please enter valid Seller Name and 10-digit Mobile");
        }
        break;

      case QuickStep.markPendingRtSellerImages:
        if (rtSellerImages.any((img) => img != null)) {
          uploadRtSellerImages();
        } else {
          Get.snackbar("Error", "Please upload at least one image as evidence");
        }
        break;

      case QuickStep.markPendingCustomerCancelOtp:
        if (customerCancelOtpText.value.length == 4) {
          await verifyCustomerCancelOtp();
        } else {
          Get.snackbar("Error", "Please enter valid 4-digit OTP");
        }
        break;

      case QuickStep.markPendingCustomerCancelImages:
        await uploadCustomerCancelImages();
        break;

      case QuickStep.markPendingInnerReasons:
        if (returnToFailedReasons.isEmpty) {
          Get.snackbar("Error", "No reasons available");
          break;
        }

        final firstReasonId = returnToFailedReasons[0]['id'].toString();
        if (selectedInnerReasonId.value == firstReasonId) {
          // Reason 1: Trigger OTP
          final success = await sendInnerCustomerCancelOtp();
          if (success) {
            currentStep.value = QuickStep.markPendingInnerOtp;
          }
        } else {
          // Other Reasons: Trigger Comment
          currentStep.value = QuickStep.markPendingInnerComment;
        }
        break;

      case QuickStep.markPendingInnerOtp:
        if (innerOtpText.value.length == 4) {
          verifyInnerCustomerCancelOtp();
        } else {
          Get.snackbar("Error", "Please enter 4-digit OTP");
        }
        break;

      case QuickStep.markPendingInnerComment:
        await submitInnerCustomerCancel();
        break;

      case QuickStep.markDeliveredOtp:
        if (isOuterFlowEntry.value) {
          // Gateway OTP -> Hub Screen (Verify first)
          final success = await verifyCustomerCancelOtp();
          if (success) {
            currentStep.value = QuickStep.markPendingCustomerCancelDetails;
          }
        } else {
          // Hub-to-Delivery OTP -> Options
          currentStep.value = QuickStep.markDeliveredOptions;
        }
        break;

      case QuickStep.markDeliveredOptions:
        if (rtDeliverSelectedOption.value == "seller") {
          rtDeliverRecipientNameController.text = "SUNIL KAJLA"; // Dummy Name
          rtDeliverRecipientPhoneController.text = "9876543210"; // Dummy Mobile
          currentStep.value = QuickStep.markDeliveredRecipientDetails;
        } else if (rtDeliverSelectedOption.value == "other") {
          rtDeliverRecipientNameController.clear();
          rtDeliverRecipientPhoneController.clear();
          currentStep.value = QuickStep.markDeliveredRecipientDetails;
        } else {
          Get.snackbar("Error", "Please select a delivery option");
        }
        break;

      case QuickStep.markDeliveredRecipientDetails:
        if (rtDeliverRecipientNameController.text.isNotEmpty &&
            rtDeliverRecipientPhoneController.text.isNotEmpty) {
          currentStep.value = QuickStep.markDeliveredImages;
        } else {
          Get.snackbar("Error", "Please fill recipient details");
        }
        break;

      case QuickStep.markDeliveredImages:
        // Show context-aware success message
        final message = isDeliveryUndelivered.value
            ? "Order Marked Undelivered Successfully"
            : "Order Marked Delivered Successfully";
        _showSuccessDialog(message);
        fetchOrders();
        break;

      default:
        Get.back();
        break;
    }
  }

  void previousMarkPendingStep() {
    switch (currentStep.value) {
      case QuickStep.markPendingReason:
      case QuickStep.markPendingCustomerCancelReasons:
        hideLoading();
        // Restore step based on context before going back
        if (isDeliveryUndelivered.value) {
          currentStep.value = QuickStep.fvdDetails;
        } else {
          currentStep.value = QuickStep.pickupVerification;
        }
        Get.back();
        break;

      case QuickStep.markPendingOtp:
      case QuickStep.markPendingPreOtp:
      case QuickStep.markPendingComment:
        currentStep.value = QuickStep.markPendingReason;
        break;

      case QuickStep.markPendingCustomerCancelDetails:
        currentStep.value = QuickStep.markPendingCustomerCancelReasons;
        break;

      case QuickStep.markPendingCustomerCancelOtp:
        if (selectedCustomerCancelReasonId.value == "2") {
          currentStep.value = QuickStep.markPendingCustomerCancelDetails;
        } else {
          currentStep.value = QuickStep.markPendingCustomerCancelReasons;
        }
        break;

      case QuickStep.markPendingCustomerCancelImages:
        currentStep.value = QuickStep.markPendingCustomerCancelOtp;
        break;

      case QuickStep.markPendingOtherReturnFailed:
        currentStep.value = QuickStep.markPendingCustomerCancelReasons;
        break;

      case QuickStep.markPendingOtherImages:
        currentStep.value = QuickStep.markPendingOtherReturnFailed;
        break;

      case QuickStep.markPendingInnerReasons:
        currentStep.value = QuickStep.markPendingCustomerCancelDetails;
        break;

      case QuickStep.markPendingInnerOtp:
      case QuickStep.markPendingInnerComment:
        currentStep.value = QuickStep.markPendingCustomerCancelDetails;
        break;

      case QuickStep.markDeliveredImages:
        currentStep.value = QuickStep.markDeliveredRecipientDetails;
        break;

      case QuickStep.markDeliveredRecipientDetails:
        currentStep.value = QuickStep.markDeliveredOptions;
        break;

      case QuickStep.markDeliveredOtp:
        if (isOuterFlowEntry.value) {
          currentStep.value = QuickStep.markPendingCustomerCancelReasons;
        } else {
          currentStep.value = QuickStep.markPendingCustomerCancelDetails;
        }
        break;

      case QuickStep.markPendingCustomerCancelDetails:
        if (isDeliveryUndelivered.value) {
          if (!isOuterReasonOther.value) {
            isOuterFlowEntry.value = true;
            currentStep.value = QuickStep.markDeliveredOtp;
          } else {
            currentStep.value = QuickStep.markPendingCustomerCancelReasons;
          }
        } else {
          currentStep.value = QuickStep.details;
        }
        break;

      case QuickStep.markDeliveredOptions:
        currentStep.value = QuickStep.markPendingCustomerCancelDetails;
        break;

      case QuickStep.markPendingInnerReasons:
        currentStep.value = QuickStep.markPendingCustomerCancelDetails;
        break;

      case QuickStep.markPendingInnerOtp:
      case QuickStep.markPendingInnerComment:
        currentStep.value = QuickStep.markPendingInnerReasons;
        break;

      case QuickStep.markPendingRtSellerOtp:
        currentStep.value = QuickStep.markPendingCustomerCancelDetails;
        break;

      case QuickStep.markPendingRtSellerDetails:
        currentStep.value = QuickStep.markPendingRtSellerOtp;
        break;

      case QuickStep.markPendingRtSellerImages:
        currentStep.value = QuickStep.markPendingRtSellerDetails;
        break;

      default:
        break;
    }
  }

  String? _getOrderId() {
    final order = selectedOrder.value;
    if (order == null) return null;
    dynamic rawId = order['order_id'] ?? order['id'];
    if (rawId == null && order['order'] != null) {
      rawId = order['order']?['id'] ?? order['order']?['order_id'];
    }
    return (rawId is num) ? rawId.toInt().toString() : rawId.toString();
  }

  Future<bool> _fetchOrderDetails(String orderId) async {
    try {
      showLoading();
      final token = _sessionService.token;
      if (token == null) return false;

      final response = await _shipmentRepository.getQuickOrderDetails(
        orderId: orderId,
        token: token,
      );

      debugPrint("✅ [API RES] Fetch Order Details (RT Hub): $response");

      if (response['success'] == true) {
        final detailData = response['data'];
        // Merging ensures we preserve payment_status from home list
        selectedOrder.value =
            _mergeOrderData(selectedOrder.value ?? {}, detailData);
        return true;
      } else {
        handleError(response['message'] ?? "Failed to fetch order details");
        return false;
      }
    } catch (e) {
      handleError("Error fetching details: $e");
      return false;
    } finally {
      hideLoading();
    }
  }

  Future<bool> sendInnerCustomerCancelOtp() async {
    try {
      showLoading();
      final orderId = _getOrderId();
      final token = _sessionService.token;
      if (orderId != null && token != null) {
        // Step 1: Submit the failure reason
        final submitResponse =
            await _shipmentRepository.submitQuickReturnToFailed(
          orderId: orderId,
          cancelReasonId: selectedInnerReasonId.value,
          reasonDetails: "", // No details for OTP path yet
          token: token,
        );

        if (submitResponse['success'] != true) {
          handleError(submitResponse['message'] ??
              "Failed to initiate return to failed process");
          return false;
        }

        // Step 2: Send OTP
        final otpResponse =
            await _shipmentRepository.sendQuickReturnToFailedOtp(
          orderId: orderId,
          token: token,
        );
        if (otpResponse['success'] == true) {
          Get.snackbar(
              "Success", otpResponse['message'] ?? "OTP sent successfully");
          return true;
        } else {
          handleError(otpResponse['message'] ?? "Failed to send OTP");
        }
      }
    } catch (e) {
      handleError("Error in return to failed process: $e");
    } finally {
      hideLoading();
    }
    return false;
  }

  Future<void> verifyInnerCustomerCancelOtp() async {
    try {
      showLoading();
      final orderId = _getOrderId();
      final token = _sessionService.token;
      if (orderId != null && token != null) {
        final response = await _shipmentRepository.verifyQuickReturnToFailedOtp(
          orderId: orderId,
          otp: innerOtpText.value,
          token: token,
        );
        if (response['success'] == true) {
          _showSuccessDialog(response['message'] ?? "Verified Successfully");
          fetchOrders();
        } else {
          handleError(response['message'] ?? "Verification failed");
        }
      }
    } catch (e) {
      handleError("Error verifying OTP: $e");
    } finally {
      hideLoading();
    }
  }

  Future<bool> submitCustomerCancelReasons() async {
    try {
      showLoading();
      final orderId = _getOrderId();
      final token = _sessionService.token;

      if (orderId != null && token != null) {
        final response = await _shipmentRepository.submitQuickCustomerCancel(
          orderId: orderId,
          cancelReasonId: selectedCustomerCancelReasonId.value,
          reasonDetails: "", // No comment field yet for outer reasons
          token: token,
        );
        if (response['success'] == true) {
          return true;
        } else {
          handleError(response['message'] ?? "Failed to submit cancellation");
        }
      }
    } catch (e) {
      handleError("Error submitting cancellation: $e");
    } finally {
      hideLoading();
    }
    return false;
  }

  // Renamed the original submitInnerCustomerCancel logic to avoid confusion
  Future<void> submitInnerCustomerCancel() async {
    try {
      showLoading();
      final orderId = _getOrderId();
      final token = _sessionService.token;
      if (orderId != null && token != null) {
        final response = await _shipmentRepository.submitQuickReturnToFailed(
          orderId: orderId,
          cancelReasonId: selectedInnerReasonId.value,
          reasonDetails: innerCommentController.text,
          token: token,
        );
        if (response['success'] == true) {
          _showSuccessDialog(
              response['message'] ?? "Order Marked Pending Successfully");
          fetchOrders();
        } else {
          handleError(response['message'] ?? "Failed to submit cancellation");
        }
      }
    } catch (e) {
      handleError("Error submitting cancellation: $e");
    } finally {
      hideLoading();
    }
  }

  Future<bool> sendCustomerCancelOtp() async {
    try {
      showLoading();
      final orderId = _getOrderId();
      final token = _sessionService.token;

      if (orderId != null && token != null) {
        final response = await _shipmentRepository.sendQuickCustomerCancelOtp(
          orderId: orderId,
          token: token,
        );
        if (response['success'] == true) {
          Get.snackbar("Success", response['message'] ?? "OTP sent");
          return true;
        } else {
          handleError(response['message'] ?? "Failed to send OTP");
        }
      }
    } catch (e) {
      handleError("Error sending OTP: $e");
    } finally {
      hideLoading();
    }
    return false;
  }

  Future<bool> verifyCustomerCancelOtp() async {
    try {
      showLoading();
      final orderId = _getOrderId();
      final token = _sessionService.token;
      final otp = rtDeliverOtpText.value;

      if (orderId != null && token != null) {
        final response = await _shipmentRepository.verifyQuickCustomerCancelOtp(
          orderId: orderId,
          otp: otp,
          token: token,
        );

        if (response['success'] == true) {
          // Success! Now fetch details before proceeding to Hub
          return await _fetchOrderDetails(orderId);
        } else {
          handleError(response['message'] ?? "Incorrect OTP");
        }
      }
    } catch (e) {
      handleError("Error verifying OTP: $e");
    } finally {
      hideLoading();
    }
    return false;
  }

  Future<void> fetchCustomerCancelReasons() async {
    try {
      final token = _sessionService.token;
      if (token != null) {
        final response =
            await _shipmentRepository.getQuickCustomerCancelReasons(
          token: token,
        );
        if (response['success'] == true) {
          final List<dynamic> reasons = response['data']?['reasons'] ?? [];
          customerCancelReasons.assignAll(
              reasons.map((e) => e as Map<String, dynamic>).toList());
        }
      }
    } catch (e) {
      debugPrint("Error fetching customer cancel reasons: $e");
    }
  }

  Future<void> fetchReturnToFailedReasons() async {
    try {
      showLoading();
      final token = _sessionService.token;
      if (token != null) {
        final response =
            await _shipmentRepository.getQuickReturnToFailedReasons(
          token: token,
        );
        if (response != null && response['success'] == true) {
          final List<dynamic> reasons = response['data']?['reasons'] ?? [];
          returnToFailedReasons.assignAll(
              reasons.map((e) => e as Map<String, dynamic>).toList());

          if (returnToFailedReasons.isNotEmpty) {
            selectedInnerReasonId.value =
                returnToFailedReasons[0]['id'].toString();
          }
        } else {
          handleError(response?['message'] ?? "Failed to fetch reasons.");
        }
      }
    } catch (e) {
      handleError("Error fetching return to failed reasons: $e");
    } finally {
      hideLoading();
    }
  }

  void _showSuccessDialog(String message) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            const Text("The operation has been completed successfully.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Get.back();
                resetState();
                Get.offAllNamed(AppRoutes.quickHome);
              },
              child: const Text("OK",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showConfirmDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    required String confirmText,
    required Color confirmColor,
  }) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            child:
                Text(confirmText, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> submitCustomerCancel() async {
    if (selectedCustomerCancelReasonId.value.isEmpty) {
      Get.snackbar("Error", "Please select a reason");
      return;
    }

    try {
      showLoading();
      final token = _sessionService.token;
      final order = selectedOrder.value;
      if (token != null && order != null) {
        dynamic rawId = order['order_id'] ?? order['id'];
        if (rawId == null && order['order'] != null) {
          rawId = order['order']?['id'] ?? order['order']?['order_id'];
        }
        final String orderId =
            (rawId is num) ? rawId.toInt().toString() : rawId.toString();

        final response = await _shipmentRepository.submitQuickCustomerCancel(
          orderId: orderId,
          cancelReasonId: selectedCustomerCancelReasonId.value,
          reasonDetails: customerCancelCommentController.text.trim(),
          token: token,
        );

        if (response['success'] == true) {
          hideLoading();
          _showSuccessDialog(response['message'] ?? "Successfully Submitted");
        } else {
          Get.snackbar(
              "Error", response['message'] ?? "Failed to submit cancellation");
        }
      }
    } catch (e) {
      handleError(e);
    } finally {
      hideLoading();
    }
  }

  Future<void> uploadCustomerCancelImages() async {
    if (customerCancelImages[0] == null || customerCancelImages[1] == null) {
      Get.snackbar("Error", "Please take both required images");
      return;
    }

    try {
      showLoading();
      final token = _sessionService.token;
      final order = selectedOrder.value;
      if (token != null && order != null) {
        dynamic rawId = order['order_id'] ?? order['id'];
        if (rawId == null && order['order'] != null) {
          rawId = order['order']?['id'] ?? order['order']?['order_id'];
        }
        final String orderId =
            (rawId is num) ? rawId.toInt().toString() : rawId.toString();

        final response =
            await _shipmentRepository.uploadQuickCustomerCancelImages(
          orderId: orderId,
          photos: customerCancelImages.whereType<File>().toList(),
          token: token,
        );

        if (response['success'] == true) {
          hideLoading();
          _showSuccessDialog(
              response['message'] ?? "Order cancelled successfully");
          fetchOrders();
        } else {
          Get.snackbar(
              "Error", response['message'] ?? "Failed to upload images");
        }
      }
    } catch (e) {
      handleError(e);
    } finally {
      hideLoading();
    }
  }

  void confirmLogout() {
    _showConfirmDialog(
      title: "Logout",
      message: "Are you sure you want to logout?",
      onConfirm: () => Get.offAllNamed(AppRoutes.login),
      confirmText: "LOGOUT",
      confirmColor: Colors.red,
    );
  }

  Future<bool> confirmAppExit() async {
    bool exit = false;
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("exitApp".tr),
        content: Text("exitMessage".tr),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: Text("no".tr.toUpperCase())),
          ElevatedButton(
            onPressed: () {
              exit = true;
              Get.back();
              SystemNavigator.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text("yes".tr.toUpperCase(),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return exit;
  }

  void submitMarkPending() {
    resetState();
    Get.offAllNamed(AppRoutes.quickHome);
  }

  Future<bool> sendPickupCancelOtp() async {
    try {
      showLoading();
      final token = _sessionService.token;
      final order = selectedOrder.value;
      if (token != null && order != null) {
        dynamic rawId = order['order_id'] ?? order['id'];
        if (rawId == null && order['order'] != null) {
          rawId = order['order']?['id'] ?? order['order']?['order_id'];
        }
        final String orderId =
            (rawId is num) ? rawId.toInt().toString() : rawId.toString();

        final response = await _shipmentRepository.sendQuickPickupCancelOtp(
          orderId: orderId,
          token: token,
        );

        if (response['success'] == true) {
          Get.snackbar("Success", response['message'] ?? "OTP sent to seller");
          return true;
        } else {
          Get.snackbar("Error", response['message'] ?? "Failed to send OTP");
        }
      }
    } catch (e) {
      handleError(e);
    } finally {
      hideLoading();
    }
    return false;
  }

  Future<void> verifyPickupCancelOtp() async {
    try {
      showLoading();
      final token = _sessionService.token;
      final order = selectedOrder.value;
      if (token != null && order != null) {
        dynamic rawId = order['order_id'] ?? order['id'];
        if (rawId == null && order['order'] != null) {
          rawId = order['order']?['id'] ?? order['order']?['order_id'];
        }
        final String orderId =
            (rawId is num) ? rawId.toInt().toString() : rawId.toString();

        final response = await _shipmentRepository.verifyQuickPickupCancelOtp(
          orderId: orderId,
          otp: pendingOtpText.value,
          token: token,
        );

        if (response['success'] == true) {
          submitPickupCancel(); // Final submission and success popup
        } else {
          Get.snackbar("Error", response['message'] ?? "Invalid OTP");
        }
      }
    } catch (e) {
      handleError(e);
    } finally {
      hideLoading();
    }
  }

  Future<void> submitPickupCancel() async {
    try {
      showLoading();
      final token = _sessionService.token;
      if (token != null) {
        final order = selectedOrder.value;
        dynamic rawId = order?['order_id'] ?? order?['id'];
        if (rawId == null && order?['order'] != null) {
          rawId = order?['order']?['id'] ?? order?['order']?['order_id'];
        }
        final String orderId =
            (rawId is num) ? rawId.toInt().toString() : rawId.toString();

        final response = await _shipmentRepository.submitQuickPickupCancel(
          orderId: orderId,
          reasonId: selectedPendingReasonId.value,
          reasonDetails: pendingCommentController.text.trim(),
          token: token,
        );

        if (response['success'] == true) {
          hideLoading();

          Get.dialog(
            AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title:
                  const Icon(Icons.check_circle, color: Colors.green, size: 60),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(response['message'] ?? "Successfully Marked",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  const Text("The order status has been updated successfully.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
              actions: [
                Center(
                  child: TextButton(
                    onPressed: () {
                      Get.back();
                      resetState();
                      fetchOrders();
                      Get.offAllNamed(AppRoutes.quickHome);
                    },
                    child: const Text("OK",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
            barrierDismissible: false,
          );
        } else {
          Get.snackbar(
              "Error", response['message'] ?? "Failed to cancel pickup");
        }
      }
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred: $e");
    } finally {
      hideLoading();
    }
  }

  void pickPickupImage(int index) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 1024,
    );
    if (image != null) {
      pickupImages[index] = File(image.path);
    }
  }

  Future<void> pickCustomerCancelImage(int index) async {
    if (isPickerActive.value) return;
    isPickerActive.value = true;
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxWidth: 1024,
      );
      if (photo != null) {
        customerCancelImages[index] = File(photo.path);
      }
    } finally {
      isPickerActive.value = false;
    }
  }

  Future<void> pickRtDeliverImage(int index) async {
    if (isPickerActive.value) return;
    isPickerActive.value = true;
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxWidth: 1024,
      );
      if (photo != null) {
        rtDeliverImages[index] = File(photo.path);
      }
    } finally {
      isPickerActive.value = false;
    }
  }

  Future<void> pickRtSellerImage(int index) async {
    if (isPickerActive.value) return;
    isPickerActive.value = true;
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxWidth: 1024,
      );
      if (photo != null) {
        rtSellerImages[index] = File(photo.path);
      }
    } finally {
      isPickerActive.value = false;
    }
  }

  Future<void> pickFvdImage(int index) async {
    if (isPickerActive.value) return;
    isPickerActive.value = true;
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxWidth: 1024,
      );
      if (photo != null) {
        fvdImages[index] = File(photo.path);
      }
    } finally {
      isPickerActive.value = false;
    }
  }

  void finishFvdDelivery() {
    if (fvdImages[0] == null || fvdImages[1] == null) {
      Get.snackbar(
          "Error", "Please add at least 2 images (Front & Back) for proof");
      return;
    }
    _submitFinalDelivery();
  }

  Future<void> verifyFvdUpiPayment() async {
    try {
      showLoading();
      final token = _sessionService.token;
      if (token != null) {
        final order = selectedOrder.value;
        dynamic rawId = order?['order_id'] ?? order?['id'];
        if (rawId == null && order?['order'] != null) {
          rawId = order?['order']?['id'] ?? order?['order']?['order_id'];
        }
        final String orderId =
            (rawId is num) ? rawId.toInt().toString() : rawId.toString();

        final response = await _shipmentRepository.verifyQuickPayment(
          orderId: orderId,
          token: token,
        );

        if (response['success'] == true && response['data'] != null) {
          final data = response['data'];
          final orderData = data['order'] ?? {};
          final paymentStatus = (orderData['payment_status'] ??
                  data['payment_status'] ??
                  'unknown')
              .toString()
              .toLowerCase();
          final orderStatus = (orderData['status'] ?? data['status'] ?? '')
              .toString()
              .toLowerCase();

          if (paymentStatus == 'paid' ||
              paymentStatus == 'success' ||
              orderStatus == 'delivered' ||
              paymentStatus == 'unknown') {
            isFvdPaymentVerified.value = true;
            Get.snackbar("Success",
                response['message'] ?? "Payment verified successfully!");
          } else {
            if (paymentStatus == 'pending') {
              Get.snackbar(
                  "Pending", "Payment not yet received. Please try again.");
              isFvdPaymentVerified.value = false;
            } else {
              isFvdPaymentVerified.value = true;
              Get.snackbar("Success", "Verified with status: $paymentStatus");
            }
          }
        } else {
          Get.snackbar(
              "Error",
              response['message'] ??
                  "Payment not yet received. Please try again.");
          isFvdPaymentVerified.value = false;
        }
      }
    } catch (e) {
      debugPrint("Error verifying payment: $e");
      Get.snackbar("Error", "Payment verification failed. Please try again.");
      isFvdPaymentVerified.value = false;
    } finally {
      hideLoading();
    }
  }

  Future<void> pickPendingRTImage(int index) async {
    if (isPickerActive.value) return;
    isPickerActive.value = true;
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        imageQuality: 50,
      );
      if (image != null) {
        pendingRTImages[index] = File(image.path);
      }
    } finally {
      isPickerActive.value = false;
    }
  }

  void startFvdFlow() {
    if (!_isDisposed) {
      fvdOtpController.clear();
      fvdRecipientNameController.clear();
      fvdRecipientPhoneController.clear();
      fvdOtherAddressController.clear();
    }
    fvdImages.assignAll([null, null]);
    fvdSelectedRecipient.value = "";
    fvdSelectedPaymentMethod.value = "";
    isFvdScanDone.value = false;
    isFvdOtpVerified.value = false;
    isFvdPaymentVerified.value = false;
    fvdPaymentDetails.clear();

    // Always start at Delivery Details for both Prepaid and COD
    currentStep.value = QuickStep.fvdDetails;
    // Barcode scan is bypassed entirely
    isFvdScanDone.value = true;

    Get.toNamed(AppRoutes.quickFvd);
  }

  Future<void> _sendDeliveryOtp() async {
    try {
      showLoading();
      final token = _sessionService.token;
      if (token != null) {
        final order = selectedOrder.value;
        dynamic rawId = order?['order_id'] ?? order?['id'];
        if (rawId == null && order?['order'] != null) {
          rawId = order?['order']?['id'] ?? order?['order']?['order_id'];
        }
        final String orderId =
            (rawId is num) ? rawId.toInt().toString() : rawId.toString();

        final response = await _shipmentRepository.sendQuickDeliverOtp(
          orderId: orderId,
          token: token,
        );

        if (response['success'] == true) {
          Get.snackbar("Success",
              response['message'] ?? "Delivery OTP sent successfully");
          currentStep.value = QuickStep.fvdOtp;
        } else {
          Get.snackbar(
              "Error", response['message'] ?? "Failed to send Delivery OTP");
        }
      }
    } catch (e) {
      debugPrint("Error sending delivery otp: $e");
      Get.snackbar("Error", "Failed to send OTP. Please try again.");
    } finally {
      hideLoading();
    }
  }

  Future<void> _verifyDeliveryOtp() async {
    try {
      showLoading();
      final token = _sessionService.token;
      if (token != null) {
        final order = selectedOrder.value;
        dynamic rawId = order?['order_id'] ?? order?['id'];
        if (rawId == null && order?['order'] != null) {
          rawId = order?['order']?['id'] ?? order?['order']?['order_id'];
        }
        final String orderId =
            (rawId is num) ? rawId.toInt().toString() : rawId.toString();

        final response = await _shipmentRepository.verifyQuickDeliverOtp(
          orderId: orderId,
          otp: fvdOtpText.value,
          token: token,
        );

        if (response['success'] == true) {
          isFvdOtpVerified.value = true;
          Get.snackbar(
              "Success", response['message'] ?? "Delivery OTP Verified");
          currentStep.value = QuickStep.fvdOptions;
        } else {
          Get.snackbar("Error", response['message'] ?? "Invalid Delivery OTP");
        }
      }
    } catch (e) {
      debugPrint("Error verifying delivery otp: $e");
      Get.snackbar("Error", "Verification failed. Please try again.");
    } finally {
      hideLoading();
    }
  }

  Future<void> _submitDeliveryRecipientDetails() async {
    try {
      showLoading();
      final token = _sessionService.token;
      if (token != null) {
        final order = selectedOrder.value;
        dynamic rawId = order?['order_id'] ?? order?['id'];
        if (rawId == null && order?['order'] != null) {
          rawId = order?['order']?['id'] ?? order?['order']?['order_id'];
        }
        final String orderId =
            (rawId is num) ? rawId.toInt().toString() : rawId.toString();

        final response = await _shipmentRepository.submitQuickDeliveryDetails(
          orderId: orderId,
          recipientName: fvdRecipientNameController.text.trim(),
          recipientMobile: fvdRecipientPhoneController.text.trim(),
          notes: fvdOtherAddressController.text.trim(),
          orderType: "",
          token: token,
        );

        if (response['success'] == true) {
          if (isCod) {
            currentStep.value = QuickStep.fvdPayment;
          } else {
            currentStep.value = QuickStep.fvdImages;
          }
        } else {
          Get.snackbar("Error",
              response['message'] ?? "Failed to submit recipient details");
        }
      }
    } catch (e) {
      debugPrint("Error submitting delivery details: $e");
      Get.snackbar("Error", "Failed to submit data. Please try again.");
    } finally {
      hideLoading();
    }
  }

  void nextFvdStep() {
    if (currentStep.value == QuickStep.fvdDetails) {
      isFvdScanDone.value = true;
      if (isCod) {
        currentStep.value = QuickStep.fvdOptions;
      } else {
        _sendDeliveryOtp();
      }
    } else if (currentStep.value == QuickStep.fvdScan) {
      if (isFvdScanDone.value) {
        if (isCod) {
          currentStep.value = QuickStep.fvdOptions;
        } else {
          _sendDeliveryOtp();
        }
      }
    } else if (currentStep.value == QuickStep.fvdOtp) {
      if (fvdOtpText.value.length == 4) {
        _verifyDeliveryOtp();
      } else {
        Get.snackbar("Error", "Please enter valid 4-digit OTP");
      }
    } else if (currentStep.value == QuickStep.fvdOptions) {
      if (isFvdOptionsStepValid) {
        if (fvdSelectedRecipient.value == 'customer') {
          final customer = selectedOrder.value?['customer'] ?? {};
          fvdRecipientNameController.text = customer['name']?.toString() ?? "";
          fvdRecipientPhoneController.text =
              customer['mobile']?.toString() ?? "";
          fvdNameText.value = fvdRecipientNameController.text;
          fvdPhoneText.value = fvdRecipientPhoneController.text;
        } else {
          fvdRecipientNameController.clear();
          fvdRecipientPhoneController.clear();
          fvdNameText.value = "";
          fvdPhoneText.value = "";
        }
        currentStep.value = QuickStep.fvdRecipientDetails;
      }
    } else if (currentStep.value == QuickStep.fvdRecipientDetails) {
      if (isFvdRecipientDetailsStepValid) {
        _submitDeliveryRecipientDetails();
      }
    } else if (currentStep.value == QuickStep.fvdPayment) {
      if (isFvdPaymentStepValid) {
        if (fvdSelectedPaymentMethod.value == 'upi') {
          _fetchPaymentQr();
        } else {
          _submitCollectCash();
        }
      }
    } else if (currentStep.value == QuickStep.fvdPaymentDetails) {
      currentStep.value = QuickStep.fvdImages;
    } else if (currentStep.value == QuickStep.fvdImages) {
      if (isFvdImageStepValid) {
        _submitFinalDelivery();
      } else {
        Get.snackbar("Error", "Please take both photos");
      }
    }
  }

  Future<void> _submitCollectCash() async {
    try {
      showLoading();
      final token = _sessionService.token;
      if (token != null) {
        final order = selectedOrder.value;
        dynamic rawId = order?['order_id'] ?? order?['id'];
        if (rawId == null && order?['order'] != null) {
          rawId = order?['order']?['id'] ?? order?['order']?['order_id'];
        }
        final String orderId =
            (rawId is num) ? rawId.toInt().toString() : rawId.toString();

        final response = await _shipmentRepository.collectQuickCash(
          orderId: orderId,
          token: token,
        );

        if (response['success'] == true) {
          Get.snackbar(
              "Success", response['message'] ?? "Cash collected successfully");
          currentStep.value = QuickStep.fvdImages;
        } else {
          Get.snackbar(
              "Error", response['message'] ?? "Failed to collect cash");
        }
      }
    } catch (e) {
      debugPrint("Error collecting cash: $e");
      Get.snackbar("Error", "Failed to process cash collection");
    } finally {
      hideLoading();
    }
  }

  Future<void> _fetchPaymentQr() async {
    try {
      showLoading();
      final token = _sessionService.token;
      if (token != null) {
        final order = selectedOrder.value;
        dynamic rawId = order?['order_id'] ?? order?['id'];
        if (rawId == null && order?['order'] != null) {
          rawId = order?['order']?['id'] ?? order?['order']?['order_id'];
        }
        final String orderId =
            (rawId is num) ? rawId.toInt().toString() : rawId.toString();

        final response = await _shipmentRepository.generateQuickPaymentQr(
          orderId: orderId,
          token: token,
        );

        if (response['success'] == true) {
          fvdPaymentDetails.assignAll(response['data'] ?? {});
          currentStep.value = QuickStep.fvdPaymentDetails;
        } else {
          Get.snackbar("Error", response['message'] ?? "Failed to generate QR");
        }
      }
    } catch (e) {
      debugPrint("Error fetching QR: $e");
      Get.snackbar("Error", "Failed to generate QR. Please try again.");
    } finally {
      hideLoading();
    }
  }

  Future<void> _submitFinalDelivery() async {
    try {
      showLoading();
      final token = _sessionService.token;
      if (token != null) {
        final order = selectedOrder.value;
        dynamic rawId = order?['order_id'] ?? order?['id'];
        if (rawId == null && order?['order'] != null) {
          rawId = order?['order']?['id'] ?? order?['order']?['order_id'];
        }
        final String orderId =
            (rawId is num) ? rawId.toInt().toString() : rawId.toString();

        final response = await _shipmentRepository.uploadQuickDeliveryImages(
          orderId: orderId,
          images: fvdImages.toList(),
          token: token,
        );

        if (response['success'] == true) {
          Get.dialog(
            AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 60),
                  SizedBox(height: 10),
                  Text("Success",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    response['message'] ?? "Delivery completed successfully!",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  // if (isCod) ...[
                  //   const SizedBox(height: 15),
                  //   Text(
                  //     "Delivery Time payment Mode = ${(selectedOrder.value?['order']?['payment_method'] ?? 'COD').toString().toUpperCase()}",
                  //     style: const TextStyle(
                  //       color: Colors.blue,
                  //       fontWeight: FontWeight.bold,
                  //       fontSize: 14,
                  //     ),
                  //   ),
                  // ],
                ],
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      resetState();
                      fetchOrders();
                      if (Get.isRegistered<HomeController>()) {
                        Get.find<HomeController>()
                            .fetchOrders(showLoadingIndicator: false);
                        Get.find<HomeController>().fetchSummary();
                      }
                      Get.offAllNamed(AppRoutes.quickHome);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("OK",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
            barrierDismissible: false,
          );
        } else {
          Get.snackbar(
              "Error", response['message'] ?? "Failed to upload images");
        }
      }
    } catch (e) {
      debugPrint("Error submitting final delivery: $e");
      Get.snackbar("Error", "Failed to complete delivery. Please try again.");
    } finally {
      hideLoading();
    }
  }

  void previousFvdStep() {
    if (currentStep.value == QuickStep.fvdDetails) {
      Get.back();
    } else if (currentStep.value == QuickStep.fvdScan) {
      currentStep.value = QuickStep.fvdDetails;
    } else if (currentStep.value == QuickStep.fvdOtp) {
      currentStep.value = QuickStep.fvdDetails;
    } else if (currentStep.value == QuickStep.fvdOptions) {
      if (isCod) {
        currentStep.value = QuickStep.fvdDetails;
      } else {
        currentStep.value = QuickStep.fvdOtp;
      }
    } else if (currentStep.value == QuickStep.fvdRecipientDetails) {
      currentStep.value = QuickStep.fvdOptions;
    } else if (currentStep.value == QuickStep.fvdPayment) {
      currentStep.value = QuickStep.fvdRecipientDetails;
    } else if (currentStep.value == QuickStep.fvdPaymentDetails) {
      currentStep.value = QuickStep.fvdPayment;
    } else if (currentStep.value == QuickStep.fvdImages) {
      if (isCod) {
        currentStep.value = QuickStep.fvdPaymentDetails;
      } else {
        currentStep.value = QuickStep.fvdRecipientDetails;
      }
    }
  }

  void _applyLocalFilter() {
    if (searchText.value.isEmpty) {
      filteredOrders.assignAll(orders);
    } else {
      final query = searchText.value.toLowerCase();
      final results = orders.where((o) {
        final id = o['tracking_id']?.toString().toLowerCase() ?? "";
        final trackingId = o['id']?.toString().toLowerCase() ?? "";
        final name = (o['vendor']?['name'] ?? "").toString().toLowerCase();
        final customerName =
            (o['customer']?['name'] ?? "").toString().toLowerCase();

        return id.contains(query) ||
            trackingId.contains(query) ||
            name.contains(query) ||
            customerName.contains(query);
      }).toList();
      filteredOrders.assignAll(results);
    }
  }

  Future<void> launchCaller(String? phone) async {
    if (phone == null || phone.isEmpty) {
      Get.snackbar("Error", "Phone number not available");
      return;
    }
    final Uri url = Uri.parse("tel:$phone");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        Get.snackbar("Error", "Could not launch dialer");
      }
    } catch (e) {
      debugPrint("Error launching caller: $e");
    }
  }

  Future<void> launchMap(String? lat, String? long) async {
    if (lat == null || lat.isEmpty || long == null || long.isEmpty) {
      Get.snackbar("Error", "Location coordinates not available");
      return;
    }
    final Uri url =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$long");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar("Error", "Could not launch maps");
      }
    } catch (e) {
      debugPrint("Error launching maps: $e");
    }
  }

  Future<void> sendRtSellerOtp() async {
    try {
      showLoading();
      final orderId = _getOrderId();
      final token = _sessionService.token;
      if (orderId != null && token != null) {
        final response = await _shipmentRepository.sendQuickReturnToSellerOtp(
          orderId: orderId,
          token: token,
        );
        if (response['success'] == true) {
          Get.snackbar(
              "Success", response['message'] ?? "OTP sent successfully");
        } else {
          handleError(response['message'] ?? "Failed to send OTP");
        }
      }
    } catch (e) {
      handleError("Error sending OTP: $e");
    } finally {
      hideLoading();
    }
  }

  Future<void> verifyRtSellerOtp() async {
    try {
      showLoading();
      final orderId = _getOrderId();
      final token = _sessionService.token;
      if (orderId != null && token != null) {
        final response = await _shipmentRepository.verifyQuickReturnToSellerOtp(
          orderId: orderId,
          otp: rtSellerOtpText.value,
          token: token,
        );
        if (response['success'] == true) {
          currentStep.value = QuickStep.markPendingRtSellerOptions;
        } else {
          handleError(response['message'] ?? "Invalid OTP");
        }
      }
    } catch (e) {
      handleError("Error verifying OTP: $e");
    } finally {
      hideLoading();
    }
  }

  Future<void> submitRtSellerDetails() async {
    try {
      showLoading();
      final orderId = _getOrderId();
      final token = _sessionService.token;
      if (orderId != null && token != null) {
        final response =
            await _shipmentRepository.submitQuickReturnToSellerDetails(
          orderId: orderId,
          name: rtSellerNameController.text.trim(),
          mobile: rtSellerMobileController.text.trim(),
          token: token,
        );
        if (response['success'] == true) {
          currentStep.value = QuickStep.markPendingRtSellerImages;
        } else {
          handleError(response['message'] ?? "Failed to save seller details");
        }
      }
    } catch (e) {
      handleError("Error submitting details: $e");
    } finally {
      hideLoading();
    }
  }

  Future<void> uploadRtSellerImages() async {
    try {
      showLoading();
      final orderId = _getOrderId();
      final token = _sessionService.token;
      if (orderId != null && token != null) {
        final photos = rtSellerImages.whereType<File>().toList();
        final response =
            await _shipmentRepository.uploadQuickReturnToSellerImages(
          orderId: orderId,
          photos: photos,
          token: token,
        );
        if (response['success'] == true) {
          _showSuccessDialog(response['message'] ??
              "Return to Seller Flow Completed Successfully");
        } else {
          handleError(response['message'] ?? "Failed to upload images");
        }
      }
    } catch (e) {
      handleError("Error uploading images: $e");
    } finally {
      hideLoading();
    }
  }
}
