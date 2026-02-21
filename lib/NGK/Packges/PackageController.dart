import 'package:flutter/material.dart';
import 'package:cutomer_app/NGK/ClinicManagement/ClinicModelWithLocation.dart';
import 'package:cutomer_app/NGK/Packges/PackageModel.dart';
import 'package:cutomer_app/NGK/service/clinic_service.dart';
import 'package:cutomer_app/NGK/Packges/package_service.dart';

class PackageController {
  // =====================================================
  // MODE SWITCH (VERY IMPORTANT)
  // =====================================================
  bool isPackageMode = false;

  // =====================================================
  // CLINIC DATA
  // =====================================================
  List<ClinicModelWithLocation> _originalClinicList = [];
  List<ClinicModelWithLocation> _filteredClinicList = [];

  // =====================================================
  // PACKAGE DATA
  // =====================================================
  List<PackageModel> _originalPackageList = [];
  List<PackageModel> _filteredPackageList = [];

  // =====================================================
  // NOTIFIERS
  // =====================================================
  ValueNotifier<List<ClinicModelWithLocation>> clinicList = ValueNotifier([]);
  ValueNotifier<String> selectedFilter = ValueNotifier("All");

  ValueNotifier<List<PackageModel>> packageList = ValueNotifier([]);

  ValueNotifier<int> itemsPerPage = ValueNotifier(5);
  ValueNotifier<int> currentPage = ValueNotifier(1);
  ValueNotifier<int> totalPages = ValueNotifier(1);
  ValueNotifier<bool> loading = ValueNotifier(false);

  // =====================================================
  // LOAD CLINICS
  // =====================================================
  Future<void> loadClinics({
    required double latitude,
    required double longitude,
    required String state,
  }) async {
    loading.value = true;
    isPackageMode = false;

    try {
      final data = await PackageService.fetchPackagesClinics(
        latitude: latitude,
        longitude: longitude,
        state: state,
      );

      _originalClinicList = data;
      _filteredClinicList = List.from(data);

      currentPage.value = 1;
      _updateClinicPageData();
    } catch (e) {
      debugPrint("Clinic fetch error: $e");
    } finally {
      loading.value = false;
    }
  }

  // =====================================================
  // LOAD PACKAGES
  // =====================================================
  Future<void> loadPackages({
    required String clinicId,
  }) async {
    loading.value = true;
    isPackageMode = true;

    debugPrint("📦 Loading packages for clinicId: $clinicId");

    try {
      final data = await ClinicService.fetchPackagesByClinicId(
        clinicId: clinicId,
      );

      debugPrint("📦 API Returned Packages Count: ${data.length}");

      if (data.isNotEmpty) {
        debugPrint("📦 First Package Name: ${data.first.packageName}");
        debugPrint("💰 Price: ${data.first.price}");
        debugPrint("🎯 Discount %: ${data.first.totalDiscountPercentage}");
        debugPrint("💸 Discounted Amount: ${data.first.totalDiscountedAmount}");
        debugPrint("💸 Platform Fee: ${data.first.platformFee}");
        debugPrint(
            "💸 Platform platformFeePercentage: ${data.first.platformFeePercentage}");
      } else {
        debugPrint("⚠️ No packages received from API");
      }

      _originalPackageList = data;
      _filteredPackageList = List.from(data);

      debugPrint("📦 Original List Length: ${_originalPackageList.length}");
      debugPrint("📦 Filtered List Length: ${_filteredPackageList.length}");

      currentPage.value = 1;
      _updatePackagePageData();

      debugPrint("📄 Paginated List Length: ${packageList.value.length}");
    } catch (e) {
      debugPrint("❌ Package fetch error: $e");
    } finally {
      loading.value = false;
      debugPrint("📦 Loading Finished");
    }
  }

  // =====================================================
  // CLINIC PAGINATION
  // =====================================================
  void _updateClinicPageData() {
    final perPage = itemsPerPage.value;
    final total = _filteredClinicList.length;

    if (total == 0) {
      clinicList.value = [];
      totalPages.value = 1;
      return;
    }

    totalPages.value = (total / perPage).ceil();

    final start = (currentPage.value - 1) * perPage;
    final end = start + perPage > total ? total : start + perPage;

    clinicList.value = _filteredClinicList.sublist(start, end);
  }

