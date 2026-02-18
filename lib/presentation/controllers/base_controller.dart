import 'package:get/get.dart';

class BaseController extends GetxController {
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  void showLoading() => _isLoading.value = true;
  void hideLoading() => _isLoading.value = false;

  void handleError(dynamic error) {
    hideLoading();
    Get.snackbar('Error', error.toString());
  }
}
