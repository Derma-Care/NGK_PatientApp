import 'dart:convert';

import 'package:cutomer_app/NGK/ClinicManagement/AboutClinicScreen.dart';
import 'package:cutomer_app/NGK/ClinicManagement/ClinicModelWithLocation.dart';
import 'package:cutomer_app/NGK/Contoller/CliniContoller.dart';
import 'package:cutomer_app/NGK/Modals/clinic_model.dart';
import 'package:cutomer_app/NGK/Screens/ClinicListScreen.dart';
import 'package:cutomer_app/NGK/Widgets/FiltterButtons.dart';
import 'package:cutomer_app/NGK/Widgets/clinic_details_modal.dart';
import 'package:cutomer_app/NGK/Widgets/procedures_packages_tab_screen.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/FormatOfferDate.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:cutomer_app/Utils/NOClinicAvailableUi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class Offerslistscreen extends StatefulWidget {
  const Offerslistscreen({super.key});

  @override
  State<Offerslistscreen> createState() => _OfferslistscreenState();
}

class _OfferslistscreenState extends State<Offerslistscreen> {
  final ClinicContoller controller = ClinicContoller();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.loadClinicsWithOffers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: CommonHeader(title: "Nearby Clinics with Offers"),
      body: RefreshIndicator(
        color: mainColor,
        onRefresh: () {
          controller.loadClinicsWithOffers();
          return Future.value();
        },
        child: Column(
          children: [
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  controller.applySearch(value);
                  setState(() {}); // 🔄 update clear button visibility
                },
                decoration: InputDecoration(
                  hintText: "Search Clinics...",
                  prefixIcon: const Icon(Icons.search),

                  // ❌ CLEAR BUTTON
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () {
                            searchController.clear();
                            controller.applySearch(""); // reset search
                            setState(() {});
                          },
                        )
                      : null,

                  filled: true,
                  fillColor: Colors.white,

                  // 🔹 NORMAL BORDER
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),

                  // 🔹 FOCUSED BORDER
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.pink, width: 1.5),
                  ),

                  // 🔹 FALLBACK
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // centers buttons
                children: [
                  filterButton("All", controller),
                  const SizedBox(width: 8),
                  filterButton("Near Me", controller),
                  const SizedBox(width: 8),
                  filterButton("Rating", controller),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: controller.isLoading,
                builder: (_, loading, __) {
                  if (loading) {
                    return const Center(
                      child: SpinKitFadingCircle(
                        color: mainColor,
                        size: 40,
                      ),
                    );
                  }

                  return ValueListenableBuilder<List<ClinicModelWithLocation>>(
                    valueListenable: controller.clinicList,
                    builder: (_, list, __) {
                      if (list.isEmpty) {
                        return noClinicAvailableUI();
                      }
                      // if (list.isNotEmpty)

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final clinic = list[i];

                          return Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.fromLTRB(12, 36,
                                        12, 12), // 👈 top space for strip
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(14),
                                      onTap: () {
                                        Get.to(() => ServicesTabScreen(
                                              clinicId: clinic.clinicId,
                                              isofferClinic: true,
                                            ));
                                      },
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          /// 🟩 LOGO — 30%
                                          Expanded(
                                            flex: 3,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: SizedBox(
                                                height: 70,
                                                child: clinicLogoWidget(
                                                    clinic.hospitalLogo),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          /// 🟦 DETAILS — 70%
                                          Expanded(
                                            flex: 7,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  clinic.name,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  clinic.address,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Icon(Icons.star,
                                                            size: 16,
                                                            color:
                                                                Colors.amber),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          "${clinic.hospitalOverallRating.toStringAsFixed(1)}",
                                                        ),
                                                        const SizedBox(
                                                            width: 12),
                                                        const Icon(
                                                            Icons
                                                                .directions_car,
                                                            size: 16),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(clinic
                                                            .distanceInKm),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 30,
                                                      child: OutlinedButton(
                                                        onPressed: () {
                                                          Get.to(() =>
                                                              AboutClinicScreen(
                                                                clinicId: clinic
                                                                    .clinicId,
                                                                distanceInKm: clinic
                                                                    .distanceInKm,
                                                              ));
                                                        },
                                                        style: OutlinedButton
                                                            .styleFrom(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      14),
                                                          side: const BorderSide(
                                                              color: Colors
                                                                  .deepOrange),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          "About",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors
                                                                .deepOrange,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (clinic.maxOfferPercentage != null &&
                                      clinic.maxOfferPercentage! > 0)
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 28,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(14),
                                            topRight: Radius.circular(14),
                                          ),
                                        ),
                                        child: Text(
                                          "UP TO ${clinic.maxOfferPercentage!.toStringAsFixed(0)}% OFF",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget discountStrip(
    String text,
  ) {
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
              // Text(
              //   formatOfferDate(procedure?.offerValidDate),
              //   style: const TextStyle(
              //     fontSize: 12,
              //     fontWeight: FontWeight.w600,
              //     color: Colors.white,
              //   ),
              // ),
              // Text(
              //   formatOfferDate(procedure?.offerValidDate),
              //   style: const TextStyle(
              //     fontSize: 12,
              //     fontWeight: FontWeight.w600,
              //     color: Colors.white,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
