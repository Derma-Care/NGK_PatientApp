import 'package:cutomer_app/NGK/ClinicManagement/AboutClinicScreen.dart';
import 'package:cutomer_app/NGK/ClinicManagement/ClinicControllerLocation.dart';
import 'package:cutomer_app/NGK/ClinicManagement/ClinicModelWithLocation.dart';
import 'package:cutomer_app/NGK/Modals/PaymentModal.dart';
import 'package:cutomer_app/NGK/Packges/PackageController.dart';
import 'package:cutomer_app/NGK/Widgets/CommonPaginationBar.dart';
import 'package:cutomer_app/NGK/Widgets/FiltterButtons.dart';
import 'package:cutomer_app/NGK/Widgets/PackageBookingSheet.dart';
import 'package:cutomer_app/NGK/Widgets/common_pagination.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/DateConverter.dart';
import 'package:cutomer_app/Utils/FormatOfferDate.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'PackageModel.dart';

class PackageListScreen extends StatefulWidget {
  final ClinicModelWithLocation clinicData;
  final bool hideHeader;

  final bool isClinic;
  PackageListScreen(
      {this.hideHeader = false,
      this.isClinic = false,
      required this.clinicData});
  @override
  State<PackageListScreen> createState() => _PackageListScreenState();
}

class _PackageListScreenState extends State<PackageListScreen> {
  late PackageController controller;
  String? openCard;
  late ScrollController scrollController;
  ValueNotifier<bool> showPagination = ValueNotifier(true);
  final TextEditingController searchController = TextEditingController();
  double lastOffset = 0;
  double? lat;
  double? long;
  String? stateName;
  String? expandedPackageId;
  final ClinicControllerLocation ccontroller =
      Get.put(ClinicControllerLocation());

  @override
  void initState() {
    super.initState();
    controller = PackageController();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    loadClinicPacakages();
  }

  Future<void> loadClinicPacakages() async {
    controller.loadPackages(
      clinicId: widget.clinicData.clinicId,
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

    await loadClinicPacakages(); // reload backend data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: widget.hideHeader ? null : CommonHeader(title: "Packages"),
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

                return ValueListenableBuilder<List<PackageModel>>(
                  valueListenable: controller.packageList,
                  builder: (context, list, _) {
                    return Column(
                      children: [
                        /// ✅ SHOW FILTERS ONLY IF DATA EXISTS
                        // if (list.isNotEmpty)
                        //   Column(
                        //     children: [
                        //       SingleChildScrollView(
                        //         scrollDirection: Axis.horizontal,
                        //         child: Row(
                        //           children: [
                        //             widget.isClinic
                        //                 ? const SizedBox()
                        //                 : filterButton("All", controller),
                        //             filterButton("Near Me", controller),
                        //             filterButton("High Discount", controller),
                        //             filterButton("Low Price", controller),
                        //             widget.isClinic
                        //                 ? const SizedBox()
                        //                 : filterButton("Rating", controller),
                        //             filterButton("High Price", controller),
                        //           ],
                        //         ),
                        //       ),
                        //       const SizedBox(height: 10),
                        //     ],
                        //   ),

                        buildSmallHospitalCard(
                          hospitalName: widget.clinicData.name,
                          distanceKm: widget.clinicData.distanceInKm,
                          rating: widget.clinicData.hospitalOverallRating,
                          city: widget.clinicData.city,
                          address: widget.clinicData.address,
                          onAboutPressed: () {
                            Get.to(() => AboutClinicScreen(
                                  clinicId: widget.clinicData.clinicId,
                                  distanceInKm: widget.clinicData.distanceInKm,
                                ));
                            print("About Clicked");
                          },
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
                                    padding: const EdgeInsets.all(16),
                                    itemCount: list.length,
                                    itemBuilder: (context, index) {
                                      final pkg = list[index];

                                      return _buildPackageCard(pkg);
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

  int getOfferDaysLeft(String? offerDate) {
    if (offerDate == null || offerDate.isEmpty) return 0;

    try {
      final expiry = DateTime.parse(offerDate);
      final now = DateTime.now();
      final difference = expiry.difference(now).inDays;

      return difference > 0 ? difference : 0;
    } catch (_) {
      return 0;
    }
  }

  Widget _buildPackageCard(PackageModel pkg) {
    final int discountPercent = pkg.totalDiscountPercentage.toInt();
    final double saveAmount = pkg.totalDiscountAmount ?? 0;
    final int daysLeft = getOfferDaysLeft(pkg.offerValidDate);

    bool isExpanded = expandedPackageId == pkg.packageId;

    String offerText;
    if (!pkg.offerActive) {
      offerText = "";
    } else if (pkg.offerValidDate == null ||
        pkg.offerValidDate!.isEmpty ||
        daysLeft <= 0) {
      offerText = "Limited Offer";
    } else {
      offerText = "$daysLeft Days Left";
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          expandedPackageId =
              isExpanded ? null : pkg.packageId; // toggle expand
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Stack(
          children: [
            /// 🔴 TOP RIGHT DISCOUNT
            if (pkg.offerActive && discountPercent > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      topRight: Radius.circular(14),
                    ),
                  ),
                  child: Text(
                    "$discountPercent% OFF",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            /// 🟣 TOP LEFT OFFER
            if (pkg.offerActive)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(10),
                      topLeft: Radius.circular(14),
                    ),
                  ),
                  child: Text(
                    offerText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  /// PACKAGE NAME
                  Text(
                    pkg.packageName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// PRICE ROW
                  Row(
                    children: [
                      Text(
                        "₹${pkg.price.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 13,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "₹${pkg.totalDiscountedAmount.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      ),
                    ],
                  ),

                  if (saveAmount > 0)
                    Text(
                      "Save ₹${saveAmount.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.redAccent,
                      ),
                    ),

                  const SizedBox(height: 8),

                  /// TAP TEXT (ONLY WHEN COLLAPSED)
                  if (!isExpanded)
                    const Text(
                      "Tap to view details",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                      ),
                    ),

                  /// ---------------- EXPANDED CONTENT ----------------
                  if (isExpanded) ...[
                    const SizedBox(height: 12),

                    /// PROCEDURES LIST
                    ...pkg.procedures.map((p) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// NO OF SITTINGS (FIRST)
                            Text(
                              "${p.noOfSittings} sittings",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.pink,
                              ),
                            ),

                            const SizedBox(height: 6),

                            /// PROCEDURE NAME (SECOND)
                            Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: mainColor,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    p.procedureName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 12),

                    /// BOOK BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          final payment = PaymentModal.fromPackage(pkg);

                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.white,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            builder: (_) =>
                                PackageBookingSheet(payment: payment),
                          );
                        },
                        child: const Text(
                          "Book Package",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSmallHospitalCard({
    required String hospitalName,
    required String distanceKm,
    required double rating,
    required String city,
    required String address,
    required VoidCallback onAboutPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          /// 🔹 Left Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hospitalName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 2),
                    Text(
                      "${distanceKm} ",
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "${address} ",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black45,
                  ),
                ),
                Text(
                  city,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),

          /// 🔹 About Button (Small)
          TextButton(
            onPressed: onAboutPressed,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              "About",
              style: TextStyle(
                fontSize: 12,
                color: Colors.pink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
