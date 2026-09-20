import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_app/app/util/theme.dart';

/// Skeleton Loading Widgets for MedsKai App
///
/// Usage:
/// ```dart
/// Skeletonizer(
///   enabled: isLoading,
///   child: YourWidget(),
/// )
/// ```
///
/// Or use pre-built skeleton widgets:
/// ```dart
/// SkeletonCourseCard()
/// SkeletonCourseList()
/// ```

// ============================================================
// Course Card Skeleton
// ============================================================

class SkeletonCourseCard extends StatelessWidget {
  const SkeletonCourseCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.sectionBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category chip
                Container(
                  width: 80,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colors.sectionBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 12),
                // Title
                Container(
                  width: double.infinity,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colors.sectionBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colors.sectionBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                // Instructor row
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colors.sectionBg,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: colors.sectionBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Price and rating row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                        color: colors.sectionBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: colors.sectionBg,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 30,
                          height: 14,
                          decoration: BoxDecoration(
                            color: colors.sectionBg,
                            borderRadius: BorderRadius.circular(4),
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
    );
  }
}

// ============================================================
// Course List Skeleton (Multiple Cards)
// ============================================================

class SkeletonCourseList extends StatelessWidget {
  final int itemCount;

  const SkeletonCourseList({
    Key? key,
    this.itemCount = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: colors.sectionBg,
        highlightColor: colors.surface,
        duration: const Duration(milliseconds: 1500),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return const SkeletonCourseCard();
        },
      ),
    );
  }
}

// ============================================================
// Horizontal Course Card Skeleton (for carousels)
// ============================================================

class SkeletonHorizontalCourseCard extends StatelessWidget {
  const SkeletonHorizontalCourseCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.sectionBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors.sectionBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 150,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors.sectionBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 10),
                // Price
                Container(
                  width: 50,
                  height: 18,
                  decoration: BoxDecoration(
                    color: colors.sectionBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Horizontal Course List Skeleton
// ============================================================

class SkeletonHorizontalCourseList extends StatelessWidget {
  final int itemCount;

  const SkeletonHorizontalCourseList({
    Key? key,
    this.itemCount = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
      final colors = context.kaiColors;
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: colors.sectionBg,
        highlightColor: colors.surface,
        duration: const Duration(milliseconds: 1500),
      ),
      child: SizedBox(
        height: 240,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return const SkeletonHorizontalCourseCard();
          },
        ),
      ),
    );
  }
}

// ============================================================
// Category Skeleton
// ============================================================

class SkeletonCategoryChip extends StatelessWidget {
  const SkeletonCategoryChip({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      final colors = context.kaiColors;
    return Container(
      width: 100,
      height: 40,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: colors.sectionBg,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class SkeletonCategoryList extends StatelessWidget {
  final int itemCount;

  const SkeletonCategoryList({
    Key? key,
    this.itemCount = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
      final colors = context.kaiColors;
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: colors.sectionBg,
        highlightColor: colors.surface,
        duration: const Duration(milliseconds: 1500),
      ),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return const SkeletonCategoryChip();
          },
        ),
      ),
    );
  }
}

// ============================================================
// User Profile Card Skeleton
// ============================================================

