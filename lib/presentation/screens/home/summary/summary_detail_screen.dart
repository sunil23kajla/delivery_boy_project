import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';
import 'package:delivery_boy/data/models/order_model.dart';

class SummaryDetailScreen extends StatelessWidget {
  const SummaryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shipment = Get.arguments as OrderModel;
    final status = (shipment.orderStatus ?? 'DISPATCH').toUpperCase();

    Color statusColor;
    switch (status) {
      case 'SUCCESS':
      case 'DELIVERED':
        statusColor = Colors.green;
        break;
      case 'FAILED':
      case 'CANCELLED':
        statusColor = Colors.red;
        break;
      default:
        statusColor = AppColors.primary;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Shipment Details",
          style: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order & Tracking ID
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Order ID: ${shipment.id ?? '-'}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("Tracking ID: ${shipment.orderNumber ?? '-'}",
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 14)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Customer Detail Card
                  _buildSectionCard([
                    Row(
                      children: [
                        const Icon(Icons.person,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(shipment.customer?.name ?? 'Customer',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1),
                              const SizedBox(height: 4),
                              Text(_buildAddressString(shipment),
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2),
                            ],
                          ),
                        ),
                        const Spacer(),
                        _IconButton(
                            icon: Icons.phone,
                            color: Colors.green,
                            onTap: () {}),
                        const SizedBox(width: 8),
                        _IconButton(
                            icon: Icons.navigation_outlined,
                            color: Colors.blue,
                            onTap: () {}),
                      ],
                    ),
                  ]),

                  const SizedBox(height: 15),

                  // Product Detail Card
                  _buildSectionCard([
                    const Text("CONTENT",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                            fontSize: 12)),
                    const SizedBox(height: 10),
                    ...(shipment.items ?? []).map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item.productName ?? 'Product',
                                  style: const TextStyle(fontSize: 14)),
                              Text("x${item.quantity ?? 1}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )),
                  ]),
                ],
              ),
            ),
          ),

          // Status Indicator
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: statusColor, width: 2),
              ),
              child: Center(
                child: Text(
                  status,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
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
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconButton(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
