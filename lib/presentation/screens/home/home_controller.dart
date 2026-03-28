import 'package:delivery_boy/core/services/session_service.dart';
import 'package:delivery_boy/data/models/order_model.dart';
import 'package:delivery_boy/data/repository/shipment_repository.dart';
import 'package:delivery_boy/presentation/controllers/base_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends BaseController {
  final ShipmentRepository _shipmentRepository = Get.find<ShipmentRepository>();
  final SessionService _sessionService = Get.find<SessionService>();

  final rxIndex = 0.obs;
  final rxSelectedFilter = 'All'.obs;
  final rxSearchText = ''.obs;
  final rxDeliveryManName = ''.obs;
  final shipments = <OrderModel>[].obs;

  // Pagination fields
  int currentPage = 1;
  int lastPage = 1;
  var isFetchingMore = false.obs;
  final ScrollController scrollController = ScrollController();

  // Static tab counts to preserve them when filtering from backend
  final tabCountAll = 0.obs;
  final tabCountFwd = 0.obs;
  final tabCountRvp = 0.obs;
  final tabCountRt = 0.obs;
  final tabCountFm = 0.obs;

  // Dashboard Counts
  final rxTotalCount = 0.obs;
  final rxDeliveredCount = 0.obs;
  final rxPendingCount = 0.obs;

  // Summary State
  final orderSummaryData = <String, dynamic>{}.obs;
  final totalCollection = "0.00".obs;
  final cashValue = "0.00".obs;
  final onlineValue = "0.00".obs;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    fetchOrders();
    fetchSummary();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoading &&
        !isFetchingMore.value) {
      loadMoreOrders();
    }
  }

  void changeTabIndex(int index) {
    rxIndex.value = index;
    if (index == 0) {
      fetchOrders(showLoadingIndicator: false);
    } else {
      fetchSummary();
    }
  }

  Future<void> fetchOrders({bool showLoadingIndicator = true}) async {
    try {
      currentPage = 1;
      if (showLoadingIndicator) {
        shipments.clear();
        showLoading();
      }
      final token = _sessionService.token ?? "";
      final response = await _shipmentRepository.getOrderListing(
        page: currentPage,
        token: token,
        status: rxSelectedFilter.value,
      );

      if (response['success'] == false) {
        if (showLoadingIndicator) hideLoading();
        handleError(response['message'] ?? "Failed to fetch orders");
        return;
      }

      if (response['success'] == true && response['data'] != null) {
        final rawData = response['data'];
        List<dynamic> orderList = [];

        if (rawData is Map) {
          // Parse delivery man name
          if (rawData['delivery_man'] != null) {
            rxDeliveryManName.value = rawData['delivery_man']['name'] ?? '';
          }

          // Parse dashboard counts with robust fallback keys
          rxTotalCount.value = rawData['total_orders'] ??
              rawData['total'] ??
              response['total_orders'] ??
              response['total'] ??
              0;
          rxDeliveredCount.value = rawData['delivered_orders'] ??
              rawData['delivered'] ??
              response['delivered_orders'] ??
              response['delivered'] ??
              0;
          rxPendingCount.value = rawData['pending_orders'] ??
              rawData['pending'] ??
              response['pending_orders'] ??
              response['pending'] ??
              0;

          // Nested under 'orders' key (actual API format)
          if (rawData['orders'] != null) {
            orderList = rawData['orders'] is List ? rawData['orders'] : [];
          } else if (rawData['data'] != null) {
            orderList = rawData['data'] is List ? rawData['data'] : [];
          }
        } else if (rawData is List) {
          orderList = rawData;
        }

        if (rawData is Map && rawData['pagination'] != null) {
          currentPage = rawData['pagination']['current_page'] ?? 1;
          lastPage = rawData['pagination']['last_page'] ?? 1;

          final apiTotal = rawData['pagination']['total'] ?? 0;
          if (apiTotal > 0 && rxSelectedFilter.value == 'All') {
            rxTotalCount.value = apiTotal;
          }
        }

        shipments
            .assignAll(orderList.map((e) => OrderModel.fromJson(e)).toList());

        // Update dashboard counts from order_type_counts if available
        if (rawData['order_type_counts'] != null) {
          final counts = rawData['order_type_counts'];
          rxTotalCount.value = counts['all'] ?? counts['total'] ?? 0;
          rxDeliveredCount.value = counts['delivered'] ?? 0;
          // Calculate pending if not provided, ensuring it's never negative (v1.9.4)
          final total = rxTotalCount.value;
          final delivered = rxDeliveredCount.value;
          rxPendingCount.value =
              (total - delivered) < 0 ? 0 : (total - delivered);
        } else {
          // Robust fallback keys
          rxTotalCount.value = rawData['total_orders'] ??
              rawData['total'] ??
              response['total_orders'] ??
              response['total'] ??
              0;
          rxDeliveredCount.value = rawData['delivered_orders'] ??
              rawData['delivered'] ??
              response['delivered_orders'] ??
              response['delivered'] ??
              0;
          rxPendingCount.value = rawData['pending_orders'] ??
              rawData['pending'] ??
              response['pending_orders'] ??
              response['pending'] ??
              0;
        }

        // Update tab counts only when we fetch 'All' data, so they are preserved
        if (rxSelectedFilter.value == 'All') {
          tabCountAll.value = rxTotalCount.value;
          tabCountFwd.value = shipments
              .where((s) => ['FWD', 'NORMAL', 'FORWARD']
                  .contains((s.orderType ?? '').toUpperCase()))
              .length;
          tabCountRvp.value = shipments
              .where((s) => ['RVP', 'REVERSE', 'REVERSE_PICKUP']
                  .contains((s.orderType ?? '').toUpperCase()))
              .length;
          tabCountRt.value = shipments
              .where((s) =>
                  ['RT', 'RETURN'].contains((s.orderType ?? '').toUpperCase()))
              .length;
          tabCountFm.value = shipments
              .where((s) => ['FM', 'FIRST_MILE', 'FIRSTMILE']
                  .contains((s.orderType ?? '').toUpperCase()))
              .length;
        }

        // Fallback: If counts are still 0 but we have shipments, calculate from list
        if (rxTotalCount.value == 0 && tabCountAll.value > 0) {
          rxTotalCount.value = tabCountAll.value;
        }
        if (rxPendingCount.value == 0 && tabCountAll.value > 0) {
          rxPendingCount.value = tabCountAll.value;
        }
      }
      if (showLoadingIndicator) hideLoading();
    } catch (e) {
      if (showLoadingIndicator) hideLoading();
      handleError(e);
    }
  }

  Future<void> fetchSummary() async {
    try {
      final token = _sessionService.token ?? "";
      final response = await _shipmentRepository.getOrderSummary(token: token);

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        if (data['order_type_wise'] != null) {
          orderSummaryData.assignAll(data['order_type_wise']);
        }
        totalCollection.value = (data['total_collection_amount'] ?? 0).toString();
        cashValue.value = (data['cash_value'] ?? 0).toString();
        onlineValue.value = (data['online_value'] ?? 0).toString();
      }
    } catch (e) {
      debugPrint("Error fetching summary: $e");
    }
  }

  Future<void> loadMoreOrders() async {
    if (currentPage >= lastPage) return; // Reached the end

    try {
      isFetchingMore.value = true;
      currentPage++;
      final token = _sessionService.token ?? "";

      final response = await _shipmentRepository.getOrderListing(
        page: currentPage,
        token: token,
        status: rxSelectedFilter.value,
      );

      if (response['success'] == false) {
        isFetchingMore.value = false;
        currentPage--;
        handleError(response['message'] ?? "Failed to load more orders");
        return;
      }

      if (response['success'] == true && response['data'] != null) {
        final rawData = response['data'];
        List<dynamic> orderList = [];

        if (rawData is Map) {
          if (rawData['orders'] != null) {
            orderList = rawData['orders'] is List ? rawData['orders'] : [];
          } else if (rawData['data'] != null) {
            orderList = rawData['data'] is List ? rawData['data'] : [];
          }

          if (rawData['pagination'] != null) {
            currentPage = rawData['pagination']['current_page'] ?? currentPage;
            lastPage = rawData['pagination']['last_page'] ?? lastPage;
          }
        } else if (rawData is List) {
          orderList = rawData;
        }

        final newOrders = orderList.map((e) => OrderModel.fromJson(e)).toList();
        shipments.addAll(newOrders);
      }
      isFetchingMore.value = false;
    } catch (e) {
      isFetchingMore.value = false;
      currentPage--; // Rollback page count on error
      handleError(e);
    }
  }


  void selectFilter(String filter) {
    if (rxSelectedFilter.value != filter) {
      rxSelectedFilter.value = filter;
      fetchOrders();
    }
  }

  String resolveCategory(OrderModel shipment) {
    final type = (shipment.orderType ?? '').toLowerCase();
    switch (type) {
      case 'rvp':
      case 'reverse':
      case 'reverse_pickup':
        return 'RVP'; // Fallback if type is filled but object is missing
      case 'rt':
      case 'return':
        return 'RT';
      case 'fm':
      case 'first_mile':
      case 'firstmile':
        return 'FM';
      case 'normal':
      case 'fwd':
      case 'forward':
      default:
        // Try to identify from raw string if not matching anything above
        return type.isNotEmpty ? type.toUpperCase() : 'FWD';
    }
  }

  List<OrderModel> get filteredShipments {
    List<OrderModel> list = shipments.toList();

    // Filter by search text (name or tracking_id)
    if (rxSearchText.value.isNotEmpty) {
      final query = rxSearchText.value.toLowerCase();
      list = list.where((s) {
        final name = (s.customer?.name ?? '').toLowerCase();
        final trackingId = (s.orderNumber ?? '').toLowerCase();
        return name.contains(query) || trackingId.contains(query);
      }).toList();
    }

    return list;
  }

  int getCount(String status) {
    if (tabCountAll.value == 0 &&
        rxSelectedFilter.value == 'All' &&
        !isLoading) {
      // Fallback before first 'All' is fully parsed
      if (status == 'All') return shipments.length;
      return shipments.where((s) => resolveCategory(s) == status).length;
    }

    switch (status) {
      case 'All':
        return tabCountAll.value;
      case 'FWD':
        return tabCountFwd.value;
      case 'RVP':
        return tabCountRvp.value;
      case 'RT':
        return tabCountRt.value;
      case 'FM':
        return tabCountFm.value;
      default:
        return 0;
    }
  }

  // --- Summary Flow Methods ---

  int getSummaryCount(String category, String status) {
    if (orderSummaryData.isEmpty) return 0;

    final catData = orderSummaryData[category.toLowerCase()];
    if (catData == null) return 0;

    switch (status.toUpperCase()) {
      case "DISPATCH":
        return catData['dispatch'] ?? 0;
      case "SUCCESS":
        return catData['success'] ?? 0;
      case "FAILED":
        return catData['failed'] ?? 0;
      default:
        return 0;
    }
  }

  List<OrderModel> getSummaryList(String category, String status) {
    return shipments.where((s) {
      final matchesCategory =
          (category == "ALL") || (resolveCategory(s) == category);
      final currentStatus = (s.orderStatus ?? '').toUpperCase();

      bool matchesStatus = false;
      if (status == "DISPATCH") {
        matchesStatus = currentStatus == "DISPATCH" ||
            currentStatus == "SHIPPED" ||
            currentStatus == "OUT_FOR_DELIVERY" ||
            currentStatus == "ASSIGNED" ||
            currentStatus == "READY_FOR_PICKUP";
      } else if (status == "SUCCESS") {
        matchesStatus = currentStatus == "DELIVERED";
      } else if (status == "FAILED") {
        matchesStatus = currentStatus == "CANCELLED" ||
            currentStatus == "UNDELIVERED" ||
            currentStatus == "RETURNED";
      }

      return matchesCategory && matchesStatus;
    }).toList();
  }

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    // We defer actual .dispose() to avoid Flutter's
    // "ScrollController used after being disposed"
    // error when rapidly navigating away from Home.
    super.onClose();
  }
}
