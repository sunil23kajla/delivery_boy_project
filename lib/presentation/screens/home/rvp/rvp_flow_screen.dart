import 'package:delivery_boy/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'rvp_flow_controller.dart';
import 'widgets/rvp_cancel_view.dart';
import 'widgets/rvp_details_view.dart';
import 'widgets/rvp_evidence_view.dart';
import 'widgets/rvp_scan_view.dart';

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
            return const Text("CANCEL RETURN",
                style: TextStyle(
                    color: AppColors.textPrimary, fontWeight: FontWeight.bold));
          }

          String title = "";
          switch (controller.currentStep.value) {
            case RvpStep.details:
              title = "RETURN DETAILS";
              break;
            case RvpStep.checklist:
              title = "VERIFICATION";
              break;
            case RvpStep.evidence:
              title = "RETURN EVIDENCE";
              break;
            case RvpStep.scan:
              title = "SCAN QR CODE";
              break;
            case RvpStep.complete:
              title = "PICKUP SUCCESS";
              break;
            default:
              title = "RVP FLOW";
          }
          return Text(title,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5));
        }),
      ),
      body: Obx(() {
        if (controller.isCancelFlow.value) return const RvpCancelView();

        switch (controller.currentStep.value) {
          case RvpStep.details:
            return const RvpDetailsView();
          case RvpStep.evidence:
            return const RvpEvidenceView();
          case RvpStep.scan:
            return const RvpScanView();
          case RvpStep.complete:
            return const Center(
                child:
                    Icon(Icons.check_circle, size: 100, color: Colors.green));
          default:
            return const SizedBox.shrink();
        }
      }),
    );
  }
}
