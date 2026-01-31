import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ClinicModelWithLocation.dart';
import 'Clinic_service_Location.dart';

class ClinicControllerLocation extends GetxController {
  RxList<ClinicModelWithLocation> clinicList = <ClinicModelWithLocation>[].obs;

  RxList<ClinicModelWithLocation> filteredList =
      <ClinicModelWithLocation>[].obs;
  RxList<ClinicModelWithLocation> paginatedList =
      <ClinicModelWithLocation>[].obs;
  RxBool isLoading = false.obs;
  ValueNotifier<int> itemsPerPage = ValueNotifier(5);
  ValueNotifier<int> currentPage = ValueNotifier(1);
  ValueNotifier<int> totalPages = ValueNotifier(1);
  ValueNotifier<bool> showPagination = ValueNotifier(false);

  /// Used by filter buttons
  final ValueNotifier<String> selectedFilter = ValueNotifier<String>("");

  double userLat = 0;
  double userLng = 0;

  Future<void> loadClinics({
    required double latitude,
    required double longitude,
    required String procedureId,
  }) async {
    try {
      isLoading.value = true;
      userLat = latitude;
      userLng = longitude;

      final clinics = await ClinicServiceLocation.fetchClinics(
        latitude: latitude,
        longitude: longitude,
        procedureId: procedureId,
      );

      clinicList.assignAll(clinics);
      filteredList.assignAll(clinics);
      currentPage.value = 5;
      _applyPagination();
    } finally {
      isLoading.value = false;
    }
  }

  // 🔍 SEARCH
  void applySearch(String query) {
    if (query.isEmpty) {
      filteredList.assignAll(clinicList);
    } else {
      filteredList.assignAll(
        clinicList.where((c) =>
            c.name.toLowerCase().contains(query.toLowerCase()) ||
            c.address.toLowerCase().contains(query.toLowerCase())),
      );
    }

    currentPage.value = 1;
    _applyPagination(); // ✅ only once
  }

  void _applyPagination() {
    final int totalItems = filteredList.length;
    final int perPage = itemsPerPage.value;

    // 1️⃣ Calculate total pages
    totalPages.value = (totalItems / perPage).ceil();
    if (totalPages.value < 1) totalPages.value = 1;

    // 2️⃣ Ensure current page is valid
    if (currentPage.value > totalPages.value) {
      currentPage.value = totalPages.value;
    }

    // 3️⃣ Calculate slice indexes
    final int start = (currentPage.value - 1) * perPage;
    int end = start + perPage;
    if (end > totalItems) end = totalItems;

    // 4️⃣ Update paginated list
    paginatedList.assignAll(
      start < totalItems
          ? filteredList.sublist(start, end)
          : <ClinicModelWithLocation>[],
    );

    // 5️⃣ 🔥 MOST IMPORTANT: show pagination only if multiple pages exist
    showPagination.value = totalPages.value > 0;
  }

  // 🔘 FILTER HANDLER
  void applyFilter(String filter) {
    selectedFilter.value = filter;

    switch (filter) {
      case "Near Me":
        filterNearMe();
        break;
      case "High Discount":
        filterHighDiscount();
        break;
      case "Rating":
        filterByRating();
        break;
      case "Reset":
        resetFilters();
        break;
    }
  }

  double parseDistance(String value) {
    return double.tryParse(
          value.toLowerCase().replaceAll('km', '').trim(),
        ) ??
        double.infinity;
  }

  void filterNearMe() {
    final list = clinicList
        .map((c) => MapEntry(c, parseDistance(c.distanceInKm)))
        .where((e) => e.value <= 100)
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    filteredList.assignAll(list.map((e) => e.key));
    currentPage.value = 1;
    _applyPagination();
  }

  void filterHighDiscount() {
    final list = clinicList.where((c) => c.procedurePricing != null).toList()
      ..sort((a, b) => b.procedurePricing!.totalDiscountPercentage.compareTo(
            a.procedurePricing!.totalDiscountPercentage,
          ));

    filteredList.assignAll(list);
    currentPage.value = 1;
    _applyPagination();
  }

  void filterByRating() {
    filteredList.assignAll(
      clinicList.where((c) => c.hospitalOverallRating >= 4),
    );
    currentPage.value = 1;
    _applyPagination();
  }

  void resetFilters() {
    selectedFilter.value = "";
    filteredList.assignAll(clinicList);
    currentPage.value = 1;
    _applyPagination();
  }

  /// TEMP distance (replace with haversine later)
  double _distance(double lat, double lng) => 0.5;

  /// 🎯 OFFER TEXT (TEMP LOGIC – backend ready)
  String getOfferText(ClinicModelWithLocation clinic) {
    final discount = clinic.procedurePricing?.totalDiscountPercentage;

    if (discount != null && discount >= 0) {
      return "${discount.toInt()}% OFF";
    }
    return "";
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      _applyPagination();
    }
  }

  void prevPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      _applyPagination();
    }
  }

  void goToPage(int page) {
    currentPage.value = page;
    _applyPagination();
  }

  void changeItemsPerPage(int value) {
    itemsPerPage.value = value;
    currentPage.value = 1;
    _applyPagination();
  }
}
