import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:delivery_boy/core/network/api_client.dart';
import 'package:delivery_boy/core/constants/app_constants.dart';
import 'package:delivery_boy/data/repository/auth_repository.dart';
import 'package:delivery_boy/data/repository/profile_repository.dart';
import 'package:delivery_boy/data/repository/shipment_repository.dart';
import 'package:delivery_boy/presentation/controllers/base_controller.dart';
import 'package:delivery_boy/presentation/screens/settings/settings_controller.dart';
import 'package:delivery_boy/presentation/screens/auth/auth_controller.dart';
import 'package:delivery_boy/core/services/session_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.put<SessionService>(SessionService(), permanent: true);

    // Core
    Get.put<http.Client>(http.Client(), permanent: true);
    Get.put<ApiClient>(
      ApiClient(
        baseUrl: AppConstants.baseUrl,
        client: Get.find<http.Client>(),
      ),
      permanent: true,
    );

    // Repositories
    Get.lazyPut<AuthRepository>(
        () => AuthRepository(apiClient: Get.find<ApiClient>()),
        fenix: true);
    Get.lazyPut<ProfileRepository>(
        () => ProfileRepository(apiClient: Get.find<ApiClient>()),
        fenix: true);
    Get.lazyPut<ShipmentRepository>(
        () => ShipmentRepository(apiClient: Get.find<ApiClient>()),
        fenix: true);

    // Controllers
    Get.lazyPut<BaseController>(() => BaseController(), fenix: true);
    Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}
