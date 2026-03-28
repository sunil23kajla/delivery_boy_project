import 'package:get/get.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/session_service.dart';

class SplashController extends GetxController {
  final SessionService _sessionService = Get.find<SessionService>();

  @override
  void onInit() {
    super.onInit();
    _handleNavigation();
  }

  void _handleNavigation() async {
    await Future.delayed(const Duration(seconds: 3));
    if (_sessionService.isLoggedIn) {
      if (_sessionService.isQuickFlow) {
        Get.offAllNamed(AppRoutes.quickHome);
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
