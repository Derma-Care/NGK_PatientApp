import 'dart:convert';
import 'dart:io';

import 'package:cutomer_app/BottomNavigation/Profile/ProfileScreens.dart';
import 'package:cutomer_app/Dashboard/DashBoardController.dart';
import 'package:cutomer_app/NGK/Contoller/customer_controller.dart';
import 'package:cutomer_app/NGK/Modals/customer_profile_model.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/ScaffoldMessageSnacber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerProfilePage extends StatefulWidget {
  final String mobileNumber;

  const CustomerProfilePage({super.key, required this.mobileNumber});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  final customerController = Get.find<CustomerGetController>();
  final LocalAuthentication auth = LocalAuthentication();
  final dashboardcontroller = Get.put(Dashboardcontroller());
  bool _biometricEnabled = false;
  bool _loadingBio = true;

  @override
  void initState() {
    super.initState();
    customerController.fetchCustomer(widget.mobileNumber);
    _loadBiometricSetting();
    loadSavedImage();
  }

  // Load saved biometric setting
  Future<void> _loadBiometricSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _biometricEnabled = prefs.getBool('isAuthenticated') ?? false;
      _loadingBio = false;
    });
  }

  // Toggle biometric login
  Future<void> _toggleBiometric(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value) {
      try {
        bool available = await auth.canCheckBiometrics;
        if (!available) {
          ScaffoldMessageSnackbar.show(
            context: context,
            message: "Biometrics not available",
            type: SnackbarType.error,
          );
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(content: Text("Biometrics not available")),
          // );
          return;
        }

        bool success = await auth.authenticate(
          localizedReason: "Enable biometric login",
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );

        if (success) {
          await prefs.setBool('isAuthenticated', true);
          setState(() => _biometricEnabled = true);

          ScaffoldMessageSnackbar.show(
            context: context,
            message: "Biometric login enabled",
            type: SnackbarType.success,
          );

          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(content: Text("Biometric login enabled")),
          // );
        }
      } catch (e) {
        ScaffoldMessageSnackbar.show(
          context: context,
          message: "Error enabling biometrics: $e",
          type: SnackbarType.error,
        );
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text("Error enabling biometrics: $e")),
        // );
      }
    } else {
      await prefs.setBool('isAuthenticated', false);
      setState(() => _biometricEnabled = false);
      ScaffoldMessageSnackbar.show(
        context: context,
        message: "Biometric login disabled",
        type: SnackbarType.warning,
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("Biometric login disabled")),
      // );
    }
  }

  /// Load saved profile image from SharedPreferences
  Future<void> loadSavedImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedImagePath = prefs.getString('profile_image');

    if (savedImagePath != null) {
      final file = File(savedImagePath);
      if (await file.exists()) {
        dashboardcontroller.imageFile.value = file;
      }
    }
  }

  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final file = File(picked.path);

    dashboardcontroller.imageFile.value = file;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('profile_image', picked.path);
  }

  // -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: mainColor,
      ),
      body: Obx(() {
        if (customerController.isLoading.value) {
          return const Center(
            child: SpinKitFadingCircle(
              color: mainColor,
              size: 40,
            ),
          );
        }

        if (customerController.customer.value == null) {
          return const Center(
            child: Text(
              "Unable to fetch data.\nServer may be busy.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.orange, fontSize: 16),
            ),
          );
        }

        return _buildProfileUI(customerController.customer.value!);
      }),
    );
  }

  // ⭐ Profile UI
  Widget _buildProfileUI(CustomerProfileModel profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),

          // Avatar
          GestureDetector(
            onTap: pickProfileImage,
            child: Obx(() {
              final file = dashboardcontroller.imageFile.value;

              return Stack(
                children: [
                  /// 🔵 Outer Border
                  CircleAvatar(
                    radius: 47,
                    backgroundColor: mainColor,
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: file != null
                          ? FileImage(file)
                          : const AssetImage('assets/ic_launcher.png')
                              as ImageProvider,
                    ),
                  ),

                  /// 📸 Camera Icon (Bottom Right)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: pickProfileImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: mainColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),

          const SizedBox(height: 10),

          // Name
          Text(
            profile.fullName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          // Mobile
          Text(profile.mobile),

          const SizedBox(height: 20),

          // View profile
          _menuItem(
            icon: Icons.person,
            title: "View Profile Details",
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => ProfileModalCard(profile: profile),
              );
            },
          ),

          // Logout
          _menuItem(
            icon: Icons.logout,
            title: "Logout",
            onTap: () {
              _showLogoutConfirmation(context);
            },
          ),

          _loadingBio
              ? const Center(
                  child: SpinKitFadingCircle(
                    color: mainColor,
                    size: 40,
                  ),
                )
              : Card(
                  color: Colors.white,
                  child: ListTile(
                    leading: const Icon(Icons.fingerprint, color: mainColor),
                    title: const Text(
                      "Enable Biometric Login",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),

                    // 🔥 MINI SWITCH
                    trailing: Transform.scale(
                      scale: 0.7, // <= control switch size (0.6–1.0)
                      child: Switch(
                        value: _biometricEnabled,
                        activeColor: mainColor,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey.shade400,
                        onChanged: (value) => _toggleBiometric(value),
                      ),
                    ),
                  ),
                )
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.logout,
                size: 40,
                color: mainColor,
              ),
              const SizedBox(height: 10),
              const Text(
                "Logout",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: mainColor),
              ),
              const SizedBox(height: 10),
              const Text(
                "Are you sure you want to logout?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: mainColor),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(
                          color: mainColor, // border color
                          width: 1.2,
                        ),
                      ),
                      onPressed: () {
                        Get.back(); // close bottom sheet
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: mainColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();

                        await prefs.remove('mobileNumber');
                        await prefs.remove('isAuthenticated');
                        await prefs.remove('isFirstLoginDone');

                        Get.offAllNamed('/login');
                      },
                      child: const Text("Logout"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: mainColor),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
