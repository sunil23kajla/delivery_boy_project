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
              Obx(() => Container(
                    width: width * 0.7,
                    height: width * 0.7,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: AppColors.primary, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: controller.isCameraActive.value
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              MobileScanner(
                                controller: controller.scanController,
                                onDetect: controller.onScan,
                              ),
                              _ScanFrame(size: width * 0.5),
                            ],
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.qr_code_scanner,
                                    size: 60,
                                    color: Colors.white.withOpacity(0.5)),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: controller.toggleCamera,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 15),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  child: const Text('SCAN',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                ),
                              ],
                            ),
                          ),
                  )),
              const SizedBox(height: 40),
              TextButton(
                onPressed: controller.skipScan,
                child: const Text("PROCESS NEXT WITHOUT SCAN",
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline)),
              ),
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
            child: Obx(() => ElevatedButton(
                  onPressed: controller.scannedBarcode.value.isNotEmpty
                      ? controller.nextStep
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
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

class _ScanFrame extends StatelessWidget {
  final double size;
  const _ScanFrame({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
      ),
      child: const Stack(
        children: [
          _Corner(alignment: Alignment.topLeft),
          _Corner(alignment: Alignment.topRight),
          _Corner(alignment: Alignment.bottomLeft),
          _Corner(alignment: Alignment.bottomRight),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final Alignment alignment;
  const _Corner({required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          border: Border(
            top: alignment == Alignment.topLeft ||
                    alignment == Alignment.topRight
                ? const BorderSide(color: AppColors.primary, width: 4)
                : BorderSide.none,
            bottom: alignment == Alignment.bottomLeft ||
                    alignment == Alignment.bottomRight
                ? const BorderSide(color: AppColors.primary, width: 4)
                : BorderSide.none,
            left: alignment == Alignment.topLeft ||
                    alignment == Alignment.bottomLeft
                ? const BorderSide(color: AppColors.primary, width: 4)
                : BorderSide.none,
            right: alignment == Alignment.topRight ||
                    alignment == Alignment.bottomRight
                ? const BorderSide(color: AppColors.primary, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
