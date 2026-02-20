import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../delivery_flow_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../widgets/custom_button.dart';

class DeliveryImageView extends GetView<DeliveryFlowController> {
  const DeliveryImageView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: EdgeInsets.all(width * 0.07),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              AppBar().preferredSize.height -
              MediaQuery.of(context).padding.top -
              (width * 0.14),
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.addImage,
                style: TextStyle(
                  fontSize: width * 0.06,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add product photos as proof of delivery.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // ── Required slots: Front + Back ─────────────────────────
              const _SectionLabel(text: 'Required Photos', color: Colors.red),
              const SizedBox(height: 10),
              Obx(() => Row(
                    children: [
                      _ImageSlot(
                        label: 'Front',
                        icon: Icons.photo_camera_front,
                        file: controller.images.isNotEmpty
                            ? controller.images[0]
                            : null,
                        isRequired: true,
                      ),
                      const SizedBox(width: 12),
                      _ImageSlot(
                        label: 'Back',
                        icon: Icons.crop_portrait,
                        file: controller.images.length > 1
                            ? controller.images[1]
                            : null,
                        isRequired: true,
                      ),
                    ],
                  )),

              const SizedBox(height: 20),

              // ── Optional slot: Customer ──────────────────────────────
              const _SectionLabel(text: 'Optional Photo', color: Colors.blue),
              const SizedBox(height: 10),
              Obx(() => Row(
                    children: [
                      _ImageSlot(
                        label: 'Customer',
                        icon: Icons.person_outline,
                        file: controller.images.length > 2
                            ? controller.images[2]
                            : null,
                        isRequired: false,
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  )),

              const SizedBox(height: 20),

              // ── Counter badge ────────────────────────────────────────
              Obx(() {
                final count = controller.images.length;
                final requiredDone = count >= 2;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: requiredDone
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: requiredDone
                          ? Colors.green.shade300
                          : Colors.orange.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        requiredDone
                            ? Icons.check_circle_rounded
                            : Icons.camera_alt_rounded,
                        color: requiredDone ? Colors.green : Colors.orange,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        requiredDone
                            ? count == 3
                                ? 'All 3 photos captured!'
                                : 'Required photos done ✔'
                            : '$count / 2 required photos added',
                        style: TextStyle(
                          color: requiredDone
                              ? Colors.green.shade800
                              : Colors.orange.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 14),

              // ── Add Photo button ────────────────────────────────────
              Obx(() => controller.images.length < 3
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: controller.pickImage,
                        icon: const Icon(Icons.add_a_photo, size: 18),
                        label: Text(AppStrings.add),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),

              const Spacer(),
              const SizedBox(height: 40),
              Obx(() => CustomButton(
                    text: AppStrings.delivered,
                    isEnabled: controller.isImageStepValid,
                    onPressed: controller.finishDelivery,
                    color: Colors.green,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper Widgets ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionLabel({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _ImageSlot extends StatelessWidget {
  final String label;
  final IconData icon;
  final dynamic file;
  final bool isRequired;

  const _ImageSlot({
    required this.label,
    required this.icon,
    required this.file,
    required this.isRequired,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = file != null;
    final width = MediaQuery.of(context).size.width;
    final slotSize = (width - width * 0.14 - 12) / 2;

    return SizedBox(
      width: slotSize,
      height: slotSize,
      child: Container(
        decoration: BoxDecoration(
          color: hasImage ? null : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasImage
                ? Colors.green.shade400
                : isRequired
                    ? Colors.orange.shade300
                    : Colors.blue.shade200,
            width: hasImage ? 2 : 1.5,
            style:
                isRequired && !hasImage ? BorderStyle.solid : BorderStyle.solid,
          ),
          image: hasImage
              ? DecorationImage(
                  image: FileImage(file),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: hasImage
            ? Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.grey.shade400, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isRequired)
                    const Text(
                      'Required',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    const Text(
                      'Optional',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