class SkeletonUserCard extends StatelessWidget {
  const SkeletonUserCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      final colors = context.kaiColors;
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: colors.sectionBg,
        highlightColor: colors.surface,
        duration: const Duration(milliseconds: 1500),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B39BF).withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colors.sectionBg,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 18,
                    decoration: BoxDecoration(
                      color: colors.sectionBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 180,
                    height: 14,
                    decoration: BoxDecoration(
                      color: colors.sectionBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: colors.sectionBg,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Overview Stats Skeleton
// ============================================================

class SkeletonOverviewStats extends StatelessWidget {
  const SkeletonOverviewStats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      final colors = context.kaiColors;
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: colors.sectionBg,
        highlightColor: colors.surface,
        duration: const Duration(milliseconds: 1500),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(3, (index) => _buildStatItem(colors)),
        ),
      ),
    );
  }

  Widget _buildStatItem(MedsKaiThemeColors colors) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.sectionBg,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 30,
          height: 20,
          decoration: BoxDecoration(
            color: colors.sectionBg,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 60,
          height: 12,
          decoration: BoxDecoration(
            color: colors.sectionBg,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Instructor Card Skeleton
// ============================================================

class SkeletonInstructorCard extends StatelessWidget {
  const SkeletonInstructorCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      final colors = context.kaiColors;
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colors.sectionBg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 12),
          // Name
          Container(
            width: 100,
            height: 16,
            decoration: BoxDecoration(
              color: colors.sectionBg,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          // Role
          Container(
            width: 70,
            height: 12,
            decoration: BoxDecoration(
              color: colors.sectionBg,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonInstructorList extends StatelessWidget {
  final int itemCount;

  const SkeletonInstructorList({
    Key? key,
    this.itemCount = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
      final colors = context.kaiColors;
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: colors.sectionBg,
        highlightColor: colors.surface,
        duration: const Duration(milliseconds: 1500),
      ),
      child: SizedBox(
        height: 140,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return const SkeletonInstructorCard();
          },
        ),
      ),
    );
  }
}

// ============================================================
// Notification Item Skeleton
// ============================================================

class SkeletonNotificationItem extends StatelessWidget {
  const SkeletonNotificationItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      final colors = context.kaiColors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.sectionBg,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors.sectionBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 150,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors.sectionBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 80,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colors.sectionBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonNotificationList extends StatelessWidget {
  final int itemCount;

  const SkeletonNotificationList({
    Key? key,
    this.itemCount = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
      final colors = context.kaiColors;
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: colors.sectionBg,
        highlightColor: colors.surface,
        duration: const Duration(milliseconds: 1500),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return const SkeletonNotificationItem();
        },
      ),
    );
  }
}

// ============================================================
// Course Detail Skeleton
// ============================================================

class SkeletonCourseDetail extends StatelessWidget {
  const SkeletonCourseDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      final colors = context.kaiColors;
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: colors.sectionBg,
        highlightColor: colors.surface,
        duration: const Duration(milliseconds: 1500),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            Container(
              height: 220,
              width: double.infinity,
              color: colors.sectionBg,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  Container(
                    width: 100,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colors.sectionBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Container(
                    width: double.infinity,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colors.sectionBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 250,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colors.sectionBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Stats row
                  Row(
                    children: List.generate(
                      4,
                      (index) => Expanded(
                        child: Container(
                          height: 60,
                          margin: EdgeInsets.only(right: index < 3 ? 12 : 0),
                          decoration: BoxDecoration(
                            color: colors.sectionBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Description
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: colors.sectionBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: colors.sectionBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 200,
                    height: 16,
                    decoration: BoxDecoration(
                      color: colors.sectionBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Instructor
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: colors.sectionBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 120,
                            height: 18,
                            decoration: BoxDecoration(
                              color: colors.sectionBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 80,
                            height: 14,
                            decoration: BoxDecoration(
                              color: colors.sectionBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Curriculum section
                  Container(
                    width: 150,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colors.sectionBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Lesson items
                  ...List.generate(
                    4,
                    (index) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.sectionBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: colors.surface,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: 60,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: colors.surface,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Generic Text Skeleton
// ============================================================

class SkeletonText extends StatelessWidget {
  final double width;
  final double height;

  const SkeletonText({
    Key? key,
    this.width = double.infinity,
    this.height = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
      final colors = context.kaiColors;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.sectionBg,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ============================================================
// Generic Box Skeleton
// ============================================================

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final bool isCircle;

  const SkeletonBox({
    Key? key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.isCircle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
      final colors = context.kaiColors;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.sectionBg,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}

// ============================================================
// Shimmer Effect Wrapper
// ============================================================

class SkeletonShimmer extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const SkeletonShimmer({
    Key? key,
    required this.child,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
      final colors = context.kaiColors;
    return Skeletonizer(
      enabled: enabled,
      effect: ShimmerEffect(
        baseColor: colors.sectionBg,
        highlightColor: colors.surface,
        duration: const Duration(milliseconds: 1500),
      ),
      child: child,
    );
  }
}

// ============================================================
// Categories Section Skeleton (for Home)
// ============================================================

class SkeletonCategoriesSection extends StatelessWidget {
  const SkeletonCategoriesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      final colors = context.kaiColors;
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: colors.sectionBg,
        highlightColor: colors.surface,
        duration: const Duration(milliseconds: 1500),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 24,
                      decoration: BoxDecoration(
                        color: colors.sectionBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 180,
                      height: 14,
                      decoration: BoxDecoration(
                        color: colors.sectionBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 60,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors.sectionBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Categories List
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: colors.sectionBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 70,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors.sectionBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Horizontal Course Section Skeleton (for Home)
// ============================================================

class SkeletonHorizontalCourseSection extends StatelessWidget {
  final String title;

  const SkeletonHorizontalCourseSection({
    Key? key,
    this.title = 'Courses',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
      final colors = context.kaiColors;
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: colors.sectionBg,
        highlightColor: colors.surface,
        duration: const Duration(milliseconds: 1500),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150,
                      height: 22,
                      decoration: BoxDecoration(
                        color: colors.sectionBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        color: colors.sectionBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.sectionBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const SizedBox(width: 60, height: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Courses List
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  width: 240,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image placeholder
                      Container(
                        height: 130,
                        decoration: BoxDecoration(
                          color: colors.sectionBg,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 16,
                              decoration: BoxDecoration(
                                color: colors.sectionBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 140,
                              height: 16,
                              decoration: BoxDecoration(
                                color: colors.sectionBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 1,
                              color: colors.border,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 60,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: colors.sectionBg,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: colors.sectionBg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Instructors Section Skeleton (for Home)
// ============================================================

class SkeletonInstructorsSection extends StatelessWidget {
  const SkeletonInstructorsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      final colors = context.kaiColors;
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: colors.sectionBg,
        highlightColor: colors.surface,
        duration: const Duration(milliseconds: 1500),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 100,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colors.sectionBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 60,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors.sectionBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Instructors List
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  width: 260,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6B39BF).withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: colors.sectionBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 16,
                              decoration: BoxDecoration(
                                color: colors.sectionBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: colors.sectionBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 50,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: colors.sectionBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: List.generate(
                                4,
                                (i) => Container(
                                  width: 26,
                                  height: 26,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: colors.sectionBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for latest news/blog section on the home screen
class SkeletonLatestNewsSection extends StatelessWidget {
  const SkeletonLatestNewsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      final colors = context.kaiColors;
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: colors.sectionBg,
        highlightColor: colors.surface,
        duration: const Duration(milliseconds: 1500),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: 150,
              height: 20,
              decoration: BoxDecoration(
                color: colors.sectionBg,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(2, (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: colors.sectionBg,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: double.infinity, height: 14, decoration: BoxDecoration(color: colors.sectionBg, borderRadius: BorderRadius.circular(4))),
                          const SizedBox(height: 8),
                          Container(width: 150, height: 14, decoration: BoxDecoration(color: colors.sectionBg, borderRadius: BorderRadius.circular(4))),
                          const Spacer(),
                          Container(width: 80, height: 12, decoration: BoxDecoration(color: colors.sectionBg, borderRadius: BorderRadius.circular(4))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}
