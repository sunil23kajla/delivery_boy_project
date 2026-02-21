import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../rt_flow_controller.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';

class RtOptionsView extends GetView<RtFlowController> {
  const RtOptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("SELECT DELIVERY OPTION",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 30),
                _buildOptionTile("DELIVERD TO SELLER", "seller",
                    "AUTOMATICK FILL CUSTOMER DETAILS"),
                const SizedBox(height: 20),
                _buildOptionTile("DELIVERED TO OTHER", "other",
                    "AS PER SELLER REQS -> MANUAL FILL"),
              ],
            ),
          ),
        ),
        _buildFooter(width),
      ],
    );
  }

  Widget _buildOptionTile(String title, String type, String subtitle) {
    return Obx(() => InkWell(
          onTap: () => controller.selectedRecipientType.value = type,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: controller.selectedRecipientType.value == type
                  ? AppColors.primary.withOpacity(0.05)
                  : Colors.white,
              border: Border.all(
                  color: controller.selectedRecipientType.value == type
                      ? AppColors.primary
                      : Colors.grey.shade200,
                  width: 2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 5),
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Radio<String>(
                  value: type,
                  groupValue: controller.selectedRecipientType.value,
                  onChanged: (val) =>
                      controller.selectedRecipientType.value = val!,
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildFooter(double width) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: controller.previousStep,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("BACK",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Obx(() => ElevatedButton(
                  onPressed: controller.selectedRecipientType.value.isNotEmpty
                      ? controller.nextStep
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("NEXT",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                )),
          ),
        ],
      ),
    );
  }
}
