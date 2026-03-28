import 'package:delivery_boy/core/constants/app_routes.dart';
import 'package:delivery_boy/presentation/screens/home/home_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SummaryView extends StatelessWidget {
  const SummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Order Summary", 
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchSummary(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Table
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Obx(() {
                  if (controller.orderSummaryData.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1.2),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1),
                      4: FlexColumnWidth(1),
                    },
                    border: TableBorder.symmetric(
                      inside: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                    children: [
                      // Header Row
                      TableRow(
                        children: [
                          _buildHeaderCell("Category"),
                          _buildHeaderCell("Desp"),
                          _buildHeaderCell("Succ"),
                          _buildHeaderCell("Fail"),
                          _buildHeaderCell("Rate %"),
                        ],
                      ),
                      // Data Rows
                      _buildRow(controller, "ALL"),
                      _buildRow(controller, "FWD"),
                      _buildRow(controller, "RVP"),
                      _buildRow(controller, "FM"),
                      _buildRow(controller, "RT"),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 25),
              
              // Collection Info Card
              _buildCollectionCard(controller),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          fontSize: 11,
        ),
      ),
    );
  }

  TableRow _buildRow(HomeController controller, String type) {
    final data = controller.orderSummaryData[type.toLowerCase()];
    if (data == null) {
      return const TableRow(children: [SizedBox(), SizedBox(), SizedBox(), SizedBox(), SizedBox()]);
    }

    final int dispatch = data['dispatch'] ?? 0;
    final int success = data['success'] ?? 0;
    final int failed = data['failed'] ?? 0;
    final dynamic rate = data['success_rate_percent'] ?? 0;

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(type, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 13)),
        ),
        _buildDataCell(dispatch, AppColors.primary, type, "DISPATCH"),
        _buildDataCell(success, Colors.green, type, "SUCCESS"),
        _buildDataCell(failed, Colors.red, type, "FAILED"),
        _buildRawDataCell("$rate%", Colors.blueGrey),
      ],
    );
  }

  Widget _buildRawDataCell(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _buildDataCell(int value, Color color, String type, String status) {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.summaryList, arguments: {
        'category': type,
        'status': status,
      }),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          "$value",
          textAlign: TextAlign.center,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildCollectionCard(HomeController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const Text("Collection Details", 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCollectionItem("Total", controller.totalCollection, AppColors.primary),
              _buildCollectionItem("Cash", controller.cashValue, Colors.green),
              _buildCollectionItem("Online", controller.onlineValue, Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionItem(String label, RxString value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 6),
        Obx(() => Text("₹${value.value}", 
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14))),
      ],
    );
  }
}
