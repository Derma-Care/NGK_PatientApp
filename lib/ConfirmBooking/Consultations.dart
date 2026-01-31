import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:cutomer_app/APIs/FetchServices.dart';
import 'package:cutomer_app/Dashboard/DashBoardController.dart';
import 'package:cutomer_app/Dashboard/ImagePreview.dart';
import 'package:cutomer_app/NGK/ClinicManagement/ClinicLactionScreen.dart';
import 'package:cutomer_app/NGK/Contoller/referral_wallet_controller.dart';
import 'package:cutomer_app/NGK/Modals/customer_profile_model.dart';
import 'package:cutomer_app/NGK/Offers/OffersListScreen.dart';
import 'package:cutomer_app/NGK/Packges/PackageListScreen.dart';
import 'package:cutomer_app/NGK/Procedures/ProcedureListScreen.dart';
import 'package:cutomer_app/NGK/Procedures/ProcedureScreenName.dart';
import 'package:cutomer_app/NGK/Screens/ClinicListScreen.dart';
import 'package:cutomer_app/NGK/Service/customer_service.dart'
    show CustomerService;
import 'package:cutomer_app/Notification/NotificationController.dart';
import 'package:cutomer_app/Notification/Notifications.dart';
import 'package:cutomer_app/Screens/RefferalCode.dart';
import 'package:cutomer_app/Screens/WhatsUpPreviewCard.dart';
import 'package:cutomer_app/TreatmentAndServices/SubserviceController.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/GradintColor.dart';
import 'package:cutomer_app/Utils/LocationService.dart';
import 'package:cutomer_app/Utils/capitalizeFirstLetter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final dashboardcontroller = Get.put(Dashboardcontroller());

  bool loading = true;
  String? cityName;
  double? latitude;
  double? longitude;
  String? fullName;

  String selectedVisitType = "First Time"; // 👈 store visit type here
  final NotificationController notificationController = Get.find();
  final TextEditingController searchController = TextEditingController();
  final subServiceController = Get.put(SubServiceController());
  List<ProcedureOffer> allProcedures = [];
  List<ProcedureOffer> filteredProcedures = [];
  final walletController = Get.find<ReferralWalletController>();
  Timer? _debounce;
  final FocusNode _focusNode = FocusNode();

  bool isLoading = false;
  @override
  void initState() {
    super.initState();

    _loadLocation();
    dashboardcontroller.setMobileNumber(widget.mobileNumber);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        hideDropdownOverlay(); // 🔥
      }
    });
    loadProcedures();
    _loadCustomerProfile();
    walletController.loadWallet();

    // 👇 BEAUTIFUL FIRST-TIME ANIMATED POPUP
    showWelcomeRewardBottomSheet();
  }

  Future<CustomerProfileModel?> _loadProfile() {
    return CustomerService.getCustomer(widget.mobileNumber);
  }

  Future<void> loadProcedures() async {
    setState(() => isLoading = true);
    allProcedures = await ServiceFetcher.fetchAllProceduresOffers();
    setState(() => isLoading = false);
  }

  final GlobalKey _searchFieldKey = GlobalKey();

  @override
  void dispose() {
    hideDropdownOverlay();
    _debounce?.cancel();
    searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _reloadLocation() async {
    try {
      setState(() {
        cityName = "Updating...";
      });

      await LocationService.fetchAndStoreLocation();

      final prefs = await SharedPreferences.getInstance();

      setState(() {
        cityName = prefs.getString('cityName');
        latitude = prefs.getDouble('latitude');
        longitude = prefs.getDouble('longitude');
      });

      debugPrint("📍 Location refreshed: $cityName");
    } catch (e) {
      debugPrint("❌ Location refresh failed: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to refresh location"),
        ),
      );
    }
  }

  void filterSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      final q = query.toLowerCase();

      setState(() {
        filteredProcedures = allProcedures
            .where((p) => p.name.toLowerCase().contains(q))
            .toList();
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

  Future<void> _loadCustomerProfile() async {
    final profile = await CustomerService.getCustomer(widget.mobileNumber);
    debugPrint("👤 Customer API result: $profile");

    if (profile != null && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('customer_full_name', profile.fullName);
      await prefs.setString('customer_Id', profile.customerId);

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
        child: SingleChildScrollView(
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
                        Get.to(ProcedureGridScreen());
                      },
                    ),
                    _mainCard(
                      "Packages",
                      "assets/package.png",
                      () {
                        Get.to(PackageListScreen());
                      },
                    ),
                    _mainCard(
                      "Clinics",
                      "assets/clinic.png",
                      () {
                        Get.to(ClinicListScreen());
                      },
                    ),
                    _mainCard(
                      "Offers",
                      "assets/offer.png",
                      () {
                        Get.to(Offerslistscreen());
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                // WhatsAppPreviewCard()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showWelcomeRewardBottomSheet() async {
    final prefs = await SharedPreferences.getInstance();

    final bool alreadyShown = prefs.getBool('welcome_reward_shown') ?? false;
    final mobile = prefs.getString('mobileNumber') ?? widget.mobileNumber;

    debugPrint("Welcome reward shown before: $alreadyShown");

    // ✅ If already shown, do nothing
    if (alreadyShown) return;

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.85, end: 1),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [mainColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wallet,
                    size: 42,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Congratulations 🎉",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "You received 100 Reward Coins",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Membership: BASIC",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: mainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();

                      // ✅ Mark as shown
                      await prefs.setBool('welcome_reward_shown', true);

                      Navigator.pop(context);
                      Get.to(() => ReferralWalletPage(mobile: mobile));
                    },
                    child: const Text(
                      "Start Exploring",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
          const SizedBox(width: 6),

          /// 📍 CITY NAME
          Expanded(
            child: Text(
              "You're in : $cityName",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          /// 🔄 REFRESH LOCATION ICON
          InkWell(
            onTap: _reloadLocation,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.refresh,
                color: Colors.white,
                size: 18,
              ),
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
                  filteredProcedures.clear();
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
          child: filteredProcedures.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "No matching services found",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: min(50.0 * filteredProcedures.length, 250),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: filteredProcedures.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      if (index >= filteredProcedures.length)
                        return const SizedBox.shrink();
                      final ProcedureOffer item = filteredProcedures[index];

                      return ListTile(
                        dense: true,
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onTap: () {
                          hideDropdownOverlay();
                          searchController.clear();
                          setState(() => filteredProcedures.clear());

                          // 🚀 Navigate to next screen with ID & NAME
                          Get.to(
                            () => const ClinicListLocationScreen(),
                            arguments: {
                              "procedureId": item.procedureId,
                              "procedureName": item.name
                            },
                          );
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
        ],
      ),
    );
  }

  void hideDropdownOverlay() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
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

          return Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Get.to(() => NotificationScreen());
                  Get.find<NotificationController>().markAllAsRead();
                },
              ),
              if (count > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        count > 99 ? "99+" : count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
        GestureDetector(
          onTap: () =>
              Get.to(() => ReferralWalletPage(mobile: widget.mobileNumber)),
          child: Stack(
            children: [
              Center(
                child: IconButton(
                  icon: const Icon(Icons.wallet, color: Colors.white, size: 28),
                  onPressed: () {
                    Get.to(
                      () => ReferralWalletPage(mobile: widget.mobileNumber),
                    );
                  },
                ),
              ),
              Positioned(
                right: 4,
                top: 0,
                child: Obx(() => Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,

                          // decoration: BoxDecoration(
                          //   color: Colors.white.withOpacity(0.2),
                          //   shape: BoxShape.circle,
                          // ),
                          child: Image.asset(
                            "assets/coin.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                        Text(
                          "${walletController.walletSummary.value?.balance.toDouble().toStringAsFixed(0)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )),
                // child: Text('💰 2000',
                //     style: TextStyle(
                //         color: Colors.white,
                //         fontSize: 12,
                //         fontWeight: FontWeight.bold)),
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
}
