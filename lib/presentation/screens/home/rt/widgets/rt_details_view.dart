import 'package:delivery_boy/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/external_actions.dart';
import '../rt_flow_controller.dart';

class RtDetailsView extends GetView<RtFlowController> {
  const RtDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 1: Identifiers Card (Tracking & Order ID)
                _buildIdentifiersCard(),
                const SizedBox(height: 15),

                // Section 2: Product Highlight Card
                _buildProductHighlightCard(),
                const SizedBox(height: 15),

                // Section 3: Customer/Recipient Card
                _buildCustomerCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _buildFooter(width),
      ],
    );
  }

  Widget _buildCustomerCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.purple,
                radius: 18,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => Text(
                      controller.shipment['name']?.toString() ?? "-------",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    )),
              ),
              IconButton.filledTonal(
                onPressed: () {
                  final phone = controller.shipment['phone']?.toString();
                  if (phone != null && phone.isNotEmpty) {
                    ExternalActions.makeCall(phone);
                  } else {
                    Get.snackbar("Error", "Phone number not available");
                  }
                },
                icon: const Icon(Icons.call, color: Colors.purple),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.purple.withOpacity(0.1),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: () {
                  final lat = controller.shipment['lat'];
                  final lng = controller.shipment['lng'];
                  if (lat != null && lng != null) {
                    ExternalActions.openMap(double.parse(lat.toString()),
                        double.parse(lng.toString()));
                  } else {
                    Get.snackbar("Error", "Location coordinates not available");
                  }
                },
                icon: const Icon(Icons.navigation_outlined, color: Colors.blue),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                ),
              ),
            ],
          ),
          const Divider(height: 25),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Obx(() => Text(
                      controller.shipment['address']?.toString() ?? "-------",
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIdentifiersCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          _buildInfoItem(Icons.qr_code, "TRACKING ID",
              controller.shipment['barcode']?.toString() ?? "-------"),
          const SizedBox(height: 12),
          _buildInfoItem(Icons.numbers, "ORDER ID",
              controller.shipment['orderId']?.toString() ?? "-------"),
        ],
      ),
    );
  }

  Widget _buildProductHighlightCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade300, Colors.purple.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.purple.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child:
                const Icon(Icons.shopping_bag, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "PRODUCT TO RETURN",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                      controller.shipment['product']?.toString() ?? "-------",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        SizedBox(
          width: 85,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary)),
        ),
        const Text(" :  ", style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(double width) {
    return Container(
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
              onPressed: controller.startCancelFlow,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("MARK UNDELIVERED",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: controller.nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("MARK DELIVERED",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
