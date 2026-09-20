import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';

class BlogCategoryItem {
  final int id;
  final String name;
  final int count;

  BlogCategoryItem({required this.id, required this.name, this.count = 0});

  factory BlogCategoryItem.fromJson(Map<String, dynamic> json) {
    return BlogCategoryItem(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class BlogCategoryFilter extends StatelessWidget {
  final List<BlogCategoryItem> categories;
  final int? selectedId;
  final ValueChanged<int?> onChanged;

  const BlogCategoryFilter({
    Key? key,
    required this.categories,
    this.selectedId,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(tr(LocaleKeys.ui_all)),
              selected: selectedId == null,
              onSelected: (_) => onChanged(null),
            ),
          ),
          ...categories.map((cat) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text('${cat.name} (${cat.count})'),
                selected: selectedId == cat.id,
                onSelected: (_) => onChanged(cat.id),
              ),
            );
          }),
        ],
      ),
    );
  }
}
