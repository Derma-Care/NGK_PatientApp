import 'package:cutomer_app/NGK/ClinicManagement/ClinicModelWithLocation.dart';
import 'package:cutomer_app/NGK/Modals/PaymentModal.dart';

import 'package:cutomer_app/NGK/Packges/PackageModel.dart';

import 'package:cutomer_app/NGK/Procedures/ProcedureModel.dart';
import 'package:cutomer_app/NGK/Procedures/procedure_details_modal.dart';
import 'package:cutomer_app/NGK/Service/clinic_service.dart';
import 'package:cutomer_app/NGK/Widgets/CommonPaginationBar.dart';
import 'package:cutomer_app/NGK/Widgets/PackageBookingSheet.dart';
import 'package:cutomer_app/Utils/FormatOfferDate.dart';

import 'package:cutomer_app/Utils/Header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class ServicesTabScreen extends StatefulWidget {
  final String clinicId;
  final bool isofferClinic;

  const ServicesTabScreen({
    super.key,
    required this.clinicId,
    this.isofferClinic = false,
  });

  @override
  State<ServicesTabScreen> createState() => _ServicesTabScreenState();
}

class _ServicesTabScreenState extends State<ServicesTabScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  late Future<ClinicServicesResponse> servicesFuture;

  final ValueNotifier<bool> showPagination = ValueNotifier(true);
  final ValueNotifier<int> itemsPerPage = ValueNotifier(5);

  final ValueNotifier<int> procedurePage = ValueNotifier(1);
  final ValueNotifier<int> packagePage = ValueNotifier(1);

  final ValueNotifier<int> procedureTotal = ValueNotifier(1);
  final ValueNotifier<int> packageTotal = ValueNotifier(1);
  bool expanded = false;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    servicesFuture = _fetchServices();

    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        if (tabController.index == 0) {
          procedurePage.value = 1;
        } else {
          packagePage.value = 1;
        }
        setState(() {});
      }
    });
  }

  Future<ClinicServicesResponse> _fetchServices() {
    if (widget.isofferClinic) {
      return ClinicService.fetchClinicServicesOffers(widget.clinicId);
    } else {
      return ClinicService.fetchClinicServices(widget.clinicId);
    }
  }

  Future<void> _refreshServices() async {
    procedurePage.value = 1;
    packagePage.value = 1;

    setState(() {
      servicesFuture = _fetchServices();
    });

    await Future.delayed(const Duration(milliseconds: 500));
  }

  List paginate({
    required List list,
    required ValueNotifier<int> page,
    required ValueNotifier<int> total,
  }) {
    final ipp = itemsPerPage.value;
    total.value = (list.length / ipp).ceil().clamp(1, 999);

    final start = (page.value - 1) * ipp;
    final end = (start + ipp).clamp(0, list.length);

    if (start >= list.length) return [];
    return list.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final isProcedureTab = tabController.index == 0;

    return Scaffold(
      appBar: CommonHeader(title: "Services"),
      body: Column(
        children: [
          /// 🔹 Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: tabController,
              labelColor: Colors.pink,
              indicatorColor: Colors.pink,
              tabs: const [
                Tab(text: "Procedures"),
                Tab(text: "Packages"),
              ],
            ),
          ),

          /// 🔹 Content
          Expanded(
            child: FutureBuilder<ClinicServicesResponse>(
              future: servicesFuture,
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: SpinKitThreeBounce(
                      color: Colors.pink,
                      size: 22,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  print("SERVICE ERROR: ${snapshot.error}");
                  return Center(child: Text("Failed to load services"));
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text("No services found"));
                }

                final data = snapshot.data!;

                final procedures = snapshot.data?.procedures ?? [];
                final packages = snapshot.data?.packages ?? [];

                final procedureItems = paginate(
                  list: procedures,
                  page: procedurePage,
                  total: procedureTotal,
                );

                final packageItems = paginate(
                  list: packages,
                  page: packagePage,
                  total: packageTotal,
                );

                return RefreshIndicator(
                  color: Colors.pink,
                  onRefresh: _refreshServices,
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      ServicesListView(
                        items: procedureItems,
                        isPackage: false,
                      ),
                      ServicesListView(
                        items: packageItems,
                        isPackage: true,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          /// 🔹 Pagination
          CommonPaginationBar(
            showPagination: showPagination,
            itemsPerPage: itemsPerPage,
            currentPage: isProcedureTab ? procedurePage : packagePage,
            totalPages: isProcedureTab ? procedureTotal : packageTotal,
            onItemsPerPageChanged: (count) {
              itemsPerPage.value = count;
              procedurePage.value = 1;
              packagePage.value = 1;
              setState(() {});
            },
            onNext: () {
              final page = isProcedureTab ? procedurePage : packagePage;
              final total = isProcedureTab ? procedureTotal : packageTotal;

              if (page.value < total.value) {
                page.value++;
                setState(() {});
              }
            },
            onPrev: () {
              final page = isProcedureTab ? procedurePage : packagePage;
              if (page.value > 1) {
                page.value--;
                setState(() {});
              }
            },
            onPageSelected: (p) {
              final page = isProcedureTab ? procedurePage : packagePage;
              page.value = p;
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}

class ServicesListView extends StatelessWidget {
  final List items;
  final bool isPackage;

  const ServicesListView({
    super.key,
    required this.items,
    required this.isPackage,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Center(child: Text("No data available")),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ServiceExpandableCard(
          item: items[index],
          isPackage: isPackage,
        );
      },
    );
  }
}

class ServiceExpandableCard extends StatelessWidget {
  final dynamic item;
  final bool isPackage;

  const ServiceExpandableCard({
    super.key,
    required this.item,
    required this.isPackage,
  });

  @override
  Widget build(BuildContext context) {
    final String name = isPackage ? item.packageName : item.procedureName;

    final double price = item.price;
    final double finalCost = item.totalDiscountedAmount;
    final int discount = item.totalDiscountPercentage.round();
    final bool showOffer = isOfferValid(item.offerActive, item.offerValidDate);

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.all(16),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            collapsedShape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.pink.shade50,
                  child: Icon(
                    isPackage ? Icons.inventory_2 : Icons.medical_services,
                    color: Colors.pink,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "₹${price.toStringAsFixed(0)}",
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "₹${finalCost.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "Save ₹${item.totalDiscountAmount.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.pink,
                      ),
                    ),
                  ],
                ),
                if (showOffer && item.offerValidDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "Offer valid till ${formatOfferDate(item.offerValidDate)}",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                const Text(
                  "Tap to view details",
                  style: TextStyle(fontSize: 11),
                ),
              ],
            ),
            children: [
              const Divider(),

              /// 🔹 SITTINGS
              Row(
                children: [
                  const Icon(Icons.event_repeat, size: 18, color: Colors.pink),
                  const SizedBox(width: 6),
                  Text(
                    "No of sittings: ${item.sittings}",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// 🔹 PACKAGE PROCEDURES
              if (isPackage && item.procedures.isNotEmpty) ...[
                const Text(
                  "Included Procedures",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...item.procedures.map<Widget>((p) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            size: 16, color: Colors.green),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "${p.procedureName} (${p.noOfSittings} sittings)",
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 12),
              ],

              /// 🔹 CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    if (isPackage) {
                      final payment = PaymentModal.fromPackage(item);

                      /// ✅ PRINT FULL PAYMENT DATA
                      debugPrint("========== PAYMENT DATA ==========");
                      debugPrint(payment.toJson().toString());
                      debugPrint("=================================");
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => PackageBookingSheet(payment: payment),
                      );
                    } else {
                      Get.to(
                        () => ProcedureDetailsPage(service: item),
                      );
                    }
                  },
                  child: Text(
                    isPackage ? "Book Now" : "Select",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),

        /// 🔥 OFFER BADGE
        if (showOffer && discount > 0)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "$discount% OFF",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

bool isOfferValid(bool offerActive, String? offerValidDate) {
  if (!offerActive || offerValidDate == null || offerValidDate.isEmpty) {
    return false;
  }

  try {
    final endDate = DateTime.parse(offerValidDate);

    // Offer valid until 11:59:59 PM of the given date
    final expiryDateTime = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      23,
      59,
      59,
    );

    return DateTime.now().isBefore(expiryDateTime);
  } catch (_) {
    return false;
  }
}
