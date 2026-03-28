import 'package:delivery_boy/core/constants/app_colors.dart';
import 'package:delivery_boy/data/models/order_model.dart';
import 'package:delivery_boy/presentation/screens/order_details/order_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/external_actions.dart';

class OrderDetailsScreen extends GetView<OrderDetailsController> {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<OrderDetailsController>()) {
      Get.put(OrderDetailsController());
    }
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Order Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final shipment = controller.shipment.value;
        if (controller.isLoading) {
          return _buildShimmerLoading(width);
        }

        if (shipment == null) {
          return const Center(child: Text("Order not found"));
        }

        final items = shipment.items ?? [];

        return SingleChildScrollView(
          padding: EdgeInsets.all(width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderHeader(shipment, width),
              const SizedBox(height: 10),
              _buildSectionTitle('Customer Info'),
              const SizedBox(height: 5),
              _buildCustomerCard(shipment),
              const SizedBox(height: 12),
              _buildSectionTitle('Order Items'),
              const SizedBox(height: 5),
              ...items.map((item) => _buildItemCard(item)),
              const SizedBox(height: 12),
              _buildSectionTitle('Payment Details'),
              const SizedBox(height: 5),
              _buildPaymentSummary(shipment),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOrderHeader(OrderModel shipment, double width) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
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
              Icons.location_on_outlined, controller.buildAddressString(),
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
          Text('₹ ${item.itemTotal ?? 0.0}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(OrderModel shipment) {
    final status = (shipment.paymentStatus ?? 'Paid').toUpperCase();
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
            (shipment.paymentMethod ?? 'Online').toUpperCase(),
          ),
          _buildSummaryRow(
            'Payment Status',
            status,
            valueColor: _getStatusColor(shipment.paymentStatus),
          ),
          const Divider(height: 25, thickness: 1),
          _buildSummaryRow(
            'Total Amount',
            '₹ ${shipment.totalAmount ?? 0.0}',
            isBold: true,
            fontSize: 20,
            valueColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => controller.markUndelivered(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('MARK UNDELIVERED',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton(
            onPressed: () => controller.collectPayment(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('DELIVERED',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
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
      padding: const EdgeInsets.symmetric(vertical: 2),
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

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'PAID':
      case 'DELIVERED':
      case 'SUCCESS':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildShimmerLoading(double width) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerPlaceholder(width: width, height: 160), // Header
          const SizedBox(height: 20),
          _ShimmerPlaceholder(width: width * 0.4, height: 20), // Section Title
          const SizedBox(height: 10),
          _ShimmerPlaceholder(
              width: width, height: 180), // Customer Card with Actions
          const SizedBox(height: 20),
          _ShimmerPlaceholder(width: width * 0.3, height: 20), // Section Title
          const SizedBox(height: 10),
          _ShimmerPlaceholder(width: width, height: 70), // Item 1
          const SizedBox(height: 10),
          _ShimmerPlaceholder(width: width, height: 70), // Item 2
          const SizedBox(height: 20),
          _ShimmerPlaceholder(width: width, height: 100), // Payment Summary
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

class _ShimmerPlaceholder extends StatefulWidget {
  final double width;
  final double height;

  const _ShimmerPlaceholder({
    required this.width,
    required this.height,
  });

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade200,
                Colors.grey.shade100,
                Colors.grey.shade200,
              ],
              stops: [
                0.0,
                0.5 + (_animation.value / 4),
                1.0,
              ],
              transform:
                  _SlidingGradientTransform(slidePercent: _animation.value),
            ),
          ),
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}
