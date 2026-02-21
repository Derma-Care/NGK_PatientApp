import 'dart:convert';

import 'package:cutomer_app/NGK/ClinicManagement/AboutClinicScreen.dart';
import 'package:cutomer_app/NGK/ClinicManagement/ClinicControllerLocation.dart';
import 'package:cutomer_app/NGK/ClinicManagement/ClinicModelWithLocation.dart';
import 'package:cutomer_app/NGK/Modals/PaymentModal.dart';
import 'package:cutomer_app/NGK/Packges/PackageController.dart';
import 'package:cutomer_app/NGK/Packges/PackageListScreen.dart';
import 'package:cutomer_app/NGK/Widgets/CommonPaginationBar.dart';
import 'package:cutomer_app/NGK/Widgets/FiltterButtons.dart';
import 'package:cutomer_app/NGK/Widgets/PackageBookingSheet.dart';
import 'package:cutomer_app/NGK/Widgets/common_pagination.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/DateConverter.dart';
import 'package:cutomer_app/Utils/FormatOfferDate.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:cutomer_app/Widget/ClinicCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'PackageModel.dart';

class PackageListClinics extends StatefulWidget {
  final bool hideHeader;

  final bool isClinic;
  PackageListClinics({this.hideHeader = false, this.isClinic = false});
  @override
  State<PackageListClinics> createState() => _PackageListClinicsState();
}

class _PackageListClinicsState extends State<PackageListClinics> {
  late PackageController controller;
  String? openCard;
  late ScrollController scrollController;
  ValueNotifier<bool> showPagination = ValueNotifier(true);
  final TextEditingController searchController = TextEditingController();
  double lastOffset = 0;
  double? lat;
  double? long;
  String? stateName;
  final ClinicControllerLocation ccontroller =
      Get.put(ClinicControllerLocation());

  @override
  void initState() {
    super.initState();
    controller = PackageController();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    // ✅ LOAD BACKEND DATA
    loadCoordinates();
  }

  Future<void> loadCoordinates() async {
    final prefs = await SharedPreferences.getInstance();

    lat = prefs.getDouble('latitude');
    long = prefs.getDouble('longitude');
    stateName = prefs.getString('stateName');

    // ✅ Fallback safety (optional)
    if (lat == null || long == null || stateName == null) {
      debugPrint("❌ Location not found in storage");
      return;
    }

    // ✅ Call backend API with stored coordinates
    controller.loadClinics(
      latitude: lat!,
      longitude: long!,
      state: stateName!,
    );
  }

  void _onScroll() {
    double offset = scrollController.offset;

    if (offset > lastOffset) {
      // USER SCROLLED DOWN → HIDE PAGINATION
      if (showPagination.value == true) showPagination.value = false;
    } else {
      // USER SCROLLED UP → SHOW PAGINATION
      if (showPagination.value == false) showPagination.value = true;
    }

    lastOffset = offset;
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    openCard = null; // collapse expanded card

    await loadCoordinates(); // reload backend data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar:
          widget.hideHeader ? null : CommonHeader(title: "Packages Clinics"),
      body: Column(
        children: [
          SizedBox(height: 10),

          // ---------------------- SEARCH BAR ----------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                controller.applySearch(value);
                setState(() {}); // to update clear button visibility
              },
              decoration: InputDecoration(
                hintText: "Search procedures...",
                prefixIcon: Icon(Icons.search),

                // ------- CLEAR BUTTON --------
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          searchController.clear(); // clear text
                          controller.applySearch(""); // reset search
                          setState(() {}); // refresh UI
                        },
                      )
                    : null,

                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          SizedBox(height: 10),

          // ---------------------- FILTER BUTTONS ----------------------
          // SingleChildScrollView(
          //   scrollDirection: Axis.horizontal,
          //   child: Row(
          //     children: [
          //       widget.isClinic ? SizedBox() : filterButton("All", controller),
          //       filterButton("Near Me", controller),
          //       filterButton("High Discount", controller),
          //       filterButton("Low Price", controller),
          //       widget.isClinic
          //           ? SizedBox()
          //           : filterButton("Rating", controller),
          //       filterButton("High Price", controller),
          //     ],
          //   ),
          // ),

          // SizedBox(height: 10),

          // ---------------------- PACKAGE LIST ----------------------
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: controller.loading,
              builder: (context, isLoading, _) {
                if (isLoading) {
                  return Center(
                    child: SpinKitFadingCircle(
                      color: mainColor,
                      size: 40,
                    ),
                  );
                }

                return ValueListenableBuilder<List<ClinicModelWithLocation>>(
                  valueListenable: controller.clinicList,
                  builder: (context, list, _) {
                    return Column(
                      children: [
                        /// ✅ SHOW FILTERS ONLY IF DATA EXISTS
                        if (list.isNotEmpty)
                          Column(
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    widget.isClinic
                                        ? const SizedBox()
                                        : filterButton("All", controller),
                                    filterButton("Near Me", controller),
                                    // filterButton("High Discount", controller),
                                    // filterButton("Low Price", controller),
                                    widget.isClinic
                                        ? const SizedBox()
                                        : filterButton("Rating", controller),
                                    // filterButton("High Price", controller),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),

                        /// 📦 LIST / EMPTY STATE
                        Expanded(
                          child: list.isEmpty
                              ? const Center(
                                  child: Text(
                                    "No packages found",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              : RefreshIndicator(
                                  color: mainColor,
                                  onRefresh: _onRefresh,
                                  child: ListView.builder(
                                    controller: scrollController,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(16),
                                    itemCount: list.length,
                                    itemBuilder: (context, index) {
                                      final pkg = list[index];

                                      return buildClinicCard(pkg);
                                    },
                                  ),
                                ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          CommonPaginationBar(
            showPagination: showPagination,
            itemsPerPage: controller.itemsPerPage,
            currentPage: controller.currentPage,
            totalPages: controller.totalPages,
            onItemsPerPageChanged: controller.changeItemsPerPage,
            onNext: controller.nextPage,
            onPrev: controller.prevPage,
            onPageSelected: controller.goToPage,
          ),
        ],
      ),
    );
  }
}
