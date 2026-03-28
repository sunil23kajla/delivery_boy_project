import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../rvp_flow_controller.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';

class RvpCancelView extends GetView<RvpFlowController> {
  const RvpCancelView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(width * 0.05),
            child: Obx(() {
              if (controller.currentCancelStep.value == RvpCancelStep.reasons) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "SELECT CANCELLATION REASON",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 20),
                    _buildReasonList(),
                  ],
                );
              } else {
                final reason = controller.selectedReason.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "REASON: ${reason?['reason']?.toString().toUpperCase() ?? ''}",
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 30),
                    if (reason?['id'] == 1 ||
                        reason?['id'] == "1" ||
                        reason?['requires_otp'] == true ||
                        reason?['requires_otp'] == 1)
                      _buildOtpSection(width)
                    else
                      _buildDetailSection(),
                  ],
                );
              }
            }),
          ),
        ),
        _buildFooter(width),
      ],
    );
  }

  Widget _buildReasonList() {
    return Obx(() {
      if (controller.cancelReasons.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        );
      }
      return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200)),
        child: Column(
          children: controller.cancelReasons.map((reason) {
            final label = reason['reason']?.toString() ?? "Unknown";
            final id = reason['id'];

            return RadioListTile<dynamic>(
              title: Text(label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              value: id,
              groupValue: controller.selectedReason.value?['id'],
              onChanged: (val) => controller.selectedReason.value = reason,
              activeColor: AppColors.primary,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildOtpSection(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("VERIFY OTP",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const SizedBox(height: 15),
        Center(
          child: Pinput(
            length: 4,
            controller: controller.cancelOtpController,
            enabled: !controller.isCancelOtpVerified.value,
            defaultPinTheme: PinTheme(
              width: 45,
              height: 50,
              textStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildDetailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("REASON DETAILS (OPTIONAL)",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const SizedBox(height: 10),
        TextField(
          controller: controller.cancelReasonDetailController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Type reason here...",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
        ),
      ],
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
            child: Obx(() {
              final isReasonsStep =
                  controller.currentCancelStep.value == RvpCancelStep.reasons;
              final hasSelectedReason = controller.selectedReason.value != null;

              return ElevatedButton(
                onPressed: hasSelectedReason ? controller.nextStep : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isReasonsStep ? AppColors.primary : Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: Text(
                  isReasonsStep ? "NEXT" : "CANCEL ORDER",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
