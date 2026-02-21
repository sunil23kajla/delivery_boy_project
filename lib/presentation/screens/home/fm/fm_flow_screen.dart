import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'fm_flow_controller.dart';
import 'widgets/fm_details_view.dart';
import 'widgets/fm_images_view.dart';
import 'widgets/fm_scan_view.dart';
import 'widgets/fm_cancel_view.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';

class FmFlowScreen extends StatelessWidget {
  const FmFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FmFlowController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(() {
          if (controller.isCancelFlow.value) {
            return const Text("MARK PENDING",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold));
          }
          return const Text("FM PICKUP",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
        }),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: controller.previousStep,
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Obx(() {
                if (controller.isCancelFlow.value)
                  return const SizedBox.shrink();
                return Text(
                  "STEP ${controller.currentStep.value.index + 1}/3",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                );
              }),
            ),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isCancelFlow.value) {
          return const FmCancelView();
        }

        switch (controller.currentStep.value) {
          case FmStep.details:
            return const FmDetailsView();
          case FmStep.images:
            return const FmImagesView();
          case FmStep.scan:
            return const FmScanView();
          case FmStep.complete:
            return const Center(child: CircularProgressIndicator());
        }
      }),
    );
  }
}
