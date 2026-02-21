import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'delivery_flow_controller.dart';
import 'widgets/delivery_scan_view.dart';
import 'widgets/delivery_otp_view.dart';
import 'widgets/delivery_options_view.dart';
import 'widgets/delivery_payment_view.dart';
import 'widgets/delivery_image_view.dart';
import 'widgets/delivery_payment_details_view.dart';
import 'widgets/delivery_recipient_details_view.dart';
import '../../../core/constants/app_colors.dart';

class DeliveryFlowScreen extends StatelessWidget {
  const DeliveryFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DeliveryFlowController());

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
          String title = "";
          switch (controller.currentStep.value) {
            case DeliveryStep.scan:
              title = "Scan Product";
              break;
            case DeliveryStep.otp:
              title = "OTP Verification";
              break;
            case DeliveryStep.options:
              title = "Delivery Option";
              break;
            case DeliveryStep.recipientDetails:
              title = "Recipient Details";
              break;
            case DeliveryStep.payment:
              title = "Payment Option";
              break;
            case DeliveryStep.paymentDetails:
              title = controller.selectedPaymentMethod.value == 'cash'
                  ? "Collect Cash"
                  : "UPI Payment";
              break;
            case DeliveryStep.images:
              title = "Add Images";
              break;
          }
          return Text(title,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.bold));
        }),
      ),
      body: Obx(() {
        switch (controller.currentStep.value) {
          case DeliveryStep.scan:
            return const DeliveryScanView();
          case DeliveryStep.otp:
            return const DeliveryOtpView();
          case DeliveryStep.options:
            return const DeliveryOptionsView();
          case DeliveryStep.recipientDetails:
            return const DeliveryRecipientDetailsView();
          case DeliveryStep.payment:
            return const DeliveryPaymentView();
          case DeliveryStep.paymentDetails:
            return const DeliveryPaymentDetailsView();
          case DeliveryStep.images:
            return const DeliveryImageView();
        }
      }),
    );
  }
}
