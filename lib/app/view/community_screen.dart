import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/community_controller.dart';
import '../util/theme.dart';
import '../../l10n/locale_keys.g.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommunityController>(
      builder: (controller) {
        final colors = context.kaiColors;
        return Scaffold(
          backgroundColor: colors.background,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                backgroundColor: colors.background,
                elevation: 0,
                floating: true,
                snap: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: colors.textPrimary, size: 20),
                  onPressed: () => controller.onBack(),
                ),
                title: Text(
                  tr(LocaleKeys.community_title),
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                centerTitle: true,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Container(
                    height: 1,
                    color: colors.border.withOpacity(0.5),
                  ),
                ),
              ),
            ],
            body: _buildBody(controller, colors, context),
          ),
        );
      },
    );
  }

  Widget _buildBody(CommunityController controller, MedsKaiThemeColors colors, BuildContext context) {
    if (controller.isLoading) {
      return _buildLoadingSkeleton(colors);
    }

    if (controller.hasError) {
      return _buildError(controller, colors);
    }

    if (controller.groups.isEmpty) {
      return _buildEmpty(colors);
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchMyGroups(),
      color: MedsKaiColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        itemCount: controller.groups.length,
        itemBuilder: (context, index) {
          final group = controller.groups[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _buildGroupCard(group, controller, colors),
          );
        },
      ),
    );
  }

  Widget _buildGroupCard(dynamic group, CommunityController controller, MedsKaiThemeColors colors) {
    return GestureDetector(
      onTap: () => controller.onGroupTapped(group),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.border.withOpacity(0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: MedsKaiColors.primary.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top gradient banner
            Container(
              height: 6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    MedsKaiColors.primary,
                    MedsKaiColors.primary.withOpacity(0.5),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Icon container with gradient
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              MedsKaiColors.primary,
                              MedsKaiColors.primary.withOpacity(0.75),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: MedsKaiColors.primary.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.forum_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.name ?? 'Group',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (group.description != null && (group.description as String).isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                group.description!,
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 12,
                                  color: colors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: MedsKaiColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: MedsKaiColors.primary,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Divider
                  Container(
                    height: 1,
                    color: colors.border.withOpacity(0.4),
                  ),
                  const SizedBox(height: 14),
                  // Stats row
                  Row(
                    children: [
                      _buildStatPill(
                        Icons.people_rounded,
                        '${group.membersCount} ${tr(LocaleKeys.community_members)}',
                        MedsKaiColors.primary,
                        colors,
                      ),
                      const SizedBox(width: 10),
                      _buildStatPill(
                        Icons.chat_bubble_rounded,
                        '${group.discussionsCount} ${tr(LocaleKeys.community_discussions)}',
                        MedsKaiColors.success,
                        colors,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(IconData icon, String label, Color color, MedsKaiThemeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(MedsKaiThemeColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: MedsKaiColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group_off_rounded,
                color: MedsKaiColors.primary.withOpacity(0.5),
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              tr(LocaleKeys.community_empty),
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(CommunityController controller, MedsKaiThemeColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: MedsKaiColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded, color: MedsKaiColors.error, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              controller.errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textPrimary, fontFamily: 'Manrope', fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => controller.fetchMyGroups(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: MedsKaiColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(MedsKaiThemeColors colors) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      itemCount: 4,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: _shimmerEffect(colors),
        ),
      ),
    );
  }

  Widget _shimmerEffect(MedsKaiThemeColors colors) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Container(color: colors.surface),
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 6,
              color: colors.border.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
