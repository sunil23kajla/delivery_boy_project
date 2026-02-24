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
}
