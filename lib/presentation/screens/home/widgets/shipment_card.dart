import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/external_actions.dart';
import '../../../../data/models/order_model.dart';

/// Maps the order status or delivery type to the internal category label.
String _resolveCategory(OrderModel shipment) {
  final type = (shipment.orderType ?? '').toLowerCase();
  switch (type) {
    case 'rvp':
    case 'reverse':
    case 'reverse_pickup':
      return 'RVP';
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
      return 'FWD';
    default:
      return type.isNotEmpty ? type.toUpperCase() : 'FWD';
  }
}

/// Navigate to the correct flow screen based on order category.
void _navigateToFlow(OrderModel shipment) {
  final category = _resolveCategory(shipment);
  switch (category) {
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
      // Pass the whole model as argument
      Get.toNamed(AppRoutes.orderDetails, arguments: shipment);
      break;
  }
}

Color _categoryColor(String category) {
  switch (category) {
    case 'RVP':
      return Colors.orange;
    case 'RT':
      return Colors.purple;
    case 'FM':
      return Colors.teal;
    case 'FWD':
    default:
      return AppColors.primary;
  }
}

class ShipmentCard extends StatelessWidget {
  final OrderModel shipment;
  final bool navigateOnTap;

  const ShipmentCard({
    super.key,
    required this.shipment,
    this.navigateOnTap = true,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final category = _resolveCategory(shipment);
    final catColor = _categoryColor(category);
    final uiOrderType = (shipment.orderType ?? '').toUpperCase();

    final customerName = shipment.customer?.name ?? 'Customer';
    final orderNumber = shipment.orderNumber ?? '-';
    final paymentMethod = (shipment.paymentMethod ?? 'online').toUpperCase();
    final paymentStatus = (shipment.paymentStatus ?? 'paid').toUpperCase();
    final totalAmount = shipment.totalAmount;
    final phone = shipment.customer?.mobile ?? '';

    // address
    final addr = shipment.deliveryAddress;
    String addressText = '';
    if (addr != null) {
      final parts = [
        addr.addressLine1,
        addr.addressLine2,
        addr.area?.name,
        addr.city?.name,
        addr.state?.name,
        addr.pincode,
      ].where((e) => e != null && e.toString().isNotEmpty).toList();
      addressText = parts.join(', ');
    }

    final lat = shipment.deliveryAddress?.latitude ?? 0.0;
    final lng = shipment.deliveryAddress?.longitude ?? 0.0;
    final isCod = paymentMethod == 'COD';

    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: navigateOnTap ? () => _navigateToFlow(shipment) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    customerName,
                    style: TextStyle(
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    uiOrderType,
                    style: TextStyle(
                      color: catColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#$orderNumber',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: width * 0.032),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    addressText.isNotEmpty
                        ? addressText
                        : 'Address not available',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              paymentMethod,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (isCod && totalAmount != null)
                            _Badge(
                              label: '₹ $totalAmount',
                              bg: Colors.green.shade50,
                              border: Colors.green.shade200,
                              textColor: Colors.green.shade700,
                            )
                          else
                            _Badge(
                              label: paymentStatus,
                              bg: Colors.blue.shade50,
                              border: Colors.blue.shade200,
                              textColor: Colors.blue,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _ActionButton(
                      icon: Icons.phone,
                      color: Colors.green,
                      onTap: () => ExternalActions.makeCall(phone),
                    ),
                    const SizedBox(width: 12),
                    _ActionButton(
                      icon: Icons.navigation_outlined,
                      color: Colors.blue,
                      onTap: () => ExternalActions.openMap(lat, lng),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color bg, border, textColor;
  const _Badge(
      {required this.label,
      required this.bg,
      required this.border,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Text(label,
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}
