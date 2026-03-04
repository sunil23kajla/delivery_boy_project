import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import 'home_controller.dart';
import 'summary/summary_view.dart';
import 'widgets/shipment_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final width = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        _showExitDialog(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            AppStrings.homePage,
            style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.person,
                    color: AppColors.primary, size: 18),
              ),
              onPressed: () => Get.toNamed(AppRoutes.settings),
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: Obx(() => controller.rxIndex.value == 0
            ? Column(
                children: [
                  // Greeting Banner
                  Obx(() {
                    final now = DateTime.now();
                    final hour = now.hour;
                    final greeting = hour < 12
                        ? 'Good Morning'
                        : hour < 17
                            ? 'Good Afternoon'
                            : 'Good Evening';
                    final months = [
                      'Jan',
                      'Feb',
                      'Mar',
                      'Apr',
                      'May',
                      'Jun',
                      'Jul',
                      'Aug',
                      'Sep',
                      'Oct',
                      'Nov',
                      'Dec'
                    ];
                    final dateStr =
                        '${now.day} ${months[now.month - 1]} ${now.year}';
                    return Column(
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(
                              width * 0.04, 10, width * 0.04, 0),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, Color(0xFF1976D2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Obx(() => Text(
                                              '$greeting, ${controller.rxDeliveryManName.value} 👋',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            )),
                                        const SizedBox(height: 2),
                                        Text(
                                          dateStr,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                      width: 30,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  _QuickStat(
                                      label: 'Total',
                                      value: '${controller.rxTotalCount.value}',
                                      color: Colors.white),
                                  const SizedBox(width: 12),
                                  _QuickStat(
                                      label: 'Delivered',
                                      value:
                                          '${controller.rxDeliveredCount.value}',
                                      color: Colors.greenAccent),
                                  const SizedBox(width: 12),
                                  _QuickStat(
                                      label: 'Pending',
                                      value:
                                          '${controller.rxPendingCount.value}',
                                      color: Colors.orangeAccent),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Search Bar
                        Container(
                          margin: EdgeInsets.fromLTRB(
                              width * 0.04, 15, width * 0.04, 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            autofocus: false,
                            onChanged: (value) =>
                                controller.rxSearchText.value = value,
                            decoration: InputDecoration(
                              hintText: "Search by name or tracking ID...",
                              prefixIcon: const Icon(Icons.search,
                                  color: AppColors.textSecondary),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              suffixIcon: Obx(
                                  () => controller.rxSearchText.value.isNotEmpty
                                      ? IconButton(
                                          icon:
                                              const Icon(Icons.clear, size: 20),
                                          onPressed: () {
                                            controller.rxSearchText.value = "";
                                          },
                                        )
                                      : const SizedBox.shrink()),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),

                  // Filter Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                        horizontal: width * 0.04, vertical: 10),
                    child: Row(
                      children: [
                        _FilterChip(
                          label: "All (${controller.rxTotalCount.value})",
                          isSelected:
                              controller.rxSelectedFilter.value == "All",
                          onTap: () => controller.selectFilter("All"),
                        ),
                        _FilterChip(
                          label: "FWD",
                          isSelected:
                              controller.rxSelectedFilter.value == "FWD",
                          onTap: () => controller.selectFilter("FWD"),
                        ),
                        _FilterChip(
                          label: "RVP",
                          isSelected:
                              controller.rxSelectedFilter.value == "RVP",
                          onTap: () => controller.selectFilter("RVP"),
                        ),
                        _FilterChip(
                          label: "RT",
                          isSelected: controller.rxSelectedFilter.value == "RT",
                          onTap: () => controller.selectFilter("RT"),
                        ),
                        _FilterChip(
                          label: "FM",
                          isSelected: controller.rxSelectedFilter.value == "FM",
                          onTap: () => controller.selectFilter("FM"),
                        ),
                      ],
                    ),
                  ),

                  // Shipment List
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () =>
                          controller.fetchOrders(showLoadingIndicator: false),
                      child: controller.isLoading
                          ? _buildShimmerList(width)
                          : controller.filteredShipments.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  controller: controller.scrollController,
                                  padding: EdgeInsets.all(width * 0.04),
                                  itemCount: controller
                                          .filteredShipments.length +
                                      (controller.isFetchingMore.value ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index ==
                                        controller.filteredShipments.length) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 20.0),
                                        child: Center(
                                            child: CircularProgressIndicator()),
                                      );
                                    }
                                    return ShipmentCard(
                                        shipment: controller
                                            .filteredShipments[index]);
                                  },
                                ),
                    ),
                  ),
                ],
              )
            : const SummaryView()),
        bottomNavigationBar: Obx(() => BottomNavigationBar(
              currentIndex: controller.rxIndex.value,
              onTap: controller.changeTabIndex,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.grid_view_rounded),
                  label: AppStrings.shipments,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.assignment_outlined),
                  label: AppStrings.summary,
                ),
              ],
            )),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    Get.defaultDialog(
      title: AppStrings.exitApp,
      middleText: AppStrings.exitMessage,
      textConfirm: AppStrings.yes,
      textCancel: AppStrings.no,
      confirmTextColor: Colors.white,
      onConfirm: () => SystemNavigator.pop(),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        const SizedBox(height: 60),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 72,
                  color: AppColors.primary.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Orders Yet',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Koi order assign nahi hua abhi.\nNeeche pull karke refresh karein.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9E9E9E),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              OutlinedButton.icon(
                onPressed: () => Get.find<HomeController>()
                    .fetchOrders(showLoadingIndicator: true),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Refresh'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerList(double width) {
    return ListView.builder(
      padding: EdgeInsets.all(width * 0.04),
      itemCount: 5,
      itemBuilder: (context, index) => _ShimmerCard(width: width),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  final double width;
  const _ShimmerCard({required this.width});

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _shimmerBox(widget.width * 0.4, 20),
                  _shimmerBox(widget.width * 0.2, 20),
                ],
              ),
              const SizedBox(height: 12),
              _shimmerBox(widget.width * 0.3, 14),
              const SizedBox(height: 16),
              Row(
                children: [
                  _shimmerBox(20, 20),
                  const SizedBox(width: 8),
                  _shimmerBox(widget.width * 0.5, 12),
                ],
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(40, 10),
                      const SizedBox(height: 6),
                      _shimmerBox(80, 16),
                    ],
                  ),
                  Row(
                    children: [
                      _shimmerBox(40, 40),
                      const SizedBox(width: 12),
                      _shimmerBox(40, 40),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerBox(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade100,
            Colors.grey.shade200,
          ],
          stops: [
            0.0,
            0.5 + (_animation.value / 4),
            1.0,
          ],
          transform: _SlidingGradientTransform(slidePercent: _animation.value),
        ),
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _QuickStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
