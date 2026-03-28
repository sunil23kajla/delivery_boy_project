import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../rt_flow_controller.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';

class RtCancelView extends GetView<RtFlowController> {
  const RtCancelView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(width * 0.05),
            child: Obx(() {
              if (controller.currentCancelStep.value == RtCancelStep.reasons) {
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
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "REASON: ${_formatReason(controller.selectedCancelReason.value)}",
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 30),
                    if (controller.selectedCancelReason.value ==
                        RtCancelReason.cancelledBySellerContentMismatch)
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

  String _formatReason(RtCancelReason? reason) {
    if (reason == null) return "";
    return reason
        .toString()
        .split('.')
        .last
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim()
        .toUpperCase();
  }

  Widget _buildReasonList() {
    return Column(
      children: [
        _buildReasonTile("ORDER CANCELLED BY SELLER",
            RtCancelReason.cancelledBySellerContentMismatch, "1"),
        _buildReasonTile("DELIVERY REASEDUAL BY SELLER",
            RtCancelReason.rescheduledBySeller, "2"),
        _buildReasonTile(
            "SELLER UNAVAILABLE", RtCancelReason.sellerUnavailable, "3"),
        _buildReasonTile(
            "INCOMPLET NUM./AD.", RtCancelReason.incompleteAddress, "4"),
        _buildReasonTile("MISROUTE.", RtCancelReason.misroute, "5"),
      ],
    );
  }

  Widget _buildReasonTile(
      String label, RtCancelReason reason, String reasonId) {
    return Obx(() => RadioListTile<RtCancelReason>(
          title: Text(label,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          value: reason,
          groupValue: controller.selectedCancelReason.value,
          onChanged: (val) {
            controller.selectedCancelReason.value = val;
            controller.selectedCancelReasonId.value = reasonId;
          },
          activeColor: AppColors.primary,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        ));
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
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 25),
        const SizedBox(height: 15),
        const Center(
          child: Text(
            "Enter the 4-digit OTP mentioned above",
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("REASON DETAILS",
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
                  controller.currentCancelStep.value == RtCancelStep.reasons;
              final hasSelectedReason =
                  controller.selectedCancelReason.value != null;

              return ElevatedButton(
                onPressed: hasSelectedReason ? controller.nextStep : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isReasonsStep ? AppColors.primary : Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: Text(
                  isReasonsStep ? "NEXT" : "MARK PENDING",
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
