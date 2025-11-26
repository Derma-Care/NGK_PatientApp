import 'package:flutter/material.dart';

class CommonPagination extends StatelessWidget {
  final ValueNotifier<int> currentPage;
  final ValueNotifier<int> totalPages;
  final Function() onNext;
  final Function() onPrev;
  final Function(int) onPageSelected;

  const CommonPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    required this.onPrev,
    required this.onPageSelected,
  });

  // ---------- Page numbers (1 2 ... 5 6 7 ... 20) ----------
  List<Widget> _compactPageNumbers(int current, int total) {
    List<Widget> pages = [];

    for (int i = 1; i <= total; i++) {
      if (i == 1 || i == total || (i >= current - 1 && i <= current + 1)) {
        pages.add(_pageButton(i, current));
      } else if (i == current - 2 || i == current + 2) {
        pages.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Text("...", style: TextStyle(fontSize: 14)),
        ));
      }
    }

    return pages;
  }

  // ---------- Small Page Box Widget ----------
  Widget _pageButton(int page, int current) {
    bool active = page == current;

    return GestureDetector(
      onTap: () => onPageSelected(page),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? Colors.pink : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          "$page",
          style: TextStyle(
            fontSize: 14,
            color: active ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: totalPages,
      builder: (context, tValue, _) {
        int total = tValue;

        return ValueListenableBuilder(
          valueListenable: currentPage,
          builder: (context, cValue, _) {
            int current = cValue;

            return Row(
              children: [
                // < Previous
                GestureDetector(
                  onTap: onPrev,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Icon(Icons.chevron_left, size: 26),
                  ),
                ),

                const SizedBox(width: 10),

                // Page numbers
                ..._compactPageNumbers(current, total),

                const SizedBox(width: 10),

                // > Next
                GestureDetector(
                  onTap: onNext,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Icon(Icons.chevron_right, size: 26),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
