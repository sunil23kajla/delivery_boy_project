import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'order_details_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/external_actions.dart';
import '../../widgets/custom_button.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderDetailsController());
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "${AppStrings.trackingId}: #${controller.shipment['tracking_id'] ?? 'SK45621'}",
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.shipment['name'] ?? 'Sunil Kumar',
                            style: TextStyle(
                              fontSize: width * 0.055,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Text(
                                controller.shipment['type'] ?? "COD",
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "10:30 AM",
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _IconButton(
                            icon: Icons.phone,
                            color: Colors.green,
                            onTap: () => ExternalActions.makeCall(controller.shipment['phone'] ?? ''),
                          ),
                          const SizedBox(width: 10),
                          _IconButton(
                            icon: Icons.navigation_outlined,
                            color: Colors.blue,
                            onTap: () => ExternalActions.openMap(
                              controller.shipment['lat'] ?? 0.0,
                              controller.shipment['lng'] ?? 0.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 40),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          controller.shipment['address'] ?? '123, Street Name, City, State, 110001',
                          style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Content Items
            Text(
              AppStrings.contentItems,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  _ItemRow(name: "Smart Watch", qty: "1"),
                  _ItemRow(name: "Leather Belt", qty: "2"),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Payment Status
            Center(
              child: Column(
                children: [
                  Text(
                    controller.shipment['amount'] ?? "₹79.00",
                    style: TextStyle(
                      fontSize: width * 0.1,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      AppStrings.paymentPending,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Actions
            CustomButton(
              text: AppStrings.paymentOptions,
              onPressed: () => _showPaymentOptions(context, controller),
            ),
            const SizedBox(height: 15),
            Center(
              child: TextButton(
                onPressed: controller.markUndelivered,
                child: Text(
                  AppStrings.markUndelivered,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentOptions(BuildContext context, OrderDetailsController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(5))),
              const SizedBox(height: 20),
              Text(AppStrings.paymentOptions, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              _PaymentMethodTile(
                icon: Icons.qr_code_scanner,
                title: AppStrings.qrCodeScan,
                subtitle: AppStrings.customerScanToPay,
                onTap: () {
                  Get.back();
                  _showQRModal(context, controller);
                },
              ),
              const SizedBox(height: 15),
              _PaymentMethodTile(
                icon: Icons.money_rounded,
                title: AppStrings.collectCash,
                subtitle: AppStrings.cashPaymentDoorstep,
                onTap: () {
                  Get.back();
                  _showCashModal(context, controller);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showQRModal(BuildContext context, OrderDetailsController controller) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppStrings.qrCodeScan, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                  ],
                ),
                const SizedBox(height: 20),
                const Icon(Icons.qr_code_2_rounded, size: 200, color: AppColors.textPrimary),
                const SizedBox(height: 20),
                Text(
                  "${controller.shipment['amount'] ?? '₹79.00'} ${AppStrings.confirmPayment}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                CustomButton(
                  text: AppStrings.confirmPayment,
                  onPressed: () {
                    Get.back();
                    Get.snackbar(AppStrings.success, AppStrings.paymentCollectedSuccess);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCashModal(BuildContext context, OrderDetailsController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.money, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Text(AppStrings.collectCash, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                controller.shipment['amount'] ?? "₹79.00",
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Text(AppStrings.paymentPending, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.orange.shade100)),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                    const SizedBox(width: 10),
                    Expanded(child: Text(AppStrings.recountCashInfo, style: const TextStyle(fontWeight: FontWeight.w500))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(AppStrings.tryAnotherPayment, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.keyboard_arrow_down),
                onTap: () {
                  Get.back();
                  _showPaymentOptions(context, controller);
                },
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: AppStrings.collectCash,
                onPressed: () {
                  Get.back();
                  Get.snackbar(AppStrings.success, AppStrings.cashCollectedSuccess);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PaymentMethodTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primary)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ]),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final String name;
  final String qty;

  const _ItemRow({required this.name, required this.qty});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 16)),
          Text("x$qty", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
