import 'package:cutomer_app/NGK/ClinicManagement/ClinicModelWithLocation.dart';
import 'package:cutomer_app/NGK/Modals/clinic_model.dart';
import 'package:cutomer_app/NGK/service/clinic_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClinicContoller {
  ValueNotifier<List<ClinicModelWithLocation>> clinicList = ValueNotifier([]);
  ValueNotifier<bool> isLoading = ValueNotifier(false);
  ValueNotifier<String> selectedFilter = ValueNotifier("All");

  List<ClinicModelWithLocation> _allClinics = [];
  List<ClinicModelWithLocation> _filteredClinics = [];

  // ---------------- LOAD ----------------
  Future<void> loadClinics() async {
    isLoading.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble('latitude');
      final lng = prefs.getDouble('longitude');
      final state = prefs.getString('stateName');

      if (lat == null || lng == null || state == null) return;

      _allClinics = await ClinicService.fetchNearbyClinics(
        lat: lat,
        lng: lng,
        state: state,
      );

      // ✅ DEFAULT STATE
      _filteredClinics = List.from(_allClinics);
      clinicList.value = _filteredClinics;
    } catch (e) {
      debugPrint("Clinic API Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadClinicsWithOffers() async {
    isLoading.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble('latitude');
      final lng = prefs.getDouble('longitude');
      final state = prefs.getString('stateName');

      if (lat == null || lng == null || state == null) return;

      _allClinics = await ClinicService.fetchNearbyClinicsWithOffers(
        lat: lat,
        lng: lng,
        state:state,
      );

      // ✅ DEFAULT STATE
      _filteredClinics = List.from(_allClinics);
      clinicList.value = _filteredClinics;
    } catch (e) {
      debugPrint("Clinic API Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> loadProcedurePricingWithClinicId(
  //     String clinicId, String procedureId) async {
  //   try {
  //     final pricing = await ClinicService.getProcedurePricingWithClinicId(
  //       clinicId: clinicId,
  //       procedureId: procedureId,
  //     );

  //     debugPrint("Procedure: ${pricing.procedureName}");
  //     debugPrint("Final Price: ${pricing.totalDiscountedAmount}");
  //   } catch (e) {
  //     debugPrint("ERROR: $e");
  //   }
  // }

  Future<void> loadPackagePricingWithClinicId(
      String clinicId, String procedureId) async {
    try {
      final pricing = await ClinicService.getPackagePricingWithClinicId(
        clinicId: clinicId,
        packageId: procedureId,
      );

      debugPrint("Procedure: ${pricing.packageName}");
      debugPrint("Final Price: ${pricing.totalDiscountedAmount}");
    } catch (e) {
      debugPrint("ERROR: $e");
    }
  }

  // ---------------- SEARCH ----------------
  void applySearch(String query) {
    final q = query.toLowerCase();

    _filteredClinics = _allClinics.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.address.toLowerCase().contains(q);
    }).toList();

    // 🔁 reapply active filter
    applyFilter(selectedFilter.value, fromSearch: true);
  }

  // ---------------- FILTER ----------------
  void applyFilter(String filter, {bool fromSearch = false}) {
    selectedFilter.value = filter;

    List<ClinicModelWithLocation> list =
        fromSearch ? List.from(_filteredClinics) : List.from(_filteredClinics);

    switch (filter) {
      case "Rating":
        list.sort((a, b) =>
            b.hospitalOverallRating.compareTo(a.hospitalOverallRating));
        break;

      case "Near Me":
        list.sort((a, b) => a.distanceInKm.compareTo(b.distanceInKm));
        break;

      case "All":
      default:
        list = List.from(_filteredClinics);
        break;
    }

    clinicList.value = list;
  }

  // ---------------- RESET (OPTIONAL) ----------------
  void resetFilters() {
    selectedFilter.value = "All";
    _filteredClinics = List.from(_allClinics);
    clinicList.value = _filteredClinics;
  }
}
