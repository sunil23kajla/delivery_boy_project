import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';
import 'package:delivery_boy/core/constants/app_routes.dart';
import '../quick_flow_controller.dart';

class QuickSummaryView extends GetView<QuickFlowController> {
  const QuickSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final summaryData = controller.rxQuickSummary.value;
      if (summaryData == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderSummaryTable(summaryData),
            const SizedBox(height: 24),
            _buildCollectionDetailsCard(summaryData),
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      );
    });
  }

  Widget _buildOrderSummaryTable(Map<String, dynamic> data) {
    final orderTypeWise = data['order_type_wise'] ?? {};
    final quick = orderTypeWise['quick'] ?? {};
    final all = orderTypeWise['all'] ?? {};

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 25,
              headingRowHeight: 45,
              dataRowHeight: 55,
              columns: const [
                DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                DataColumn(label: Text('Desp', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                DataColumn(label: Text('Succ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                DataColumn(label: Text('Fail', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                DataColumn(label: Text('Rate %', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
              ],
              rows: [
                _buildDataRow(
                  'Quick',
                  (quick['count'] ?? 0).toString(),
                  (quick['dispatch'] ?? 0).toString(),
                  (quick['success'] ?? 0).toString(),
                  (quick['failed'] ?? 0).toString(),
                  '${quick['success_rate_percent'] ?? 0}%',
                  isBold: true,
                ),
                _buildDataRow(
                  'All',
                  (all['count'] ?? 0).toString(),
                  (all['dispatch'] ?? 0).toString(),
                  (all['success'] ?? 0).toString(),
                  (all['failed'] ?? 0).toString(),
                  '${all['success_rate_percent'] ?? 0}%',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  DataRow _buildDataRow(String category, String total, String desp, String succ, String fail, String rate, {bool isBold = false}) {
    final style = TextStyle(
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontSize: 14,
      color: const Color(0xFF333333),
    );

    void navigate(String status, String countValue) {
      if (int.tryParse(countValue) != null && int.parse(countValue) > 0) {
        Get.toNamed(AppRoutes.summaryList, arguments: {
          'isQuick': true,
          'category': category.toUpperCase(),
          'status': status.toUpperCase(),
        });
      }
    }

    return DataRow(cells: [
      DataCell(Text(category, style: style)),
      DataCell(
        GestureDetector(
          onTap: () => navigate('ALL', total),
          child: Text(total, style: style.copyWith(color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
        ),
      ),
      DataCell(
        GestureDetector(
          onTap: () => navigate('DISPATCH', desp),
          child: Text(desp, style: style.copyWith(color: Colors.blue.shade700)),
        ),
      ),
      DataCell(
        GestureDetector(
          onTap: () => navigate('SUCCESS', succ),
          child: Text(succ, style: style.copyWith(color: Colors.green.shade600)),
        ),
      ),
      DataCell(
        GestureDetector(
          onTap: () => navigate('FAILED', fail),
          child: Text(fail, style: style.copyWith(color: Colors.red.shade600)),
        ),
      ),
      DataCell(Text(rate, style: style.copyWith(color: const Color(0xFF546E7A)))),
    ]);
  }

  Widget _buildCollectionDetailsCard(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          const Text(
            "Collection Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem("Total", "₹${data['total_collection_amount'] ?? 0}", AppColors.primary),
              _buildMetricItem("Cash", "₹${data['cash_value'] ?? 0}", Colors.green.shade700),
              _buildMetricItem("Online", "₹${data['online_value'] ?? 0}", Colors.orange.shade700),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
