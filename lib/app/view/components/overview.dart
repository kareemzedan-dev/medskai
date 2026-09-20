import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/app/view/components/cached_image.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/route_manager.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class Overview extends StatelessWidget {
  final dynamic overview;
  const Overview({super.key, required this.overview});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final courseData = overview is Map ? overview["course_data"] : null;
    final resultData = courseData is Map ? courseData["result"] : null;
    final itemsData = resultData is Map ? resultData["items"] : null;

    final resultValue = resultData is Map && resultData["result"] is num
        ? (resultData["result"] as num).round() : 0;

    final lessonPercent = _getPercent(itemsData, 'lesson');
    final quizPercent = _getPercent(itemsData, 'quiz');

    final sectionCount = overview is Map && overview["sections"] is List
        ? overview["sections"].length : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.sectionBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const SizedBox(height: 4),

          // Progress Section
          Row(
            children: [
              // Circular Progress
              CircularPercentIndicator(
                radius: 42,
                percent: (resultValue / 100).clamp(0.0, 1.0),
                lineWidth: 8,
                backgroundColor: colors.border,
                progressColor: MedsKaiColors.primary,
                circularStrokeCap: CircularStrokeCap.round,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$resultValue%",
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      tr(LocaleKeys.myOrders_completed),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Stats
              Expanded(
                child: Column(
                  children: [
                    _buildStatRow(
                      icon: Icons.book_outlined,
                      label: tr(LocaleKeys.lesson),
                      percent: lessonPercent,
                      colors: colors,
                    ),
                    const SizedBox(height: 14),
                    _buildStatRow(
                      icon: Icons.help_outline,
                      label: tr(LocaleKeys.quiz),
                      percent: quizPercent,
                      colors: colors,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: 16),

          // Course Info with thumbnail + Continue button
          GestureDetector(
            onTap: () {
              Get.toNamed(AppRouter.getCourseDetailRoute(), arguments: [overview["id"]]);
            },
            child: Row(
              children: [
                // Course thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: overview is Map && overview["image"] != null
                      ? AppCachedImage(
                          imageUrl: overview["image"],
                          width: 50,
                          height: 50,
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: MedsKaiColors.primary10,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.book, color: MedsKaiColors.primary, size: 24),
                        ),
                ),
                const SizedBox(width: 12),
                // Title + sections
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        overview is Map ? (overview["name"] ?? '') : '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$sectionCount ${sectionCount > 1 ? tr(LocaleKeys.home_overview_sections) : tr(LocaleKeys.home_overview_section)}',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Continue button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: MedsKaiColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.play_arrow, color: MedsKaiColors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        tr(LocaleKeys.home_overview_continueButton),
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: MedsKaiColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getPercent(dynamic itemsData, String key) {
    if (itemsData is! Map || itemsData[key] is! Map) return 0;
    final completed = double.tryParse(itemsData[key]['completed']?.toString() ?? '0') ?? 0;
    final total = double.tryParse(itemsData[key]['total']?.toString() ?? '1') ?? 1;
    if (total == 0) return 0;
    return ((completed / total) * 100).round();
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required int percent,
    required MedsKaiThemeColors colors,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: MedsKaiColors.primary10,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: MedsKaiColors.primary),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: colors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          '$percent%',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
