import 'package:delivery_boy/core/constants/app_routes.dart';
import 'package:delivery_boy/core/services/session_service.dart';
import 'package:delivery_boy/data/models/order_model.dart';
import 'package:delivery_boy/data/repository/shipment_repository.dart';
import 'package:delivery_boy/presentation/controllers/base_controller.dart';
import 'package:get/get.dart';

class OrderDetailsController extends BaseController {
  final ShipmentRepository _shipmentRepository = Get.find<ShipmentRepository>();
  final SessionService _sessionService = Get.find<SessionService>();

  final shipment = Rxn<OrderModel>();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      if (Get.arguments is OrderModel) {
        shipment.value = Get.arguments;
      } else if (Get.arguments is Map<String, dynamic>) {
        shipment.value = OrderModel.fromJson(Get.arguments);
      }
    }
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails({bool showLoadingIndicator = true}) async {
    try {
      final orderId = shipment.value?.id?.toString() ??
          (Get.arguments is Map ? Get.arguments['id']?.toString() : null);
      if (orderId == null) return;

      if (showLoadingIndicator) {
        shipment.value = null; // Clear stale data BEFORE showing loading
        showLoading();
      }
      final token = _sessionService.token ?? "";
      final response =
          await _shipmentRepository.getOrderDetails(orderId, token);

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];

        // The API returns nested objects: { order: {}, customer: {}, delivery_address: {} }
        // We need to flatten this into one map for OrderModel.fromJson
        final Map<String, dynamic> flattenedData = {};

        if (data['order'] != null) {
          flattenedData.addAll(data['order'] as Map<String, dynamic>);
        }
        if (data['customer'] != null) {
          flattenedData['customer'] = data['customer'];
        }
        if (data['vendor'] != null) {
          flattenedData['vendor'] = data['vendor'];
        }
        if (data['delivery_address'] != null) {
          flattenedData['delivery_address'] = data['delivery_address'];
        }
        if (data['items'] != null) {
          flattenedData['items'] = data['items'];
        }
        if (data['payments'] != null) {
          flattenedData['payments'] = data['payments'];
        }

        shipment.value = OrderModel.fromJson(flattenedData);
      }
      hideLoading();
    } catch (e) {
      handleError(e);
    }
  }

  void markUndelivered() {
    if (shipment.value != null) {
      Get.toNamed(AppRoutes.undeliveredProcess, arguments: shipment.value);
    } else {
      Get.snackbar('Error', 'Order details not loaded');
    }
  }

  void collectPayment() {
    if (shipment.value != null) {
      Get.toNamed(AppRoutes.deliveryFlow, arguments: shipment.value);
    } else {
      Get.snackbar('Error', 'Order details not loaded');
    }
  }

  String buildAddressString() {
    final addr = shipment.value?.deliveryAddress;
    if (addr == null) return '';
    final parts = [
      addr.addressLine1,
      addr.addressLine2,
      addr.area?.name,
      addr.city?.name,
      addr.state?.name,
      addr.pincode,
    ].where((e) => e != null && e.toString().isNotEmpty).toList();
    return parts.join(', ');
  }
}
