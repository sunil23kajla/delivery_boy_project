import 'package:delivery_boy/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../fm_flow_controller.dart';

class FmScanView extends GetView<FmFlowController> {
  const FmScanView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("SCAN SECURE QR/BARCODE",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 30),
              Container(
                width: width * 0.7,
                height: width * 0.7,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: MobileScanner(
                    controller: controller.scanController,
                    onDetect: controller.onScan,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Obx(() => Text(
                    controller.scannedBarcode.value.isEmpty
                        ? "No barcode scanned"
                        : "Scanned: ${controller.scannedBarcode.value}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.primary),
                  )),
            ],
          ),
        ),
        _buildFooter(width),
      ],
    );
  }

  Widget _buildFooter(double width) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: controller.previousStep,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("BACK",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                controller.scannedBarcode.value = ""; // Clear just in case
                controller.nextStep(); // This triggers skip logic
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                side: const BorderSide(color: Colors.orange),
              ),
              child: const Text("SKIP",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.orange)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Obx(() => ElevatedButton(
                  onPressed: controller.scannedBarcode.value.isNotEmpty
                      ? controller.nextStep
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("NEXT",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                )),
          ),
        ],
      ),
    );
  }
}
