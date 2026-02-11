import 'dart:convert';
import 'dart:io';
import 'package:cutomer_app/NGK/Modals/PaymentModal.dart';
import 'package:cutomer_app/NGK/Procedures/ProcedureModel.dart';
import 'package:cutomer_app/NGK/Widgets/PackageBookingSheet.dart';
import 'package:cutomer_app/NGK/service/clinic_service.dart';
import 'package:cutomer_app/Utils/DateConverter.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:cutomer_app/Utils/procedureImageWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';

class ProcedureDetailsPage extends StatefulWidget {
  // final ProcedureListModal service;
  final String clinicId;
  final String procedureId;
  final String clinicName;

  const ProcedureDetailsPage(
      {super.key,
      // required this.service,
      required this.clinicId,
      required this.procedureId,
      required this.clinicName});

  @override
  State<ProcedureDetailsPage> createState() => _ProcedureDetailsPageState();
}

class _ProcedureDetailsPageState extends State<ProcedureDetailsPage> {
  bool isLoading = true;
  ProcedureListModal? pricing; // use your actual model
  String? error;

  @override
  void initState() {
    super.initState();
    _loadPricing();
  }

  Future<void> _loadPricing() async {
    try {
      final result = await ClinicService.getProcedurePricingWithClinicId(
        clinicId: widget.clinicId,
        procedureId: widget.procedureId,
      );
      if (!mounted) return;
      setState(() {
        pricing = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  bool _isFutureOrToday(String date) {
    try {
      final endDate = DateTime.parse(date);
      final today = DateTime.now();

      final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);
      final normalizedToday = DateTime(today.year, today.month, today.day);

      return !normalizedEnd.isBefore(normalizedToday);
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = pricing;

    return Scaffold(
      appBar: CommonHeader(
        title: service?.procedureName ?? " ",
        subtitle: widget.clinicName ?? "",
      ),

      body: isLoading
          ? const Center(
              child: SpinKitFadingCircle(
                color: Colors.pink,
                size: 40,
              ),
            )
          : error != null
              ? Center(child: Text(error!))
              : pricing == null
                  ? const Center(child: Text("No data found"))
                  : _buildDetailsView(pricing!), // ✅ SAFE
    );
  }

  // ---------- MAIN VIEW ----------
  Widget _buildDetailsView(ProcedureListModal service) {
    final tabs = <Tab>[];
    final views = <Widget>[];

    if (service.preProcedureQA.isNotEmpty) {
      tabs.add(const Tab(text: "Pre-Procedure"));
      views.add(_qaList(service.preProcedureQA));
    }
    if (service.procedureQA.isNotEmpty) {
      tabs.add(const Tab(text: "Procedure"));
      views.add(_qaList(service.procedureQA));
    }
    if (service.postProcedureQA.isNotEmpty) {
      tabs.add(const Tab(text: "Post-Procedure"));
      views.add(_qaList(service.postProcedureQA));
    }

    final hasTabs = tabs.isNotEmpty;

    return DefaultTabController(
      length: hasTabs ? tabs.length : 1,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: procedureImageWidget(service.procedureImage),
              ),
            ),

            const SizedBox(height: 20),

            // DESCRIPTION
            const Text(
              "Description",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              service.description,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 25),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔗 Procedure Link
                if (service.procedureLink != null &&
                    service.procedureLink!.isNotEmpty)
                  infoItem(
                    label: "Procedure Process",
                    icon: Icons.open_in_new,
                    value: InkWell(
                      onTap: () async {
                        final uri = Uri.parse(service.procedureLink!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      child: const Text(
                        "View Procedure Process",
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                /// 🧪 Sittings
                infoItem(
                  label: "Sittings",
                  icon: Icons.repeat,
                  value: Text(
                    "${service.sittings}",
                    style: const TextStyle(fontSize: 14),
                  ),
                ),

                /// ⏱ Minimum Time
                infoItem(
                  label: "Minimum Time",
                  icon: Icons.timer,
                  value: Text(
                    service.minTime,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),

                /// 🏷 Offer End Date
                if (service.offerValidDate != null &&
                    service.offerValidDate!.isNotEmpty &&
                    _isFutureOrToday(service.offerValidDate ?? ""))
                  infoItem(
                    label: "Offer End Date",
                    icon: Icons.calendar_today,
                    value: Text(
                      "${formatDateOnly(service.offerValidDate)}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
              ],
            ),

            // ---------- TABS ----------
            if (hasTabs) ...[
              const SizedBox(height: 20),
              TabBar(
                labelColor: Colors.pink,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.pink,
                tabs: tabs,
              ),
              SizedBox(
                height: 250,
                child: TabBarView(children: views),
              ),
            ],

            const SizedBox(height: 20),

            // ---------- BOOK NOW BUTTON ----------
            ElevatedButton(
              onPressed: () {
                // PaymentModal fromProcedure(ProcedureListModal p) {
                //     return PaymentModal(
                //       clinicId: p.clinicId,
                //       serviceId: p.procedureId,
                //       serviceType: "PROCEDURE",
                //       price: p.price,
                //       consultationFee: p.consultationFee,
                //       gst: p.gst,
                //       gstAmount: p.gstAmount,
                //       taxPercentage: p.taxPercentage,
                //       taxAmount: p.taxAmount,
                //       discountPercentage: p.totalDiscountPercentage,
                //       discountAmount: p.totalDiscountAmount,
                //       platformFee: 10,
                //       finalCost: p.finalCost,
                //     );
                //   }

                final payment = PaymentModal.fromProcedure(service);

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
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                minimumSize: const Size(double.infinity, 55),
              ),
              child: const Text("Book Now", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoItem({
    required String label,
    required Widget value,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: Colors.pinkAccent),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          value,
        ],
      ),
    );
  }

  // ---------- QA LIST ----------
  Widget _qaList(List<Map<String, dynamic>> qaData) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: qaData.length,
      itemBuilder: (context, index) {
        final item = qaData[index];

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: item.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    ...List<String>.from(entry.value)
                        .map((v) =>
                            Text("- $v", style: const TextStyle(fontSize: 14)))
                        .toList(),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
