import 'package:get/get.dart';
import '../controllers/base_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BaseController());
    // Add other persistent dependencies here
  }
}
