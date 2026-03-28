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
  static const String orderSummaryEndpoint = '/delivery/orders/summary';
  static const String orderListByCountEndpoint =
      '/delivery/orders/list-by-count';
  static const String orderDeliverEndpoint = '/delivery/orders/{id}/deliver';
  static const String paymentDetailsEndpoint =
      '/delivery/orders/{id}/payment-details';
  static const String verifyPaymentEndpoint =
      '/delivery/orders/{id}/verify-payment';
  static const String deliveryProofEndpoint =
      '/delivery/orders/{id}/delivery-proof';
  static const String generatePaymentQrEndpoint =
      '/delivery/payment/orders/{order_id}/generate-qr';
  static const String fwdCompleteEndpoint = '/delivery/fwd/complete';
  static const String fwdVerifyQrEndpoint = '/delivery/fwd/verify-qr';
  static const String fwdPaymentReceiveEndpoint =
      '/delivery/fwd/payment/receive';
  static const String fwdPaymentVerifyEndpoint = '/delivery/fwd/payment/verify';
  static const String fwdVerifyUndeliveredOtpEndpoint =
      '/delivery/fwd/verify-otp';
  static const String fwdVerifyQrOtpEndpoint = '/delivery/fwd/verify-qr-otp';
  static const String orderListingEndpoint = '/delivery/orders';
  static const String registrationEndpoint = '/delivery-boy/register';
  static const String undeliveryReasonsEndpoint =
      '/delivery/undelivery-reasons';
  static const String markUndeliveredEndpoint =
      '/delivery/orders/{id}/mark-undelivered';
  static const String quickOrdersEndpoint = '/delivery/quick/orders';
  static const String quickOrderDetailsEndpoint = '/delivery/quick/orders/details';
  static const String quickPickupVerificationEndpoint = '/delivery/quick/pickup-verification';
  static const String quickPickupAnswersEndpoint = '/delivery/quick/pickup-verification/answers';
  static const String quickPickupPhotosEndpoint = '/delivery/quick/pickup-verification/photos';
  static const String quickPickupCancelReasonsEndpoint = '/delivery/quick/pickup-cancel-reasons';
  static const String quickPickupCancelEndpoint = '/delivery/quick/pickup-cancel';
  static const String quickPickupCancelSendOtpEndpoint = '/delivery/quick/pickup-cancel/send-otp';
  static const String quickPickupCancelVerifyOtpEndpoint = '/delivery/quick/pickup-cancel/verify-otp';
  static const String quickDeliverSendOtpEndpoint = '/delivery/quick/deliver-to-customer/send-otp';
  static const String quickDeliverVerifyOtpEndpoint = '/delivery/quick/deliver-to-customer/verify-otp';
  static const String quickDeliverEndpoint = '/delivery/orders/{order_id}/deliver';
  static const String quickDeliverImagesEndpoint = '/delivery/quick/deliver-to-customer/upload-images';
  static const String quickCollectCashEndpoint = '/delivery/quick/collect-cash';
  static const String quickCustomerCancelReasonsEndpoint = '/delivery/quick/customer-cancel-reasons';
  static const String quickCustomerCancelEndpoint = '/delivery/quick/customer-cancel';
  static const String quickCustomerCancelSendOtpEndpoint = '/delivery/quick/customer-cancel/send-otp';
  static const String quickCustomerCancelVerifyOtpEndpoint = '/delivery/quick/customer-cancel/verify-otp';
  static const String quickCustomerCancelImagesEndpoint = '/delivery/quick/customer-cancel/upload-images';
  static const String quickOrdersSummaryEndpoint = '/delivery/quick/orders/summary';
  static const String quickOrdersListByCountEndpoint = '/delivery/quick/orders/list-by-count';

  // FM Endpoints
  static const String fmQuestionsEndpoint = '/delivery/fm/questions';
  static const String fmPendingReasonsEndpoint = '/delivery/fm/pending-reasons';
  static const String fmAnswersEndpoint = '/delivery/fm/answers';
  static const String fmUploadImagesEndpoint = '/delivery/fm/upload-images';
  static const String fmVerifyQrEndpoint = '/delivery/fm/verify-qr';
  static const String fmCompleteEndpoint = '/delivery/fm/complete';
  static const String fmVerifyOtpEndpoint = '/delivery/fm/verify-otp';
  static const String fmMarkPendingEndpoint = '/delivery/fm/mark-pending';

  // RVP Endpoints
  static const String rvpChecklistEndpoint =
      '/delivery/rvp/returns/{id}/checklist';
  static const String rvpCancelReasonsEndpoint = '/delivery/rvp/cancel-reasons';
  static const String rvpMediaEndpoint = '/delivery/rvp/returns/{id}/media';
  static const String rvpVerifyQrEndpoint =
      '/delivery/rvp/returns/{id}/verify-qr';
  static const String rvpPickupEndpoint =
      '/delivery/rvp/returns/{id}/picked-up';
  static const String rvpCancelVerifyOtpEndpoint =
      '/delivery/rvp/orders/{id}/cancel/verify-otp';
  static const String rvpCancelEndpoint = '/delivery/rvp/orders/{id}/cancel';
  static const String rtCompleteEndpoint = '/delivery/rt/complete';
  static const String rtVerifyUndeliveredOtpEndpoint =
      '/delivery/rt/verify-undelivered-otp';
  static const String rtVerifyQrEndpoint = '/delivery/rt/verify-qr';
  static const String rtVerifyOtpEndpoint = '/delivery/rt/verify-otp';
  static const String rtMarkUndeliveredEndpoint =
      '/delivery/rt/mark-undelivered';
}
