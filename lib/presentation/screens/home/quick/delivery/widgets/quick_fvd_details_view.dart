import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:delivery_boy/presentation/screens/home/quick/quick_flow_controller.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class QuickFvdDetailsView extends GetView<QuickFlowController> {
  const QuickFvdDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Obx(() {
      final data = controller.selectedOrder.value;
      if (data == null) return const Center(child: Text("Order not found"));

      final order = data['order'] as Map<String, dynamic>? ?? data ?? {};
      final customer = data['customer'] as Map<String, dynamic>? ?? {};
      final items = (data['items'] ?? order['items']) as List<dynamic>? ?? [];
      final payment = (data['payments'] is List && (data['payments'] as List).isNotEmpty)
          ? (data['payments'] as List)[0] as Map<String, dynamic>
          : (data['payment'] as Map<String, dynamic>? ?? {});

      // Robust address extraction (same as QuickDetailsScreen)
      final addressMap = (data['delivery_address'] ?? order['delivery_address']) as Map<String, dynamic>? ?? {};
      String displayAddress = addressMap['address_line1'] ?? addressMap['address'] ?? '';
      if (displayAddress.isEmpty && addressMap['landmark'] != null) {
        displayAddress = addressMap['landmark'];
        if (addressMap['area'] != null && addressMap['area']['name'] != null) {
          displayAddress += ", ${addressMap['area']['name']}";
        }
      }
      if (displayAddress.isEmpty) displayAddress = '-';

      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIdCard(order),
                  const SizedBox(height: 8),
                  _buildAddressCard(
                    title: "CUSTOMER DETAILS",
                    name: customer['name']?.toString() ?? '-',
                    address: displayAddress,
                    mobile: customer['mobile']?.toString() ?? '-',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Order Items'),
                  const SizedBox(height: 8),
                  if (items.isEmpty)
                    _buildItemCard({
                      'product_name': 'Sample Product (Static)',
                      'qty': 1,
                      'price': order['total_amount'] ?? '500.00'
                    })
                  else
                    ...items.map((item) => _buildItemCard(item)),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Payment Details'),
                  const SizedBox(height: 8),
                  _buildPaymentSummary(order, payment),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Bottom Bar Actions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5))
            ]),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        controller.goToMarkPending(isPickup: false),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: const Text("MARK UNDELIVERED",
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.nextFvdStep(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: const Text("DELIVERED",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildIdCard(Map<String, dynamic> order) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          _buildDetailRow(
              "Tracking ID", order['order_number']?.toString() ?? "-",
              isBold: true),
          const Divider(height: 24),
          _buildDetailRow("Order ID", (order['order_id'] ?? order['id'] ?? "-").toString()),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isValueBold = false,
      Color? labelColor,
      Color? valueColor,
      bool isBold = false}) {
    final finalValueBold = isValueBold || isBold;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              color: labelColor ?? Colors.black54,
              fontSize: 13,
            )),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: finalValueBold ? FontWeight.bold : FontWeight.w600,
                color: valueColor ?? Colors.black,
                fontSize: 13,
              )),
        ),
      ],
    );
  }

  Widget _buildAddressCard({
    required String title,
    required String name,
    required String address,
    required String mobile,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          Text(name,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(address, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 16),
          Row(
            children: [
              _ActionButton(
                icon: Icons.call,
                label: "Call",
                color: Colors.green,
                onTap: () => launchUrl(Uri.parse("tel:$mobile")),
              ),
              const SizedBox(width: 12),
              _ActionButton(
                icon: Icons.location_on,
                label: "Map",
                color: Colors.blue,
                onTap: () => launchUrl(Uri.parse(
                    "https://www.google.com/maps/search/?api=1&query=$address")),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildItemCard(dynamic item) {
    // API uses 'product_images' and 'quantity' and 'unit_price'
    final images = (item['product_images'] ?? item['images']) as List<dynamic>? ?? [];
    final imageUrl = images.isNotEmpty ? images[0]['image_url'] : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 50,
              height: 50,
              color: Colors.grey[200],
              child: imageUrl != null
                  ? Image.network(imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image, color: Colors.grey))
                  : const Icon(Icons.image, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['product_name']?.toString() ?? 'Product',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text('Qty: ${item['quantity'] ?? item['qty'] ?? 1}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Text('₹ ${item['unit_price'] ?? item['price'] ?? item['item_total'] ?? 0.0}',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(
      Map<String, dynamic> order, Map<String, dynamic> payment) {
    // Use controller's robust isCod logic
    final isCod = controller.isCod;
    
    String mode = isCod ? "COD" : "ONLINE";
    String status = isCod ? "PENDING" : "PAID";

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border:
            Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            'Payment Mode',
            mode.toUpperCase(),
          ),
          _buildSummaryRow(
            'Payment Status',
            status,
            valueColor: status == 'PAID' ? Colors.green : Colors.orange,
          ),
          const Divider(height: 25, thickness: 1),
          _buildSummaryRow(
            'Total Amount',
            '₹ ${order['total_amount'] ?? payment['total_amount'] ?? '0.00'}',
            isBold: true,
            fontSize: 20,
            valueColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
