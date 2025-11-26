import 'dart:convert';
import 'package:cutomer_app/NGK/Modals/PaymentModal.dart';
import 'package:cutomer_app/NGK/Procedures/ProcedureModel.dart';
import 'package:cutomer_app/NGK/Widgets/PackageBookingSheet.dart';
import 'package:flutter/material.dart';

class ProcedureDetailsPage extends StatefulWidget {
  final ProcedureListmodel service;

  const ProcedureDetailsPage({super.key, required this.service});

  @override
  State<ProcedureDetailsPage> createState() => _ProcedureDetailsPageState();
}

class _ProcedureDetailsPageState extends State<ProcedureDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final service = widget.service;

    return Scaffold(
      appBar: AppBar(
        title: Text(service.subServiceName),
        backgroundColor: Colors.pink,
      ),
      body: _buildDetailsView(service),
    );
  }

  // ---------- MAIN VIEW ----------
  Widget _buildDetailsView(ProcedureListmodel service) {
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
              child: Image.memory(
                base64Decode(service.subServiceImage),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
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
              service.viewDescription,
              style: const TextStyle(fontSize: 14, height: 1.4),
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
                final paymentModal = PaymentModal(
                  price: service.price.toDouble(),
                  discountPercentage: service.discountPercentage,
                );

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => PackageBookingSheet(payment: paymentModal),
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
