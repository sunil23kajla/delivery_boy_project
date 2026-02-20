import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import 'widgets/shipment_card.dart';
import 'summary/summary_view.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
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
              child:
                  const Icon(Icons.person, color: AppColors.primary, size: 18),
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
                  final total = controller.shipments.length;
                  final pending = total;
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
                  return Container(
                    margin:
                        EdgeInsets.fromLTRB(width * 0.04, 10, width * 0.04, 0),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$greeting, Sunil 👋',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.delivery_dining,
                                  color: Colors.white, size: 26),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _QuickStat(
                                label: 'Total',
                                value: '$total',
                                color: Colors.white),
                            const SizedBox(width: 12),
                            const _QuickStat(
                                label: 'Delivered',
                                value: '0',
                                color: Colors.greenAccent),
                            const SizedBox(width: 12),
                            _QuickStat(
                                label: 'Pending',
                                value: '$pending',
                                color: Colors.orangeAccent),
                          ],
                        ),
                      ],
                    ),
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
                        label: "All(${controller.getCount("All")})",
                        isSelected: controller.rxSelectedFilter.value == "All",
                        onTap: () => controller.selectFilter("All"),
                      ),
                      _FilterChip(
                        label: "FWD(${controller.getCount("FWD")})",
                        isSelected: controller.rxSelectedFilter.value == "FWD",
                        onTap: () => controller.selectFilter("FWD"),
                      ),
                      _FilterChip(
                        label: "RVP(${controller.getCount("RVP")})",
                        isSelected: controller.rxSelectedFilter.value == "RVP",
                        onTap: () => controller.selectFilter("RVP"),
                      ),
                      _FilterChip(
                        label: "RT(${controller.getCount("RT")})",
                        isSelected: controller.rxSelectedFilter.value == "RT",
                        onTap: () => controller.selectFilter("RT"),
                      ),
                      _FilterChip(
                        label: "FM(${controller.getCount("FM")})",
                        isSelected: controller.rxSelectedFilter.value == "FM",
                        onTap: () => controller.selectFilter("FM"),
                      ),
                    ],
                  ),
                ),

                // Shipment List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(width * 0.04),
                    itemCount: controller.filteredShipments.length,
                    itemBuilder: (context, index) {
                      return ShipmentCard(
                          shipment: controller.filteredShipments[index]);
                    },
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
    );
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
