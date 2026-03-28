import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'dart:io';
import 'package:delivery_boy/presentation/screens/home/quick/quick_flow_controller.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';
import 'package:delivery_boy/presentation/widgets/loading_overlay.dart';

class QuickMarkUndeliveredScreen extends GetView<QuickFlowController> {
  const QuickMarkUndeliveredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          controller.hideLoading();
        }
      },
      child: LoadingOverlay(
        isLoading: controller.isLoadingRx,
        child: Scaffold(
          backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Mark Undelivered",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => controller.previousMarkPendingStep(),
          ),
        ),
        body: Obx(() {
          switch (controller.currentStep.value) {
            case QuickStep.markPendingCustomerCancelReasons:
              return _buildReasonsView(context);
            case QuickStep.markPendingCustomerCancelOtp:
              return _buildOtpView(context);
            case QuickStep.markPendingCustomerCancelDetails:
              return _buildDetailsView(context);
            case QuickStep.markPendingCustomerCancelImages:
              return _buildImagesView(context);
            case QuickStep.markPendingOtherReturnFailed:
              return _buildOtherReturnFailedView(context);
            case QuickStep.markPendingOtherImages:
              return _buildOtherImagesView(context);
            case QuickStep.markPendingInnerReasons:
              return _buildInnerReasonsView(context);
            case QuickStep.markPendingInnerOtp:
              return _buildInnerOtpView(context);
            case QuickStep.markPendingInnerComment:
              return _buildInnerCommentView(context);
            default:
              return const Center(child: CircularProgressIndicator());
          }
        }),
        ),
      ),
    );
  }

  Widget _buildReasonsView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("SELECT CANCELLATION REASON",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 15),
                Obx(() => Column(
                      children: controller.customerCancelReasons.map((reason) {
                        final id = reason['id'].toString();
                        final name =
                            (reason['reason'] ?? reason['name'] ?? "").toString();
                        return Obx(() => RadioListTile<String>(
                              title: Text(name.toUpperCase(),
                                  style: const TextStyle(fontSize: 14)),
                              value: id,
                              groupValue:
                                  controller.selectedCustomerCancelReasonId.value,
                              onChanged: (val) {
                                if (val != null) {
                                  controller.selectedCustomerCancelReasonId.value =
                                      val;
                                }
                              },
                              activeColor: AppColors.primary,
                              contentPadding: EdgeInsets.zero,
                            ));
                      }).toList(),
                    )),
              ],
            ),
          ),
        ),
        _buildFooter(0, isReasons: true),
      ],
    );
  }

  Widget _buildOtpView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
              child: Column(
                children: [
                  const Icon(Icons.mark_email_unread_outlined, size: 80, color: AppColors.primary),
                  const SizedBox(height: 30),
                  const Text("VERIFY OTP",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  const SizedBox(height: 15),
                  const Text(
                    "PLEASE ENTER THE 4-DIGIT OTP PROVIDED BY THE CUSTOMER",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 40),
                  Pinput(
                    length: 4,
                    controller: controller.customerCancelOtpController,
                    onChanged: (val) => controller.customerCancelOtpText.value = val,
                    defaultPinTheme: PinTheme(
                      width: 60,
                      height: 65,
                      textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildFooter(0, isOtp: true),
      ],
    );
  }

  Widget _buildDetailsView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade100, width: 2),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.error_outline_rounded, color: Colors.red, size: 60),
                      SizedBox(height: 15),
                      Text("RETURN TO FAILED",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.red)),
                      SizedBox(height: 10),
                      Text(
                        "The order will be marked as undelivered and should be returned to the center.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Images are recommended for evidence of failure.",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ),
        // Two-Button Layout Footer
        Container(
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
                  onPressed: () => controller.currentStep.value = QuickStep.markPendingInnerReasons,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("MARK UNDELIVERED",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.currentStep.value = QuickStep.markPendingCustomerCancelImages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text("IMAGES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtherReturnFailedView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade100, width: 2),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.error_outline_rounded, color: Colors.red, size: 60),
                      SizedBox(height: 15),
                      Text("RETURN TO FAILED",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.red)),
                      SizedBox(height: 10),
                      Text(
                        "The order will be marked as undelivered and should be returned to the center.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Images are recommended for evidence of failure.",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ),
        // Two-Button Layout Footer
        Container(
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
                  onPressed: () => controller.currentStep.value = QuickStep.markPendingInnerReasons,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("MARK UNDELIVERED",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.currentStep.value = QuickStep.markPendingOtherImages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text("IMAGES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtherImagesView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("CAPTURE PROOF",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                const Text(
                    "Please capture front and back photos as evidence of the failed delivery."),
                const SizedBox(height: 20),
                Obx(() => Row(
                      children: [
                        _ImagePickerBox(
                          label: "FRONT PHOTO",
                          file: controller.customerCancelImages[0],
                          onTap: () => controller.pickCustomerCancelImage(0),
                        ),
                        const SizedBox(width: 15),
                        _ImagePickerBox(
                          label: "BACK PHOTO",
                          file: controller.customerCancelImages[1],
                          onTap: () => controller.pickCustomerCancelImage(1),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5))
          ]),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                  Get.snackbar("Success", "Images uploaded successfully (UI Only).",
                      snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("SUBMIT CANCELLATION",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagesView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("CAPTURE PROOF",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                const Text(
                    "Please capture front and back photos as evidence of the failed delivery."),
                const SizedBox(height: 20),
                Obx(() => Row(
                      children: [
                        _ImagePickerBox(
                          label: "FRONT PHOTO",
                          file: controller.customerCancelImages[0],
                          onTap: () => controller.pickCustomerCancelImage(0),
                        ),
                        const SizedBox(width: 15),
                        _ImagePickerBox(
                          label: "BACK PHOTO",
                          file: controller.customerCancelImages[1],
                          onTap: () => controller.pickCustomerCancelImage(1),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5))
          ]),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.uploadCustomerCancelImages(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("SUBMIT CANCELLATION",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInnerReasonsView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("SELECT REASON",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 15),
                Obx(() => Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text("REASON 1 (WITH OTP)", style: TextStyle(fontSize: 14)),
                          value: "1",
                          groupValue: controller.selectedInnerReasonId.value,
                          onChanged: (val) => controller.selectedInnerReasonId.value = val!,
                          activeColor: AppColors.primary,
                        ),
                        RadioListTile<String>(
                          title: const Text("REASON 2 (TEXTFIELD)", style: TextStyle(fontSize: 14)),
                          value: "2",
                          groupValue: controller.selectedInnerReasonId.value,
                          onChanged: (val) => controller.selectedInnerReasonId.value = val!,
                          activeColor: AppColors.primary,
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
        _buildInnerFooter(isNext: true),
      ],
    );
  }

  Widget _buildInnerOtpView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
              child: Column(
                children: [
                  const Icon(Icons.mark_email_unread_outlined, size: 80, color: AppColors.primary),
                  const SizedBox(height: 30),
                  const Text("VERIFY OTP",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  const SizedBox(height: 15),
                  const Text(
                    "PLEASE ENTER THE 4-DIGIT OTP",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 40),
                  Pinput(
                    length: 4,
                    controller: controller.innerOtpController,
                    onChanged: (val) => controller.innerOtpText.value = val,
                    defaultPinTheme: PinTheme(
                      width: 60,
                      height: 65,
                      textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildInnerFooter(isSubmit: true),
      ],
    );
  }

  Widget _buildInnerCommentView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("ADDITIONAL DETAILS",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  const Text("Please provide any additional comments or reason details. This is optional.",
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller.innerCommentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Enter your comment here...",
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildInnerFooter(isSubmit: true),
      ],
    );
  }

  Widget _buildInnerFooter({bool isNext = false, bool isSubmit = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
      ]),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => controller.previousMarkPendingStep(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: const BorderSide(color: AppColors.textSecondary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("BACK", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Obx(() {
              bool canPress = true;
              if (controller.currentStep.value == QuickStep.markPendingInnerReasons && controller.selectedInnerReasonId.value.isEmpty) {
                canPress = false;
              }
              if (controller.currentStep.value == QuickStep.markPendingInnerOtp && controller.innerOtpText.value.length != 4) {
                canPress = false;
              }
              return ElevatedButton(
                onPressed: canPress ? () => controller.nextMarkPendingStep() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(isNext ? "NEXT" : "SUBMIT", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(double width,
      {bool isReasons = false,
      bool isOtp = false,
      bool isDetails = false}) {
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
              onPressed: () => controller.previousMarkPendingStep(),
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
              bool canPress = true;
              if (isReasons && controller.selectedCustomerCancelReasonId.value.isEmpty) canPress = false;
              if (isOtp && controller.customerCancelOtpText.value.length != 4) canPress = false;

              return ElevatedButton(
                onPressed: canPress ? () => controller.nextMarkPendingStep() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                    isOtp || isReasons
                        ? "NEXT"
                        : isDetails
                            ? "SUBMIT"
                            : "NEXT",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ImagePickerBox extends StatelessWidget {
  final String label;
  final File? file;
  final VoidCallback onTap;

  const _ImagePickerBox({
    required this.label,
    this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: file != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(file!,
                          fit: BoxFit.cover, width: double.infinity),
                    )
                  : const Center(
                      child: Icon(Icons.add_a_photo,
                          color: AppColors.primary, size: 40)),
            ),
          ),
        ],
      ),
    );
  }
}
