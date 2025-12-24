import 'package:cutomer_app/Utils/Constant.dart';
import 'package:flutter/material.dart';

class ProcedureFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final RangeValues offerRange;
  final ValueChanged<RangeValues> onRangeChanged;
  final VoidCallback onClear;

  const ProcedureFilterBar({
    super.key,
    required this.searchController,
    required this.offerRange,
    required this.onRangeChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Search procedure...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Offer Range: ${offerRange.start.toInt()}% - ${offerRange.end.toInt()}%",
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: mainColor),
              ),
              RangeSlider(
                activeColor: mainColor,
                values: offerRange,
                min: 0,
                max: 100,
                divisions: 20,
                labels: RangeLabels(
                  "${offerRange.start.toInt()}%",
                  "${offerRange.end.toInt()}%",
                ),
                onChanged: onRangeChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
