import 'package:flutter/material.dart';
import 'common_pagination.dart'; // your reusable pagination numbers widget

class CommonPaginationBar extends StatelessWidget {
  final ValueNotifier<bool> showPagination;
  final ValueNotifier<int> itemsPerPage;
  final ValueNotifier<int> currentPage;
  final ValueNotifier<int> totalPages;

  final Function(int) onItemsPerPageChanged;
  final Function() onNext;
  final Function() onPrev;
  final Function(int) onPageSelected;

  const CommonPaginationBar({
    super.key,
    required this.showPagination,
    required this.itemsPerPage,
    required this.currentPage,
    required this.totalPages,
    required this.onItemsPerPageChanged,
    required this.onNext,
    required this.onPrev,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: showPagination,
      builder: (context, visible, _) {
        return AnimatedSlide(
          duration: const Duration(milliseconds: 250),
          offset: visible ? const Offset(0, 0) : const Offset(0, 1),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: visible ? 1 : 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  // ---------------- ITEMS PER PAGE DROPDOWN ----------------
                  ValueListenableBuilder(
                    valueListenable: itemsPerPage,
                    builder: (context, perPage, _) {
                      return DropdownButton<int>(
                        value: perPage,
                        underline: SizedBox(),
                        items: [1, 5, 10, 20].map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text("$e"),
                          );
                        }).toList(),
                        onChanged: (v) {
                          onItemsPerPageChanged(v!);
                        },
                      );
                    },
                  ),

                  // ---------------- PAGE NUMBERS ----------------
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CommonPagination(
                          currentPage: currentPage,
                          totalPages: totalPages,
                          onNext: onNext,
                          onPrev: onPrev,
                          onPageSelected: onPageSelected,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
