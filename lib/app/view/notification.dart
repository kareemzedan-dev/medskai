import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/controller/notification_controller.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/app/view/components/skeleton/skeleton_widgets.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:indexed/indexed.dart';
import '../controller/notification_local_controller.dart';
import 'components/item-notification.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  NotificationController notificationController =
      Get.find<NotificationController>();
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  void initState() {
    NotificationLocalController.initialize(flutterLocalNotificationsPlugin);
    Future.delayed(Duration.zero, () async {
      await notificationController.refreshData();
      if (Get.arguments != null) {
        notificationController.checkUpdateNotification(Get.arguments);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return GetBuilder<NotificationController>(builder: (value) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: colors.background,
        drawerEnableOpenDragGesture: false,
        body: Stack(
          children: <Widget>[
            // Gradient header background
            Indexed(
              index: 1,
              child: Positioned(
                right: 0,
                top: 0,
                left: 0,
                child: Container(
                  width: screenWidth,
                  height: (200 / 375) * screenWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        MedsKaiColors.accent.withOpacity(0.12),
                        MedsKaiColors.primary.withOpacity(0.06),
                        colors.sectionBg,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  // Header
                  Container(
                    height: 60.0,
                    width: screenWidth,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: colors.cardBg,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6B39BF).withOpacity(0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: colors.textPrimary,
                              size: 18,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [MedsKaiColors.primary, MedsKaiColors.primary.withOpacity(0.85)],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.notifications_rounded,
                                color: MedsKaiColors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              tr(LocaleKeys.notification_title),
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                                color: colors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 44),
                      ],
                    ),
                  ),
                  // Notification list with skeleton
                  Expanded(
                    child: value.hasError && value.notificationList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: MedsKaiColors.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.cloud_off_rounded,
                                    size: 40,
                                    color: MedsKaiColors.error,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  tr(LocaleKeys.error),
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  value.errorMessage,
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 14,
                                    color: colors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () => value.retryLoadData(),
                                  icon: const Icon(Icons.refresh_rounded, size: 20),
                                  label: Text(tr(LocaleKeys.common_retry)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: MedsKaiColors.primary,
                                    foregroundColor: MedsKaiColors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : value.isInitialLoading
                        ? SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                            child: Column(
                              children: List.generate(
                                6,
                                (index) => const SkeletonNotificationItem(),
                              ),
                            ),
                          )
                        : value.notificationList.isEmpty
                            ? _buildEmptyState()
                            : RefreshIndicator(
                                onRefresh: () => value.refreshData(),
                                color: MedsKaiColors.primary,
                                child: ListView.builder(
                                  controller: value.scrollController,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  itemCount: value.notificationList.length +
                                      (value.isLoadingMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == value.notificationList.length) {
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor: AlwaysStoppedAnimation(
                                                  MedsKaiColors.primary),
                                            ),
                                          ),
                                        ),
                                      );
                                    } else if (index <
                                        value.notificationList.length) {
                                      return ItemNotification(
                                        key: ValueKey(value.notificationList[index].notification_id ?? index),
                                        item: value.notificationList[index],
                                      );
                                    } else {
                                      return Container();
                                    }
                                  },
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    final colors = context.kaiColors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  MedsKaiColors.primary.withOpacity(0.15),
                  MedsKaiColors.primary.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 50,
              color: MedsKaiColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            tr(LocaleKeys.notification_empty),
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tr(LocaleKeys.empty_notificationsHint),
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
