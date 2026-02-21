import 'package:cutomer_app/Utils/Constant.dart';
import 'package:flutter/material.dart';

class ProcedureFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final RangeValues offerRange;
  final double maxAvailableOffer;
  final ValueChanged<RangeValues> onRangeChanged;
  final VoidCallback onClear;

  const ProcedureFilterBar({
    super.key,
    required this.searchController,
    required this.offerRange,
    required this.maxAvailableOffer,
    required this.onRangeChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFiltering =
        offerRange.start != 0 || offerRange.end != maxAvailableOffer;

    return Column(
      children: [
        /// 🔍 SEARCH
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

        /// 🎯 OFFER RANGE
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isFiltering
                    ? "Offer: ${offerRange.start.toInt()}% - ${offerRange.end.toInt()}%"
                    : "Offer: 0% - ${maxAvailableOffer.toInt()}%",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isFiltering ? mainColor : Colors.grey,
                ),
              ),
              RangeSlider(
                activeColor: mainColor,
                min: 0,
                max: maxAvailableOffer == 0 ? 1 : maxAvailableOffer,

                /// IMPORTANT FIX
                divisions:
                    maxAvailableOffer > 0 ? maxAvailableOffer.toInt() : null,

                values: offerRange,

                labels: RangeLabels(
                  "${offerRange.start.toInt()}%",
                  "${offerRange.end.toInt()}%",
                ),

                /// Disable slider if no offers
                onChanged: maxAvailableOffer == 0
                    ? null
                    : (value) => onRangeChanged(value),
              )
            ],
          ),
        ),
      ],
    );
  }
}
