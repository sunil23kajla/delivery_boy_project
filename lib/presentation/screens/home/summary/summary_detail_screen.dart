import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';

class SummaryDetailScreen extends StatelessWidget {
  const SummaryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shipment = Get.arguments as Map<String, dynamic>;
    final status = shipment['delivery_status'] ?? 'DISPATCH';

    Color statusColor;
    switch (status) {
      case 'SUCCESS':
        statusColor = Colors.green;
        break;
      case 'FAILED':
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
                  // Order & Tracking ID at the top (plain text as in sketch)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Order ID: ${shipment['order_id']}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("Tracking ID: ${shipment['tracking_id']}",
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(shipment['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: Get.width * 0.5,
                              child: Text(shipment['address'],
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13)),
                            ),
                          ],
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
                    ...(shipment['items'] as List).map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item['name'],
                                  style: const TextStyle(fontSize: 14)),
                              Text("x${item['qty']}",
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

          // Large Pill-Shaped Status Indicator as in Sketch (Static)
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

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color ?? Colors.black)),
        ],
      ),
    );
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
