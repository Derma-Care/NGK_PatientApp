import 'package:flutter/material.dart';
import 'PackageModel.dart';

class PackageController {
  // ---------- Original Data ----------
  final List<PackageModel> _originalList = [
    PackageModel(
      packageId: 1,
      packageName: "Glow Skin Brightening",
      clinicId: "CLN001",
      clinicName: "GlowKart Clinic",
      clinicAddress: "Jubilee Hills",
      clinicRating: "4.5",
      distance: "2 KM",
      price: 8000,
      discountPercentage: 20,
      finalPrice: 6400,
      procedures: [
        ProcedureModel(procedureName: "Chemical Peel", noOfSittings: 3),
        ProcedureModel(procedureName: "Laser Toning", noOfSittings: 2),
      ],
    ),
    PackageModel(
      packageId: 2,
      packageName: "Acne Control Package",
      clinicId: "CLN002",
      clinicName: "FreshFace Clinic",
      clinicAddress: "Banjara Hills",
      clinicRating: "4.7",
      distance: "3.1 KM",
      price: 6500,
      discountPercentage: 25,
      finalPrice: 4875,
      procedures: [
        ProcedureModel(procedureName: "Acne Peel", noOfSittings: 4),
        ProcedureModel(procedureName: "LED Therapy", noOfSittings: 3),
      ],
    ),
    PackageModel(
      packageId: 3,
      packageName: "Anti-Aging Rejuvenation",
      clinicId: "CLN003",
      clinicName: "New You Clinic",
      clinicAddress: "Madhapur",
      clinicRating: "4.3",
      distance: "1.8 KM",
      price: 12000,
      discountPercentage: 15,
      finalPrice: 10200,
      procedures: [
        ProcedureModel(procedureName: "Hydra Facial", noOfSittings: 3),
        ProcedureModel(procedureName: "Micro Needling", noOfSittings: 2),
      ],
    ),
    PackageModel(
      packageId: 4,
      packageName: "Hair Growth PRP Package",
      clinicId: "CLN004",
      clinicName: "DermaCare Clinic",
      clinicAddress: "Kondapur",
      clinicRating: "4.6",
      distance: "4 KM",
      price: 8000,
      discountPercentage: 10,
      finalPrice: 7200,
      procedures: [
        ProcedureModel(procedureName: "PRP Therapy", noOfSittings: 4),
      ],
    ),
    PackageModel(
      packageId: 5,
      packageName: "Tan Removal Package",
      clinicId: "CLN005",
      clinicName: "Skin Glow Hub",
      clinicAddress: "Ameerpet",
      clinicRating: "4.4",
      distance: "2.7 KM",
      price: 5500,
      discountPercentage: 20,
      finalPrice: 4400,
      procedures: [
        ProcedureModel(procedureName: "De-Tan Peel", noOfSittings: 2),
        ProcedureModel(procedureName: "Laser Toning", noOfSittings: 1),
      ],
    ),
    PackageModel(
      packageId: 6,
      packageName: "Full Body Laser Hair Removal",
      clinicId: "CLN006",
      clinicName: "Skin Revive Clinic",
      clinicAddress: "Gachibowli",
      clinicRating: "4.8",
      distance: "5 KM",
      price: 15000,
      discountPercentage: 30,
      finalPrice: 10500,
      procedures: [
        ProcedureModel(procedureName: "Laser Hair Removal", noOfSittings: 6),
      ],
    ),
    PackageModel(
      packageId: 7,
      packageName: "Bridal Glow Package",
      clinicId: "CLN007",
      clinicName: "Royal Skin Studio",
      clinicAddress: "Begumpet",
      clinicRating: "4.9",
      distance: "2.2 KM",
      price: 9500,
      discountPercentage: 20,
      finalPrice: 7600,
      procedures: [
        ProcedureModel(procedureName: "Hydra Facial", noOfSittings: 2),
        ProcedureModel(procedureName: "Glow Peel", noOfSittings: 2),
      ],
    ),
    PackageModel(
      packageId: 8,
      packageName: "Pigmentation Treatment Package",
      clinicId: "CLN008",
      clinicName: "DermaSkin Clinic",
      clinicAddress: "Kukatpally",
      clinicRating: "4.2",
      distance: "3.5 KM",
      price: 10000,
      discountPercentage: 15,
      finalPrice: 8500,
      procedures: [
        ProcedureModel(procedureName: "Q-Switch Laser", noOfSittings: 3),
        ProcedureModel(procedureName: "Chemical Peel", noOfSittings: 1),
      ],
    ),
    PackageModel(
      packageId: 9,
      packageName: "Weight Loss Fat Freeze",
      clinicId: "CLN009",
      clinicName: "SlimFit Wellness",
      clinicAddress: "Film Nagar",
      clinicRating: "4.1",
      distance: "1.2 KM",
      price: 12000,
      discountPercentage: 20,
      finalPrice: 9600,
      procedures: [
        ProcedureModel(procedureName: "Cryolipolysis", noOfSittings: 3),
      ],
    ),
    PackageModel(
      packageId: 10,
      packageName: "Under-Eye Rejuvenation",
      clinicId: "CLN010",
      clinicName: "Youth Derma",
      clinicAddress: "Hitech City",
      clinicRating: "4.6",
      distance: "2.9 KM",
      price: 8500,
      discountPercentage: 15,
      finalPrice: 7225,
      procedures: [
        ProcedureModel(procedureName: "Under Eye Peeling", noOfSittings: 2),
        ProcedureModel(procedureName: "Laser Tightening", noOfSittings: 1),
      ],
    ),
  ];

