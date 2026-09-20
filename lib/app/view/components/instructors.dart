import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/models/instructor-model.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';

import '../../helper/router.dart';

class Instructors extends StatelessWidget {
  final List<UserInstructorModel> instructorList;

  Instructors({super.key, required this.instructorList});

  void onNavigate(UserInstructorModel item) {
    Get.toNamed(AppRouter.getInstructorDetailRoute(), arguments: [item]);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  tr(LocaleKeys.instructor_title),
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
                onTap: () => Get.toNamed(AppRouter.getInstructorsList()),
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
        ),
        const SizedBox(height: 12),

        // Instructors Horizontal List
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: instructorList.length,
            itemBuilder: (context, index) {
              final instructor = instructorList[index];
              final totalCourses = (instructor.instructor_data is Map
                  ? instructor.instructor_data["total_courses"]?.toString()
                  : null) ?? '0';
              final totalStudents = (instructor.instructor_data is Map
                  ? instructor.instructor_data["total_users"]?.toString()
                  : null) ?? '0';

              return GestureDetector(
                key: ValueKey(instructor.id ?? index),
                onTap: () => onNavigate(instructor),
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border, width: 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Avatar (circular)
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: MedsKaiColors.primary20,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: instructor.avatar_url != null && instructor.avatar_url!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: instructor.avatar_url!,
                                  fit: BoxFit.cover,
                                  width: 56,
                                  height: 56,
                                )
                              : Container(
                                  color: MedsKaiColors.primary10,
                                  child: const Icon(
                                    Icons.person,
                                    color: MedsKaiColors.primary,
                                    size: 28,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Name
                      Text(
                        instructor.name ?? '',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.book_outlined, size: 13, color: MedsKaiColors.primary),
                          const SizedBox(width: 3),
                          Text(
                            totalCourses,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
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
