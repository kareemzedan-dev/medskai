import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/models/instructor-model.dart';
import 'package:flutter_app/app/controller/home_controller.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';

class InstructorsListScreen extends StatelessWidget {
  const InstructorsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final HomeController homeController = Get.find<HomeController>();
    final instructors = homeController.instructorList;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          tr(LocaleKeys.instructors_title),
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: instructors.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined, size: 64, color: colors.textHint),
                  const SizedBox(height: 16),
                  Text(tr(LocaleKeys.ui_noInstructorsFound),
                      style: TextStyle(color: colors.textSecondary, fontSize: 16)),
                ],
              ),
            )
          : Column(
              children: [
                _buildSummaryBox(instructors, colors),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    itemCount: instructors.length,
                    itemBuilder: (context, index) {
                      return KeyedSubtree(
                        key: ValueKey(instructors[index].id ?? index),
                        child: _buildInstructorCard(instructors[index], colors),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryBox(List<UserInstructorModel> instructors, MedsKaiThemeColors colors) {
    int totalCourses = 0;
    for (var i in instructors) {
      if (i.instructor_data is Map) {
        totalCourses += (int.tryParse(i.instructor_data['total_courses']?.toString() ?? '0') ?? 0);
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: MedsKaiColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryStat('${instructors.length}+', tr(LocaleKeys.instructors_title), colors),
          Container(width: 1, height: 40, color: MedsKaiColors.primary.withOpacity(0.3)),
          _buildSummaryStat('$totalCourses+', tr(LocaleKeys.home_countCourse), colors),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String value, String label, MedsKaiThemeColors colors) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: MedsKaiColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructorCard(UserInstructorModel instructor, MedsKaiThemeColors colors) {
    final totalCourses = instructor.instructor_data is Map
        ? (int.tryParse(instructor.instructor_data['total_courses']?.toString() ?? '0') ?? 0)
        : 0;

    // Get initials from name
    final initials = _getInitials(instructor.name ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: MedsKaiColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: MedsKaiColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: instructor.avatar_url != null && instructor.avatar_url!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: instructor.avatar_url!,
                      fit: BoxFit.cover,
                      width: 70,
                      height: 70,
                      errorWidget: (_, __, ___) => Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: MedsKaiColors.primary,
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: MedsKaiColors.primary,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instructor.name ?? '',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                if (instructor.description != null && instructor.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    instructor.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatChip(Icons.play_circle_outline_rounded, '$totalCourses ${tr(LocaleKeys.instructors_courses)}', colors),
                  ],
                ),
              ],
            ),
          ),

          // View Button
          IconButton(
            onPressed: () {
              Get.toNamed(AppRouter.getInstructorDetailRoute(), arguments: [instructor]);
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: MedsKaiColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: MedsKaiColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '?';
  }

  Widget _buildStatChip(IconData icon, String text, MedsKaiThemeColors colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: colors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
