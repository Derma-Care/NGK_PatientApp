import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:cutomer_app/APIs/FetchServices.dart';
import 'package:cutomer_app/ConfirmBooking/ConsultationServices.dart';
import 'package:cutomer_app/Dashboard/DashBoardController.dart';
import 'package:cutomer_app/Dashboard/Dashboard.dart';
import 'package:cutomer_app/Dashboard/ImagePreview.dart';
import 'package:cutomer_app/Dashboard/VisitType.dart';
import 'package:cutomer_app/Inputs/CustomInputField.dart';
import 'package:cutomer_app/Modals/ServiceModal.dart';
import 'package:cutomer_app/NGK/Modals/customer_profile_model.dart';
import 'package:cutomer_app/NGK/Packges/PackageListScreen.dart';
import 'package:cutomer_app/NGK/Procedures/ProcedureListScreen.dart';
import 'package:cutomer_app/NGK/Screens/ClinicListScreen.dart';
import 'package:cutomer_app/NGK/Service/customer_service.dart'
    show CustomerService;
import 'package:cutomer_app/NGK/Widgets/procedures_packages_tab_screen.dart';
import 'package:cutomer_app/Notification/NotificationController.dart';
import 'package:cutomer_app/Notification/Notifications.dart';
import 'package:cutomer_app/Screens/RefferalCode.dart';
import 'package:cutomer_app/SubserviceAndHospital/HospitalCardScreen%20.dart';
import 'package:cutomer_app/TreatmentAndServices/SubserviceController.dart';
import 'package:cutomer_app/Utils/CommonCarouselAds.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/CopyRigths.dart';
import 'package:cutomer_app/Utils/GradintColor.dart';
import 'package:cutomer_app/Utils/capitalizeFirstLetter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Consultations/SymptomsForm.dart';
import 'ConsultationController.dart';

class ConsultationsType extends StatefulWidget {
  final String mobileNumber;

  const ConsultationsType({
    super.key,
    required this.mobileNumber,
  });

  @override
  ConsultationsTypeState createState() => ConsultationsTypeState();
}

class ConsultationsTypeState extends State<ConsultationsType> {
  final consultationcontroller = Get.find<Consultationcontroller>();
  final dashboardcontroller = Get.put(Dashboardcontroller());
  List<ConsultationModel> _consultations = [];
  bool loading = true;
  String? cityName;
  double? latitude;
  double? longitude;
  String? fullName;

