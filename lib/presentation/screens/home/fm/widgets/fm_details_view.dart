import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../fm_flow_controller.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';

class FmDetailsView extends GetView<FmFlowController> {
  const FmDetailsView({super.key});

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
                _buildInfoRow(
                    "TRAKING ID", controller.shipment['barcode'] ?? "-------"),
                _buildInfoRow(
                    "ORDER ID", controller.shipment['orderId'] ?? "-------"),
                _buildInfoRow("NAME", controller.shipment['name'] ?? "-------"),
                _buildInfoRow(
                    "ADD.", controller.shipment['address'] ?? "-------"),
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 20),
                _buildChecklistRow(
                    "PRODUCT VISIBLE", controller.isProductVisible),
                const SizedBox(height: 15),
                _buildChecklistRow("WEIGH MATCH", controller.isWeightMatch),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
        _buildFooter(width),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 100,
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.textSecondary))),
          const Text(": ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textPrimary))),
        ],
      ),
    );
  }

  Widget _buildChecklistRow(String label, Rxn<bool> obs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 10),
        Obx(() => Row(
              children: [
                _buildCheckButton("YES", true, obs),
                const SizedBox(width: 20),
                _buildCheckButton("NO", false, obs),
              ],
            )),
      ],
    );
  }

  Widget _buildCheckButton(String label, bool value, Rxn<bool> obs) {
    final isSelected = obs.value == value;
    return InkWell(
      onTap: () => obs.value = value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
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
              child: const Text("MARK PENDING",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Obx(() => ElevatedButton(
                  onPressed: (controller.isProductVisible.value != null &&
                          controller.isWeightMatch.value != null)
                      ? controller.nextStep
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: const Text("MARK PICKUP",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                )),
          ),
        ],
      ),
    );
  }
}
