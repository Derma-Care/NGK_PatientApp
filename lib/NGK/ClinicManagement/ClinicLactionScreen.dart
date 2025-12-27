import 'dart:convert';
import 'package:cutomer_app/NGK/ClinicManagement/AboutClinicScreen.dart';
import 'package:cutomer_app/NGK/Procedures/procedure_details_modal.dart';
import 'package:cutomer_app/NGK/Widgets/CommonPaginationBar.dart';
import 'package:cutomer_app/NGK/Widgets/FiltterButtons.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/FormatOfferDate.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:cutomer_app/Utils/NOClinicAvailableUi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ClinicControllerLocation.dart';

class ClinicListLocationScreen extends StatefulWidget {
  const ClinicListLocationScreen({super.key});

  @override
  State<ClinicListLocationScreen> createState() =>
      _ClinicListLocationScreenState();
}

class _ClinicListLocationScreenState extends State<ClinicListLocationScreen> {
  final ClinicControllerLocation controller =
      Get.put(ClinicControllerLocation());

  final TextEditingController searchController = TextEditingController();
  late String procedureId;
  late String procedureName;

  @override
  void initState() {
    super.initState();
    procedureId = Get.arguments['procedureId'];
    procedureName = Get.arguments['procedureName'];
    _loadClinics();
  }

  Future<void> _loadClinics() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('latitude');
    final lng = prefs.getDouble('longitude');

    if (lat == null || lng == null) return;

    controller.loadClinics(
      latitude: lat,
      longitude: lng,
      procedureId: procedureId,
    );
  }

  // Widget offerValidBadge(DateTime? offerDate) {
  //   if (offerDate == null) return const SizedBox.shrink();

  //   final DateTime today =
  //       DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  //   final DateTime validDate =
  //       DateTime(offerDate.year, offerDate.month, offerDate.day);

  //   final int remainingDays = validDate.difference(today).inDays;

  //   Color bgColor;
  //   Color textColor;

  //   if (remainingDays < 0) {
  //     bgColor = Colors.red.withOpacity(0.1);
  //     textColor = Colors.red;
  //   } else if (remainingDays <= 2) {
  //     bgColor = Colors.orange.withOpacity(0.15);
  //     textColor = Colors.orange;
  //   } else {
  //     bgColor = Colors.green.withOpacity(0.15);
  //     textColor = Colors.green;
  //   }

  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //     decoration: BoxDecoration(
  //       color: bgColor,
  //       borderRadius: BorderRadius.circular(6),
  //     ),
  //     child: Text(
  //       formatOfferDate(offerDate),
  //       style: TextStyle(
  //         fontSize: 12,
  //         fontWeight: FontWeight.w600,
  //         color: textColor,
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          CommonHeader(title: "Nearby Clinics", subtitle: "${procedureName}"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: controller.applySearch,
              decoration: InputDecoration(
                hintText: "Search Clinics...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          searchController.clear();
                          controller.applySearch("");
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                filterButton("Near Me", controller),
                filterButton("High Discount", controller),
                filterButton("Rating", controller),
                filterButton("Reset", controller),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: SpinKitFadingCircle(
                    color: mainColor,
                    size: 40,
                  ),
                );
              }
              // ✅ NO CLINICS AVAILABLE
              if (controller.filteredList.isEmpty) {
                return noClinicAvailableUI();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.paginatedList.length,
                itemBuilder: (context, index) {
                  // final clinic = controller.filteredList[index];
                  final clinic = controller.paginatedList[index];

                  final offerText = controller.getOfferText(clinic);
                  final procedure = clinic.procedurePricing;
                  return Card(
                    color: Colors.white,
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: mainColor.withOpacity(0.3), // border color
                        width: 1, // border thickness
                      ),
                    ),
                    child: IntrinsicHeight(
                      // 🔑 auto height
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          /// 🖼 IMAGE (20%)
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.20,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                              child: buildClinicImage(clinic.hospitalLogo),
                            ),
                          ),

                          /// 📄 DETAILS
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Clinic Name
                                  Text(
                                    clinic.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  /// Address (max 2 lines)
                                  Text(
                                    clinic.address,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),

                                  /// Distance & Rating
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_pin,
                                            size: 14,
                                            color: mainColor,
                                          ),
                                          Text(
                                            clinic.distanceInKm,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black45,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(
                                            Icons.star,
                                            size: 14,
                                            color: mainColor,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            clinic.hospitalOverallRating
                                                .toStringAsFixed(1),
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black45,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "₹ ${procedure?.price.toStringAsFixed(0)}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.red,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              decorationColor: Colors.red,
                                              decorationThickness: 2,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const SizedBox(width: 2),
                                          Text(
                                            "₹ ${procedure?.finalCost.toStringAsFixed(0)}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 6),

                                  /// 👉 About Clinic
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        height: 28,
                                        child: OutlinedButton(
                                          onPressed: () {
                                            Get.to(() => AboutClinicScreen(
                                                clinic: clinic));
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                            side: const BorderSide(
                                                color: Colors.deepOrange),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                          child: const Text(
                                            "About",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.deepOrange,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 28,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Get.to(() => ProcedureDetailsPage(
                                                service: procedure!));
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14),
                                            backgroundColor: mainColor,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                          child: const Text(
                                            "Select",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Chip(
                                  //   backgroundColor:
                                  //       Colors.green.withOpacity(0.15),
                                  //   label: Text(
                                  //     formatOfferDate(
                                  //         procedure?.offerValidDate),
                                  //     style: const TextStyle(
                                  //       fontSize: 12,
                                  //       fontWeight: FontWeight.w600,
                                  //       color: Colors.green,
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),

                          /// 🎯 OFFER STRIP (RIGHT)
                          if (offerText.isNotEmpty)
                            SizedBox(
                              width: 36,
                              child: discountStrip(offerText, procedure),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: CommonPaginationBar(
        showPagination: controller.showPagination,
        itemsPerPage: controller.itemsPerPage,
        currentPage: controller.currentPage,
        totalPages: controller.totalPages,
        onItemsPerPageChanged: controller.changeItemsPerPage,
        onNext: controller.nextPage,
        onPrev: controller.prevPage,
        onPageSelected: controller.goToPage,
      ),
    );
  }

  Widget discountStrip(String text, procedure) {
    return Container(
      decoration: const BoxDecoration(
        color: mainColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Center(
        child: RotatedBox(
          quarterTurns: 3,
          child: Column(
            children: [
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
              Text(
                formatOfferDate(procedure?.offerValidDate),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildClinicImage(String imageUrl) {
    if (imageUrl.startsWith('data:image')) {
      try {
        final bytes = base64Decode(imageUrl.split(',').last);
        return Image.memory(
          bytes,
          fit: BoxFit.contain,
        );
      } catch (_) {}
    }

    return Image.asset(
      'assets/images/clinic.png',
      fit: BoxFit.cover,
    );
  }
}
