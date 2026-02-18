import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import 'widgets/shipment_card.dart';
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
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            onPressed: () => Get.toNamed(AppRoutes.settings),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 10),
            child: Obx(() => Row(
                  children: [
                    _FilterChip(
                      label: "All(5)",
                      isSelected: controller.rxSelectedFilter.value == "All",
                      onTap: () => controller.selectFilter("All"),
                    ),
                    _FilterChip(
                      label: "FWD(5)",
                      isSelected: controller.rxSelectedFilter.value == "FWD",
                      onTap: () => controller.selectFilter("FWD"),
                    ),
                    _FilterChip(
                      label: "RVP",
                      isSelected: controller.rxSelectedFilter.value == "RVP",
                      onTap: () => controller.selectFilter("RVP"),
                    ),
                    _FilterChip(
                      label: "RT",
                      isSelected: controller.rxSelectedFilter.value == "RT",
                      onTap: () => controller.selectFilter("RT"),
                    ),
                    _FilterChip(
                      label: "RIF",
                      isSelected: controller.rxSelectedFilter.value == "RIF",
                      onTap: () => controller.selectFilter("RIF"),
                    ),
                  ],
                )),
          ),

          // Shipment List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(width * 0.04),
              itemCount: controller.shipments.length,
              itemBuilder: (context, index) {
                return ShipmentCard(shipment: controller.shipments[index]);
              },
            ),
          ),
        ],
      ),
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
