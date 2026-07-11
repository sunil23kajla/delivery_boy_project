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
    return Obx(() {
      final step = controller.currentStep.value;
      final isRTDetails = step == QuickStep.markPendingCustomerCancelDetails;
      final isInnerStep = step == QuickStep.markPendingInnerReasons ||
          step == QuickStep.markPendingInnerOtp ||
          step == QuickStep.markPendingInnerComment;

      final isRtDeliverStep = step == QuickStep.markDeliveredOtp ||
          step == QuickStep.markDeliveredOptions ||
          step == QuickStep.markDeliveredRecipientDetails ||
          step == QuickStep.markDeliveredImages ||
          step == QuickStep.markPendingCustomerCancelDetails ||
          step == QuickStep.markPendingRtSellerOtp ||
          step == QuickStep.markPendingRtSellerOptions ||
          step == QuickStep.markPendingRtSellerDetails ||
          step == QuickStep.markPendingRtSellerImages;

      final isInnerFlow = step == QuickStep.markPendingInnerReasons ||
          step == QuickStep.markPendingInnerOtp ||
          step == QuickStep.markPendingInnerComment;

      final isOuterReasons = step == QuickStep.markPendingCustomerCancelReasons;
      final isOuterOtp = step == QuickStep.markDeliveredOtp &&
          controller.isOuterFlowEntry.value;

      final bool useMarkUndeliveredTitle =
          isInnerFlow || isOuterReasons || isOuterOtp;

      return PopScope(
        canPop: isOuterReasons, // Only allow pop from first step
        onPopInvoked: (didPop) {
          if (!didPop) {
            // System back button was pressed but intercepted
            controller.previousMarkPendingStep();
          } else {
            controller.hideLoading();
          }
        },
        child: LoadingOverlay(
          isLoading: controller.isLoadingRx,
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FB),
            appBar: AppBar(
              title: Text(
                "MARK UNDELIVERED",
                style: TextStyle(
                  color: (isRTDetails || isInnerStep || isRtDeliverStep)
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              backgroundColor: (isRTDetails || isInnerStep || isRtDeliverStep)
                  ? AppColors.primary
                  : Colors.white,
              elevation: 0,
              centerTitle: (isInnerStep ||
                      isRtDeliverStep ||
                      isOuterReasons ||
                      isOuterOtp)
                  ? true
                  : false,
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: (isRTDetails || isInnerStep || isRtDeliverStep)
                        ? Colors.white
                        : Colors.black),
                onPressed: () => controller.previousMarkPendingStep(),
              ),
              actions: [
                if (!useMarkUndeliveredTitle)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        _getStepLabel(step),
                        style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ),
                  )
              ],
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
                case QuickStep.markPendingOtherImages:
                  return _buildOtherImagesView(context);
                case QuickStep.markPendingInnerReasons:
                  return _buildInnerReasonsView(context);
                case QuickStep.markPendingInnerOtp:
                  return _buildInnerOtpView(context);
                case QuickStep.markPendingInnerComment:
                  return _buildInnerCommentView(context);
                case QuickStep.markDeliveredOtp:
                  return _buildRtDeliverOtpView(context);
                case QuickStep.markDeliveredOptions:
                  return _buildRtDeliverOptionsView(context);
                case QuickStep.markDeliveredRecipientDetails:
                  return _buildRtDeliverRecipientDetailsView(context);
                case QuickStep.markDeliveredImages:
                  return _buildRtDeliverImagesView(context);
                case QuickStep.markPendingRtSellerOtp:
                  return _buildRtSellerOtpView(context);
                case QuickStep.markPendingRtSellerOptions:
                  return _buildRtSellerOptionsView(context);
                case QuickStep.markPendingRtSellerDetails:
                  return _buildRtSellerDetailsView(context);
                case QuickStep.markPendingRtSellerImages:
                  return _buildRtSellerImagesView(context);
                default:
                  return const Center(child: CircularProgressIndicator());
              }
            }),
          ),
        ),
      );
    });
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
                        final name = (reason['reason'] ?? reason['name'] ?? "")
                            .toString();
                        return Obx(() => RadioListTile<String>(
                              title: Text(name.toUpperCase(),
                                  style: const TextStyle(fontSize: 14)),
                              value: id,
                              groupValue: controller
                                  .selectedCustomerCancelReasonId.value,
                              onChanged: (val) {
                                if (val != null) {
                                  controller.selectedCustomerCancelReasonId
                                      .value = val;
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
                  const Icon(Icons.mark_email_unread_outlined,
                      size: 80, color: AppColors.primary),
                  const SizedBox(height: 30),
                  const Text("VERIFY OTP",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  const SizedBox(height: 15),
                  const Text(
                    "PLEASE ENTER THE 4-DIGIT OTP PROVIDED BY THE CUSTOMER",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 40),
                  Pinput(
                    length: 4,
                    controller: controller.customerCancelOtpController,
                    onChanged: (val) =>
                        controller.customerCancelOtpText.value = val,
                    defaultPinTheme: PinTheme(
                      width: 60,
                      height: 65,
                      textStyle: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.send_rounded,
                        size: 16, color: AppColors.primary),
                    label: const Text(
                      "SEND OTP",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
    final data = controller.selectedOrder.value;
    final order = data?['order'] ?? {};
    final customer = data?['customer'] ?? {};
    final address = data?['delivery_address'] ?? {};
    final items = data?['items'] as List? ?? [];

    final trackingId = order['tracking_id']?.toString() ?? "N/A";
    final orderId = order['id']?.toString() ?? "N/A";
    final customerName = customer['name']?.toString() ?? "Customer";
    final customerMobile = customer['mobile']?.toString() ?? "";
    final lat = address['latitude']?.toString() ?? "";
    final long = address['longitude']?.toString() ?? "";

    // Format address string
    final landmark = address['landmark']?.toString() ?? "";
    final area = address['area']?['name']?.toString() ?? "";
    final city = address['city']?['name']?.toString() ?? "";
    final pincode = address['pincode']?.toString() ?? "";

    final fullAddress =
        [landmark, area, city, pincode].where((e) => e.isNotEmpty).join(", ");
    final shippingAddress =
        fullAddress.isNotEmpty ? fullAddress : "Address not available";

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                // Tracking Id and Order Id Card
                _buildInfoCard([
                  _buildRowItem(
                      Icons.qr_code_scanner, "TRACKING ID", trackingId),
                  const Divider(height: 1, indent: 40),
                  _buildRowItem(Icons.tag, "ORDER ID", orderId),
                ]),
                const SizedBox(height: 15),

                // Product Card (Purple Gradient) - Now listing all items
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDD78F5), Color(0xFFB180F3)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.purple.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.shopping_bag,
                                color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Text("RETURN TO SELLER",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      ...items.map((item) {
                        final pName = item['product_name']?.toString() ?? "N/A";
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8, left: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("• ",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Text(pName,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // Customer Info Card
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFF9C27B0),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person,
                                  color: Colors.white, size: 25),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(customerName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                            ),
                            // Call and Navigator buttons
                            InkWell(
                              onTap: () =>
                                  controller.launchCaller(customerMobile),
                              child: _buildCircleButton(
                                  Icons.call_outlined,
                                  const Color(0xFFF3E5F5),
                                  const Color(0xFF9C27B0)),
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () => controller.launchMap(lat, long),
                              child: _buildCircleButton(Icons.near_me_outlined,
                                  const Color(0xFFE3F2FD), AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(height: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined,
                                color: Colors.grey, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                shippingAddress,
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                    height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom Footer Buttons
        Container(
          padding: const EdgeInsets.all(20),
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
                  onPressed: () => controller.nextMarkPendingStep(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("MARK UNDELIVERED",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 11)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Transition to Return to Seller OTP Screen
                    controller.resetRtSellerState(); // Clean start
                    controller.currentStep.value =
                        QuickStep.markPendingRtSellerOtp;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("MARK DELIVERED",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStepLabel(QuickStep step) {
    switch (step) {
      case QuickStep.markPendingCustomerCancelDetails:
        return "STEP 1/6";
      case QuickStep.markPendingRtSellerOtp:
        return "STEP 3/6";
      case QuickStep.markPendingRtSellerOptions:
        return "STEP 4/6";
      case QuickStep.markPendingRtSellerDetails:
        return "STEP 5/6";
      case QuickStep.markPendingRtSellerImages:
        return "STEP 6/6";
      case QuickStep.markDeliveredOtp:
        return "STEP 2/6";
      case QuickStep.markDeliveredOptions:
        return "STEP 4/6";
      case QuickStep.markDeliveredRecipientDetails:
        return "STEP 5/6";
      case QuickStep.markDeliveredImages:
        return "STEP 6/6";
      default:
        return "";
    }
  }

  Widget _buildRtDeliverOtpView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
              child: Column(
                children: [
                  const Text("VERIFY OTP",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  const SizedBox(height: 40),
                  Pinput(
                    length: 4,
                    controller: controller.rtDeliverOtpController,
                    onChanged: (val) => controller.rtDeliverOtpText.value = val,
                    defaultPinTheme: PinTheme(
                      width: 65,
                      height: 70,
                      textStyle: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.send_rounded,
                        size: 16, color: AppColors.primary),
                    label: const Text(
                      "SEND OTP",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "TO VIEW THE OTP, CLICK ON THIS ORDER IN THE MY ORDER SECTION OF THE CUSTOMER MOB. APPLICATION AND VIEW THE OTP",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildFooter(0, isRtDeliverNext: true),
      ],
    );
  }

  Widget _buildRtDeliverOptionsView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("SELECT DELIVERY OPTION",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 25),
                _buildOptionCard(
                  "DELIVERD TO SELLER",
                  "AUTOMATICK FILL CUSTOMER DETAILS",
                  "seller",
                ),
                const SizedBox(height: 15),
                _buildOptionCard(
                  "DELIVERED TO OTHER",
                  "AS PER SELLER REQS -> MANUAL FILL",
                  "other",
                ),
              ],
            ),
          ),
        ),
        _buildFooter(0, isRtDeliverNext: true),
      ],
    );
  }

  Widget _buildOptionCard(String title, String subtitle, String value) {
    return Obx(() {
      final isSelected = controller.rtDeliverSelectedOption.value == value;
      return GestureDetector(
        onTap: () => controller.rtDeliverSelectedOption.value = value,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade200,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 5),
                    Text(subtitle,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isSelected ? AppColors.primary : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildRtDeliverRecipientDetailsView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("RECIPIENT DETAILS",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 30),
                const Text("NAME",
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.rtDeliverRecipientNameController,
                  onChanged: (val) =>
                      controller.rtDeliverRecipientNameText.value = val,
                  decoration: InputDecoration(
                    hintText: "Enter Name",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("MOB.",
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.rtDeliverRecipientPhoneController,
                  onChanged: (val) =>
                      controller.rtDeliverRecipientPhoneText.value = val,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "Enter Mobile",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildFooter(0, isRtDeliverNext: true),
      ],
    );
  }

  Widget _buildRtDeliverImagesView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("CLICK IMAGES",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildImageSlot(0, "FRONT", isRequired: true),
                    _buildImageSlot(1, "BACK", isRequired: true),
                    _buildImageSlot(2, "CUSTMER", isRequired: false),
                  ],
                ),
                const SizedBox(height: 40),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                          text: "REQUIRED: ",
                          style: TextStyle(color: Colors.red)),
                      TextSpan(
                          text: "FRONT, BACK",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                          text: "OPTIONAL: ",
                          style: TextStyle(color: Colors.blue)),
                      TextSpan(
                          text: "CUSTMER",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildFooter(0, isRtDeliverNext: true, isRtDeliverFinal: true),
      ],
    );
  }

  Widget _buildImageSlot(int index, String label, {required bool isRequired}) {
    return Column(
      children: [
        Obx(() {
          final image = controller.rtDeliverImages[index];
          return GestureDetector(
            onTap: () => controller.pickRtDeliverImage(index),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isRequired
                      ? Colors.red.withOpacity(0.3)
                      : Colors.blue.withOpacity(0.3),
                ),
              ),
              child: image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(image, fit: BoxFit.cover),
                    )
                  : Icon(Icons.camera_alt,
                      color: isRequired ? Colors.red : Colors.blue, size: 30),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRtSellerOptionsView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("SELECT DELIVERY OPTION",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 30),
                Obx(() => _buildSelectionCard(
                      title: "DELIVERD TO SELLER",
                      subtitle: "AUTOMATICK FILL CUSTOMER DETAILS",
                      isSelected:
                          controller.rtSellerSelectedOption.value == 'seller',
                      onTap: () =>
                          controller.rtSellerSelectedOption.value = 'seller',
                    )),
                const SizedBox(height: 20),
                Obx(() => _buildSelectionCard(
                      title: "DELIVERED TO OTHER",
                      subtitle: "AS PER SELLER REQS -> MANUAL FILL",
                      isSelected:
                          controller.rtSellerSelectedOption.value == 'other',
                      onTap: () =>
                          controller.rtSellerSelectedOption.value = 'other',
                    )),
              ],
            ),
          ),
        ),
        _buildFooter(0, isRtDeliverNext: true),
      ],
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  Text(subtitle,
                      style:
                          TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRtSellerOtpView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
              child: Column(
                children: [
                  const Text("VERIFY OTP",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  const SizedBox(height: 40),
                  Pinput(
                    length: 4,
                    controller: controller.rtSellerOtpController,
                    onChanged: (val) => controller.rtSellerOtpText.value = val,
                    defaultPinTheme: PinTheme(
                      width: 65,
                      height: 70,
                      textStyle: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.send_rounded,
                        size: 16, color: AppColors.primary),
                    label: const Text(
                      "SEND OTP",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "PLEASE ENTER THE OTP TO PROCEED WITH RETURN TO SELLER",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildFooter(0, isRtDeliverNext: true),
      ],
    );
  }

  Widget _buildRtSellerDetailsView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("SELLER DETAILS",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 30),
                const Text("SELLER NAME",
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.rtSellerNameController,
                  onChanged: (val) => controller.rtSellerNameText.value = val,
                  decoration: InputDecoration(
                    hintText: "Enter Seller Name",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("SELLER MOBILE",
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.rtSellerMobileController,
                  onChanged: (val) => controller.rtSellerMobileText.value = val,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "Enter Mobile Number",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildFooter(0, isRtDeliverNext: true),
      ],
    );
  }

  Widget _buildRtSellerImagesView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("DOCUMENT RETURN",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 30),
                Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ImagePickerBox(
                          label: "FRONT",
                          file: controller.rtSellerImages[0],
                          onTap: () => controller.pickRtSellerImage(0),
                        ),
                        const SizedBox(width: 10),
                        _ImagePickerBox(
                          label: "BACK",
                          file: controller.rtSellerImages[1],
                          onTap: () => controller.pickRtSellerImage(1),
                        ),
                        const SizedBox(width: 10),
                        _ImagePickerBox(
                          label: "OTHER",
                          file: controller.rtSellerImages[2],
                          onTap: () => controller.pickRtSellerImage(2),
                        ),
                      ],
                    )),
                const SizedBox(height: 40),
                const Text(
                  "PLEASE UPLOAD AT LEAST TWO IMAGES TO COMPLETE THE RETURN PROCESS",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        _buildFooter(0, isRtDeliverNext: true, isRtDeliverFinal: true),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildRowItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 20),
          const SizedBox(width: 15),
          Text(label,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(": ", style: const TextStyle(color: Colors.grey)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, Color bg, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: 22),
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
                      Icon(Icons.error_outline_rounded,
                          color: Colors.red, size: 60),
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
                  onPressed: () => controller.nextMarkPendingStep(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("MARK UNDELIVERED",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.currentStep.value =
                      QuickStep.markPendingOtherImages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text("IMAGES",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
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
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                Get.snackbar(
                    "Success", "Images uploaded successfully (UI Only).",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("SUBMIT CANCELLATION",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
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
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("SUBMIT CANCELLATION",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
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
                const Text("SELECT CANCELLATION REASON",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF333333))),
                const SizedBox(height: 30),
                Obx(() => Column(
                      children: controller.returnToFailedReasons.map((reason) {
                        final id = reason['id'].toString();
                        final name = (reason['reason'] ?? reason['name'] ?? "")
                            .toString()
                            .toUpperCase();
                        final isSelected =
                            controller.selectedInnerReasonId.value == id;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.grey.shade100
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: RadioListTile<String>(
                            title: Text(name,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600)),
                            value: id,
                            groupValue: controller.selectedInnerReasonId.value,
                            onChanged: (val) =>
                                controller.selectedInnerReasonId.value = val!,
                            activeColor: AppColors.primary,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 10),
                          ),
                        );
                      }).toList(),
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
    final selectedReason = controller.returnToFailedReasons.firstWhere(
        (r) => r['id'].toString() == controller.selectedInnerReasonId.value,
        orElse: () => {"reason": "N/A"});
    final reasonName =
        (selectedReason['reason'] ?? "N/A").toString().toUpperCase();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("REASON: $reasonName",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 40),
                  const Text("VERIFY OTP",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey)),
                  const SizedBox(height: 15),
                  Center(
                    child: Pinput(
                      length: 4,
                      controller: controller.innerOtpController,
                      onChanged: (val) => controller.innerOtpText.value = val,
                      defaultPinTheme: PinTheme(
                        width: 55,
                        height: 55,
                        textStyle: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.send_rounded,
                          size: 16, color: AppColors.primary),
                      label: const Text(
                        "SEND OTP",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Center(
                    child: Text(
                      "Enter the 4-digit OTP mentioned above",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
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
    final selectedReason = controller.returnToFailedReasons.firstWhere(
        (r) => r['id'].toString() == controller.selectedInnerReasonId.value,
        orElse: () => {"reason": "N/A"});
    final reasonName =
        (selectedReason['reason'] ?? "N/A").toString().toUpperCase();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("REASON: $reasonName",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 40),
                  const Text("REASON DETAILS",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: controller.innerCommentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Type reason here...",
                      filled: true,
                      fillColor: Colors.white,
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
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("BACK",
                  style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Obx(() {
              bool canPress = true;
              if (controller.currentStep.value ==
                      QuickStep.markPendingInnerReasons &&
                  controller.selectedInnerReasonId.value.isEmpty) {
                canPress = false;
              }
              if (controller.currentStep.value ==
                      QuickStep.markPendingInnerOtp &&
                  controller.innerOtpText.value.length != 4) {
                canPress = false;
              }

              final btnColor = isSubmit
                  ? Colors.orange
                  : (canPress ? AppColors.primary : Colors.grey.shade300);

              return ElevatedButton(
                onPressed:
                    canPress ? () => controller.nextMarkPendingStep() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: btnColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(isNext ? "NEXT" : "MARK PENDING",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        fontSize: 12)),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(int i,
      {bool isOtp = false,
      bool isReasons = false,
      bool isInnerReason = false,
      bool isRtDeliverNext = false,
      bool isRtDeliverFinal = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => controller.previousMarkPendingStep(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("BACK",
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Obx(() {
              // Access an observable to satisfy GetX Obx requirement
              final step = controller.currentStep.value;

              // Custom next button logic for RT Deliver
              if (isRtDeliverNext) {
                bool isEnabled = true;
                if (step == QuickStep.markDeliveredOtp) {
                  isEnabled = controller.rtDeliverOtpText.value.length == 4;
                } else if (step == QuickStep.markDeliveredOptions) {
                  isEnabled =
                      controller.rtDeliverSelectedOption.value.isNotEmpty;
                } else if (step == QuickStep.markPendingRtSellerOtp) {
                  isEnabled = controller.rtSellerOtpText.value.length == 4;
                } else if (step == QuickStep.markPendingRtSellerOptions) {
                  isEnabled =
                      controller.rtSellerSelectedOption.value.isNotEmpty;
                } else if (step == QuickStep.markPendingRtSellerDetails) {
                  isEnabled = controller.rtSellerNameText.value
                          .trim()
                          .isNotEmpty &&
                      controller.rtSellerMobileText.value.trim().length == 10;
                } else if (step == QuickStep.markDeliveredRecipientDetails) {
                  isEnabled = controller.rtDeliverRecipientNameText.value
                          .trim()
                          .isNotEmpty &&
                      controller.rtDeliverRecipientPhoneText.value
                              .trim()
                              .length ==
                          10;
                } else if (step == QuickStep.markPendingRtSellerImages) {
                  // At least one image required
                  isEnabled =
                      controller.rtSellerImages.any((img) => img != null);
                }

                return ElevatedButton(
                  onPressed:
                      isEnabled ? () => controller.nextMarkPendingStep() : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEnabled
                        ? (isRtDeliverFinal
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.8))
                        : Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(isRtDeliverFinal ? "DELIVERED" : "NEXT",
                      style: TextStyle(
                          color:
                              isEnabled ? Colors.white : Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                );
              }

              // Original logic preserved for other steps...
              final isEnabled = isReasons
                  ? controller.selectedCustomerCancelReasonId.value.isNotEmpty
                  : isOtp
                      ? controller.customerCancelOtpText.value.length == 4
                      : isInnerReason
                          ? controller.selectedInnerReasonId.value.isNotEmpty
                          : true;

              return ElevatedButton(
                onPressed:
                    isEnabled ? () => controller.nextMarkPendingStep() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isEnabled ? AppColors.primary : Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(isInnerReason ? "PROCEED" : "NEXT",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
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
