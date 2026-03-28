import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';
import 'package:delivery_boy/core/constants/app_routes.dart';
import 'package:delivery_boy/presentation/screens/home/widgets/shipment_card.dart';

import './summary_list_controller.dart';

class SummaryListScreen extends GetView<SummaryListController> {
  const SummaryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Text(
              "${controller.category} - ${controller.status}",
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            )),
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.shipments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text("No shipments found", 
                  style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            )
          );
        }

        return ListView.builder(
          controller: controller.scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          itemCount: controller.shipments.length +
              (controller.isFetchingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < controller.shipments.length) {
              final shipment = controller.shipments[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.summaryDetail,
                      arguments: {
                        'shipment': shipment,
                        'isQuick': controller.isQuick,
                      }),
                  child: ShipmentCard(
                    shipment: shipment, 
                    navigateOnTap: false,
                    forcedStatus: controller.status,
                    forcedColor: controller.status == "SUCCESS" ? Colors.green : (controller.status == "FAILED" ? Colors.red : AppColors.primary),
                    showActions: false,
                    isQuick: controller.isQuick,
                  ),
                ),
              );
            } else {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(strokeWidth: 3),
              ));
            }
          },
        );
      }),
    );
  }
}