  String selectedVisitType = "First Time"; // 👈 store visit type here
  final NotificationController notificationController = Get.find();
  final TextEditingController searchController = TextEditingController();
  final subServiceController = Get.put(SubServiceController());
  List<Map<String, dynamic>> allSubServices = [];
  List<Map<String, dynamic>> filteredSubServices = [];
  Timer? _debounce;
  final FocusNode _focusNode = FocusNode();

  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _loadLocation();
    dashboardcontroller.setMobileNumber(widget.mobileNumber);
    _loadConsultations();
    loadSubServices();
    _fetchCustomerName();
  }

  Future<CustomerProfileModel?> _loadProfile() {
    return CustomerService.getCustomer(widget.mobileNumber);
  }

  Future<void> loadSubServices() async {
    setState(() => isLoading = true);
    allSubServices = await ServiceFetcher.fetchAllSubServices();
    print("🟢 Subservices loaded: ${allSubServices.length}");
    setState(() => isLoading = false);
  }

  final GlobalKey _searchFieldKey = GlobalKey();

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void filterSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final lowerQuery = query.toLowerCase();
      setState(() {
        filteredSubServices = allSubServices.where((item) {
          final subName = item['subServiceName']?.toLowerCase() ?? '';
          final serviceName = item['serviceName']?.toLowerCase() ?? '';
          final categoryName = item['categoryName']?.toLowerCase() ?? '';
          return subName.contains(lowerQuery) ||
              serviceName.contains(lowerQuery) ||
              categoryName.contains(lowerQuery);
        }).toList();
        print("🔍 Filtered ${filteredSubServices.length} results for '$query'");
      });
    });
  }

  // void navigateToHospitalCard(Map<String, dynamic> sub) {
  //   consultationcontroller.setConsultation(_consultations.first);
  //   final subService = SubServiceAdmin.fromJson(sub);
  //   subServiceController.setSelectedSubService(subService);
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => HospitalCardScreen(
  //         categoryName: sub['categoryName'],
  //         categoryId: sub['categoryId'],
  //         serviceId: sub['serviceId'],
  //         serviceName: sub['serviceName'],
  //         selectedService: subService, // optional
  //         mobileNumber: widget.mobileNumber,

  //       ),
  //     ),
  //   );
  // }

  Future<void> _loadConsultations() async {
    setState(() => loading = true);
    final consultations = await getConsultationDetails();
    setState(() {
      _consultations = consultations;
      loading = false;
    });
    // ✅ Automatically store the first consultation if available
    if (_consultations.isNotEmpty) {
      consultationcontroller.setConsultation(_consultations.first);
      print(
          "✅ Default consultation stored: ${_consultations.first.consultationType}");
    }
  }

  Future<void> _fetchCustomerName() async {
    final profile = await CustomerService.getCustomer(widget.mobileNumber);
    if (profile != null) {
      setState(() {
        fullName = profile.fullName;
      });
    }
  }

  Future<void> _loadLocation() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      cityName = prefs.getString('cityName');
      latitude = prefs.getDouble('latitude');
      longitude = prefs.getDouble('longitude');
    });

    print("City loaded: $cityName");
    print("Lat: $latitude, Lng: $longitude");
  }

  OverlayEntry? overlayEntry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          hideDropdownOverlay();
        },
        child: loading
            ? const Center(
                child: SpinKitFadingCircle(
                  color: mainColor,
                  size: 40.0,
                ),
              )
            : _consultations.isEmpty
                ? _noConsultationsView()
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 10),
                          // CommonCarouselAds(
                          //   media: dashboardcontroller.carouselImages,
                          //   height: 170,
                          // ),
                          const SizedBox(height: 10),

                          // ✅ Search box stays visible top
                          _buildSearchBox(),
                          const SizedBox(height: 10),

                          // ✅ City banner (only if available)
                          if (cityName != null) _buildLocationBanner(),
                          // const SizedBox(height: 10),

                          const SizedBox(height: 20),

                          // ✅ Grid content (no IntrinsicHeight)
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 0.9,
                            children: [
                              _mainCard(
                                "Procedures",
                                "assets/treat.png",
                                () {
                                  consultationcontroller
                                      .setConsultation(_consultations.first);
                                  Get.to(SubServiceListScreen());
                                },
                              ),
                              _mainCard(
                                "Packages",
                                "assets/package.png",
                                () {
                                  consultationcontroller
                                      .setConsultation(_consultations.first);
                                  Get.to(PackageListScreen());
                                },
                              ),
                              _mainCard(
                                "Clinics",
                                "assets/clinic.png",
                                () {
                                  consultationcontroller
                                      .setConsultation(_consultations.first);
                                  Get.to(ClinicListScreen());
                                },
                              ),
                              _mainCard(
                                "Offers",
                                "assets/offer.png",
                                _showConsultationOptions,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildLocationBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [mainColor, secondaryColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_on, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              "You're in : $cityName",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return TextField(
      key: _searchFieldKey,
      controller: searchController,
      focusNode: _focusNode,
      decoration: InputDecoration(
        labelText: 'Search Procedures',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  searchController.clear();
                  filteredSubServices.clear();
                  hideDropdownOverlay();
                  setState(() {});
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: (query) {
        filterSearch(query);
        if (query.isNotEmpty) {
          showDropdownOverlay();
        } else {
          hideDropdownOverlay();
        }
      },
    );
  }

  void showDropdownOverlay() {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    hideDropdownOverlay();

    final renderBox =
        _searchFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy + size.height + 4,
        width: size.width,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(12),
          child: filteredSubServices.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "No matching services found",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: min(50.0 * filteredSubServices.length, 250),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: filteredSubServices.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      if (index >= filteredSubServices.length)
                        return const SizedBox.shrink();
                      final item = filteredSubServices[index];

                      return ListTile(
                        dense: true,
                        title: Text(item['subServiceName'] ?? ''),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            "${item['serviceName']} • ${item['categoryName']}",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ),
                        onTap: () {
                          hideDropdownOverlay();
                          searchController.clear();
                          setState(() => filteredSubServices.clear());
                          // navigateToHospitalCard(item);
                        },
                      );
                    },
                  ),
                ),
        ),
      ),
    );

    overlay.insert(overlayEntry!);
  }

  Widget _noConsultationsView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("No service available",
              style: TextStyle(color: mainColor)),
          const SizedBox(height: 12),
          ElevatedButton(
              onPressed: _loadConsultations, child: const Text("Refresh")),
        ],
      ),
    );
  }

  void hideDropdownOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace:
          Container(decoration: BoxDecoration(gradient: appGradient())),
      title: Row(children: [
        Obx(() {
          final image = dashboardcontroller.imageFile.value;
          return GestureDetector(
            onTap: () {
              if (image != null) {
                Get.to(ImagePreviewScreen(imagePath: image.path));
              } else {
                dashboardcontroller.showImagePickerOptions(context, image);
              }
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[200],
              backgroundImage: image != null
                  ? FileImage(image)
                  : const AssetImage('assets/ic_launcher.png') as ImageProvider,
            ),
          );
        }),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hi, Welcome Back",
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            // Username Text
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: fullName == null
                  ? Row(
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Loading...",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    )
                  : Text(
                      capitalizeFirstLetter(fullName!),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
            )
          ],
        ),
        const Spacer(),
        Obx(() {
          final count = Get.find<NotificationController>().unreadCount.value;
          return Obx(() => Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Get.to(() => NotificationScreen());
                    },
                  ),
                  if (notificationController.unreadCount.value > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          notificationController.unreadCount.value.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ));
        }),
        GestureDetector(
          onTap: () => Get.to(() => ReferralWalletPage()),
          child: Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.wallet, color: Colors.white),
                onPressed: () {},
              ),
              const Positioned(
                right: 0,
                top: -2,
                child: Text('💰 2000',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _mainCard(String title, String imagePath, VoidCallback onTap) {
    final isDisabled = selectedVisitType == "Follow-Up"; // 👈 check visit type

    return GestureDetector(
      onTap: isDisabled ? null : onTap, // 👈 disable tap
      child: Opacity(
        opacity: isDisabled ? 0.4 : 1.0, // 👈 visually show it's disabled
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: mainColor),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 6,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: mainColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  void _showConsultationOptions() {
    final clinicOptions = _consultations
        .where((e) => e.consultationType.toLowerCase().contains('clinic'))
        .toList();
    final onlineOptions = _consultations
        .where((e) => e.consultationType.toLowerCase().contains('online'))
        .toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (clinicOptions.isNotEmpty)
                ...clinicOptions.map((c) => ListTile(
                      leading:
                          const Icon(Icons.local_hospital, color: mainColor),
                      title: Text(c.consultationType),
                      onTap: () {
                        Navigator.pop(context);
                        consultationcontroller.setConsultation(c);
                        // Get.to(() => SymptomsForm(
                        //       mobileNumber: widget.mobileNumber,
                        //       // username: widget.username,
                        //       consulationType: c.consultationType,
                        //     ));
                      },
                    )),
              if (onlineOptions.isNotEmpty)
                ...onlineOptions.map((c) => ListTile(
                      leading: const Icon(Icons.video_call, color: mainColor),
                      title: Text(c.consultationType),
                      onTap: () {
                        Navigator.pop(context);
                        consultationcontroller.setConsultation(c);
                        // Get.to(() => SymptomsForm(
                        //       mobileNumber: widget.mobileNumber,
                        //       username: widget.username,
                        //       consulationType: c.consultationType,
                        //     ));
                      },
                    )),
            ],
          ),
        );
      },
    );
  }
}
