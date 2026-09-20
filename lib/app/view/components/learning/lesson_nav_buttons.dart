import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/models/lesson-model.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';

class LessonNavButtons extends StatelessWidget {
  final ItemLesson? previousLesson;
  final ItemLesson? nextLesson;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const LessonNavButtons({
    super.key,
    required this.previousLesson,
    required this.nextLesson,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    if (previousLesson == null && nextLesson == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // Previous
          if (previousLesson != null)
            Expanded(
              child: _NavButton(
                label: tr(LocaleKeys.learningScreen_previous),
                lessonTitle: previousLesson!.title ?? '',
                icon: Icons.arrow_back_ios_new,
                iconLeft: true,
                onTap: onPrevious,
              ),
            ),

          if (previousLesson != null && nextLesson != null)
            const SizedBox(width: 12),

          // Next
          if (nextLesson != null)
            Expanded(
              child: _NavButton(
                label: tr(LocaleKeys.learningScreen_next),
                lessonTitle: nextLesson!.title ?? '',
                icon: Icons.arrow_forward_ios,
                iconLeft: false,
                onTap: onNext,
              ),
            ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final String lessonTitle;
  final IconData icon;
  final bool iconLeft;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.lessonTitle,
    required this.icon,
    required this.iconLeft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            if (iconLeft) ...[
              Icon(icon, size: 16, color: MedsKaiColors.primary),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment:
                    iconLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lessonTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: MedsKaiColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            if (!iconLeft) ...[
              const SizedBox(width: 10),
              Icon(icon, size: 16, color: MedsKaiColors.primary),
            ],
          ],
        ),
      ),
    );
  }
}
