import 'dart:convert';
import 'package:cutomer_app/NGK/Screens/ClinicListScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/NGK/Procedures/ProcedureModel.dart';

class Procedurecontroller {
  final List<Clinic> dummyClinics = [
    Clinic(
      name: "Glow Skin Clinic",
      address: "12, MG Road, Bengaluru",
      distanceKm: 1.2,
      rating: 4.7,
      discountPercent: 30,
      imageUrl: "assets/h1.jpg",
    ),
    Clinic(
      name: "DermaCare Center",
      address: "Indiranagar, Bengaluru",
      distanceKm: 3.5,
      rating: 4.5,
      discountPercent: 20,
      imageUrl: "assets/h2.jpg",
    ),
    Clinic(
      name: "Neha’s GlowKart Clinic",
      address: "Whitefield, Bengaluru sfdsdfdsfdsfdsfsd",
      distanceKm: 5.1,
      rating: 4.9,
      discountPercent: 40,
      imageUrl: "assets/h3.jpg",
    ),
  ];

  // -------------------- API STATE --------------------
  ValueNotifier<bool> loading = ValueNotifier(false);
  ValueNotifier<List<ProcedureListmodel>> serviceList = ValueNotifier([]);
  ValueNotifier<List<Clinic>> clinicList = ValueNotifier([]);
  final String baseUrl =
      "http://3.6.119.57:9090/clinic-admin/getSubServiceByHospitalId/0001";

  Future<void> fetchSubServices() async {
    try {
      loading.value = true;

      final response = await http.get(Uri.parse(baseUrl));
      print("responseresponseresponse ${response.body}");
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List rawList = jsonData["data"];

        final List<ProcedureListmodel> parsed =
            rawList.map((e) => ProcedureListmodel.fromJson(e)).toList();

        // update service list
        serviceList.value = parsed;

        // update filtered list + pagination
        setProcedureData(parsed);
      }
    } catch (e) {
      print("Error fetching services: $e");
    } finally {
      loading.value = false;
    }
  }

  // -------------------- CONTROLLER STATE --------------------
  ValueNotifier<List<ProcedureListmodel>> procedureList = ValueNotifier([]);
  ValueNotifier<String> selectedFilter = ValueNotifier("None");
  ValueNotifier<String> searchQuery = ValueNotifier("");
  ValueNotifier<int> itemsPerPage = ValueNotifier(5);
  ValueNotifier<int> currentPage = ValueNotifier(1);
  ValueNotifier<int> totalPages = ValueNotifier(1);

  List<ProcedureListmodel> _filteredList = [];

  Procedurecontroller() {
    // Do NOT initialize with empty list
    // Wait until API finishes, then set data
  }

  // -------------------- HELPERS --------------------
  double _rating(String r) => double.tryParse(r) ?? 0;

  double _timeToMinutes(String t) {
    return double.tryParse(t.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  // ============================================================
  // SEARCH
  // ============================================================
  void applySearch(String query) {
    searchQuery.value = query.toLowerCase();

    final q = query.toLowerCase();

    _filteredList = serviceList.value.where((svc) {
      return svc.subServiceName.toLowerCase().contains(q) ||
          svc.serviceName.toLowerCase().contains(q) ||
          svc.categoryName.toLowerCase().contains(q);
      // ||
      // svc.clinicName.toLowerCase().contains(q) ||
      // svc.clinicAddress.toLowerCase().contains(q);
    }).toList();

    currentPage.value = 1;
    _updatePagination();
  }

  // ============================================================
  // FILTERS
  // ============================================================
  void applyFilter(String filter) {
    selectedFilter.value = filter;

    List<ProcedureListmodel> list = List.from(_filteredList);

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

      // case "Rating":
      //   list.sort((a, b) =>
      //       _rating(b.clinicRating).compareTo(_rating(a.clinicRating)));
      //   break;

      // case "Short Time":
      //   list.sort((a, b) =>
      //       _timeToMinutes(a.minTime).compareTo(_timeToMinutes(b.minTime)));
      //   break;

      // case "Long Time":
      //   list.sort((a, b) =>
      //       _timeToMinutes(b.minTime).compareTo(_timeToMinutes(a.minTime)));
      //   break;
    }

    _filteredList = list;

    currentPage.value = 1;
    _updatePagination();
  }

  // ============================================================
  // PAGINATION
  // ============================================================
  void _updatePagination() {
    int perPage = itemsPerPage.value;
    int total = _filteredList.length;

    totalPages.value = (total / perPage).ceil();
    if (totalPages.value < 1) totalPages.value = 1;

    if (currentPage.value > totalPages.value) {
      currentPage.value = totalPages.value;
    }

    int start = (currentPage.value - 1) * perPage;
    int end = start + perPage;
    if (end > total) end = total;

    procedureList.value = _filteredList.sublist(start, end);
  }

  void changeItemsPerPage(int count) {
    itemsPerPage.value = count;
    currentPage.value = 1;
    _updatePagination();
  }

  void goToPage(int page) {
    currentPage.value = page;
    _updatePagination();
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      _updatePagination();
    }
  }

  void prevPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      _updatePagination();
    }
  }

  // ============================================================
  // When API finishes, update controller data
  // ============================================================
  void setProcedureData(List<ProcedureListmodel> apiData) {
    _filteredList = List.from(apiData);
    currentPage.value = 1;
    _updatePagination();
  }
}
