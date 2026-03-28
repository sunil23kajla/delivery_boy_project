import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:delivery_boy/presentation/screens/home/quick/quick_flow_controller.dart';

import 'widgets/quick_fvd_scan_view.dart';
import 'widgets/quick_fvd_otp_view.dart';
import 'widgets/quick_fvd_options_view.dart';
import 'widgets/quick_fvd_recipient_details_view.dart';
import 'widgets/quick_fvd_payment_view.dart';
import 'widgets/quick_fvd_payment_details_view.dart';
import 'widgets/quick_fvd_image_view.dart';
import 'widgets/quick_fvd_details_view.dart';

import 'package:delivery_boy/presentation/widgets/loading_overlay.dart';

class QuickFVDScreen extends GetView<QuickFlowController> {
  const QuickFVDScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: controller.isLoadingRx,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Obx(() {
            String title = "Forward Delivery";
            switch (controller.currentStep.value) {
              case QuickStep.fvdDetails:
                title = "Order Details";
                break;
              case QuickStep.fvdScan:
                title = "Scan Product";
                break;
              case QuickStep.fvdOtp:
                title = "OTP Verification";
                break;
              case QuickStep.fvdOptions:
                title = "Delivery Option";
                break;
              case QuickStep.fvdRecipientDetails:
                title = "Recipient Details";
                break;
              case QuickStep.fvdPayment:
                title = "Payment Option";
                break;
              case QuickStep.fvdPaymentDetails:
                title = controller.fvdSelectedPaymentMethod.value == 'cash'
                    ? "Collect Cash"
                    : "UPI Payment";
                break;
              case QuickStep.fvdImages:
                title = "Add Images";
                break;
              default:
                break;
            }
            return Text(title,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold));
          }),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              if (controller.currentStep.value == QuickStep.fvdDetails) {
                controller.goBack();
              } else {
                controller.previousFvdStep();
              }
            },
          ),
        ),
        body: Obx(() {
          switch (controller.currentStep.value) {
            case QuickStep.fvdDetails:
              return const QuickFvdDetailsView();
            case QuickStep.fvdScan:
              return const DeliveryScanView();
            case QuickStep.fvdOtp:
              return const DeliveryOtpView();
            case QuickStep.fvdOptions:
              return const DeliveryOptionsView();
            case QuickStep.fvdRecipientDetails:
              return const DeliveryRecipientDetailsView();
            case QuickStep.fvdPayment:
              return const DeliveryPaymentView();
            case QuickStep.fvdPaymentDetails:
              return const DeliveryPaymentDetailsView();
            case QuickStep.fvdImages:
              return const DeliveryImageView();
            default:
              return const QuickFvdDetailsView();
          }
        }),
      ),
    );
  }
}
