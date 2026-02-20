import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SummaryView extends StatelessWidget {
  const SummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: EdgeInsets.all(width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Summary Table ───────────────────────────────────────────
          const Text(
            "SUMMARY PAGE",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary),
          ),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.textSecondary),
                dataTextStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
                columns: const [
                  DataColumn(label: Text('')),
                  DataColumn(label: Text('DISPATCH')),
                  DataColumn(label: Text('SUCCESS')),
                  DataColumn(label: Text('FAILED')),
                  DataColumn(label: Text('%')),
                ],
                rows: [
                  _buildSummaryRow("ALL", 28, 19, 9),
                  _buildSummaryRow("FWD", 15, 12, 3),
                  _buildSummaryRow("RVP", 8, 5, 3),
                  _buildSummaryRow("FM", 3, 1, 2),
                  _buildSummaryRow("RT", 2, 1, 1),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // ── COD Collection Footer ──────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: [
                const _CollectionItem(label: "TOTAL COD.", value: "₹ 9,168.00"),
                const Divider(height: 30),
                const _CollectionItem(label: "CASH", value: "₹ 5,074.00"),
                const Divider(height: 30),
                const _CollectionItem(label: "ONLINE", value: "₹ 4,094.00"),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  DataRow _buildSummaryRow(String type, int dispatch, int success, int failed) {
    double percent = dispatch > 0 ? (success / dispatch) * 100 : 0;
    return DataRow(cells: [
      DataCell(Text(type,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: AppColors.primary))),
      DataCell(Text("$dispatch")),
      DataCell(Text("$success")),
      DataCell(Text("$failed")),
      DataCell(Text("${percent.toStringAsFixed(0)}%")),
    ]);
  }
}

class _CollectionItem extends StatelessWidget {
  final String label;
  final String value;

  const _CollectionItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
      ],
    );
  }
}
