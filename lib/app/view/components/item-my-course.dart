import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/models/course_model.dart';
import 'package:flutter_app/app/helper/function_helper.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/route_manager.dart';

class ItemMyCourse extends StatelessWidget {
  final CourseModel item;

  ItemMyCourse({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    // Calculate target and progress for progress bar
    double targetPercent = 0;
    if (item.course_data != null &&
        item.meta_data?.lp_passing_condition != null) {
      targetPercent = (item.meta_data?.lp_passing_condition ?? 0) / 100;
    }

    double progressPercent = 0;
    if (item.course_data != null &&
        item.course_data?.result != null &&
        item.course_data?.result?.result != null) {
      progressPercent = (item.course_data?.result?.result ?? 0) / 100;
    }

    // Get status color
    Color statusColor = _getStatusColor();
    String statusText = _getStatusText();

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRouter.getCourseDetailRoute(),
        arguments: [item.id],
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B39BF).withOpacity(0.15),
              blurRadius: 1,
              spreadRadius: 1,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course image
              _buildCourseImage(colors),
              const SizedBox(width: 14),
              // Course info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category
                    if (item.categories != null && item.categories!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          item.categories!.map((e) => e.name).join(', '),
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: MedsKaiColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    // Course name
                    Text(
                      item.name ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Progress bar
                    _buildProgressBar(progressPercent, targetPercent, statusColor, colors),
                    const SizedBox(height: 10),
                    // Status and duration row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Status badge
                        _buildStatusBadge(statusText, statusColor),
                        // Duration
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: colors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              Helper.handleTranslationsDuration(item.duration.toString()),
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseImage(MedsKaiThemeColors colors) {
    return Stack(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: (item.image != null && !item.image!.contains('placeholder'))
                  ? CachedNetworkImageProvider(item.image!)
                  : const AssetImage("assets/images/logo_horizontal_light.png"),
            ),
          ),
        ),
        // Progress overlay circle
        if (item.course_data?.result?.result != null)
          Positioned(
            bottom: 6,
            right: 6,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${item.course_data!.result!.result!.toInt()}%',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _getStatusColor(),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressBar(double progress, double target, Color statusColor, MedsKaiThemeColors colors) {
    final int percentDisplay = (progress * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar container
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: colors.sectionBg,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Stack(
            children: [
              // Target marker
              if (target > 0)
                Positioned(
                  left: 0,
                  right: 0,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SizedBox(
                        height: 10,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: constraints.maxWidth * target - 1,
                              child: Container(
                                height: 10,
                                width: 2,
                                decoration: BoxDecoration(
                                  color: colors.textPrimary.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              // Progress fill
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        MedsKaiColors.primary,
                        MedsKaiColors.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Percentage text
        Text(
          '$percentDisplay% complete',
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

  Widget _buildStatusBadge(String statusText, Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (item.course_data?.graduation) {
      case 'passed':
        return MedsKaiColors.success;
      case 'failed':
        return MedsKaiColors.error;
      case 'in-progress':
      default:
        return MedsKaiColors.primary; // Primary for in-progress
    }
  }

  String _getStatusText() {
    switch (item.course_data?.graduation) {
      case 'passed':
        return tr(LocaleKeys.myCourse_filters_passed);
      case 'failed':
        return tr(LocaleKeys.myCourse_filters_failed);
      case 'in-progress':
      default:
        return tr(LocaleKeys.myCourse_filters_inProgress);
    }
  }
}
