class AppConstants {
  static const String baseUrl = 'https://taksh-admin.takshallinone.in/api';
  static const int connectionTimeout = 30000;

  // Storage Keys
  static const String tokenKey = 'token';

  // API Endpoints
  static const String sendOtpEndpoint = '/delivery-man/send-otp';
  static const String verifyOtpEndpoint = '/delivery-man/verify-otp';
  static const String profileEndpoint = '/delivery-man/profile';
  static const String profilePictureEndpoint = '/delivery-man/profile/picture';
  static const String logoutEndpoint = '/delivery-man/logout';
  static const String updateOrderStatusEndpoint =
      '/delivery/orders/{order_id}/status';
  static const String orderDetailsEndpoint = '/delivery/orders/{id}/details';
  static const String orderDeliverEndpoint = '/delivery/orders/{id}/deliver';
  static const String paymentDetailsEndpoint =
      '/delivery/orders/{id}/payment-details';
  static const String verifyPaymentEndpoint =
      '/delivery/orders/{id}/verify-payment';
  static const String deliveryProofEndpoint =
      '/delivery/orders/{id}/delivery-proof';
  static const String fwdCompleteEndpoint = '/delivery/fwd/complete';
  static const String fwdVerifyQrEndpoint = '/delivery/fwd/verify-qr';
  static const String fwdPaymentReceiveEndpoint =
      '/delivery/fwd/payment/receive';
  static const String fwdPaymentVerifyEndpoint = '/delivery/fwd/payment/verify';
  static const String orderListingEndpoint = '/delivery/orders';
  static const String registrationEndpoint = '/delivery-boy/register';
  static const String undeliveryReasonsEndpoint =
      '/delivery/undelivery-reasons';
  static const String markUndeliveredEndpoint =
      '/delivery/orders/{id}/mark-undelivered';

  // FM Endpoints
  static const String fmQuestionsEndpoint = '/delivery/fm/questions';
  static const String fmAnswersEndpoint = '/delivery/fm/answers';
  static const String fmUploadImagesEndpoint = '/delivery/fm/upload-images';
  static const String fmVerifyQrEndpoint = '/delivery/fm/verify-qr';
  static const String fmCompleteEndpoint = '/delivery/fm/complete';
}
