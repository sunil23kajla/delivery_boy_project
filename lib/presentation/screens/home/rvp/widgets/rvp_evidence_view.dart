import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../rvp_flow_controller.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';

class RvpEvidenceView extends GetView<RvpFlowController> {
  const RvpEvidenceView({super.key});

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
                const Text(
                  "CLICK 3-4 IMAGES THEN APP WILL SHOW YOU CAN PICK-UP PRODUCT OR NOT",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 20),
                Obx(() => Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ...controller.evidenceImages.map((file) => Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                    image: FileImage(file), fit: BoxFit.cover),
                              ),
                            )),
                        if (controller.evidenceImages.length < 4)
                          InkWell(
                            onTap: controller.pickEvidenceImage,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.grey.shade300,
                                    style: BorderStyle.solid),
                              ),
                              child: const Icon(Icons.add_a_photo,
                                  color: Colors.grey),
                            ),
                          ),
                      ],
                    )),
                const SizedBox(height: 30),
                Obx(() => controller.evidenceImages.length >= 3
                    ? Column(
                        children: [
                          _buildActionButton("PICKUP PRODUCT", Colors.green,
                              controller.nextStep),
                          const SizedBox(height: 15),
                          _buildActionButton("DON'T PICKUP PRODUCT", Colors.red,
                              controller.startCancelFlow),
                        ],
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
        ),
        _buildFooter(width),
      ],
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
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
          const Expanded(child: SizedBox()), // Placeholder for balance
        ],
      ),
    );
  }
}
