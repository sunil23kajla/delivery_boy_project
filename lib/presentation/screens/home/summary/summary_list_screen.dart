import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';
import 'package:delivery_boy/core/constants/app_routes.dart';
import 'package:delivery_boy/presentation/screens/home/home_controller.dart';
import 'package:delivery_boy/presentation/screens/home/widgets/shipment_card.dart';

class SummaryListScreen extends StatelessWidget {
  const SummaryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final args = Get.arguments as Map<String, dynamic>;
    final category = args['category'] as String;
    final status = args['status'] as String;

    final list = controller.getSummaryList(category, status);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "$category - $status",
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: list.isEmpty
          ? const Center(child: Text("No shipments found"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.summaryDetail,
                      arguments: list[index]),
                  child:
                      ShipmentCard(shipment: list[index], navigateOnTap: false),
                );
              },
            ),
    );
  }
}
