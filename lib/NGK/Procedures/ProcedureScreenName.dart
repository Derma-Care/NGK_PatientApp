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

  /// 🔥 Range slider values
  RangeValues _offerRange = const RangeValues(0, 0);

  /// 🔥 Max offer from API (used for default range)
  double _maxAvailableOffer = 0;

  List<ProcedureOffer> allProcedures = [];
  bool isLoading = false;

  /// 🔍 SEARCH + OFFER FILTER (FINAL LOGIC)
  List<ProcedureOffer> get _filteredProcedures {
    return allProcedures.where((p) {
      final matchesName =
          p.name.toLowerCase().contains(_searchController.text.toLowerCase());

      /// ✅ Default state = show all
      final bool isDefaultRange =
          _offerRange.start == 0 && _offerRange.end == _maxAvailableOffer;

      final bool matchesOffer = isDefaultRange
          ? true
          : (p.maxOffer >= _offerRange.start && p.minOffer <= _offerRange.end);

      return matchesName && matchesOffer;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    loadProcedures();

    _searchController.addListener(() {
      setState(() {});
    });
  }

  /// 🔄 FETCH DATA
  Future<void> loadProcedures() async {
    setState(() => isLoading = true);

    final data = await ServiceFetcher.fetchAllProceduresOffers();

    double maxOffer = 0;
    for (final p in data) {
      if (p.maxOffer > maxOffer) {
        maxOffer = p.maxOffer.toDouble();
      }
    }

    setState(() {
      allProcedures = data;
      _maxAvailableOffer = maxOffer;

      /// ✅ DEFAULT RANGE = 0 → MAX (show all)
      _offerRange = RangeValues(0, maxOffer);

      isLoading = false;
    });
  }

  /// ❌ CLEAR FILTERS
  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _offerRange = RangeValues(0, _maxAvailableOffer);
    });
  }

  Future<void> _onRefresh() async {
    await loadProcedures();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          : Column(
              children: [
                /// 🔹 FILTER BAR
                ProcedureFilterBar(
                  searchController: _searchController,
                  offerRange: _offerRange,
                  maxAvailableOffer: _maxAvailableOffer,
                  onRangeChanged: (value) {
                    setState(() => _offerRange = value);
                  },
                  onClear: _clearFilters,
                ),

                const SizedBox(height: 10),

                /// 🔹 GRID
                Expanded(
                  child: _filteredProcedures.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.search_off,
                                size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text("No procedures match your filters"),
                          ],
                        )
                      : RefreshIndicator(
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
                              return ProcedureCard(
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
