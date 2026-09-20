import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

enum CourseSortOption {
  newest,
  titleAZ,
  titleZA,
  priceHigh,
  priceLow,
  popular,
  rating,
}

class CourseSortDropdown extends StatelessWidget {
  final CourseSortOption selected;
  final ValueChanged<CourseSortOption> onChanged;

  const CourseSortDropdown({Key? key, required this.selected, required this.onChanged}) : super(key: key);

  String _label(CourseSortOption option) {
    switch (option) {
      case CourseSortOption.newest: return 'Newest';
      case CourseSortOption.titleAZ: return 'Title A-Z';
      case CourseSortOption.titleZA: return 'Title Z-A';
      case CourseSortOption.priceHigh: return 'Price: High to Low';
      case CourseSortOption.priceLow: return 'Price: Low to High';
      case CourseSortOption.popular: return 'Most Popular';
      case CourseSortOption.rating: return 'Highest Rated';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<CourseSortOption>(
      value: selected,
      isExpanded: true,
      underline: const SizedBox.shrink(),
      icon: const Icon(Icons.sort),
      items: CourseSortOption.values.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(_label(option), style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }

  static Map<String, String> getApiParams(CourseSortOption option) {
    switch (option) {
      case CourseSortOption.newest: return {'orderby': 'date', 'order': 'desc'};
      case CourseSortOption.titleAZ: return {'orderby': 'title', 'order': 'asc'};
      case CourseSortOption.titleZA: return {'orderby': 'title', 'order': 'desc'};
      case CourseSortOption.priceHigh: return {'orderby': 'price', 'order': 'desc'};
      case CourseSortOption.priceLow: return {'orderby': 'price', 'order': 'asc'};
      case CourseSortOption.popular: return {'popular': 'true'};
      case CourseSortOption.rating: return {'orderby': 'rating', 'order': 'desc'};
    }
  }
}
