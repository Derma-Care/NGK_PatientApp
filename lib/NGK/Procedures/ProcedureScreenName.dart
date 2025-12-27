import 'package:cutomer_app/APIs/FetchServices.dart';
import 'package:cutomer_app/NGK/Procedures/ProcedureCardName.dart';
import 'package:cutomer_app/NGK/Procedures/ProcedureFilterBar.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ProcedureGridScreen extends StatefulWidget {
  const ProcedureGridScreen({super.key});

  @override
  State<ProcedureGridScreen> createState() => _ProcedureGridScreenState();
}

class _ProcedureGridScreenState extends State<ProcedureGridScreen> {
  final TextEditingController _searchController = TextEditingController();

  RangeValues _offerRange = const RangeValues(0, 100);

  List<ProcedureOffer> allProcedures = [];
  bool isLoading = false;

  // final List<Procedure> _allProcedures = [
  //   Procedure(
  //     procedureId: "1",
  //     name: "Facial",
  //     minOffer: 10,
  //     maxOffer: 30,
  //   ),
  //   Procedure(
  //     procedureId: "2",
  //     name: "Laser",
  //     minOffer: 15,
  //     maxOffer: 25,
  //   ),
  //   Procedure(
  //     procedureId: "3",
  //     name: "PRP",
  //     minOffer: 20,
  //     maxOffer: 40,
  //   ),
  //   Procedure(
  //     procedureId: "4",
  //     name: "Botox",
  //     minOffer: 5,
  //     maxOffer: 15,
  //   ),
  //   Procedure(
  //     procedureId: "5",
  //     name: "Botox4",
  //     minOffer: 5,
  //     maxOffer: 15,
  //   ),
  //   Procedure(
  //     procedureId: "6",
  //     name: "Botox1",
  //     minOffer: 5,
  //     maxOffer: 15,
  //   ),
  //   Procedure(
  //     procedureId: "7",
  //     name: "Botox2",
  //     minOffer: 5,
  //     maxOffer: 15,
  //   ),
  //   Procedure(
  //     procedureId: "8",
  //     name: "Hydra Facial",
  //     minOffer: 10,
  //     maxOffer: 20,
  //   ),
  //   Procedure(
  //     procedureId: "9",
  //     name: "Chemical Peel",
  //     minOffer: 15,
  //     maxOffer: 35,
  //   ),
  // ];

  // 🔥 SEARCH + RANGE FILTER (FIXED)
  List<ProcedureOffer> get _filteredProcedures {
    return allProcedures.where((p) {
      final matchesName =
          p.name.toLowerCase().contains(_searchController.text.toLowerCase());

      final matchesOffer =
          p.maxOffer >= _offerRange.start && p.minOffer <= _offerRange.end;

      return matchesName && matchesOffer;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    loadProcedures();
    // 🔥 THIS MAKES SEARCH WORK
    _searchController.addListener(() {
      setState(() {});
    });
  }

  Future<void> loadProcedures() async {
    setState(() => isLoading = true);
    allProcedures = await ServiceFetcher.fetchAllProceduresOffers();
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _offerRange = const RangeValues(0, 100);
    });
  }

  Future<void> _onRefresh() async {
    await loadProcedures();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(title: "Procedures"),
      body: isLoading
          ? const Center(
              child: SpinKitFadingCircle(
                color: mainColor,
                size: 40,
              ),
            )
          : _filteredProcedures.isEmpty
              ? const Center(
                  child: Text(
                    "No procedures found",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : Column(
                  children: [
                    ProcedureFilterBar(
                      searchController: _searchController,
                      offerRange: _offerRange,
                      onRangeChanged: (value) {
                        setState(() => _offerRange = value);
                      },
                      onClear: _clearFilters,
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: RefreshIndicator(
                        color: Colors.pink,
                        onRefresh: _onRefresh,
                        child: GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(12),
                          itemCount: _filteredProcedures.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                            childAspectRatio: 0.9,
                          ),
                          itemBuilder: (context, index) {
                            return 
                            
                            ProcedureCard(
                              procedure: _filteredProcedures[index],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
