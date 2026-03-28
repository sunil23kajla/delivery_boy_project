import 'package:delivery_boy/presentation/widgets/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:delivery_boy/presentation/screens/home/quick/quick_flow_controller.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class QuickPickupScreen extends GetView<QuickFlowController> {
  const QuickPickupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: controller.isLoadingRx,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Obx(() => Text(
              controller.currentStep.value == QuickStep.pickupImages
                  ? "Click Images"
                  : "Pickup Verification",
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold))),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => controller.goBack(),
          ),
        ),
        body: Obx(() {
          if (controller.currentStep.value == QuickStep.pickupImages) {
            return _buildImagesView();
          }
          return _buildVerificationView();
        }),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildVerificationView() {
    final data = controller.pickupVerificationData.value;
    if (data == null) return const Center(child: CircularProgressIndicator());

    final order = data; // Root has tracking_id, order_id, etc.
    final vendor = data['vendor'] as Map<String, dynamic>? ?? {};
    // Match the JSON structure (items instead of order_items)
    final items = (data['items'] ?? data['order_items']) as List<dynamic>? ?? [];
    final payment = data['payment'] as Map<String, dynamic>? ?? {};
    final questions = data['verification_questions'] as List? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order IDs Section
          _buildIdCard(order),
          const SizedBox(height: 16),

          // Seller Details (Replacing Customer Details)
          const Text("SELLER INFO",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 8),
          _buildAddressCard(
            title: "SELLER DETAILS",
            name: vendor['name'] ?? vendor['shop_name'] ?? vendor['vendor_name'] ?? '-',
            address: vendor['address'] ?? vendor['shop_address'] ?? '-',
            mobile: vendor['mobile'] ?? vendor['mobile_number'] ?? vendor['vendor_mobile'] ?? '-',
            icon: Icons.store_outlined,
          ),
          const SizedBox(height: 16),

          // Product Details List
          const Text("PRODUCT DETAILS",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 8),
          if (items.isEmpty)
            _buildItemCard({
              'product_name': 'Sample Product (Static)',
              'qty': 1,
              'price': order['total_amount'] ?? '500.00'
            })
          else
            ...items.map((item) => _buildItemCard(item)),
          const SizedBox(height: 16),

          // Payment Summary
          const Text("PAYMENT DETAILS",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 8),
          _buildPaymentSummary(order, payment),
          const SizedBox(height: 24),

          // Verification Questions
          if (questions.isNotEmpty) ...[
            const Text("VERIFICATION",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 16),
            ...questions.map((q) {
              final question = q as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildCheckQuestion(question),
              );
            }),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildImagesView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("CLICK 2 IMAGES",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 10),
          const Text("Please take clear photos of the package Front and Back",
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(child: _buildImageButton(0, "FRONT")),
              const SizedBox(width: 15),
              Expanded(child: _buildImageButton(1, "BACK")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageButton(int index, String label) {
    return Obx(() => GestureDetector(
          onTap: () => controller.pickPickupImage(index),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black12),
              image: controller.pickupImages[index] != null
                  ? DecorationImage(
                      image: FileImage(controller.pickupImages[index]!),
                      fit: BoxFit.cover)
                  : null,
            ),
            child: controller.pickupImages[index] == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt,
                          size: 40, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text(label,
                          style: const TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  )
                : null,
          ),
        ));
  }

  Widget _buildIdCard(Map<String, dynamic> order) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          _buildDetailRow("Tracking ID", order['order_number']?.toString() ?? '-',
              isBold: true),
          const Divider(height: 24),
          _buildDetailRow(
              "Order ID", (order['order_id'] ?? order['id'] ?? '-').toString()),
        ],
      ),
    );
  }

  Widget _buildAddressCard({
    required String title,
    required String name,
    required String address,
    required String mobile,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          Text(name,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(address, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 16),
          Row(
            children: [
              _ActionButton(
                icon: Icons.call,
                label: "Call",
                color: Colors.green,
                onTap: () => launchUrl(Uri.parse("tel:$mobile")),
              ),
              const SizedBox(width: 12),
              _ActionButton(
                icon: Icons.location_on,
                label: "Map",
                color: Colors.blue,
                onTap: () => launchUrl(Uri.parse(
                    "https://www.google.com/maps/search/?api=1&query=$address")),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildItemCard(dynamic item) {
    // Correct mapping for product images from API JSON
    final images = (item['product_images'] ?? item['images']) as List<dynamic>? ?? [];
    final imageUrl = images.isNotEmpty ? images[0]['image_url'] : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 50,
              height: 50,
              color: Colors.grey[200],
              child: imageUrl != null
                  ? Image.network(imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image, color: Colors.grey))
                  : const Icon(Icons.image, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['product_name']?.toString() ?? 'Product',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                // Correct mapping for quantity
                Text('Qty: ${item['quantity'] ?? item['qty'] ?? 1}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          // Correct mapping for unit price
          Text('₹ ${item['unit_price'] ?? item['price'] ?? item['item_total'] ?? 0.0}',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(
      Map<String, dynamic> order, Map<String, dynamic> payment) {
    // Sync with Home Page Payment Logic
    final homeOrder = controller.selectedOrder.value ?? {};
    final apiStatus = (homeOrder['payment_status'] ?? '').toString().toLowerCase();
    
    String mode = "COD";
    String status = "PENDING";
    
    if (apiStatus == 'paid') {
      mode = "ONLINE";
      status = "PAID";
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border:
            Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            'Payment Mode',
            mode.toUpperCase(),
          ),
          _buildSummaryRow(
            'Payment Status',
            status,
            valueColor: status == 'PAID' ? Colors.green : Colors.orange,
          ),
          const Divider(height: 25, thickness: 1),
          _buildSummaryRow(
            'Total Amount',
            '₹ ${payment['total_amount'] ?? payment['total_payment'] ?? '0.00'}',
            isBold: true,
            fontSize: 20,
            valueColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {Color valueColor = Colors.black87,
      bool isBold = false,
      double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isValueBold = false,
      Color? labelColor,
      Color? valueColor,
      bool isBold = false}) {
    final finalValueBold = isValueBold || isBold;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              color: labelColor ?? Colors.black54,
              fontSize: 13,
            )),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: finalValueBold ? FontWeight.bold : FontWeight.w600,
                color: valueColor ?? Colors.black,
                fontSize: 13,
              )),
        ),
      ],
    );
  }

  Widget _buildCheckQuestion(Map<String, dynamic> question) {
    final int questionId = (question['id'] ?? 0);
    final String label = (question['question'] ?? "Question").toUpperCase();
    final List options = question['options'] as List? ?? [];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),
          Obx(() => Wrap(
                spacing: 30,
                runSpacing: 10,
                children: options.map((opt) {
                  final option = opt as Map<String, dynamic>;
                  return _buildCheckOption(
                    option['label']?.toString().toUpperCase() ?? "YES",
                    option['value']?.toString() ?? "yes",
                    questionId,
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }

  Widget _buildCheckOption(String label, String optionValue, int questionId) {
    final isSelected = controller.pickupAnswers[questionId] == optionValue;
    return GestureDetector(
      onTap: () => controller.pickupAnswers[questionId] = optionValue,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey,
                width: 2,
              ),
              color: isSelected ? AppColors.primary : Colors.transparent,
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.black54,
                fontSize: 14,
              )),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Obx(() {
      final isImagesStep =
          controller.currentStep.value == QuickStep.pickupImages;
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
                onPressed: () {
                  if (isImagesStep) {
                    controller.goBack(); // Keep "BACK" on images step
                  } else {
                    controller
                        .goToMarkPending(isPickup: true); // Correctly signal Pickup
                  }
                },
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                        color: isImagesStep ? Colors.grey : Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text(isImagesStep ? "BACK" : "MARK PENDING",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isImagesStep ? Colors.black : Colors.red)),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: ElevatedButton(
                onPressed: () => controller.nextPickupStep(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text(isImagesStep ? "SUBMIT" : "PICKUP",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
