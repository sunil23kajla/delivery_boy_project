import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:delivery_boy/presentation/screens/settings/settings_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/custom_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final width = MediaQuery.of(context).size.width;

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
          AppStrings.profile.toUpperCase(),
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading && controller.user.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = controller.user.value;

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile Icon Area
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: controller.updateProfilePicture,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        backgroundImage: user?.profilePhoto != null
                            ? NetworkImage(user!.profilePhoto!)
                            : null,
                        child: user?.profilePhoto == null
                            ? const Icon(Icons.account_circle,
                                color: AppColors.primary, size: 60)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      (user?.name ?? AppStrings.profile).toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Profile Data List
              Container(
                margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 5))
                  ],
                ),
                child: Column(
                  children: [
                    _ProfileRow(
                        label: AppStrings.name, value: user?.name ?? "N/A"),
                    _ProfileDivider(),
                    _ProfileRow(
                        label: AppStrings.mobile,
                        value: user?.mobileNumber ?? "N/A"),
                    _ProfileDivider(),
                    _ProfileRow(
                        label: AppStrings.email, value: user?.email ?? "N/A"),
                    _ProfileDivider(),

                    _ProfileRow(
                        label: AppStrings.address,
                        value: user?.address ?? "N/A"),
                    _ProfileDivider(),

                    // Language Selection
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.language,
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500),
                          ),
                          Row(
                            children: [
                              _LanguageOption(
                                label: "EN",
                                isSelected: Get.locale?.languageCode == 'en',
                                onTap: () =>
                                    Get.updateLocale(const Locale('en', 'US')),
                              ),
                              const SizedBox(width: 8),
                              _LanguageOption(
                                label: "HI",
                                isSelected: Get.locale?.languageCode == 'hi',
                                onTap: () =>
                                    Get.updateLocale(const Locale('hi', 'IN')),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              // Logout Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                child: CustomButton(
                  text: AppStrings.logout,
                  color: AppColors.error,
                  onPressed: controller.logout,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
        height: 1, color: Colors.grey.shade100, indent: 20, endIndent: 20);
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
