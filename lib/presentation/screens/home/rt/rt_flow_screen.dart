import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'rt_flow_controller.dart';
import 'widgets/rt_details_view.dart';
import 'widgets/rt_scan_view.dart';
import 'widgets/rt_otp_view.dart';
import 'widgets/rt_options_view.dart';
import 'widgets/rt_recipient_view.dart';
import 'widgets/rt_evidence_view.dart';
import 'widgets/rt_cancel_view.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';

class RtFlowScreen extends StatelessWidget {
  const RtFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RtFlowController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(() {
          if (controller.isCancelFlow.value) {
            return const Text("MARK UNDELIVERED",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold));
          }
          return const Text("RT DELIVERY",
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
                  "STEP ${controller.currentStep.value.index + 1}/6",
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
          return const RtCancelView();
        }

        switch (controller.currentStep.value) {
          case RtStep.details:
            return const RtDetailsView();
          case RtStep.scan:
            return const RtScanView();
          case RtStep.otp:
            return const RtOtpView();
          case RtStep.options:
            return const RtOptionsView();
          case RtStep.recipient:
            return const RtRecipientView();
          case RtStep.evidence:
            return const RtEvidenceView();
          case RtStep.complete:
            return const Center(child: CircularProgressIndicator());
        }
      }),
    );
  }
}
