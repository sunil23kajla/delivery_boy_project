import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../fm_flow_controller.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';

class FmImagesView extends GetView<FmFlowController> {
  const FmImagesView({super.key});

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
                const Text("CLICK 2 IMAGES",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageSlot(context, "FRONT", 0),
                    _buildImageSlot(context, "BACK", 1),
                  ],
                ),
                const SizedBox(height: 40),
                const Text("REQUIRED: FRONT, BACK",
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ],
            ),
          ),
        ),
        _buildFooter(width),
      ],
    );
  }

  Widget _buildImageSlot(BuildContext context, String label, int index) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Obx(() => InkWell(
              onTap: () => controller.pickImage(index),
              child: Container(
                width: width * 0.35,
                height: width * 0.35,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: controller.evidenceImages[index] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(controller.evidenceImages[index]!,
                            fit: BoxFit.cover),
                      )
                    : const Icon(Icons.camera_alt, color: Colors.red, size: 40),
              ),
            )),
        const SizedBox(height: 10),
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.textSecondary)),
      ],
    );
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
                  onPressed: controller.evidenceImages[0] != null &&
                          controller.evidenceImages[1] != null
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
