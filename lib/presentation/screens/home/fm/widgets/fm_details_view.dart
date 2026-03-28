import 'package:delivery_boy/core/constants/app_colors.dart';
import 'package:delivery_boy/core/utils/external_actions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../fm_flow_controller.dart';

class FmDetailsView extends GetView<FmFlowController> {
  const FmDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIdentifiersCard(),
                const SizedBox(height: 15),
                _buildProductHighlightCard(width),
                const SizedBox(height: 15),
                _buildCustomerCard(),
                const SizedBox(height: 25),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text("PICKUP CHECKLIST",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1.2,
                          color: AppColors.textSecondary)),
                ),
                const SizedBox(height: 15),
                Obx(() {
                  if (!controller.isQuestionsFetched.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.questions.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text("No checklist questions for this order.",
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold)),
                      ),
                    );
                  }
                  return Column(
                    children: controller.questions.map((q) {
                      final qId = q['id'] ?? q['question_id'];
                      final qText =
                          q['question'] ?? q['question_text'] ?? "Question?";
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: _buildDynamicChecklistRow(qText, qId),
                      );
                    }).toList(),
                  );
                }),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
        _buildFooter(width),
      ],
    );
  }

  Widget _buildIdentifiersCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          _buildCardRow("Tracking ID", controller.shipment['barcode'] ?? "---",
              Icons.qr_code),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1),
          ),
          _buildCardRow(
              "Order ID", controller.shipment['orderId'] ?? "---", Icons.tag),
        ],
      ),
    );
  }

  Widget _buildCardRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildProductHighlightCard(double width) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade300, Colors.purple.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.purple.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child:
                const Icon(Icons.shopping_bag, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "PRODUCT TO PICKUP",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                      controller.product.value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("SELLER",
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(controller.shipment['name'] ?? "Unknown Vendor",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(controller.shipment['address'] ?? "No Address",
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.call,
                  label: "CALL",
                  color: Colors.green,
                  onTap: () {
                    if (controller.phone.value.isNotEmpty) {
                      ExternalActions.makeCall(controller.phone.value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.map,
                  label: "MAP",
                  color: Colors.blue,
                  onTap: () {
                    if (controller.lat.value != 0.0) {
                      ExternalActions.openMap(
                          controller.lat.value, controller.lng.value);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicChecklistRow(String label, int questionId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Obx(() {
          final currentAnswer = controller.answers[questionId];
          return Row(
            children: [
              _buildCheckOption("YES", currentAnswer == "yes",
                  () => controller.answers[questionId] = "yes"),
              const SizedBox(width: 12),
              _buildCheckOption("NO", currentAnswer == "no",
                  () => controller.answers[questionId] = "no"),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildCheckOption(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade300),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(double width) {
    return Container(
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
              onPressed: controller.startCancelFlow,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: BorderSide(color: Colors.red.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("MARK PENDING",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Obx(() => ElevatedButton(
                  onPressed:
                      (controller.answers.length == controller.questions.length)
                          ? controller.nextStep
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("NEXT",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                )),
          ),
        ],
      ),
    );
  }
}
