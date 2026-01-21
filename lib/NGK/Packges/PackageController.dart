 
import 'package:flutter/material.dart';
import 'PackageModel.dart';
import 'package_service.dart';

class PackageController {
  // ---------- Backend Data ----------
  List<PackageModel> _originalList = [];
  late List<PackageModel> _filteredList;

  // ---------- Notifiers ----------
  ValueNotifier<List<PackageModel>> packageList = ValueNotifier([]);
  ValueNotifier<String> selectedFilter = ValueNotifier("All");
  ValueNotifier<String> searchQuery = ValueNotifier("");
  ValueNotifier<int> itemsPerPage = ValueNotifier(5);
  ValueNotifier<int> currentPage = ValueNotifier(1);
  ValueNotifier<int> totalPages = ValueNotifier(1);
  ValueNotifier<bool> loading = ValueNotifier(false);

  // ---------- INIT ----------
  Future<void> loadPackages({
    required double latitude,
    required double longitude,
  }) async {
    loading.value = true;

    try {
      final data = await PackageService.fetchPackages(
        latitude: latitude,
        longitude: longitude,
      );

      _originalList = data.map((e) => PackageModel.fromApi(e)).toList();

      _filteredList = List.from(_originalList);
      currentPage.value = 1;
      _updatePageData();
    } catch (e) {
      debugPrint("Package fetch error: $e");
    } finally {
      loading.value = false;
    }
  }

  // ---------- Helpers ----------
  double _rating(String r) => double.tryParse(r) ?? 0;
  double _distance(String d) =>
      double.tryParse(d.replaceAll("KM", "").trim()) ?? 0;

  // ============================================================
  // SEARCH
  // ============================================================
  void applySearch(String query) {
    searchQuery.value = query.toLowerCase();

    _filteredList = _originalList.where((pkg) {
      return pkg.packageName.toLowerCase().contains(query) ||
          pkg.clinicName.toLowerCase().contains(query) ||
          pkg.clinicAddress.toLowerCase().contains(query);
    }).toList();

    currentPage.value = 1;
    _updatePageData();
  }

  // ============================================================
  // FILTER
  // ============================================================
  void applyFilter(String filter) {
    selectedFilter.value = filter;

    final list = List<PackageModel>.from(_filteredList);

    switch (filter) {
      case "High Discount":
        list.sort(
            (a, b) => b.discountPercentage.compareTo(a.discountPercentage));
        break;

      case "Low Price":
        list.sort((a, b) => a.finalCost.compareTo(b.finalCost));
        break;

      case "High Price":
        list.sort((a, b) => b.finalCost.compareTo(a.finalCost));
        break;

      case "Rating":
        list.sort((a, b) =>
            _rating(b.clinicRating).compareTo(_rating(a.clinicRating)));
        break;

      case "Near Me":
        list.sort(
            (a, b) => _distance(a.distance).compareTo(_distance(b.distance)));
        break;
      case "All":
      default:
        _filteredList = List.from(_originalList);
        break;
    }

    _filteredList = list;
    currentPage.value = 1;
    _updatePageData();
  }

  // ============================================================
  // PAGINATION
  // ============================================================
  void _updatePageData() {
    final perPage = itemsPerPage.value;
    final total = _filteredList.length;

    totalPages.value = (total / perPage).ceil();
    if (totalPages.value == 0) totalPages.value = 1;

    final start = (currentPage.value - 1) * perPage;
    final end = (start + perPage).clamp(0, total);

    packageList.value = _filteredList.sublist(start, end);
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
