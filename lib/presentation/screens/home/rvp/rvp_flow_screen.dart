import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'rvp_flow_controller.dart';
import 'widgets/rvp_details_view.dart';
import 'widgets/rvp_checklist_view.dart';
import 'widgets/rvp_evidence_view.dart';
import 'widgets/rvp_scan_view.dart';
import 'widgets/rvp_cancel_view.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';

class RvpFlowScreen extends StatelessWidget {
  const RvpFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RvpFlowController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: controller.previousStep,
        ),
        title: Obx(() {
          if (controller.isCancelFlow.value) {
            return const Text("CANCEL RVP",
                style: TextStyle(
                    color: AppColors.textPrimary, fontWeight: FontWeight.bold));
          }

          String title = "";
          switch (controller.currentStep.value) {
            case RvpStep.details:
              title = "RVP Details";
              break;
            case RvpStep.checklist:
              title = "Checklist";
              break;
            case RvpStep.evidence:
              title = "Evidence";
              break;
            case RvpStep.scan:
              title = "Scan QR";
              break;
            case RvpStep.complete:
              title = "Completed";
              break;
          }
          return Text(title,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.bold));
        }),
      ),
      body: Obx(() {
        if (controller.isCancelFlow.value) return const RvpCancelView();

        switch (controller.currentStep.value) {
          case RvpStep.details:
            return const RvpDetailsView();
          case RvpStep.checklist:
            return const RvpChecklistView();
          case RvpStep.evidence:
            return const RvpEvidenceView();
          case RvpStep.scan:
            return const RvpScanView();
          case RvpStep.complete:
            return const Center(
                child:
                    Icon(Icons.check_circle, size: 100, color: Colors.green));
        }
      }),
    );
  }
}
