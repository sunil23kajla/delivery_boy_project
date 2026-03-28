import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:delivery_boy/presentation/screens/home/quick/quick_flow_controller.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';

class QuickProfileScreen extends GetView<QuickFlowController> {
  const QuickProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Profile",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final profile = controller.userProfile.value;
        if (profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: profile.profilePhoto != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: Image.network(
                                profile.profilePhoto!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.person,
                                        size: 80, color: AppColors.primary),
                              ),
                            )
                          : const Icon(Icons.person,
                              size: 80, color: AppColors.primary),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => controller.updateProfilePicture(),
                        child: const CircleAvatar(
                          backgroundColor: AppColors.primary,
                          radius: 18,
                          child: Icon(Icons.camera_alt,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(profile.name ?? "Field Executive",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              Text("ID: TKSH-Q-${profile.id ?? '001'}",
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              _buildProfileItem(Icons.phone, "Mobile Number",
                  profile.mobileNumber.isNotEmpty ? profile.mobileNumber : "N/A"),
              _buildProfileItem(Icons.email, "Email",
                  profile.email.isNotEmpty ? profile.email : "N/A"),
              _buildProfileItem(Icons.location_on, "Operating City",
                  profile.city ?? "N/A"),
              _buildProfileItem(Icons.directions_bike, "Vehicle Type",
                  profile.vehicleType ?? "N/A"),
              _buildProfileItem(Icons.numbers, "Vehicle Number",
                  profile.vehicleNumber ?? "N/A"),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => controller.confirmLogout(),
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text("LOGOUT",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text("App Version 2.3.0",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}
