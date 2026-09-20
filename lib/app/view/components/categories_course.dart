import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/models/cate-model.dart';
import 'package:flutter_app/app/controller/courses_controller.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/app/view/components/categories.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import '../../helper/dialog_helper.dart';

class CategoriesCourse extends StatelessWidget {
  final List<CategoryModel> categoriesList;

  CategoriesCourse({super.key, required this.categoriesList});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return GetBuilder<CoursesController>(builder: (value) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(0, 16, 0, 2),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Wrap(
                    direction: Axis.horizontal,
                    children: List.generate(
                      categoriesList.length,
                      (index) {
                        final isSelected = value.cateIds.isNotEmpty &&
                            value.cateIds.contains(categoriesList[index].id!);
                        return InkWell(
                          highlightColor: colors.surface,
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            DialogHelper.showLoading();
                            Future.delayed(const Duration(milliseconds: 200), () {
                              DialogHelper.hideLoading();
                              debugPrint('data: ${categoriesList[index].toString()}');
                              value.onFilter(categoriesList[index].id!);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? MedsKaiColors.primary
                                  : colors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? MedsKaiColors.primary
                                    : colors.border,
                                width: 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: MedsKaiColors.primary.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            margin: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Text(
                              Categories.getCategoryName(categoriesList[index].name),
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected
                                    ? MedsKaiColors.white
                                    : colors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
