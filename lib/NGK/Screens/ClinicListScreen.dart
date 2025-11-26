import 'package:cutomer_app/NGK/Contoller/CliniContoller.dart';
import 'package:cutomer_app/NGK/Procedures/ProcedureController.dart';
import 'package:cutomer_app/NGK/Procedures/ProcedureModel.dart';
import 'package:cutomer_app/NGK/Widgets/CommonPaginationBar.dart';
import 'package:cutomer_app/NGK/Widgets/FiltterButtons.dart';
import 'package:cutomer_app/NGK/Widgets/procedures_packages_tab_screen.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class Clinic {
  final String? name;
  final String? address;
  final double distanceKm;
  final double rating;
  final int discountPercent;
  final String? imageUrl;

  Clinic({
    required this.name,
    required this.address,
    required this.distanceKm,
    required this.rating,
    required this.discountPercent,
    this.imageUrl,
  });
}

class ClinicListScreen extends StatefulWidget {
  const ClinicListScreen({super.key});

  @override
  State<ClinicListScreen> createState() => _ClinicListScreenState();
}

class _ClinicListScreenState extends State<ClinicListScreen> {
  final Procedurecontroller controller = Procedurecontroller();
  final ClinicContoller ccontroller = ClinicContoller();
  final TextEditingController searchController = TextEditingController();

  ValueNotifier<bool> showPagination = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: CommonHeader(title: "Nearby Clinics"),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchController,
              onChanged: (value) => controller.applySearch(value),
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
                    borderSide: BorderSide.none),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // FILTERS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                filterButton("Near Me", ccontroller),
                filterButton("High Discount", ccontroller),
                filterButton("Rating", ccontroller),
              ],
            ),
          ),

          const SizedBox(height: 5),

          // LIST (REACTIVE)
          Expanded(
            child: ValueListenableBuilder<List<Clinic>>(
              valueListenable: ccontroller.clinicList,
              builder: (context, list, _) {
                if (list.isEmpty) {
                  return const Center(child: Text("No clinics found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final clinic = list[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ClinicCard(
                        clinicName: clinic.name!,
                        address: clinic.address!,
                        rating: clinic.rating,
                        distance: clinic.distanceKm,
                        discount: clinic.discountPercent,
                        imageUrl: clinic.imageUrl!,
                        onTap: () {
                          Get.to(() => ServicesTabScreen(isClinic: true));
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // PAGINATION BAR
          CommonPaginationBar(
            showPagination: showPagination,
            itemsPerPage: ccontroller.itemsPerPage,
            currentPage: ccontroller.currentPage,
            totalPages: ccontroller.totalPages,
            onItemsPerPageChanged: ccontroller.changeItemsPerPage,
            onNext: ccontroller.nextPage,
            onPrev: ccontroller.prevPage,
            onPageSelected: ccontroller.goToPage,
          ),
        ],
      ),
    );
  }
}

class ClinicCard extends StatelessWidget {
  final String clinicName;
  final String address;
  final double rating;
  final int discount;
  final String imageUrl;
  final double distance;
  final VoidCallback? onTap;

  const ClinicCard({
    super.key,
    required this.clinicName,
    required this.address,
    required this.rating,
    required this.discount,
    required this.imageUrl,
    this.onTap,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Image.asset(
                  imageUrl,
                  width: 70,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clinicName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.red, size: 18),
                            SizedBox(width: 5),
                            Text("${distance.toString()} KM"),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 16, color: Colors.amber),
                              SizedBox(width: 5),
                              Text(rating.toString()),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(address, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.20,
                decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    const Text("Upto", style: TextStyle(color: Colors.white)),
                    Text(
                      "$discount%",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    const Text("OFF", style: TextStyle(color: Colors.white)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
