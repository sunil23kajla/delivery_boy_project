import 'package:get/get.dart';

class OrderDetailsController extends GetxController {
  final shipment = RxMap<String, dynamic>();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      shipment.addAll(Get.arguments);
    }
  }

  void markUndelivered() {
    Get.snackbar('Status Updated', 'Order marked as Undelivered');
  }

  void collectPayment() {
    // This will open the QR/Payment modal
    Get.snackbar('Collect Payment', 'Opening Payment QR Code');
  }
}
