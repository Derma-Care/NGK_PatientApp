import 'package:flutter/material.dart';

typedef SearchFunction<T> = bool Function(T item, String query);
typedef SortFunction<T> = int Function(T a, T b);

class ListController<T> {
  // Original data source
  List<T> _originalList = [];

  // After search + filter
  List<T> _filteredList = [];

  // PAGINATION NOTIFIERS
  ValueNotifier<List<T>> paginatedList = ValueNotifier([]);
  ValueNotifier<int> itemsPerPage = ValueNotifier(5);
  ValueNotifier<int> currentPage = ValueNotifier(1);
  ValueNotifier<int> totalPages = ValueNotifier(1);

  // SEARCH
  ValueNotifier<String> searchQuery = ValueNotifier("");

  // FILTER
  ValueNotifier<String> selectedFilter = ValueNotifier("None");

  // Provided callbacks
  final SearchFunction<T> searchFn;
  final Map<String, SortFunction<T>> filterMap;

  ListController({
    required List<T> initialData,
    required this.searchFn,
    required this.filterMap,
  }) {
    _originalList = List.from(initialData);
    _filteredList = List.from(initialData);
    _updatePagination();
  }

  // ───────────────────────────────────────────
  // SET INITIAL DATA (API response)
  // ───────────────────────────────────────────
  void setData(List<T> data) {
    _originalList = List.from(data);
    _filteredList = List.from(data);
    currentPage.value = 1;
    _updatePagination();
  }

  // ───────────────────────────────────────────
  // SEARCH
  // ───────────────────────────────────────────
  void applySearch(String query) {
    searchQuery.value = query;

    _filteredList = _originalList.where((item) {
      return searchFn(item, query.toLowerCase());
    }).toList();

    currentPage.value = 1;
    _updatePagination();
  }

  // ───────────────────────────────────────────
  // FILTER (SORT)
  // ───────────────────────────────────────────
  void applyFilter(String filter) {
    selectedFilter.value = filter;

    if (filterMap.containsKey(filter)) {
      _filteredList.sort(filterMap[filter]!);
    }

    currentPage.value = 1;
    _updatePagination();
  }

  // ───────────────────────────────────────────
  // PAGINATION
  // ───────────────────────────────────────────
  void _updatePagination() {
    int total = _filteredList.length;
    int perPage = itemsPerPage.value;

    totalPages.value = (total / perPage).ceil();
    if (totalPages.value == 0) totalPages.value = 1;

    if (currentPage.value > totalPages.value) {
      currentPage.value = totalPages.value;
    }

    int start = (currentPage.value - 1) * perPage;
    int end = start + perPage;
    if (end > total) end = total;

    paginatedList.value = _filteredList.sublist(start, end);
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

  // RESET EVERYTHING
  void reset() {
    _filteredList = List.from(_originalList);
    searchQuery.value = "";
    selectedFilter.value = "None";
    currentPage.value = 1;
    _updatePagination();
  }
}
