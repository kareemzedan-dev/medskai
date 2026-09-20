import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/models/notification_model.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../helper/router.dart';

class ItemNotification extends StatelessWidget {
  final NotificationModel item;

  ItemNotification({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        RegExp regExp = RegExp(r'\d+');
        Iterable<RegExpMatch> matches = regExp.allMatches(item.source ?? "");
        List<String> numbers = matches.map((match) => match.group(0)!).toList();
        if (numbers.isNotEmpty) {
          Get.toNamed(AppRouter.getCourseDetailRoute(),
              arguments: [numbers[0]], preventDuplicates: false);
        }
      },
      child: Container(
        width: screenWidth,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B39BF).withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.image != null && item.image != '' && item.image != 'null')
              Container(
                width: screenWidth,
                height: (180 / 375) * screenWidth,
                margin: const EdgeInsetsDirectional.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(item.image!),
                  ),
                ),
              ),
            if (item.title != null && item.title != '')
              Text(
                item.title!,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: colors.textPrimary,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              item.content ?? '',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: colors.textSecondary.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  item.formattedDateCreated,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: colors.textSecondary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
