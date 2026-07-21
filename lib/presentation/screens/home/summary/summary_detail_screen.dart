import 'package:delivery_boy/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';
import 'package:delivery_boy/data/models/order_model.dart';
import './summary_list_controller.dart';
import '../../../../core/utils/external_actions.dart';

class SummaryDetailScreen extends GetView<SummaryDetailController> {
  const SummaryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    return Obx(() {
      final shipment =
          controller.rxShipment.value ?? controller.initialShipment;

      final uiOrderType = (shipment.orderType ?? '').toUpperCase();
      final category = ['RVP', 'REVERSE', 'REVERSE_PICKUP'].contains(uiOrderType)
          ? 'RVP'
          : ['RT', 'RETURN'].contains(uiOrderType)
              ? 'RT'
              : ['FM', 'FIRST_MILE', 'FIRSTMILE'].contains(uiOrderType)
                  ? 'FM'
                  : ['NORMAL', 'FWD', 'FORWARD'].contains(uiOrderType)
                      ? 'FWD'
                      : (uiOrderType.isNotEmpty ? uiOrderType : 'FWD');

      final baseStatus = controller.listStatus ?? shipment.orderStatus?.toUpperCase() ?? 'DISPATCH';
      final displayStatus = '$category - $baseStatus';

      Color statusColor;
      switch (baseStatus) {
        case 'SUCCESS':
        case 'DELIVERED':
          statusColor = Colors.green;
          break;
        case 'FAILED':
        case 'CANCELLED':
        case 'RETURNED':
          statusColor = Colors.red;
          break;
        default:
          statusColor = AppColors.primary;
      }

      return Scaffold(
        backgroundColor: Colors.grey[50], // MATCHING order_details_screen.dart
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            "Order Details",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderHeader(shipment, statusColor, displayStatus),
                    const SizedBox(height: 10),
                    
                    if (controller.rxIsQuick.value && shipment.vendor != null) ...[
                      _buildSectionTitle('Pickup Location'),
                      const SizedBox(height: 5),
                      _buildVendorCard(shipment.vendor!),
                      const SizedBox(height: 12),
                    ],

                    _buildSectionTitle('Customer Info'),
                    const SizedBox(height: 5),
                    _buildCustomerCard(shipment),
                    const SizedBox(height: 12),
                    
                    _buildSectionTitle('Order Items'),
                    const SizedBox(height: 5),
                    if (shipment.items == null || shipment.items!.isEmpty)
                      const Center(child: Text("No products found for this order"))
                    else
                      ...(shipment.items ?? []).map((item) => _buildItemCard(item)),
                    const SizedBox(height: 12),

                    _buildSectionTitle('Payment Details'),
                    const SizedBox(height: 5),
                    _buildPaymentSummary(shipment),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            if (['FAILED', 'CANCELLED', 'UNDELIVERED', 'DISPATCH', 'PENDING'].contains(controller.listStatus))
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final cat = ['RVP', 'REVERSE', 'REVERSE_PICKUP'].contains(uiOrderType)
                          ? 'RVP'
                          : ['RT', 'RETURN'].contains(uiOrderType)
                              ? 'RT'
                              : ['FM', 'FIRST_MILE', 'FIRSTMILE'].contains(uiOrderType)
                                  ? 'FM'
                                  : 'FWD';
                      
                      switch (cat) {
                        case 'RVP':
                          Get.toNamed(AppRoutes.rvpFlow, arguments: shipment);
                          break;
                        case 'RT':
                          Get.toNamed(AppRoutes.rtFlow, arguments: shipment);
                          break;
                        case 'FM':
                          Get.toNamed(AppRoutes.fmFlow, arguments: shipment);
                          break;
                        case 'FWD':
                        default:
                          Get.toNamed(AppRoutes.orderDetails, arguments: shipment);
                          break;
                      }
                    },
                    child: const Text(
                      "UPDATE STATUS",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildOrderHeader(OrderModel shipment, Color statusColor, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order ID: #${shipment.id ?? "-"}',
                style: const TextStyle(
                    color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                'Tracking ID: ${shipment.orderNumber ?? "-"}',
                style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.2)),
            ),
            child: Text(
              status,
              style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(OrderModel shipment) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.person_outline, shipment.customer?.name ?? '-'),
          const Divider(height: 25),
          _buildInfoRow(Icons.phone_outlined, shipment.customer?.mobile ?? '-'),
          const Divider(height: 25),
          _buildInfoRow(
              Icons.location_on_outlined, _buildAddressString(shipment),
              maxLines: 2),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionChip(
                icon: Icons.phone,
                label: 'Call',
                color: Colors.green,
                onTap: () =>
                    ExternalActions.makeCall(shipment.customer?.mobile ?? ''),
              ),
              _ActionChip(
                icon: Icons.navigation_outlined,
                label: 'Navigate',
                color: Colors.blue,
                onTap: () => ExternalActions.openMap(
                  shipment.deliveryAddress?.latitude ?? 0.0,
                  shipment.deliveryAddress?.longitude ?? 0.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVendorCard(VendorModel vendor) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.storefront_outlined, vendor.shopName ?? vendor.vendorName ?? 'Pickup Location'),
          const Divider(height: 25),
          _buildInfoRow(Icons.phone_outlined, vendor.mobileNumber ?? '-'),
        ],
      ),
    );
  }

  Widget _buildItemCard(OrderItemModel item) {
    final imageUrl =
        (item.productImages != null && item.productImages!.isNotEmpty)
            ? item.productImages![0].imageUrl
            : null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(imageUrl,
                    width: 50, height: 50, fit: BoxFit.cover)
                : Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName ?? 'Product',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Qty: ${item.quantity ?? 1}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(OrderModel shipment) {
    final isCod = (shipment.paymentMethod?.toLowerCase() == 'cod');
    double totalAmount = shipment.totalPayable ?? shipment.totalAmount ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildSummaryRow(
                'Payment Mode =',
                isCod ? 'COD' : 'Prepaid',
              ),
              _buildSummaryRow(
                'Order Amount =',
                isCod ? '₹ $totalAmount' : 'Paid',
              ),
              if (shipment.deliveryTimePaymentMode != null && shipment.deliveryTimePaymentMode!.isNotEmpty)
                _buildSummaryRow(
                  'Delivery time payment mode =',
                  shipment.deliveryTimePaymentMode!.toUpperCase(),
                  valueColor: Colors.black87,
                ),
              if (controller.listStatus == 'FAILED' || controller.listStatus == 'CANCELLED' || controller.listStatus == 'UNDELIVERED') ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, thickness: 0.5),
                ),
                _buildSummaryRow(
                  'Cancel Reason =',
                  shipment.cancelReason ?? 'Not Available',
                  valueColor: Colors.red,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _buildAddressString(OrderModel shipment) {
    final addr = shipment.deliveryAddress;
    if (addr == null) return 'Address not available';
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildInfoRow(IconData icon, String value, {int maxLines = 1}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {Color valueColor = Colors.black87,
      bool isBold = false,
      double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
