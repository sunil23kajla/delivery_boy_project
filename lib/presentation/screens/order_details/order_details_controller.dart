import 'package:get/get.dart';
import 'package:delivery_boy/data/repository/shipment_repository.dart';
import 'package:delivery_boy/presentation/controllers/base_controller.dart';
import 'package:delivery_boy/core/services/session_service.dart';

class OrderDetailsController extends BaseController {
  final ShipmentRepository _shipmentRepository = Get.find<ShipmentRepository>();
  final SessionService _sessionService = Get.find<SessionService>();

  final shipment = RxMap<String, dynamic>();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      shipment.addAll(Get.arguments);
    }
  }

  Future<void> markUndelivered() async {
    try {
      showLoading();
      final token = _sessionService.token ?? "placeholder_token";
      await _shipmentRepository.updateOrderStatus(
        orderId: shipment['order_id'].toString(),
        status: "UNDELIVERED",
        token: token,
      );
      hideLoading();
      Get.snackbar('Status Updated', 'Order marked as Undelivered');
    } catch (e) {
      handleError(e);
    }
  }

  void collectPayment() {
    // This will open the QR/Payment modal (UI only for now)
    Get.snackbar('Collect Payment', 'Opening Payment QR Code');
  }
}
