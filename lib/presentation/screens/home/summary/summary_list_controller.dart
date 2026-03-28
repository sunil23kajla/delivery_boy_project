import 'package:delivery_boy/core/services/session_service.dart';
import 'package:delivery_boy/data/models/order_model.dart';
import 'package:delivery_boy/data/repository/shipment_repository.dart';
import 'package:delivery_boy/presentation/controllers/base_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SummaryDetailController extends BaseController {
  final ShipmentRepository _shipmentRepository = Get.find<ShipmentRepository>();
  final SessionService _sessionService = Get.find<SessionService>();

  final rxIsQuick = false.obs;
  final rxShipment = Rxn<OrderModel>();
  late OrderModel initialShipment;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      initialShipment = args['shipment'] as OrderModel;
      rxIsQuick.value = args['isQuick'] as bool? ?? false;
    } else {
      initialShipment = args as OrderModel;
      rxIsQuick.value = false;
    }
    rxShipment.value = initialShipment;
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    try {
      final orderId = initialShipment.id?.toString();
      if (orderId == null) return;

      showLoading();
      final token = _sessionService.token ?? "";
      final response = rxIsQuick.value
          ? await _shipmentRepository.getQuickOrderDetails(
              orderId: orderId,
              token: token,
            )
          : await _shipmentRepository.getOrderDetails(
              orderId,
              token,
            );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final Map<String, dynamic> flattenedData = {};

        if (data['order'] != null) {
          flattenedData.addAll(data['order'] as Map<String, dynamic>);
        } else {
          // Fallback: if 'order' is missing, assume fields are at the root
          flattenedData.addAll(data as Map<String, dynamic>);
        }

        // Add other root-level objects that OrderModel expects
        if (data['customer'] != null) flattenedData['customer'] = data['customer'];
        if (data['vendor'] != null) flattenedData['vendor'] = data['vendor'];
        if (data['delivery_address'] != null) flattenedData['delivery_address'] = data['delivery_address'];
        if (data['items'] != null) flattenedData['items'] = data['items'];
        if (data['payments'] != null) flattenedData['payments'] = data['payments'];
        
        // Include any other root-level amount fields
        ['total_payable', 'payable_amount', 'grand_total', 'amount', 'total_amount'].forEach((field) {
          if (data[field] != null) flattenedData[field] = data[field];
        });

        rxShipment.value = OrderModel.fromJson(flattenedData);
      }
      hideLoading();
    } catch (e) {
      hideLoading();
      debugPrint("Error fetching summary details: $e");
    }
  }
}

class SummaryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SummaryListController());
    Get.lazyPut(() => SummaryDetailController());
  }
}

class SummaryListController extends BaseController {
  final ShipmentRepository _shipmentRepository = Get.find<ShipmentRepository>();
  final SessionService _sessionService = Get.find<SessionService>();

  final shipments = <OrderModel>[].obs;
  final rxCategory = "".obs;
  final rxStatus = "".obs;
  final rxIsQuick = false.obs;

  String get category => rxCategory.value;
  String get status => rxStatus.value;
  bool get isQuick => rxIsQuick.value;

  // Pagination
  int currentPage = 1;
  int lastPage = 1;
  var isFetchingMore = false.obs;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    rxCategory.value = args['category']?.toString() ?? "ALL";
    rxStatus.value = args['status']?.toString() ?? "DISPATCH";
    rxIsQuick.value = args['isQuick'] as bool? ?? false;

    scrollController.addListener(_scrollListener);
    fetchSummaryList();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoading &&
        !isFetchingMore.value) {
      loadMore();
    }
  }

  Future<void> fetchSummaryList() async {
    try {
      showLoading();
      currentPage = 1;
      final token = _sessionService.token ?? "";

      final response = isQuick
          ? await _shipmentRepository.getQuickOrdersByCount(
              metric: status.toLowerCase(),
              page: currentPage,
              token: token,
            )
          : await _shipmentRepository.getOrdersByCount(
              orderType: category.toLowerCase(),
              page: currentPage,
              token: token,
            );

      if (response['success'] == true && response['data'] != null) {
        final rawData = response['data'];
        List<dynamic> list = [];

        if (rawData is Map) {
          list = rawData['orders'] ?? rawData['data'] ?? [];
          final pagination = rawData['pagination'];
          if (pagination != null) {
            currentPage = pagination['current_page'] ?? 1;
            lastPage = pagination['last_page'] ?? 1;
          }
        } else if (rawData is List) {
          list = rawData;
        }

        shipments.assignAll(isQuick
            ? list.map((e) => OrderModel.fromJson(e)).toList()
            : _filterByStatus(list.map((e) => OrderModel.fromJson(e)).toList()));
      }
      hideLoading();
    } catch (e) {
      hideLoading();
      handleError(e);
    }
  }

  List<OrderModel> _filterByStatus(List<OrderModel> list) {
    if (status.isEmpty ||
        status.toUpperCase() == "TOTAL" ||
        status.toUpperCase() == "COUNT") return list;

    // If the API items don't have ANY order_status, don't filter (fallback)
    final hasAnyStatus = list.any((s) => s.orderStatus != null);
    if (!hasAnyStatus) {
      debugPrint(
          "⚠️ [INFO] No order_status found in API items, skipping client-side filter.");
      return list;
    }

    final targetStatus = status.toUpperCase();
    return list.where((s) {
      final currentStatus = (s.orderStatus ?? '').toUpperCase();
      if (targetStatus == "SUCCESS") {
        return currentStatus == "DELIVERED" || currentStatus == "SUCCESS";
      } else if (targetStatus == "FAILED") {
        return currentStatus == "CANCELLED" ||
            currentStatus == "UNDELIVERED" ||
            currentStatus == "FAILED" ||
            currentStatus == "RETURNED";
      } else if (targetStatus == "DISPATCH") {
        return currentStatus == "DISPATCH" ||
            currentStatus == "SHIPPED" ||
            currentStatus == "OUT_FOR_DELIVERY" ||
            currentStatus == "ASSIGNED" ||
            currentStatus == "READY_FOR_PICKUP";
      }
      return true;
    }).toList();
  }

  Future<void> loadMore() async {
    if (currentPage >= lastPage) return;

    try {
      isFetchingMore.value = true;
      currentPage++;
      final token = _sessionService.token ?? "";

      final response = isQuick
          ? await _shipmentRepository.getQuickOrdersByCount(
              metric: status.toLowerCase(),
              page: currentPage,
              token: token,
            )
          : await _shipmentRepository.getOrdersByCount(
              orderType: category.toLowerCase(),
              page: currentPage,
              token: token,
            );

      if (response['success'] == true && response['data'] != null) {
        final rawData = response['data'];
        List<dynamic> list = [];

        if (rawData is Map) {
          list = rawData['orders'] ?? rawData['data'] ?? [];
          final pagination = rawData['pagination'];
          if (pagination != null) {
            currentPage = pagination['current_page'] ?? currentPage;
            lastPage = pagination['last_page'] ?? lastPage;
          }
        } else if (rawData is List) {
          list = rawData;
        }

        shipments.addAll(isQuick
            ? list.map((e) => OrderModel.fromJson(e)).toList()
            : _filterByStatus(list.map((e) => OrderModel.fromJson(e)).toList()));
      }
      isFetchingMore.value = false;
    } catch (e) {
      isFetchingMore.value = false;
      currentPage--;
      handleError(e);
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
