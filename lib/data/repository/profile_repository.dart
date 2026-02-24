import 'dart:io';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';

class ProfileRepository {
  final ApiClient apiClient;

  ProfileRepository({required this.apiClient});

  Future<UserModel> getProfile(String token) async {
    final response =
        await apiClient.get(AppConstants.profileEndpoint, token: token);
    if (response['success'] == true) {
      return UserModel.fromJson(response['data']);
    } else {
      throw Exception(response['message'] ?? 'Failed to fetch profile');
    }
  }

  Future<UserModel> updateProfilePicture(File image, String token) async {
    final response = await apiClient.postMultipart(
      AppConstants.profilePictureEndpoint,
      fields: {},
      files: {'profile_photo': image},
      token: token,
    );

    if (response['success'] == true) {
      return UserModel.fromJson(response['data']);
    } else {
      throw Exception(response['message'] ?? 'Failed to update picture');
    }
  }
}
