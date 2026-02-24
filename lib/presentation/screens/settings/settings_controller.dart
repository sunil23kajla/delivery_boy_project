import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:delivery_boy/presentation/controllers/base_controller.dart';
import 'package:delivery_boy/data/repository/profile_repository.dart';
import 'package:delivery_boy/data/repository/auth_repository.dart';
import 'package:delivery_boy/data/models/user_model.dart';
import 'package:delivery_boy/core/constants/app_strings.dart';
import 'package:delivery_boy/core/constants/app_routes.dart';

import 'package:delivery_boy/core/services/session_service.dart';

class SettingsController extends BaseController {
  final ProfileRepository _profileRepository = Get.find<ProfileRepository>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final SessionService _sessionService = Get.find<SessionService>();
  final ImagePicker _picker = ImagePicker();

  var user = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final token = _sessionService.token;
    if (token == null) return;

    try {
      showLoading();
      user.value = await _profileRepository.getProfile(token);
      hideLoading();
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> updateProfilePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final token = _sessionService.token;
    if (token == null) return;

    try {
      showLoading();
      user.value = await _profileRepository.updateProfilePicture(
          File(image.path), token);
      hideLoading();
      Get.snackbar("Success", "Profile picture updated");
    } catch (e) {
      handleError(e);
    }
  }

  void logout() {
    Get.defaultDialog(
      title: AppStrings.logoutConfirm,
      middleText: AppStrings.logoutMessage,
      textConfirm: AppStrings.yes,
      textCancel: AppStrings.no,
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back(); // Close dialog
        try {
          showLoading();
          final token = _sessionService.token;
          if (token != null) {
            await _authRepository.logout(token);
          }
          _sessionService.clearSession();
          hideLoading();
          Get.offAllNamed(AppRoutes.login);
        } catch (e) {
          // Even if API fails, clear session locally for safety
          _sessionService.clearSession();
          hideLoading();
          Get.offAllNamed(AppRoutes.login);
        }
      },
    );
  }
}
