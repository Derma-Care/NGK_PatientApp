import 'dart:convert';

import 'package:cutomer_app/NGK/ClinicManagement/AboutClinicScreen.dart';
import 'package:cutomer_app/NGK/ClinicManagement/ClinicModelWithLocation.dart';
import 'package:cutomer_app/NGK/Contoller/CliniContoller.dart';
import 'package:cutomer_app/NGK/Modals/clinic_model.dart';
import 'package:cutomer_app/NGK/Widgets/FiltterButtons.dart';
import 'package:cutomer_app/NGK/Widgets/clinic_details_modal.dart';
import 'package:cutomer_app/NGK/Widgets/procedures_packages_tab_screen.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:cutomer_app/Utils/NOClinicAvailableUi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class ClinicListScreen extends StatefulWidget {
  const ClinicListScreen({super.key});

  @override
  State<ClinicListScreen> createState() => _ClinicListScreenState();
}

class _ClinicListScreenState extends State<ClinicListScreen> {
  final ClinicContoller controller = ClinicContoller();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.loadClinics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: CommonHeader(title: "Nearby Clinics"),
      body: RefreshIndicator(
        color: mainColor,
        onRefresh: () {
          controller.loadClinics();
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

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final clinic = list[i];

                          return Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center, // ✅ KEY LINE
                                  children: [
                                    filterButton("All", controller),
                                    const SizedBox(width: 8),
                                    filterButton("Near Me", controller),
                                    const SizedBox(width: 8),
                                    filterButton("Rating", controller),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12),
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    Get.to(() => ServicesTabScreen(
                                          clinicId: clinic.clinicId,
                                        ));
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      /// 🟩 LOGO — 30%
                                      Expanded(
                                        flex: 3, // 👈 30%
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
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              clinic.address,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
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
                                                        color: Colors.amber),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                        "${clinic.hospitalOverallRating.toStringAsFixed(1)}"),
                                                    const SizedBox(width: 12),
                                                    const Icon(
                                                        Icons.directions_car,
                                                        size: 16),
                                                    const SizedBox(width: 4),
                                                    Text(clinic.distanceInKm),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
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
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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

  Widget clinicLogoWidget(String logo) {
    try {
      if (logo.startsWith("data:image") && logo.contains(",")) {
        final base64Str = logo.split(',').last.trim();
        if (base64Str.isNotEmpty) {
          return Image.memory(
            base64Decode(base64Str),
            fit: BoxFit.cover,
          );
        }
      }
    } catch (_) {}

    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_hospital,
        size: 36,
        color: Colors.grey,
      ),
    );
  }
}
