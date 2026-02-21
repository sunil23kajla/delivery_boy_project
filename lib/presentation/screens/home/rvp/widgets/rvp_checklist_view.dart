import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../rvp_flow_controller.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';

class RvpChecklistView extends GetView<RvpFlowController> {
  const RvpChecklistView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.all(width * 0.05),
            itemCount: controller.checklistQuestions.length,
            separatorBuilder: (context, index) => const Divider(height: 20),
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${index + 1}) ${controller.checklistQuestions[index]}",
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  Obx(() => Row(
                        children: [
                          _buildChoiceChip("YES", true, index),
                          const SizedBox(width: 20),
                          _buildChoiceChip("NO", false, index),
                        ],
                      )),
                ],
              );
            },
          ),
        ),
        _buildFooter(width),
      ],
    );
  }

  Widget _buildChoiceChip(String label, bool value, int index) {
    bool isSelected = controller.checklist[index] == value;
    return InkWell(
      onTap: () => controller.checklist[index] = value,
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_box : Icons.check_box_outline_blank,
            color: isSelected ? AppColors.primary : Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : Colors.grey)),
        ],
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
              onPressed: controller.previousStep,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: const BorderSide(color: AppColors.textSecondary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("BACK",
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold)),
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
              child: const Text("NEXT",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
