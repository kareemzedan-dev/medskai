import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/models/cate-model.dart';
import 'package:flutter_app/app/controller/courses_controller.dart';
import 'package:flutter_app/app/controller/tabs_controller.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';

class _CategoryInfo {
  final String icon;
  final String displayName;
  const _CategoryInfo({required this.icon, required this.displayName});
}

// ignore: must_be_immutable
class Categories extends StatelessWidget {
  final List<CategoryModel> categoriesList;
  TabControllerX get tabController => Get.find<TabControllerX>();
  CoursesController get courseController => Get.find<CoursesController>();

  Categories({super.key, required this.categoriesList});

  void onNavigate(CategoryModel category) {
    if (category.id == null) return;
    courseController.onSetCateId(category.id!);
    tabController.updateTabId(1);
  }

  static const String _fallbackIcon =
      'assets/images/categories/general-vert.png';

  // Match by category name (API slugs are unreliable template leftovers)
  static const Map<String, _CategoryInfo> _nameToInfo = {
    'radiology': _CategoryInfo(
      icon: 'assets/images/categories/radiology-vert.png',
      displayName: 'Radiology & Medical Imaging',
    ),
    'nutrition': _CategoryInfo(
      icon: 'assets/images/categories/nutrition-vert.png',
      displayName: 'Nutrition & Food Safety',
    ),
    'general medical': _CategoryInfo(
      icon: 'assets/images/categories/general-vert.png',
      displayName: 'General Medical Soft Skills',
    ),
    'medical laboratories': _CategoryInfo(
      icon: 'assets/images/categories/lab-vert.png',
      displayName: 'Medical Laboratories',
    ),
    'respiratory': _CategoryInfo(
      icon: 'assets/images/categories/respiratory-vert.png',
      displayName: 'Respiratory Care',
    ),
    'dental': _CategoryInfo(
      icon: 'assets/images/categories/dental-vert.png',
      displayName: 'Dental Prosthodontics',
    ),
    'engineering': _CategoryInfo(
      icon: 'assets/images/categories/engineering-vert.png',
      displayName: 'Clinical Engineering & Maintenance',
    ),
    'administration': _CategoryInfo(
      icon: 'assets/images/categories/administration-vert.png',
      displayName: 'Administration & Health Informatics',
    ),
    'optic': _CategoryInfo(
      icon: 'assets/images/categories/optic-vert.png',
      displayName: 'Optics & Vision Science',
    ),
    'public health': _CategoryInfo(
      icon: 'assets/images/categories/public-vert.png',
      displayName: 'Public Health & Environment',
    ),
    'occupational': _CategoryInfo(
      icon: 'assets/images/categories/occupational.png',
      displayName: 'Occupational Therapy',
    ),
    'anesthesia': _CategoryInfo(
      icon: 'assets/images/categories/anrsthesia.png',
      displayName: 'Anesthesia & Intensive Care',
    ),
  };

  static _CategoryInfo? _matchByName(String? name) {
    if (name == null || name.isEmpty) return null;
    final lowerName = name.toLowerCase();
    for (final entry in _nameToInfo.entries) {
      if (lowerName.contains(entry.key)) return entry.value;
    }
    return null;
  }

  String getCategoryIcon(String? name) {
    return _matchByName(name)?.icon ?? _fallbackIcon;
  }

  static String getCategoryName(String? name) {
    return _matchByName(name)?.displayName ?? name ?? '';
  }

  static const _hiddenCategories = ['biotechnology'];

  List<CategoryModel> get _filteredList => categoriesList
      .where((cat) {
        final name = (cat.name ?? '').toLowerCase();
        return !_hiddenCategories.any((hidden) => name.contains(hidden));
      })
      .toList();

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      tr(LocaleKeys.home_category),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => tabController.updateTabId(1),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: MedsKaiColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tr(LocaleKeys.home_seeAll),
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: MedsKaiColors.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
                            color: MedsKaiColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                tr(LocaleKeys.categories_title),
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Categories Horizontal List - Simple design like website
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredList.length,
            itemBuilder: (context, index) {
              final cat = _filteredList[index];
              return GestureDetector(
                key: ValueKey(cat.id ?? index),
                onTap: () => onNavigate(cat),
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      // Icon in rounded square card
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: colors.sectionBg,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            getCategoryIcon(cat.name),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            filterQuality: FilterQuality.high,
                            isAntiAlias: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Category Name
                      Text(
                        getCategoryName(cat.name),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
