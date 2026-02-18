import 'package:get/get.dart';
import '../../../core/constants/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToLogin();
  }

  void _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 3));
    Get.offAllNamed(AppRoutes.login);
  }
}
