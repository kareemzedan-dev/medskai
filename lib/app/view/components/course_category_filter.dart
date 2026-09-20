import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import '../../../app/backend/models/cate-model.dart';

class CourseCategoryFilter extends StatelessWidget {
  final List<CategoryModel> categories;
  final CategoryModel? selected;
  final ValueChanged<CategoryModel?> onChanged;

  const CourseCategoryFilter({
    Key? key,
    required this.categories,
    this.selected,
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
              selected: selected == null,
              onSelected: (_) => onChanged(null),
            ),
          ),
          ...categories.map((cat) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text('${cat.name ?? ""} ${cat.count != null ? "(${cat.count})" : ""}'),
                selected: selected?.id == cat.id,
                onSelected: (_) => onChanged(cat),
              ),
            );
          }),
        ],
      ),
    );
  }
}
