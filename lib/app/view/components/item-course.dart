import 'package:easy_localization/easy_localization.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/wishlist_store.dart';
import 'package:flutter_app/app/backend/models/course_model.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/app/helper/function_helper.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/app/view/components/cached_image.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get/get.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

import '../../backend/parse/course_detail_parse.dart';

typedef OnToggleWishlistCallback = void Function();

class ItemCourse extends StatelessWidget with GetItMixin {
  final CourseModel item;
  bool hideCategory = false;
  final CourseDetailParser courseDetailParser;

  final OnToggleWishlistCallback onToggleWishlist;

  ItemCourse(
      {super.key,
      required this.item,
      required this.onToggleWishlist,
      required this.courseDetailParser,
      hideCategory
      });

  void onNavigate() {
    Get.toNamed(AppRouter.getCourseDetailRoute(),
        arguments: [item.id], preventDuplicates: false);
  }

  WishlistStore get wishlistStore => Get.find<WishlistStore>();

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return RepaintBoundary(child: GestureDetector(
      onTap: () => onNavigate(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: colors.surface,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section - simple, no overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: AppCachedImage(imageUrl: item.image),
                  ),
                ),
                // Wishlist button - reactive via Observer
                Positioned(
                  top: 10,
                  right: 10,
                  child: Semantics(
                    button: true,
                    label: 'Toggle wishlist',
                    child: GestureDetector(
                    onTap: () => onToggleWishlist(),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Observer(
                        builder: (_) {
                          final isWishlisted = wishlistStore.data
                              .any((e) => e.id == item.id);
                          return Icon(
                            isWishlisted
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isWishlisted
                                ? MedsKaiColors.error
                                : colors.textSecondary,
                            size: 20,
                          );
                        },
                      ),
                    ),
                  ),
                  ),
                  ),
                ),
              ],
            ),
            // Content section - like website
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title - bold black
                  Text(
                    item.name ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Category - gray text
                  if (item.categories != null && item.categories!.isNotEmpty && !hideCategory)
                    Text(
                      item.categories!.map((e) => e.name).join(', '),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: colors.textSecondary,
                      ),
                    ),
                  const SizedBox(height: 12),
                  // Lessons count - always visible
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 16,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.totalLessons > 0
                            ? '${item.totalLessons} ${tr(LocaleKeys.lesson)}'
                            : (item.count_items > 0
                                ? '${item.count_items} ${tr(LocaleKeys.lesson)}'
                                : tr(LocaleKeys.lesson)),
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Price - RED like website
                  _buildPrice(colors),
                  const SizedBox(height: 14),
                  // Start Learning button - using #673ABF from website
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => onNavigate(),
                      icon: const Icon(Icons.play_arrow, size: 20),
                      label: Text(tr(LocaleKeys.singleCourse_btnStartNow)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MedsKaiColors.buttonColor,  // #673ABF from website
                        foregroundColor: MedsKaiColors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),  // 8-10px from website
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildPrice(MedsKaiThemeColors colors) {
    if (!kIsWeb && Platform.isIOS) {
      return const SizedBox.shrink();
    }
    if (item.on_sale == true) {
      return Row(
        children: [
          Text(
            item.sale_price_rendered ?? "\$${item.sale_price}",
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: MedsKaiColors.price,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.origin_price_rendered != ""
                ? "${item.origin_price_rendered}"
                : "\$${item.origin_price}",
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colors.textSecondary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      );
    } else if ((item.price ?? 0) > 0) {
      return Text(
        item.price_rendered ?? "\$${item.price}",
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: MedsKaiColors.price,
        ),
      );
    } else {
      return Text(
        tr(LocaleKeys.free),
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: MedsKaiColors.success,
        ),
      );
    }
  }
}
