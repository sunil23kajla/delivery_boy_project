import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';

class ShipmentRepository {
  final ApiClient apiClient;

  ShipmentRepository({required this.apiClient});

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    String? token,
  }) async {
    final endpoint = AppConstants.updateOrderStatusEndpoint
        .replaceAll('{order_id}', orderId);
    await apiClient.post(
      endpoint,
      body: {'status': status},
      token: token,
    );
  }
}
