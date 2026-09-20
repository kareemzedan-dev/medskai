import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';

class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
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
          tr(LocaleKeys.membership_title),
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [MedsKaiColors.primary, MedsKaiColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.workspace_premium_rounded,
                    color: MedsKaiColors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tr(LocaleKeys.membership_title),
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: MedsKaiColors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr(LocaleKeys.ui_choosePlan),
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: MedsKaiColors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Free Plan
            _buildPlanCard(
              colors: colors,
              title: tr(LocaleKeys.membership_free),
              price: '\$0',
              period: tr(LocaleKeys.membership_perMonth),
              features: [
                tr(LocaleKeys.ui_accessFreeCourses),
                tr(LocaleKeys.ui_basicSupport),
                tr(LocaleKeys.ui_communityAccess),
              ],
              isPrimary: false,
              buttonText: tr(LocaleKeys.membership_currentPlan),
              isCurrentPlan: true,
            ),
            const SizedBox(height: 16),

            // Semi-Pro Plan
            _buildPlanCard(
              colors: colors,
              title: tr(LocaleKeys.membership_semiPro),
              price: '\$159',
              period: tr(LocaleKeys.membership_perYear),
              features: [
                tr(LocaleKeys.ui_allFreeCourses),
                tr(LocaleKeys.ui_advancedCourses),
                tr(LocaleKeys.ui_certificateOfCompletion),
                tr(LocaleKeys.membership_prioritySupport),
              ],
              isPrimary: false,
              buttonText: tr(LocaleKeys.membership_subscribe),
              isCurrentPlan: false,
            ),
            const SizedBox(height: 16),

            // Pro Plan
            _buildPlanCard(
              colors: colors,
              title: tr(LocaleKeys.membership_pro),
              price: '\$299',
              period: tr(LocaleKeys.membership_perYear),
              features: [
                tr(LocaleKeys.ui_allCoursesIncluded),
                tr(LocaleKeys.ui_certificateOfCompletion),
                tr(LocaleKeys.membership_prioritySupport),
                tr(LocaleKeys.ui_personalCoaching),
                tr(LocaleKeys.ui_lifetimeAccess),
              ],
              isPrimary: true,
              buttonText: tr(LocaleKeys.membership_subscribe),
              isCurrentPlan: false,
              isRecommended: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required MedsKaiThemeColors colors,
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required bool isPrimary,
    required String buttonText,
    required bool isCurrentPlan,
    bool isRecommended = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPrimary ? MedsKaiColors.primary : colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrimary ? MedsKaiColors.primary : colors.border,
          width: isPrimary ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MedsKaiColors.primary.withValues(alpha: isPrimary ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with recommended badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isPrimary ? MedsKaiColors.white : colors.textPrimary,
                ),
              ),
              if (isRecommended)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: MedsKaiColors.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tr(LocaleKeys.ui_recommended),
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: MedsKaiColors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: isPrimary ? MedsKaiColors.white : colors.textPrimary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  period,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: isPrimary
                        ? MedsKaiColors.white.withOpacity(0.8)
                        : colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Features
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: isPrimary ? MedsKaiColors.white : MedsKaiColors.success,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isPrimary
                          ? MedsKaiColors.white.withOpacity(0.9)
                          : colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 20),

          // Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCurrentPlan ? null : () {
                // Handle subscription
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isPrimary
                    ? MedsKaiColors.white
                    : (isCurrentPlan ? colors.sectionBg : MedsKaiColors.primary),
                foregroundColor: isPrimary
                    ? MedsKaiColors.primary
                    : (isCurrentPlan ? colors.textSecondary : MedsKaiColors.white),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
