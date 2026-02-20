import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'undelivered_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../widgets/custom_button.dart';

class UndeliveredScreen extends StatelessWidget {
  const UndeliveredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UndeliveredController());
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textPrimary, size: 20),
          onPressed: () {
            if (controller.currentStep.value == UndeliveredStep.action) {
              controller.previousStep();
            } else {
              Get.back();
            }
          },
        ),
        title: Text(
          AppStrings.undeliveredProcess.toUpperCase(),
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
      body: Obx(() {
        if (controller.currentStep.value == UndeliveredStep.reasons) {
          return _buildReasonsStep(width, controller);
        } else {
          return _buildActionStep(width, controller);
        }
      }),
      bottomNavigationBar: Obx(() => _buildFooter(width, controller)),
    );
  }

  Widget _buildReasonsStep(double width, UndeliveredController controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "SELECT REASON",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary),
          ),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: List.generate(controller.reasons.length, (index) {
                return Column(
                  children: [
                    RadioListTile<int>(
                      title: Text(
                        controller.reasons[index],
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      value: index,
                      groupValue: controller.selectedReasonIndex.value,
                      onChanged: (value) =>
                          controller.selectedReasonIndex.value = value!,
                      activeColor: AppColors.primary,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    if (index < controller.reasons.length - 1)
                      Divider(
                          height: 1,
                          color: Colors.grey.shade100,
                          indent: 20,
                          endIndent: 20),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildActionStep(double width, UndeliveredController controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(width * 0.07),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.reasons[controller.selectedReasonIndex.value],
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 30),
          if (controller.isOtpReason) ...[
            Center(
              child: Column(
                children: [
                  Pinput(
                    length: 6,
                    controller: controller.otpController,
                    enabled: !controller.isOtpVerified.value,
                    defaultPinTheme: PinTheme(
                      width: 45,
                      height: 50,
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: "VERIFY OTP",
                    onPressed: controller.verifyOtp,
                    isEnabled: !controller.isOtpVerified.value,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ] else ...[
            const Text(
              "REASON DETAILS",
              style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller.reasonDetailsController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Type reason here...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter(double width, UndeliveredController controller) {
    return Container(
      padding: EdgeInsets.fromLTRB(width * 0.05, 10, width * 0.05, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: AppColors.textSecondary),
              ),
              onPressed: () {
                if (controller.currentStep.value == UndeliveredStep.action) {
                  controller.previousStep();
                } else {
                  Get.back();
                }
              },
              child: const Text("BACK",
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    controller.currentStep.value == UndeliveredStep.reasons
                        ? AppColors.primary
                        : AppColors.error,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () {
                if (controller.currentStep.value == UndeliveredStep.reasons) {
                  controller.nextStep();
                } else {
                  controller.completeProcess();
                }
              },
              child: Text(
                controller.currentStep.value == UndeliveredStep.reasons
                    ? "NEXT"
                    : "MARK UNDELIVERED",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
