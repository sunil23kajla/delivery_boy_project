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
            padding:
                EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 10),
            child: Obx(() {
              final isUpi = controller.selectedPaymentMethod.value == 'upi';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isUpi) ...[
                    // UPI Flow (Wireframe Step 9 - Left)
                    const Text(
                      'SCAN QR TO PAY',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 15),
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
                      child: Obx(() {
                        final String? qrUrl = controller.qrCodeUrl.value.isNotEmpty 
                            ? controller.qrCodeUrl.value 
                            : null;

                        return Column(
                          children: [
                            if (qrUrl != null && qrUrl.isNotEmpty)
                              Image.network(
                                qrUrl,
                                width: 160,
                                height: 160,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.error_outline,
                                        size: 100, color: Colors.red),
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const SizedBox(
                                    width: 160,
                                    height: 160,
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  );
                                },
                              )
                            else if (controller.isLoading)
                              const SizedBox(
                                width: 160,
                                height: 160,
                                child: Center(
                                    child: CircularProgressIndicator()),
                              )
                            else
                              const Icon(Icons.qr_code_2,
                                  size: 160, color: AppColors.textPrimary),
                            const SizedBox(height: 10),
                            Text(
                              "₹ ${controller.shipment.totalAmount ?? '0.00'}",
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary),
                            ),
                          ],
                        );
                      }),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: controller.isPaymentVerified.value
                          ? null
                          : () => controller.verifyUpiPayment(),
                      icon: Icon(controller.isPaymentVerified.value
                          ? Icons.check_circle
                          : Icons.check_circle_outline),
                      label: Text(controller.isPaymentVerified.value
                          ? "PAYMENT SUCCESSFUL"
                          : "CHECK PAYMENT"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.isPaymentVerified.value
                            ? Colors.green
                            : Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        disabledBackgroundColor: Colors.green,
                        disabledForegroundColor: Colors.white,
                      ),
                    ),
                  ] else ...[
                    // Cash Flow (Wireframe Step 9 - Right)
                    const Text(
                      'COLLECT CASH',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 20),
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
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900)),
                          const SizedBox(height: 5),
                          Text(
                            "₹ ${controller.shipment.totalAmount ?? '0.00'}",
                            style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
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
                        Text("Please recount the cash carefully",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
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
