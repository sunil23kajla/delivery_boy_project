import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';
import 'package:delivery_boy/data/models/order_model.dart';
import './summary_list_controller.dart';

class SummaryDetailScreen extends GetView<SummaryDetailController> {
  const SummaryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final shipment =
          controller.rxShipment.value ?? controller.initialShipment;

      // Get actual status from orderStatus, with fallback to initial status badge
      final responseStatus = shipment.orderStatus?.toUpperCase();
      final displayStatus = responseStatus ?? 'DISPATCH';

      Color statusColor;
      switch (displayStatus) {
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
        backgroundColor: const Color(0xFFF5F7FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: AppColors.textPrimary, size: 20),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            "Order Details",
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Info Card (Order ID & Tracking ID)
                    _buildHeaderCard(shipment, statusColor, displayStatus),
                    const SizedBox(height: 24),

                    // Quick Flow Specific: Vendor/Pickup Info
                    if (controller.rxIsQuick.value &&
                        shipment.vendor != null) ...[
                      _buildSectionHeader("PICKUP INFORMATION",
                          Icons.storefront_outlined, Colors.orange),
                      const SizedBox(height: 12),
                      _buildVendorCard(shipment.vendor!),
                      const SizedBox(height: 24),
                    ],

                    // Customer Section
                    _buildSectionHeader("DELIVERY INFORMATION",
                        Icons.person_pin_circle_outlined, Colors.blue),
                    const SizedBox(height: 12),
                    _buildCustomerCard(shipment),
                    const SizedBox(height: 24),

                    // Product Items Section
                    _buildSectionHeader("ITEMS SUMMARY",
                        Icons.inventory_2_outlined, Colors.purple),
                    const SizedBox(height: 12),
                    ...(shipment.items ?? [])
                        .map((item) => _buildProductItem(item)),

                    if (shipment.items == null || shipment.items!.isEmpty)
                      _buildEmptyState("No products found for this order"),

                    const SizedBox(height: 24),

                    // Payment Breakdown Section
                    _buildSectionHeader("PAYMENT SUMMARY",
                        Icons.payments_outlined, Colors.green),
                    const SizedBox(height: 12),
                    _buildPaymentCard(shipment),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey.shade800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard(
      OrderModel shipment, Color statusColor, String status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ID: #${shipment.id ?? '-'}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.tag, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    shipment.orderNumber ?? '-',
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ],
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

  Widget _buildVendorCard(VendorModel vendor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vendor.shopName ?? vendor.vendorName ?? 'Pickup Location',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone, color: Colors.blue, size: 16),
              const SizedBox(width: 8),
              Text(vendor.mobileNumber ?? '-',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(OrderModel shipment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            shipment.customer?.name ?? 'Customer Name',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone_android, color: Colors.green, size: 16),
              const SizedBox(width: 8),
              Text(shipment.customer?.mobile ?? '-',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 14)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 0.5),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Colors.redAccent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _buildAddressString(shipment),
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(OrderItemModel item) {
    String? imageUrl;
    if (item.productImages != null && item.productImages!.isNotEmpty) {
      imageUrl = item.productImages!.first.imageUrl;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F2F5),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: (imageUrl != null && imageUrl.isNotEmpty)
                ? Image.network(imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Icon(
                        Icons.image_not_supported,
                        size: 24,
                        color: Colors.grey))
                : const Icon(Icons.inventory_2_outlined,
                    size: 24, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName ?? 'Unknown Product',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "QTY: ${item.quantity ?? 1}",
                    style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "₹${(item.itemTotal ?? 0.0).toStringAsFixed(2)}",
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            Icon(Icons.category_outlined,
                size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(msg,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          ],
        ),
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

  Widget _buildPaymentCard(OrderModel shipment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 15,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          _buildPaymentRow("Subtotal", shipment.itemsTotal ?? 0.0),
          _buildPaymentRow("Delivery Fee", shipment.deliveryCharge ?? 0.0),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 0.5),
          ),
          _buildPaymentRow(controller.rxIsQuick.value ? "Total" : "Grand Total",
              shipment.totalPayable ?? 0.0,
              isBold: true),
          if (!controller.rxIsQuick.value) ...[
            _buildPaymentRow("Amount Paid", shipment.totalPaid ?? 0.0,
                color: Colors.green),
            _buildPaymentRow("Outstanding", shipment.totalDue ?? 0.0,
                color: Colors.red, isBold: true),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, double value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: isBold ? 15 : 14,
            ),
          ),
          Text(
            "₹${value.toStringAsFixed(2)}",
            style: TextStyle(
              color: color ??
                  (isBold ? AppColors.textPrimary : AppColors.textSecondary),
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
