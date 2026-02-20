import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../delivery_flow_controller.dart';
import '../../../../core/constants/app_colors.dart';

class DeliveryPaymentDetailsView extends GetView<DeliveryFlowController> {
  const DeliveryPaymentDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(width * 0.07),
            child: Obx(() {
              final isUpi = controller.selectedPaymentMethod.value == 'upi';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isUpi) ...[
                    // UPI Flow (Wireframe Step 9 - Left)
                    const Text(
                      'SCAN QR TO PAY',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary, width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5))
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.qr_code_2,
                              size: 200, color: AppColors.textPrimary),
                          const SizedBox(height: 10),
                          Text(
                            "₹ ${controller.shipment['amount'] ?? '79.00'}",
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Simulate payment verification
                        controller.isPaymentVerified.value = true;
                        Get.snackbar(
                            "Success", "Payment verified successfully!");
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text("CHECK PAYMENT"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ] else ...[
                    // Cash Flow (Wireframe Step 9 - Right)
                    const Text(
                      'COLLECT CASH',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 50),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5))
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text("Amount to Collect",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey)),
                          const SizedBox(height: 10),
                          Text(
                            "₹ ${controller.shipment['amount'] ?? '79.00'}",
                            style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.orange, size: 20),
                        SizedBox(width: 10),
                        Text("Please recount the cash carefully"),
                      ],
                    ),
                  ],
                ],
              );
            }),
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
                  onPressed: () =>
                      controller.currentStep.value = DeliveryStep.payment,
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
                child: Obx(() {
                  final isUpi = controller.selectedPaymentMethod.value == 'upi';
                  final canProceed =
                      isUpi ? controller.isPaymentVerified.value : true;

                  return ElevatedButton(
                    onPressed: canProceed ? controller.nextStep : null,
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
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
