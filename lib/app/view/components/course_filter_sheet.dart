import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/models/cate-model.dart';
import 'package:flutter_app/app/controller/courses_controller.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/app/view/components/categories.dart';
import 'package:get/get.dart';

/// Opens a modal bottom sheet with advanced course filters:
/// price, rating, and category.
void showCourseFilterSheet(BuildContext context) {
  final controller = Get.find<CoursesController>();

  // Local state copies so the user can adjust before applying.
  String? tempPrice = controller.priceFilter;
  double? tempRating = controller.minRating;
  int? tempCategoryId = controller.selectedCategory?.id ??
      (controller.cateIds.isNotEmpty ? controller.cateIds.first : null);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final colors = ctx.kaiColors;
      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filters',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            tempPrice = null;
                            tempRating = null;
                            tempCategoryId = null;
                          });
                        },
                        child: Text(
                          'Clear All',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: MedsKaiColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: colors.divider),
                // Scrollable filter content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Price filter ---
                        _SectionTitle(title: 'Price', colors: colors),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          children: [
                            _FilterChip(
                              label: 'All',
                              selected: tempPrice == null,
                              colors: colors,
                              onTap: () => setState(() => tempPrice = null),
                            ),
                            _FilterChip(
                              label: 'Free',
                              selected: tempPrice == 'free',
                              colors: colors,
                              onTap: () => setState(() => tempPrice = 'free'),
                            ),
                            _FilterChip(
                              label: 'Paid',
                              selected: tempPrice == 'paid',
                              colors: colors,
                              onTap: () => setState(() => tempPrice = 'paid'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // --- Rating filter ---
                        _SectionTitle(title: 'Rating', colors: colors),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _FilterChip(
                              label: 'Any',
                              selected: tempRating == null,
                              colors: colors,
                              onTap: () => setState(() => tempRating = null),
                            ),
                            _FilterChip(
                              label: '4+',
                              icon: Icons.star_rounded,
                              iconColor: MedsKaiColors.gold,
                              selected: tempRating == 4,
                              colors: colors,
                              onTap: () => setState(() => tempRating = 4),
                            ),
                            _FilterChip(
                              label: '3+',
                              icon: Icons.star_rounded,
                              iconColor: MedsKaiColors.gold,
                              selected: tempRating == 3,
                              colors: colors,
                              onTap: () => setState(() => tempRating = 3),
                            ),
                            _FilterChip(
                              label: '2+',
                              icon: Icons.star_rounded,
                              iconColor: MedsKaiColors.gold,
                              selected: tempRating == 2,
                              colors: colors,
                              onTap: () => setState(() => tempRating = 2),
                            ),
                            _FilterChip(
                              label: '1+',
                              icon: Icons.star_rounded,
                              iconColor: MedsKaiColors.gold,
                              selected: tempRating == 1,
                              colors: colors,
                              onTap: () => setState(() => tempRating = 1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // --- Category filter ---
                        if (controller.cateList.isNotEmpty) ...[
                          _SectionTitle(title: 'Category', colors: colors),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _FilterChip(
                                label: 'All',
                                selected: tempCategoryId == null,
                                colors: colors,
                                onTap: () =>
                                    setState(() => tempCategoryId = null),
                              ),
                              ...controller.cateList.map((cat) {
                                return _FilterChip(
                                  label: Categories.getCategoryName(cat.name),
                                  selected: tempCategoryId == cat.id,
                                  colors: colors,
                                  onTap: () =>
                                      setState(() => tempCategoryId = cat.id),
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ),
                // Apply button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Apply filters safely (controller may have been disposed)
                        if (!Get.isRegistered<CoursesController>()) return;
                        final ctrl = Get.find<CoursesController>();
                        ctrl.priceFilter = tempPrice;
                        ctrl.minRating = tempRating;

                        // Apply category selection
                        if (tempCategoryId != null) {
                          final cat = ctrl.cateList.firstWhereOrNull(
                              (c) => c.id == tempCategoryId);
                          ctrl.selectedCategory = cat;
                          ctrl.onSetCateId(tempCategoryId!);
                        } else {
                          ctrl.selectedCategory = null;
                          ctrl.cateIds.clear();
                        }

                        ctrl.refreshData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MedsKaiColors.primary,
                        foregroundColor: MedsKaiColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          );
        },
      );
    },
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final MedsKaiThemeColors colors;

  const _SectionTitle({required this.title, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final MedsKaiThemeColors colors;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? iconColor;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.colors,
    required this.onTap,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? MedsKaiColors.primary
              : colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? MedsKaiColors.primary : colors.border,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: MedsKaiColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected ? MedsKaiColors.white : iconColor,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? MedsKaiColors.white : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