  // ---------- Notifiers ----------
  ValueNotifier<List<PackageModel>> packageList = ValueNotifier([]);
  ValueNotifier<String> selectedFilter = ValueNotifier("None");
  ValueNotifier<String> searchQuery = ValueNotifier("");
  ValueNotifier<int> itemsPerPage = ValueNotifier(5);
  ValueNotifier<int> currentPage = ValueNotifier(1);
  ValueNotifier<int> totalPages = ValueNotifier(1);
  ValueNotifier<bool> loading = ValueNotifier(false);

  late List<PackageModel> _filteredList;

  PackageController() {
    _filteredList = List.from(_originalList);
    _updatePageData();
  }

  // ---------- Helpers ----------
  double _rating(String r) => double.tryParse(r) ?? 0;
  double _distance(String d) =>
      double.tryParse(d.replaceAll("KM", "").trim()) ?? 0;

  // ============================================================
  //                       SEARCH
  // ============================================================
  void applySearch(String query) {
    searchQuery.value = query.toLowerCase();

    _filteredList = _originalList.where((pkg) {
      final q = query.toLowerCase();
      return pkg.packageName.toLowerCase().contains(q) ||
          pkg.clinicName.toLowerCase().contains(q) ||
          pkg.clinicAddress.toLowerCase().contains(q);
    }).toList();

    currentPage.value = 1;
    _updatePageData();
  }

  // ============================================================
  //                       FILTER
  // ============================================================
  void applyFilter(String filter) {
    selectedFilter.value = filter;

    List<PackageModel> list = List.from(_filteredList);

    switch (filter) {
      case "High Discount":
        list.sort(
            (a, b) => b.discountPercentage.compareTo(a.discountPercentage));
        break;

      case "Low Price":
        list.sort((a, b) => a.finalPrice.compareTo(b.finalPrice));
        break;

      case "High Price":
        list.sort((a, b) => b.finalPrice.compareTo(a.finalPrice));
        break;

      case "Rating":
        list.sort((a, b) =>
            _rating(b.clinicRating).compareTo(_rating(a.clinicRating)));
        break;

      case "Near Me":
        list.sort(
            (a, b) => _distance(a.distance).compareTo(_distance(b.distance)));
        break;
    }

    _filteredList = list;

    currentPage.value = 1;
    _updatePageData();
  }

  // ============================================================
  //                     PAGINATION LOGIC
  // ============================================================
  void _updatePageData() {
    int perPage = itemsPerPage.value;
    int total = _filteredList.length;

    totalPages.value = (total / perPage).ceil();
    if (totalPages.value == 0) totalPages.value = 1;

    if (currentPage.value > totalPages.value)
      currentPage.value = totalPages.value;

    int start = (currentPage.value - 1) * perPage;
    int end = start + perPage;

    packageList.value = _filteredList.sublist(start, end > total ? total : end);
  }

  void changeItemsPerPage(int count) {
    itemsPerPage.value = count;
    currentPage.value = 1;
    _updatePageData();
  }

  void goToPage(int page) {
    currentPage.value = page;
    _updatePageData();
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      _updatePageData();
    }
  }

  void prevPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      _updatePageData();
    }
  }
}
