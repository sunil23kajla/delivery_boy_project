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
    required String token,
  }) async {
    final endpoint = AppConstants.orderDeliverEndpoint.replaceAll('{id}', id);
    return await apiClient.postMultipart(
      endpoint,
      fields: {
        'recipient_name': recipientName,
        'recipient_mobile': recipientMobile,
        'notes': notes ?? '',
      },
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
      files.add(MapEntry('images[]', photo));
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
    required String qrCode,
    required String token,
  }) async {
    return await apiClient.postMultipart(
      AppConstants.fmVerifyQrEndpoint,
      fields: {
        'order_id': orderId,
        'qr_code': qrCode,
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
}
