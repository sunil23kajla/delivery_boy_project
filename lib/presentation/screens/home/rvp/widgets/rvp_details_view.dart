import 'package:delivery_boy/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/external_actions.dart';

import '../rvp_flow_controller.dart';

class RvpDetailsView extends GetView<RvpFlowController> {
  const RvpDetailsView({super.key});

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

                // Section 2: Product Highlight Card (Highly Visible)
                _buildProductHighlightCard(),
                const SizedBox(height: 15),

                // Section 3: Customer Card (User Info & Actions)
                _buildCustomerCard(),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Icon(Icons.collections_outlined,
                        size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text("APPLICATION IMAGES",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5)),
                  ],
                ),
                const SizedBox(height: 10),
                Obx(() => _buildImageStrip(controller.applicationImages)),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Icon(Icons.camera_alt_outlined,
                        size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text("CUSTOMER IMAGES",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5)),
                  ],
                ),
                const SizedBox(height: 10),
                Obx(() => _buildImageStrip(controller.customerImages)),
                const SizedBox(height: 20),

                // Section 4: Return Reason
                const Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text("RETURN REASON",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5)),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Obx(() => Text(
                        controller.returnReason.value.isEmpty
                            ? "-------"
                            : controller.returnReason.value,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      )),
                ),
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
                backgroundColor: AppColors.primary,
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
                  final phone = controller.shipment['mobile']?.toString();
                  if (phone != null && phone.isNotEmpty) {
                    ExternalActions.makeCall(phone);
                  } else {
                    Get.snackbar("Error", "Phone number not available");
                  }
                },
                icon: const Icon(Icons.call, color: AppColors.primary),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
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
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          // Product Image
          Obx(() {
            final imageUrl = controller.applicationImages.isNotEmpty
                ? controller.applicationImages.first
                : null;
            return Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: imageUrl != null
                    ? Image.network(imageUrl, fit: BoxFit.cover)
                    : const Icon(Icons.shopping_bag,
                        color: Colors.white, size: 40),
              ),
            );
          }),
          const SizedBox(width: 15),
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "PRODUCT TO PICKUP",
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
                        fontSize: 20,
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

  Widget _buildInfoItem(IconData icon, String label, String value,
      {bool isProduct = false}) {
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
            style: TextStyle(
              fontSize: isProduct ? 14 : 13,
              fontWeight: FontWeight.w600,
              color: isProduct ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageStrip(List<String> images) {
    if (images.isEmpty) {
      return SizedBox(
        height: 90,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3, // Show 3 placeholders
          itemBuilder: (context, index) {
            return Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: const Center(
                child: Icon(Icons.image_outlined, color: Colors.grey, size: 30),
              ),
            );
          },
        ),
      );
    }

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                images[index],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2));
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                      child:
                          Icon(Icons.image_not_supported, color: Colors.grey));
                },
              ),
            ),
          );
        },
      ),
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
              child: const Text("CANCEL",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
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
              child: const Text("PICKUP",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
