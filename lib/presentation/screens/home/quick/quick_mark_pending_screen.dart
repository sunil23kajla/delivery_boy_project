import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pinput/pinput.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:delivery_boy/presentation/screens/home/quick/quick_flow_controller.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';
import 'package:delivery_boy/presentation/widgets/loading_overlay.dart';

class QuickMarkPendingScreen extends GetView<QuickFlowController> {
  const QuickMarkPendingScreen({super.key});

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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Obx(() {
            final bool isPickup = !controller.isDeliveryUndelivered.value;
            final String title = isPickup ? "Mark Pending" : "Mark Undelivered";
            final Color bgColor = isPickup ? AppColors.primary : Colors.white;
            final Color textColor = isPickup ? Colors.white : Colors.black;

            return AppBar(
              title: Text(title,
                  style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold)),
              backgroundColor: bgColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: textColor),
                onPressed: () => controller.previousMarkPendingStep(),
              ),
            );
          }),
        ),
        body: Obx(() {
          switch (controller.currentStep.value) {
            case QuickStep.markPendingReason:
              return _buildReasonSelection();
            case QuickStep.markPendingOtp:
              return _buildOtpVerification(context);
            case QuickStep.markPendingPreOtp:
              return _buildPreOtpView(context);
            case QuickStep.markPendingComment:
              return _buildCommentInput(context);
            case QuickStep.markPendingRTDetails:
              return _buildRTDetailsView(context);
            case QuickStep.markPendingRTOtp:
              return _buildRTOtpView(context);
            case QuickStep.markPendingRTImages:
              return _buildRTEvidenceView(context);
            case QuickStep.markPendingCustomerCancelOtp:
              return _buildCustomerCancelOtpView(context);
            case QuickStep.markPendingCustomerCancelReasons:
              return _buildCustomerCancelReasonsView(context);
            case QuickStep.markPendingCustomerCancelDetails:
              return _buildCustomerCancelDetailsView(context);
            case QuickStep.markPendingCustomerCancelImages:
              return _buildCustomerCancelImagesView(context);
            default:
              return const Center(child: CircularProgressIndicator());
          }
        }),
        bottomNavigationBar: const SizedBox.shrink(),
      ),
      ),
    );
  }

  Widget _buildRTDetailsView(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final data = controller.selectedOrder.value ?? {};
    final order = data['order'] as Map<String, dynamic>? ?? {};
    final customer = data['customer'] as Map<String, dynamic>? ?? {};

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRTIdentifiersCard(order),
                const SizedBox(height: 15),
                if (controller.isDeliveryUndelivered.value)
                  _buildDeliveryFailedCard()
                else
                  _buildRTProductHighlightCard(data),
                const SizedBox(height: 15),
                _buildRTCustomerCard(customer),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _buildRTFooter(width, isDetails: true),
      ],
    );
  }

  Widget _buildPreOtpView(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("VERIFY OTP",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 30),
                Pinput(
                  length: 4,
                  controller: controller.pendingPreOtpController,
                  onChanged: (val) => controller.pendingPreOtpText.value = val,
                  defaultPinTheme: PinTheme(
                    width: 55,
                    height: 60,
                    textStyle: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "PLEASE ENTER THE 4-DIGIT OTP PROVIDED BY THE CUSTOMER TO PROCEED WITH CANCELLATION",
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        _buildRTFooter(width, isPreOtp: true),
      ],
    );
  }

  Widget _buildRTOtpView(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("VERIFY OTP",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 30),
                Pinput(
                  length: 4,
                  controller: controller.pendingOtpController,
                  onChanged: (val) => controller.pendingOtpText.value = val,
                  defaultPinTheme: PinTheme(
                    width: 55,
                    height: 60,
                    textStyle: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "TO VIEW THE OTP, CLICK ON THIS ORDER IN THE MY ORDER SECTION OF THE CUSTOMER MOB. APPLICATION AND VIEW THE OTP",
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        _buildRTFooter(width, isOtp: true),
      ],
    );
  }

  Widget _buildRTCustomerCard(Map<String, dynamic> customer) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 18,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  customer['name']?.toString() ?? "-------",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
              ),
              IconButton.filledTonal(
                onPressed: () {
                  final phone = customer['mobile']?.toString();
                  if (phone != null && phone.isNotEmpty) {
                    launchUrl(Uri.parse("tel:$phone"));
                  }
                },
                icon: const Icon(Icons.call, color: Colors.blue),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: () {
                  final address = customer['address']?.toString();
                  if (address != null) {
                    launchUrl(Uri.parse(
                        "https://www.google.com/maps/search/?api=1&query=$address"));
                  }
                },
                icon: const Icon(Icons.navigation_outlined, color: Colors.blue),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                ),
              ),
            ],
          ),
          const Divider(height: 25),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  customer['address']?.toString() ?? "-------",
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRTIdentifiersCard(Map<String, dynamic> order) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          _buildRTInfoItem(Icons.qr_code, "TRACKING ID",
              order['order_number']?.toString() ?? "-------"),
          const SizedBox(height: 12),
          _buildRTInfoItem(Icons.numbers, "ORDER ID",
              order['order_id']?.toString() ?? "-------"),
        ],
      ),
    );
  }

  Widget _buildRTProductHighlightCard(Map<String, dynamic> data) {
    final order = data['order'] as Map<String, dynamic>? ?? {};
    final payment = data['payment'] as Map<String, dynamic>? ?? {};
    final items = data['items'] as List<dynamic>? ?? [];
    final item = items.isNotEmpty ? items[0] : {};

    final bool isPaid =
        (payment['payment_status'] ?? order['payment_status'] ?? '')
                .toString()
                .toUpperCase() ==
            "PAID";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.shade100, width: 2),
        boxShadow: [
          BoxShadow(
              color: Colors.purple.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.purple.shade200],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.shopping_bag,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "PRODUCT TO RETURN",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['product_name']?.toString() ??
                          order['product']?.toString() ??
                          "-------",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color:
                      isPaid ? Colors.green.shade100 : Colors.orange.shade100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isPaid ? Icons.check_circle : Icons.pending,
                      color: isPaid ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isPaid ? "PAYMENT COLLECTED" : "CASH TO COLLECT",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Text(
                  "₹${payment['total_amount'] ?? order['total_amount'] ?? order['amount'] ?? '0.00'}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryFailedCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade200, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(15),
            ),
            child:
                const Icon(Icons.cancel_outlined, color: Colors.red, size: 30),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "DELIVERY FAILED",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Please proceed to capture evidence images for cancellation.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRTInfoItem(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        SizedBox(
          width: 85,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary)),
        ),
        const Text(" :  ", style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRTFooter(double width,
      {bool isDetails = false,
      bool isOtp = false,
      bool isPreOtp = false,
      bool isEvidence = false}) {
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
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Obx(() {
              final isOtpValid = isPreOtp
                  ? controller.pendingPreOtpText.value.length == 4
                  : controller.pendingOtpText.value.length == 4;
              final areImagesDone =
                  controller.pendingRTImages[0] != null &&
                      controller.pendingRTImages[1] != null;

              bool canPress = true;
              if ((isOtp || isPreOtp) && !isOtpValid) canPress = false;
              if (isEvidence && !areImagesDone) canPress = false;

              final isComment = controller.currentStep.value == QuickStep.markPendingComment;

              return ElevatedButton(
                onPressed: canPress
                    ? () => controller.nextMarkPendingStep()
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isEvidence ? Colors.green : AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                    isEvidence
                        ? "CONFIRM DELIVERED"
                        : (isComment || isOtp)
                            ? "MARK PENDING"
                            : "NEXT",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRTEvidenceView(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("CLICK IMAGES",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRTImageSlot("FRONT", 0, required: true),
                    _buildRTImageSlot("BACK", 1, required: true),
                    _buildRTImageSlot("CUSTOMER", 2, required: false),
                  ],
                ),
                const SizedBox(height: 40),
                const Text("REQUIRED: FRONT, BACK",
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                const Text("OPTIONAL: CUSTOMER",
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ],
            ),
          ),
        ),
        _buildRTFooter(width, isEvidence: true),
      ],
    );
  }

  Widget _buildRTImageSlot(String label, int index, {required bool required}) {
    return Column(
      children: [
        Obx(() => InkWell(
              onTap: () => controller.pickPendingRTImage(index),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: required
                          ? Colors.red.shade200
                          : Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: controller.pendingRTImages[index] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(controller.pendingRTImages[index]!,
                            fit: BoxFit.cover),
                      )
                    : Icon(Icons.camera_alt,
                        color: required ? Colors.red : Colors.blue, size: 30),
              ),
            )),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildReasonSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "SELECT CANCELLATION REASON",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
        ),
        Expanded(
          child: Obx(() => ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: controller.pendingReasons.length,
            itemBuilder: (context, index) {
              final reason = controller.pendingReasons[index];
              final String name =
                  (reason['name'] ?? reason['reason'] ?? "Unknown Reason")
                      .toString()
                      .toUpperCase();
              final String reasonId = reason['id'].toString();

              return Obx(() {
                final bool isSelected =
                    controller.selectedPendingReasonId.value == reasonId;
                return RadioListTile<String>(
                  title: Text(name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? AppColors.primary : Colors.black87,
                      )),
                  value: reasonId,
                  groupValue: controller.selectedPendingReasonId.value,
                  onChanged: (val) {
                    if (val != null) {
                      controller.selectMarkPendingReason(reason);
                    }
                  },
                  activeColor: AppColors.primary,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                );
              });
            },
          )),
        ),
        _buildRTFooter(MediaQuery.of(Get.context!).size.width),
      ],
    );
  }

  Widget _buildCustomerCancelReasonsView(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
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
        _buildCustomerCancelFooter(width, isReasons: true),
      ],
    );
  }

  Widget _buildCustomerCancelDetailsView(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("ADDITIONAL DETAILS",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 15),
                const Text("PLEASE PROVIDE MORE INFORMATION ABOUT THE CANCELLATION",
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                TextField(
                  controller: controller.customerCancelCommentController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Enter reason details here...",
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildCustomerCancelFooter(width, isDetails: true),
      ],
    );
  }

  Widget _buildCustomerCancelOtpView(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("CUSTOMER CANCEL OTP",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 30),
                Pinput(
                  length: 4,
                  controller: controller.customerCancelOtpController,
                  onChanged: (val) => controller.customerCancelOtpText.value = val,
                  defaultPinTheme: PinTheme(
                    width: 55,
                    height: 60,
                    textStyle: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "PLEASE ENTER THE 4-DIGIT OTP PROVIDED BY THE CUSTOMER TO PROCEED WITH CANCELLATION",
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        _buildCustomerCancelFooter(width, isOtp: true),
      ],
    );
  }

  Widget _buildCustomerCancelImagesView(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("UPLOAD EVIDENCE IMAGES",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                const Text("PLEASE UPLOAD IMAGES FOR CANCELLATION PROOF",
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCustomerCancelImageSlot("FRONT IMAGE", 0),
                    _buildCustomerCancelImageSlot("BACK IMAGE", 1),
                  ],
                ),
              ],
            ),
          ),
        ),
        _buildCustomerCancelFooter(width, isImages: true),
      ],
    );
  }

  Widget _buildCustomerCancelImageSlot(String label, int index) {
    return Column(
      children: [
        Obx(() => InkWell(
              onTap: () async {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  controller.customerCancelImages[index] = File(pickedFile.path);
                }
              },
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: controller.customerCancelImages[index] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(controller.customerCancelImages[index]!,
                            fit: BoxFit.cover),
                      )
                    : const Icon(Icons.camera_alt, color: AppColors.primary, size: 40),
              ),
            )),
        const SizedBox(height: 10),
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildCustomerCancelFooter(double width,
      {bool isOtp = false, bool isReasons = false, bool isDetails = false, bool isImages = false}) {
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
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("BACK",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Obx(() {
              bool canPress = true;
              if (isOtp && controller.customerCancelOtpText.value.length != 4) canPress = false;
              if (isReasons && controller.selectedCustomerCancelReasonId.value.isEmpty) canPress = false;
              // Details (Description) is optional - removed canPress = false check
              if (isImages && (controller.customerCancelImages[0] == null || controller.customerCancelImages[1] == null)) canPress = false;

              return ElevatedButton(
                onPressed: canPress ? () => controller.nextMarkPendingStep() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isImages ? Colors.green : AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                    isImages
                        ? "FINISH"
                        : isDetails
                            ? "SUBMIT"
                            : isOtp
                                ? "MARK UNDELIVERED"
                                : "NEXT",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpVerification(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final reasonName = controller.selectedPendingReasonMap.value?['name'] ?? "";
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "REASON: ${reasonName.toString().toUpperCase()}",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 30),
                const Text("VERIFY OTP",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                const SizedBox(height: 15),
                Center(
                  child: Pinput(
                    length: 4,
                    controller: controller.pendingOtpController,
                    onChanged: (val) => controller.pendingOtpText.value = val,
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
                const Center(
                  child: Text(
                    "Please enter the 4-digit OTP provided by the party",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildRTFooter(width, isOtp: true),
      ],
    );
  }


  Widget _buildCommentInput(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final reasonName = controller.selectedPendingReasonMap.value?['name'] ?? "";
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "REASON: ${reasonName.toString().toUpperCase()}",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 30),
                const Text("REASON DETAILS",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                const SizedBox(height: 10),
                TextField(
                  controller: controller.pendingCommentController,
                  maxLines: 4,
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
            ),
          ),
        ),
        _buildRTFooter(width),
      ],
    );
  }
}
