import 'dart:async';
 
import 'dart:io';

import 'package:cutomer_app/Dashboard/ImagePreview.dart';
 

import 'package:cutomer_app/Utils/ScaffoldMessageSnacber.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
 

 

 
import '../Services/CarouselSliderService.dart';
 

class Dashboardcontroller extends GetxController {
  Dashboardcontroller() {
    debugPrint("🔥🔥 Dashboardcontroller CONSTRUCTOR CALLED");
  }
 
  final ImagePicker _picker = ImagePicker();
  final CarouselSliderService carouselSliderService = CarouselSliderService();

  final Rx<File?> imageFile = Rx<File?>(null);
  final RxBool isLoading = true.obs;
 
 
  final RxList<String> carouselImages = <String>[].obs;
  final RxList<String> carouseServicelImages = <String>[].obs;
 

 
 

 

  String statusMessage = "";

  RxString mobileNumber = ''.obs;
  void setMobileNumber(String number) {
    mobileNumber.value = number;
  }

  File? _imageFile;

  /// Load saved profile image
  Future<void> loadSavedImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedImagePath = prefs.getString('profile_image');
    if (savedImagePath != null && File(savedImagePath).existsSync()) {
      imageFile.value = File(savedImagePath);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      final file = File(pickedFile.path);

      // Store the file path in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('profile_image', file.path);

      // Update the reactive imageFile variable
      imageFile.value = file;
    }
  }

  // Load the stored profile image from SharedPreferences
  Future<void> loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profile_image');

    if (imagePath != null && imagePath.isNotEmpty) {
      // If the image path exists, load the image file
      imageFile.value = File(imagePath);
    }
  }

  @override
  void onInit() {
    super.onInit();
    debugPrint("🔥 Dashboardcontroller onInit CALLED");
    fetchImages();
    fetchserviceImages();
    loadProfileImage();
  }

  /// Show modal to pick image from gallery or camera
  void showImagePickerOptions(BuildContext context, image) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.preview),
                title: const Text('Preview'),
                onTap: () {
                  // Ensure that the image exists
                  if (image != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ImagePreviewScreen(imagePath: image),
                      ),
                    );
                  } else {
                    // Handle case where no image is selected
                    ScaffoldMessageSnackbar.show(
                      context: context,
                      message: "No image selected for preview",
                      type: SnackbarType.warning,
                    );
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

 
 
  /// Fetch images for carousel
  Future<void> fetchImages() async {
    try {
      final images = await carouselSliderService.fetchImages();
      carouselImages.assignAll(images);
      print("imagesimages lengrt ${images.length}");
    } catch (e) {
      print("Error fetching images: $e");
    }
  }

  /// Fetch service images for carousel
  Future<void> fetchserviceImages() async {
    try {
      final images = await carouselSliderService.fetchServiceImages();
      carouseServicelImages.assignAll(images);
      print("imagesimages fetchServiceImages ${images.length}");
    } catch (e) {
      print("Error fetching images: $e");
    }
  }

  Future<void> onRefresh(String mobileNumber) async {
    isLoading.value = true; // start loading

    try {
      // Fetch bookings or other needed data
 
      await fetchImages();
      await fetchserviceImages();
      // ✅ Only after data is fetched, stop loading
      isLoading.value = false;
    } catch (e) {
      // handle errors
      statusMessage = "Something went wrong. Please try again.";
      isLoading.value = false;
    }
  }
}
