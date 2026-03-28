import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:delivery_boy/presentation/screens/home/quick/quick_flow_controller.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:delivery_boy/presentation/widgets/loading_overlay.dart';
import 'package:delivery_boy/presentation/screens/home/quick/widgets/quick_summary_view.dart';

class QuickHomeScreen extends GetView<QuickFlowController> {
  const QuickHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await controller.confirmAppExit();
      },
      child: LoadingOverlay(
        isLoading: controller.isLoadingRx,
        child: Obx(() => Scaffold(
          backgroundColor: const Color(0xFFF5F7FB),
          appBar: controller.selectedTabIndex.value == 1
              ? AppBar(
                  backgroundColor: const Color(0xFF0D47A1),
                  elevation: 0,
                  centerTitle: true,
                  title: const Text(
                    "Order Summary",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                )
              : null,
          body: Column(
            children: [
              if (controller.selectedTabIndex.value == 0) _buildHeader(context),
              if (controller.selectedTabIndex.value == 0) ...[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildSearchBar(),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => controller.fetchOrders(),
                    child: Obx(() {
                      if (controller.filteredOrders.isEmpty) {
                        return _buildEmptyState();
                      }
                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: controller.filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = controller.filteredOrders[index];
                          return _buildOrderCard(order);
                        },
                      );
                    }),
                  ),
                ),
              ] else ...[
                const Expanded(child: QuickSummaryView()),
              ],
            ],
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        )),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 10, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "Hello, ${controller.userProfile.value?.name?.split(' ').first ?? 'Quick Boy'} 👋",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    _getFormattedDate(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )),
              GestureDetector(
                onTap: () => controller.goToProfile(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 28),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => _StatItem(
                  label: "TOTAL",
                  value: controller.totalOrders.value.toString().padLeft(2, '0'),
                  color: Colors.white)),
              Obx(() => _StatItem(
                  label: "SUCCESS",
                  value:
                      controller.totalSuccess.value.toString().padLeft(2, '0'),
                  color: const Color(0xFF69F0AE))),
              Obx(() => _StatItem(
                  label: "FAILED",
                  value: controller.totalFailed.value.toString().padLeft(2, '0'),
                  color: const Color(0xFFFFD180))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(0),
      child: Material(
        color: Colors.white,
        elevation: 6,
        shadowColor: Colors.black12,
        borderRadius: BorderRadius.circular(15),
        child: TextField(
          controller: controller.searchController,
          focusNode: controller.searchFocusNode,
          autofocus: false,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: "Search by Tracking ID...",
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF0D47A1)),
            suffixIcon: Obx(() => controller.isSearchLoading.value
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(strokeWidth: 2)))
                : controller.searchText.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () => controller.searchController.clear(),
                      )
                    : const SizedBox.shrink()),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return "${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}";
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final vendor = order['vendor'] as Map<String, dynamic>?;

    final name = vendor?['name'] ?? 'Vendor/Customer';
    final orderNumber = order['order_number'] ?? '-';
    final address = vendor?['address'] ?? 'Address not available';
    final phone = vendor?['mobile'] ?? '';

    final paymentData = order['payment'] ?? {};
    final orderData = order['order'] ?? {};
    final paymentStatus = (order['payment_status'] ?? 
                    orderData['payment_status'] ?? 
                    paymentData['payment_status'] ?? 
                    '').toString().trim().toLowerCase();
    
    bool isCod = false;
    if (paymentStatus == 'paid' || paymentStatus == 'success' || paymentStatus == 'online') {
      isCod = false; 
    } else {
        final method = (order['payment_method'] ?? 
                        orderData['payment_method'] ?? 
                        paymentData['payment_method'] ?? 
                        '').toString().trim().toLowerCase();
        if (method.contains('online') || 
            method.contains('razorpay') || 
            method.contains('prepaid') || 
            method.contains('upi')) {
            isCod = false;
        } else {
            isCod = method == 'cod' || method.contains('cash');
        }
    }
    
    final paymentAmount = order['total_payable'] ?? order['total_amount'] ?? paymentData['amount'] ?? '0.00';
    final paymentType = isCod ? "COD" : "PREPAID";

    return InkWell(
      onTap: () => controller.goToDetails(order),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "PICKUP",
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 6),
              child: Text(
                '#$orderNumber',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    address,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                _QuickButton(
                  icon: Icons.phone,
                  onTap: () => launchUrl(Uri.parse("tel:$phone")),
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _QuickButton(
                  icon: Icons.navigation_outlined,
                  onTap: () => launchUrl(Uri.parse(
                      "https://www.google.com/maps/search/?api=1&query=$address")),
                  color: Colors.blue,
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      paymentType,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isCod ? Colors.orange : Colors.green,
                      ),
                    ),
                    Text(
                      "₹ $paymentAmount",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: 500,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_late_outlined,
                  size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                "noTasksFound".tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Contact your manager if you believe this is an error.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => controller.fetchOrders(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Refresh Status"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: controller.selectedTabIndex.value,
        onTap: (index) => controller.changeTab(index),
        selectedItemColor: const Color(0xFF0D47A1),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Product',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart_rounded),
            label: 'Summary',
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _QuickButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _QuickButton(
      {required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