  // =====================================================
  // PACKAGE PAGINATION
  // =====================================================
  void _updatePackagePageData() {
    final perPage = itemsPerPage.value;
    final total = _filteredPackageList.length;

    if (total == 0) {
      packageList.value = [];
      totalPages.value = 1;
      return;
    }

    totalPages.value = (total / perPage).ceil();

    final start = (currentPage.value - 1) * perPage;
    final end = start + perPage > total ? total : start + perPage;

    packageList.value = _filteredPackageList.sublist(start, end);
  }

  // =====================================================
  // COMMON PAGINATION CONTROLS
  // =====================================================
  void changeItemsPerPage(int count) {
    itemsPerPage.value = count;
    currentPage.value = 1;

    if (isPackageMode) {
      _updatePackagePageData();
    } else {
      _updateClinicPageData();
    }
  }

  void goToPage(int page) {
    currentPage.value = page;

    if (isPackageMode) {
      _updatePackagePageData();
    } else {
      _updateClinicPageData();
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;

      if (isPackageMode) {
        _updatePackagePageData();
      } else {
        _updateClinicPageData();
      }
    }
  }

  void prevPage() {
    if (currentPage.value > 1) {
      currentPage.value--;

      if (isPackageMode) {
        _updatePackagePageData();
      } else {
        _updateClinicPageData();
      }
    }
  }

  // =====================================================
// SEARCH (WORKS FOR BOTH CLINIC + PACKAGE)
// =====================================================
  void applySearch(String query) {
    final search = query.toLowerCase();

    currentPage.value = 1;

    if (isPackageMode) {
      // 🔹 PACKAGE SEARCH
      _filteredPackageList = _originalPackageList.where((pkg) {
        return pkg.packageName.toLowerCase().contains(search) ||
            (pkg.clinicName ?? "").toLowerCase().contains(search) ||
            (pkg.clinicAddress ?? "").toLowerCase().contains(search);
      }).toList();

      _updatePackagePageData();
    } else {
      // 🔹 CLINIC SEARCH
      _filteredClinicList = _originalClinicList.where((clinic) {
        return clinic.name.toLowerCase().contains(search) ||
            clinic.address.toLowerCase().contains(search) ||
            clinic.city.toLowerCase().contains(search);
      }).toList();

      _updateClinicPageData();
    }
  }

  void clearSearch() {
    currentPage.value = 1;

    if (isPackageMode) {
      _filteredPackageList = List.from(_originalPackageList);
      _updatePackagePageData();
    } else {
      _filteredClinicList = List.from(_originalClinicList);
      _updateClinicPageData();
    }
  }

  double _distance(String? d) {
    if (d == null) return 0;
    return double.tryParse(
            d.replaceAll("KM", "").replaceAll("km", "").trim()) ??
        0;
  }

  // =====================================================
// FILTER (WORKS FOR BOTH CLINIC + PACKAGE)
// =====================================================
  void applyFilter(String filter) {
    selectedFilter.value = filter;
    currentPage.value = 1;

    if (isPackageMode) {
      // 🔹 PACKAGE FILTERS
      List<PackageModel> list = List.from(_originalPackageList);

      switch (filter) {
        case "High Discount":
          list.sort((a, b) =>
              (b.totalDiscountPercentage).compareTo(a.totalDiscountPercentage));
          break;

        case "Low Price":
          list.sort((a, b) =>
              a.totalDiscountedAmount.compareTo(b.totalDiscountedAmount));
          break;

        case "High Price":
          list.sort((a, b) =>
              b.totalDiscountedAmount.compareTo(a.totalDiscountedAmount));
          break;

        case "All":
        default:
          list = List.from(_originalPackageList);
          break;
      }

      _filteredPackageList = list;
      _updatePackagePageData();
    } else {
      // 🔹 CLINIC FILTERS
      List<ClinicModelWithLocation> list = List.from(_originalClinicList);

      switch (filter) {
        case "Near Me":
          list.sort((a, b) =>
              _distance(a.distanceInKm).compareTo(_distance(b.distanceInKm)));
          break;

        case "Rating":
          list.sort((a, b) =>
              b.hospitalOverallRating.compareTo(a.hospitalOverallRating));
          break;

        case "High Discount":
          list.sort((a, b) =>
              (b.maxOfferPercentage ?? 0).compareTo(a.maxOfferPercentage ?? 0));
          break;

        case "All":
        default:
          list = List.from(_originalClinicList);
          break;
      }

      _filteredClinicList = list;
      _updateClinicPageData();
    }
  }
}
