import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cutomer_app/Dashboard/ImagePreview.dart';
import 'package:cutomer_app/Modals/ServiceModal.dart';

import 'package:cutomer_app/Utils/ScaffoldMessageSnacber.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;



import '../BottomNavigation/Appoinments/AppointmentService.dart';

import '../BottomNavigation/Appoinments/GetAppointmentModel.dart';
import '../Services/CarouselSliderService.dart';
import '../Services/serviceb.dart';

class Dashboardcontroller extends GetxController {
  final AppointmentService _appointmentService = AppointmentService();
  final ImagePicker _picker = ImagePicker();
  final CarouselSliderService carouselSliderService = CarouselSliderService();

  final Rx<File?> imageFile = Rx<File?>(null);
  final RxBool isLoading = true.obs;
  final RxList<Serviceb> services = <Serviceb>[].obs;
  final RxList<Getappointmentmodel> allAppointments =
      <Getappointmentmodel>[].obs;
  final RxList<String> carouselImages = <String>[].obs;
  final RxList<String> carouseServicelImages = <String>[].obs;
  final selectedService = Rxn<Serviceb>();

  var selectedSubService = Rxn<Service>();
  var selectedSubSubService = Rxn<SubServiceAdmin>();
  var serviceList = <Serviceb>[];

  var subServiceList = <Service>[].obs;
  var subServiceArray = <SubServiceAdmin>[].obs;

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

  /// Fetch user appointments
  Future<void> fetchAppointments(String mobileNumber) async {
    if (mobileNumber.trim().isEmpty) {
      // No mobile number provided, clear list and exit
      allAppointments.clear();
      return;
    }

    try {
      isLoading.value = true;

      // Fetch all appointments from the service
      final appointments =
          await _appointmentService.fetchAppointments(mobileNumber);

      if (appointments != null && appointments.isNotEmpty) {
        // Filter appointments with status 'in_progress' (case-insensitive)
        final filtered = appointments
            .where((appointment) =>
                appointment.status.toLowerCase() == 'in_progress')
            .toList();

        // Update reactive list
        allAppointments.assignAll(filtered);
      } else {
        // No appointments found
        allAppointments.clear();
      }
    } catch (e) {
      // Handle error gracefully
      print("Error fetching appointments: $e");
      allAppointments.clear();
    } finally {
      // Always set loading to false at the end
      isLoading.value = false;
    }
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
      await fetchAppointments(mobileNumber);
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
