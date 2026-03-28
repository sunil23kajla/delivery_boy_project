import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../../core/error/failure.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository({required this.apiClient});

  Future<Map<String, dynamic>> sendOtp(String mobileNumber) async {
    return await apiClient.postMultipart(
      AppConstants.sendOtpEndpoint,
      fields: {'mobile_number': mobileNumber},
    );
  }

  Future<UserModel> verifyOtp(String mobileNumber, String otp) async {
    final response = await apiClient.postMultipart(
      AppConstants.verifyOtpEndpoint,
      fields: {
        'mobile_number': mobileNumber,
        'otp': otp,
      },
    );

    if (response['success'] == true) {
      return UserModel.fromJson(response['data']);
    } else {
      throw AppException(response['message'] ?? 'Verification Failed');
    }
  }

  Future<void> logout(String token) async {
    await apiClient.post(AppConstants.logoutEndpoint, token: token);
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    return await apiClient.post(
      AppConstants.registrationEndpoint,
      body: data,
    );
  }
}
