import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';

class ShipmentRepository {
  final ApiClient apiClient;

  ShipmentRepository({required this.apiClient});

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    String? token,
  }) async {
    final endpoint = AppConstants.updateOrderStatusEndpoint
        .replaceAll('{order_id}', orderId);
    await apiClient.post(
      endpoint,
      body: {'status': status},
      token: token,
    );
  }

  Future<Map<String, dynamic>> getOrderDetails(String id, String token) async {
    final endpoint = AppConstants.orderDetailsEndpoint.replaceAll('{id}', id);
    return await apiClient.get(endpoint, token: token);
  }

  Future<Map<String, dynamic>> deliverOrder({
    required String id,
    required String recipientName,
    required String recipientMobile,
    String? notes,
    required String orderType,
    List<File>? photos,
    required String token,
  }) async {
    final endpoint = AppConstants.orderDeliverEndpoint.replaceAll('{id}', id);
    final List<MapEntry<String, File>> files = [];
    if (photos != null) {
      for (var photo in photos) {
        files.add(MapEntry('images[]', photo));
      }
    }
    return await apiClient.postMultipart(
      endpoint,
      fields: {
        'recipient_name': recipientName,
        'recipient_mobile': recipientMobile,
        'notes': notes ?? '',
        'order_type': orderType,
      },
      files: files,
      token: token,
    );
  }

  Future<Map<String, dynamic>> getPaymentDetails(
      String id, String token) async {
    final endpoint = AppConstants.paymentDetailsEndpoint.replaceAll('{id}', id);
    return await apiClient.get(endpoint, token: token);
  }

  Future<Map<String, dynamic>> verifyPayment({
    required String id,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String token,
  }) async {
    final endpoint = AppConstants.verifyPaymentEndpoint.replaceAll('{id}', id);
    return await apiClient.postMultipart(
      endpoint,
      fields: {
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
      },
      token: token,
    );
  }

  Future<Map<String, dynamic>> uploadDeliveryProof({
    required String id,
    required List<File> photos,
    required String token,
  }) async {
    final endpoint = AppConstants.deliveryProofEndpoint.replaceAll('{id}', id);
    final List<MapEntry<String, File>> files = [];
    for (var photo in photos) {
      files.add(MapEntry('photos[]', photo));
    }
    return await apiClient.postMultipart(
      endpoint,
      fields: {},
      files: files,
      token: token,
    );
  }

  Future<Map<String, dynamic>> getOrderListing({
    required int page,
    required String token,
    String? status,
  }) async {
    String endpoint = '${AppConstants.orderListingEndpoint}?page=$page';
    if (status != null && status != 'All') {
      endpoint += '&order_type=${status.toLowerCase()}';
    }
    return await apiClient.get(endpoint, token: token);
  }

  Future<Map<String, dynamic>> getUndeliveryReasons({
    required String token,
  }) async {
    return await apiClient.get(
      AppConstants.undeliveryReasonsEndpoint,
      token: token,
    );
  }

  Future<Map<String, dynamic>> markUndelivered({
    required String orderId,
    required String reason,
    String? notes,
    required String token,
  }) async {
    final endpoint =
        AppConstants.markUndeliveredEndpoint.replaceAll('{id}', orderId);
    return await apiClient.postMultipart(
      endpoint,
      fields: {
        'reason': reason,
        'notes': notes ?? '',
      },
      token: token,
    );
  }

  // --- FM Flow APIs ---

  Future<dynamic> getFmQuestions({required String token}) async {
    return await apiClient.get(
      AppConstants.fmQuestionsEndpoint,
      token: token,
    );
  }

  Future<dynamic> getFmPendingReasons({required String token}) async {
    return await apiClient.get(
      AppConstants.fmPendingReasonsEndpoint,
      token: token,
    );
  }

  Future<dynamic> submitFmAnswers({
    required String orderId,
    required String answersJson,
    required String token,
  }) async {
    return await apiClient.postMultipart(
      AppConstants.fmAnswersEndpoint,
      fields: {
        'order_id': orderId,
        'answers': answersJson,
      },
      token: token,
    );
  }

  Future<dynamic> uploadFmImages({
    required String orderId,
    required List<File> photos,
    required String token,
  }) async {
    final List<MapEntry<String, File>> files = [];
    for (var photo in photos) {
      if (await photo.exists()) {
        files.add(MapEntry('images[]', photo));
      }
    }

    return await apiClient.postMultipart(
      AppConstants.fmUploadImagesEndpoint,
      fields: {'order_id': orderId},
      files: files,
      token: token,
    );
  }

  Future<dynamic> verifyFmQr({
    required String orderId,
    required String qrToken,
    required String token,
  }) async {
    return await apiClient.postMultipart(
      AppConstants.fmVerifyQrEndpoint,
      fields: {
        'order_id': orderId,
        'qr_token': qrToken,
      },
      token: token,
    );
  }

  Future<dynamic> completeFm({
    required String orderId,
    required String token,
  }) async {
    return await apiClient.postMultipart(
      AppConstants.fmCompleteEndpoint,
      fields: {'order_id': orderId},
      token: token,
    );
  }

  Future<dynamic> verifyFmPendingOtp({
    required String orderId,
    required String pendingReasonId,
    String? reasonDescription,
    required String otp,
    required String token,
  }) async {
    const endpoint = AppConstants.fmVerifyOtpEndpoint;
    debugPrint('🚀 [API REQ] POST (Multipart): $endpoint');
    final fields = {
      'order_id': orderId,
      'pending_reason_id': pendingReasonId,
      'reason_description': reasonDescription ?? '',
      'otp': otp,
    };
    debugPrint('Fields: $fields');

    final res = await apiClient.postMultipart(
      endpoint,
      fields: fields,
      token: token,
    );
    debugPrint('✅ [API RES] FM Pending OTP Verify: $res');
    return res;
  }

  Future<dynamic> markFmPending({
    required String orderId,
    required String pendingReasonId,
    String? reasonDescription,
    required String token,
  }) async {
    const endpoint = AppConstants.fmMarkPendingEndpoint;
    debugPrint('🚀 [API REQ] POST (Multipart): $endpoint');
    final fields = {
      'order_id': orderId,
      'pending_reason_id': pendingReasonId,
      'reason_description': reasonDescription ?? '',
    };
    debugPrint('Fields: $fields');

    final res = await apiClient.postMultipart(
      endpoint,
      fields: fields,
      token: token,
    );
    debugPrint('✅ [API RES] FM Mark Pending: $res');
    return res;
  }

  Future<dynamic> completeFwdDelivery({
    required String orderId,
    required String recipientName,
    required String recipientMobile,
    String? notes,
    required List<File> photos,
    required String token,
  }) async {
    final List<MapEntry<String, File>> files = [];
    for (var photo in photos) {
      files.add(MapEntry('images[]', photo));
    }

    return await apiClient.postMultipart(
      AppConstants.fwdCompleteEndpoint,
      fields: {
        'order_id': orderId,
        'recipient_name': recipientName,
        'recipient_mobile': recipientMobile,
        'notes': notes ?? '',
      },
      files: files,
      token: token,
    );
  }

  Future<dynamic> completeRtDelivery({
    required String orderId,
    required String receiverName,
    required String receiverMobile,
    String? deliveryNotes,
    required List<File> photos,
    required String token,
  }) async {
    final List<MapEntry<String, File>> files = [];
    for (var photo in photos) {
      if (await photo.exists()) {
        files.add(MapEntry('photos[]', photo));
      }
    }

    return await apiClient.postMultipart(
      AppConstants.rtCompleteEndpoint,
      fields: {
        'order_id': orderId,
        'receiver_name': receiverName,
        'receiver_mobile': receiverMobile,
        'delivery_notes': deliveryNotes ?? '',
      },
      files: files,
      token: token,
    );
  }

  Future<dynamic> verifyFwdQr({
    required String orderId,
    required String qrToken,
    required String token,
  }) async {
    return await apiClient.postMultipart(
      AppConstants.fwdVerifyQrEndpoint,
      fields: {
        'order_id': orderId,
        'qr_token': qrToken,
      },
      token: token,
    );
  }

  Future<dynamic> receiveFwdPayment({
    required String orderId,
    required String paymentMode,
    required String token,
  }) async {
    return await apiClient.postMultipart(
      AppConstants.fwdPaymentReceiveEndpoint,
      fields: {
        'order_id': orderId,
        'payment_mode': paymentMode, // e.g. 'upi'
      },
      token: token,
    );
  }

  Future<dynamic> verifyFwdPayment({
    required String orderId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String token,
  }) async {
    return await apiClient.postMultipart(
      AppConstants.fwdPaymentVerifyEndpoint,
      fields: {
        'order_id': orderId,
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
      },
      token: token,
    );
  }
  // --- RVP Flow APIs ---

  Future<dynamic> submitRvpChecklist({
    required String returnId,
    required String orderId,
    required String checklistJson,
    String? reasonNotes,
    required String token,
  }) async {
    final endpoint =
        AppConstants.rvpChecklistEndpoint.replaceAll('{id}', returnId);
    return await apiClient.postMultipart(
      endpoint,
      fields: {
        'order_id': orderId,
        'checklist': checklistJson,
        'reason_notes': reasonNotes ?? '',
      },
      token: token,
    );
  }

  Future<dynamic> getRvpCancelReasons({required String token}) async {
    return await apiClient.get(
      AppConstants.rvpCancelReasonsEndpoint,
      token: token,
    );
  }

  Future<dynamic> uploadRvpMedia({
    required String returnId,
    required String orderId,
    required List<File> photos,
    required String token,
  }) async {
    final endpoint = AppConstants.rvpMediaEndpoint.replaceAll('{id}', returnId);
    final url = Uri.parse('${apiClient.baseUrl}$endpoint');

    final request = http.MultipartRequest('POST', url);
    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['User-Agent'] = 'insomnia/11.0.0';

    request.fields['order_id'] = orderId;

    for (var photo in photos) {
      if (await photo.exists()) {
        final file = await http.MultipartFile.fromPath(
          'images[]',
          photo.path,
        );
        request.files.add(file);
      } else {
        debugPrint('❌ File not found: ${photo.path}');
      }
    }

    try {
      debugPrint('🚀 [API REQ] POST (Multipart Manual): $endpoint');
      debugPrint('Fields: ${request.fields}');
      debugPrint(
          'Files: ${request.files.map((e) => "${e.field}: ${e.filename}").toList()}');

      final streamedRes =
          await request.send().timeout(const Duration(seconds: 30));
      final res = await http.Response.fromStream(streamedRes);

      debugPrint('✅ [API RES] ${res.statusCode} | $endpoint');
      debugPrint('[API_RESPONSE] ${res.body}');
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('❌ [API ERR] $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<dynamic> verifyRvpQr({
    required String returnId,
    required String orderId,
    required String qrToken,
    required String token,
  }) async {
    final endpoint =
        AppConstants.rvpVerifyQrEndpoint.replaceAll('{id}', returnId);

    debugPrint('🚀 [API REQ] POST (Multipart): $endpoint');
    final fields = {
      'order_id': orderId,
      'qr_token': qrToken,
    };
    debugPrint('Fields: $fields');

    final res = await apiClient.postMultipart(
      endpoint,
      fields: fields,
      token: token,
    );
    debugPrint('✅ [API RES] RVP QR Verify: $res');
    return res;
  }

  Future<dynamic> getOrderSummary({
    required String token,
  }) async {
    const endpoint = AppConstants.orderSummaryEndpoint;
    debugPrint('🚀 [API REQ] GET: $endpoint');

    final res = await apiClient.get(
      endpoint,
      token: token,
    );
    debugPrint('✅ [API RES] Order Summary: $res');
    return res;
  }

  Future<dynamic> getOrdersByCount({
    required String orderType,
    required int page,
    required String token,
  }) async {
    final endpoint =
        '${AppConstants.orderListByCountEndpoint}?order_type=$orderType&page=$page';
    debugPrint('🚀 [API REQ] GET: $endpoint');

    final res = await apiClient.get(
      endpoint,
      token: token,
    );
    debugPrint('✅ [API RES] Orders by Count ($orderType): $res');
    return res;
  }

  Future<dynamic> completeRvpPickup({
    required String returnId,
    required String orderId,
    required String token,
    String? qrToken,
  }) async {
    final endpoint =
        AppConstants.rvpPickupEndpoint.replaceAll('{id}', returnId);

    debugPrint('🚀 [API REQ] POST (Multipart): $endpoint');
    final fields = {
      'order_id': orderId,
      if (qrToken != null) 'qr_token': qrToken,
    };
    debugPrint('Fields: $fields');

    final res = await apiClient.postMultipart(
      endpoint,
      fields: fields,
      token: token,
    );
    debugPrint('✅ [API RES] RVP Pickup Complete: $res');
    return res;
  }

  Future<dynamic> verifyRvpCancelOtp({
    required String orderId,
    required String otp,
    required String cancelReasonId,
    String? reasonDetails,
    required String token,
  }) async {
    final endpoint =
        AppConstants.rvpCancelVerifyOtpEndpoint.replaceAll('{id}', orderId);
    debugPrint('🚀 [API REQ] POST (Multipart): $endpoint');
    final fields = {
      'order_id': orderId,
      'otp': otp,
      'cancel_reason_id': cancelReasonId,
      'reason_details': reasonDetails ?? '',
    };
    debugPrint('Fields: $fields');

    final res = await apiClient.postMultipart(
      endpoint,
      fields: fields,
      token: token,
    );
    debugPrint('✅ [API RES] RVP Cancel OTP Verify: $res');
    return res;
  }

  Future<dynamic> cancelRvpOrder({
    required String orderId,
    required String cancelReasonId,
    String? reasonDetails,
    required String token,
  }) async {
    final endpoint = AppConstants.rvpCancelEndpoint.replaceAll('{id}', orderId);
    debugPrint('🚀 [API REQ] POST (Multipart): $endpoint');
    final fields = {
      'order_id': orderId,
      'cancel_reason_id': cancelReasonId,
      'reason_details': reasonDetails ?? '',
    };
    debugPrint('Fields: $fields');

    final res = await apiClient.postMultipart(
      endpoint,
      fields: fields,
      token: token,
    );
    debugPrint('✅ [API RES] RVP Order Cancel: $res');
    return res;
  }

  Future<dynamic> verifyRtUndeliveredOtp({
    required String orderId,
    required String otp,
    String? undeliveryReasonId,
    String? reasonDescription,
    required String token,
  }) async {
    const endpoint = AppConstants.rtVerifyUndeliveredOtpEndpoint;
    debugPrint('🚀 [API REQ] POST (Multipart): $endpoint');
    final fields = {
      'order_id': orderId,
      'otp': otp,
      'undelivery_reason_id': undeliveryReasonId ?? '',
      'reason_description': reasonDescription ?? '',
    };
    debugPrint('Fields: $fields');

    final res = await apiClient.postMultipart(
      endpoint,
      fields: fields,
      token: token,
    );
    debugPrint('✅ [API RES] RT Undelivered OTP Verify: $res');
    return res;
  }

  Future<dynamic> verifyRtQr({
    required String orderId,
    required String qrToken,
    required String token,
  }) async {
    const endpoint = AppConstants.rtVerifyQrEndpoint;
    debugPrint('🚀 [API REQ] POST (Multipart): $endpoint');
    final fields = {
      'order_id': orderId,
      'qr_token': qrToken,
    };
    debugPrint('Fields: $fields');

    final res = await apiClient.postMultipart(
      endpoint,
      fields: fields,
      token: token,
    );
    debugPrint('✅ [API RES] RT QR Verify: $res');
    return res;
  }

  Future<dynamic> generatePaymentQr({
    required String orderId,
    required String token,
  }) async {
    final endpoint = AppConstants.generatePaymentQrEndpoint
        .replaceAll('{order_id}', orderId);
    debugPrint('🚀 [API REQ] POST: $endpoint');

    final res = await apiClient.post(
      endpoint,
      token: token,
      body: {}, // Empty body as order_id is in URL
    );
    debugPrint('✅ [API RES] Generate QR: $res');
    return res;
  }

  Future<dynamic> verifyRtOtp({
    required String orderId,
    required String otp,
    required String token,
  }) async {
    const endpoint = AppConstants.rtVerifyOtpEndpoint;
    debugPrint('🚀 [API REQ] POST (Multipart): $endpoint');
    final fields = {
      'order_id': orderId,
      'otp': otp,
    };
    debugPrint('Fields: $fields');

    final res = await apiClient.postMultipart(
      endpoint,
      fields: fields,
      token: token,
    );
    debugPrint('✅ [API RES] RT Delivery OTP Verify: $res');
    return res;
  }

  Future<dynamic> markRtUndelivered({
    required String orderId,
    required String undeliveryReasonId,
    String? reasonDescription,
    required String token,
  }) async {
    const endpoint = AppConstants.rtMarkUndeliveredEndpoint;
    debugPrint('🚀 [API REQ] POST (Multipart): $endpoint');
    final fields = {
      'order_id': orderId,
      'undelivery_reason_id': undeliveryReasonId,
      'reason_description': reasonDescription ?? '',
    };
    debugPrint('Fields: $fields');

    final res = await apiClient.postMultipart(
      endpoint,
      fields: fields,
      token: token,
    );
    debugPrint('✅ [API RES] RT Mark Undelivered: $res');
    return res;
  }

  Future<dynamic> verifyFwdUndeliveredOtp({
    required String orderId,
    required String pendingReasonId,
    String? reasonDescription,
    required String otp,
    required String token,
  }) async {
    const endpoint = AppConstants.fwdVerifyUndeliveredOtpEndpoint;
    debugPrint('🚀 [API REQ] POST (Multipart): $endpoint');
    final fields = {
      'order_id': orderId,
      'pending_reason_id': pendingReasonId,
      'reason_description': reasonDescription ?? '',
      'otp': otp,
    };
    debugPrint('Fields: $fields');

    final res = await apiClient.postMultipart(
      endpoint,
      fields: fields,
      token: token,
    );
    debugPrint('✅ [API RES] FWD Undelivered OTP Verify: $res');
    return res;
  }

  Future<dynamic> verifyFwdQrOtp({
    required String orderId,
    required String mobile,
    required String otp,
    required String token,
  }) async {
    const endpoint = AppConstants.fwdVerifyQrOtpEndpoint;
    debugPrint('🚀 [API REQ] POST (Multipart): $endpoint');
    final fields = {
      'order_id': orderId,
      'mobile': mobile,
      'otp': otp,
    };
    debugPrint('Fields: $fields');

    final res = await apiClient.postMultipart(
      endpoint,
      fields: fields,
      token: token,
    );
    debugPrint('✅ [API RES] FWD QR OTP Verify: $res');
    return res;
  }

  Future<dynamic> getQuickOrders({
    required String token,
    String? search,
    int page = 1,
  }) async {
    String endpoint = '${AppConstants.quickOrdersEndpoint}?page=$page';
    if (search != null && search.isNotEmpty) {
      endpoint += '&search=$search';
    }
    return await apiClient.get(endpoint, token: token);
  }

  Future<dynamic> getQuickOrderDetails({
    required String orderId,
    required String token,
  }) async {
    return await apiClient.post(
      AppConstants.quickOrderDetailsEndpoint,
      body: {'order_id': orderId},
      token: token,
    );
  }

  Future<dynamic> getQuickPickupVerification({
    required String orderId,
    required String token,
  }) async {
    final endpoint =
        '${AppConstants.quickPickupVerificationEndpoint}?order_id=$orderId';
    return await apiClient.get(endpoint, token: token);
  }

  Future<dynamic> submitQuickPickupAnswers({
    required String orderId,
    required String answersJson,
    required String token,
  }) async {
    return await apiClient.postMultipart(
      AppConstants.quickPickupAnswersEndpoint,
      fields: {
        'order_id': orderId,
        'answers': answersJson,
      },
      token: token,
    );
  }

  Future<dynamic> submitQuickPickupPhotos({
    required String orderId,
    required List<File> photos,
    required String token,
  }) async {
    final List<MapEntry<String, File>> files = photos
        .where((f) => f.existsSync())
        .map((f) => MapEntry('photos[]', f))
        .toList();

    return await apiClient.postMultipart(
      AppConstants.quickPickupPhotosEndpoint,
      fields: {'order_id': orderId},
      files: files,
      token: token,
    );
  }

  Future<dynamic> uploadQuickDeliveryImages({
    required String orderId,
    required List<File?> images,
    required String token,
  }) async {
    final Map<String, String> fields = {
      'order_id': orderId,
    };

    final List<MapEntry<String, File>> files = [];
    for (var i = 0; i < images.length; i++) {
      if (images[i] != null) {
        files.add(MapEntry('images[]', images[i]!));
      }
    }

    return await apiClient.postMultipart(
      AppConstants.quickDeliverImagesEndpoint,
      fields: fields,
      files: files,
      token: token,
    );
  }

  Future<dynamic> getQuickCustomerCancelReasons({
    required String token,
  }) async {
    return await apiClient.get(
      AppConstants.quickCustomerCancelReasonsEndpoint,
      token: token,
    );
  }

  Future<dynamic> submitQuickCustomerCancel({
    required String orderId,
    required String cancelReasonId,
    String? reasonDetails,
    required String token,
  }) async {
    return await apiClient.postMultipart(
      AppConstants.quickCustomerCancelEndpoint,
      fields: {
        'order_id': orderId,
        'cancel_reason_id': cancelReasonId,
        'reason_details': reasonDetails ?? '',
      },
      token: token,
    );
  }

  Future<dynamic> sendQuickCustomerCancelOtp({
    required String orderId,
    required String token,
  }) async {
    return await apiClient.postMultipart(
      AppConstants.quickCustomerCancelSendOtpEndpoint,
      fields: {'order_id': orderId},
      token: token,
    );
  }

  Future<dynamic> verifyQuickCustomerCancelOtp({
    required String orderId,
    required String otp,
    required String token,
  }) async {
    return await apiClient.postMultipart(
      AppConstants.quickCustomerCancelVerifyOtpEndpoint,
      fields: {
        'order_id': orderId,
        'otp': otp,
      },
      token: token,
    );
  }

  Future<dynamic> uploadQuickCustomerCancelImages({
    required String orderId,
    required List<File> photos,
    required String token,
  }) async {
    final List<MapEntry<String, File>> files = photos
        .where((f) => f.existsSync())
        .map((f) => MapEntry('images[]', f))
        .toList();

    return await apiClient.postMultipart(
      AppConstants.quickCustomerCancelImagesEndpoint,
      fields: {'order_id': orderId},
      files: files,
      token: token,
    );
  }

  Future<dynamic> getQuickPickupCancelReasons({
    required String orderId,
    required String token,
  }) async {
    final endpoint =
        '${AppConstants.quickPickupCancelReasonsEndpoint}?order_id=$orderId';
    return await apiClient.get(endpoint, token: token);
  }

  Future<dynamic> submitQuickPickupCancel({
    required String orderId,
    required String reasonId,
    String? reasonDetails,
    required String token,
  }) async {
    return await apiClient.post(
      AppConstants.quickPickupCancelEndpoint,
      body: {
        'order_id': orderId,
        'cancel_reason_id': reasonId,
        'reason_details': reasonDetails ?? '',
      },
      token: token,
    );
  }

  Future<dynamic> sendQuickPickupCancelOtp({
    required String orderId,
    required String token,
  }) async {
    return await apiClient.post(
      AppConstants.quickPickupCancelSendOtpEndpoint,
      body: {'order_id': orderId},
      token: token,
    );
  }

  Future<dynamic> verifyQuickPickupCancelOtp({
    required String orderId,
    required String otp,
    required String token,
  }) async {
    return await apiClient.post(
      AppConstants.quickPickupCancelVerifyOtpEndpoint,
      body: {'order_id': orderId, 'otp': otp},
      token: token,
    );
  }

  Future<dynamic> sendQuickDeliverOtp({
    required String orderId,
    required String token,
  }) async {
    return await apiClient.post(
      AppConstants.quickDeliverSendOtpEndpoint,
      body: {'order_id': orderId},
      token: token,
    );
  }

  Future<dynamic> verifyQuickDeliverOtp({
    required String orderId,
    required String otp,
    required String token,
  }) async {
    return await apiClient.post(
      AppConstants.quickDeliverVerifyOtpEndpoint,
      body: {'order_id': orderId, 'otp': otp},
      token: token,
    );
  }

  Future<dynamic> submitQuickDeliveryDetails({
    required String orderId,
    String? recipientName,
    String? recipientMobile,
    String? notes,
    required String orderType,
    required String token,
  }) async {
    final endpoint =
        AppConstants.quickDeliverEndpoint.replaceFirst('{order_id}', orderId);
    return await apiClient.post(
      endpoint,
      body: {
        'recipient_name': recipientName ?? "",
        'recipient_mobile': recipientMobile ?? "",
        'notes': notes ?? "",
        'order_type': orderType,
      },
      token: token,
    );
  }

  Future<dynamic> generateQuickPaymentQr({
    required String orderId,
    required String token,
  }) async {
    final endpoint = AppConstants.generatePaymentQrEndpoint
        .replaceFirst('{order_id}', orderId);
    return await apiClient.post(
      endpoint,
      token: token,
      body: {}, // Empty body as order_id is in URL
    );
  }

  Future<dynamic> collectQuickCash({
    required String orderId,
    required String token,
  }) async {
    return await apiClient.post(
      AppConstants.quickCollectCashEndpoint,
      body: {'order_id': orderId},
      token: token,
    );
  }

  Future<dynamic> verifyQuickPayment({
    required String orderId,
    required String token,
  }) async {
    final endpoint =
        '${AppConstants.quickOrderDetailsEndpoint}?order_id=$orderId';
    return await apiClient.get(
      endpoint,
      token: token,
    );
  }

  Future<dynamic> getQuickOrdersSummary({
    required String token,
  }) async {
    return await apiClient.get(AppConstants.quickOrdersSummaryEndpoint,
        token: token);
  }

  Future<dynamic> getQuickOrdersByCount({
    required String metric,
    int page = 1,
    required String token,
  }) async {
    return await apiClient.get(
      "${AppConstants.quickOrdersListByCountEndpoint}?metric=$metric&page=$page",
      token: token,
    );
  }
}
