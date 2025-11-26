import 'package:cutomer_app/NGK/Screens/ClinicListScreen.dart';
import 'package:flutter/material.dart';

class ClinicContoller {
  // ------------------ Dummy Data ------------------
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

  // ------------------ Reactive State ------------------
  ValueNotifier<List<Clinic>> clinicList = ValueNotifier([]);
  ValueNotifier<String> selectedFilter = ValueNotifier("None");
  ValueNotifier<int> itemsPerPage = ValueNotifier(5);
  ValueNotifier<int> currentPage = ValueNotifier(1);
  ValueNotifier<int> totalPages = ValueNotifier(1);

  List<Clinic> _filteredList = [];

  ClinicContoller() {
    // load dummy data into filtered list
    _filteredList = List.from(dummyClinics);
    _updatePagination();
  }

  // ------------------ SEARCH ------------------
  void applySearch(String query) {
    final q = query.toLowerCase();

    _filteredList = dummyClinics.where((c) {
      return c.name!.toLowerCase().contains(q) ||
          c.address!.toLowerCase().contains(q);
    }).toList();

    currentPage.value = 1;
    _updatePagination();
  }

  // ------------------ FILTER ------------------
  void applyFilter(String filter) {
    selectedFilter.value = filter;

    List<Clinic> list = List.from(_filteredList);

    switch (filter) {
      case "High Discount":
        list.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
        break;

      case "Rating":
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;

      case "Near Me":
        list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
    }

    _filteredList = list;

    currentPage.value = 1;
    _updatePagination();
  }

  // ------------------ PAGINATION ------------------
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

    clinicList.value = _filteredList.sublist(start, end);
  }

  void changeItemsPerPage(int count) {
    itemsPerPage.value = count;
    currentPage.value = 1;
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

  void goToPage(int page) {
    currentPage.value = page;
    _updatePagination();
  }
}
