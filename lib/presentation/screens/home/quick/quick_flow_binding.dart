import 'package:get/get.dart';
import 'quick_flow_controller.dart';

class QuickFlowBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<QuickFlowController>(QuickFlowController(), permanent: true);
  }
}
