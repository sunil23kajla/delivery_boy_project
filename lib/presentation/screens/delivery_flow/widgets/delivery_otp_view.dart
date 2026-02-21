import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../delivery_flow_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class DeliveryOtpView extends GetView<DeliveryFlowController> {
  const DeliveryOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final defaultPinTheme = PinTheme(
      width: width * 0.12,
      height: width * 0.15,
      textStyle: TextStyle(fontSize: width * 0.05, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(width * 0.07),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.otpVerification,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Enter the 6-digit verification code sent to the customer.',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 50),
                Center(
                  child: Pinput(
                    length: 6,
                    controller: controller.otpController,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Obx(() => controller.isOtpVerified.value
                    ? Center(
                        child: Text(
                          AppStrings.otpVerifiedSuccess,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : const SizedBox()),
              ],
            ),
          ),
        ),

        // Footer Buttons
        Container(
          padding: EdgeInsets.symmetric(horizontal: width * 0.07, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('BACK',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Obx(() => ElevatedButton(
                      onPressed: controller.isOtpStepValid
                          ? controller.nextStep
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: const Text('NEXT',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    )),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
