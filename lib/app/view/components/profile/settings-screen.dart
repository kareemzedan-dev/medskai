import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:flutter_app/app/controller/theme_controller.dart';
import 'package:indexed/indexed.dart';

typedef OnNavigateCallback = void Function(int page);

class SettingsScreen extends StatefulWidget with GetItStatefulWidgetMixin {
  final PageController pageController;
  final OnNavigateCallback goBack;
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
  SettingsScreen(
      {super.key, required this.pageController, required this.goBack});
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final ThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = Get.find<ThemeController>();
  }

  void onLogin() {
    Future.delayed(Duration.zero, () {
      Get.offAllNamed(AppRouter.getLoginRoute());
    });
  }

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;
  int pageActive = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
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
                      MedsKaiColors.primary.withOpacity(0.12),
                      MedsKaiColors.accent.withOpacity(0.06),
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
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          widget.goBack(0);
                        },
                        icon: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: colors.cardBg,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF6B39BF).withOpacity(0.15),
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
                                colors: [
                                  MedsKaiColors.primary,
                                  MedsKaiColors.primary.withOpacity(0.85)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Feather.settings,
                              color: MedsKaiColors.white, // icon on primary bg
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            tr(LocaleKeys.settings_title),
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
                // Settings list
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildSettingsCard(
                          children: [
                            _buildSettingsItem(
                              icon: Feather.settings,
                              iconColor: MedsKaiColors.primary,
                              title: tr(LocaleKeys.settings_general),
                              onTap: () => Get.toNamed(AppRouter.general),
                            ),
                            _buildDivider(),
                            _buildSettingsItem(
                              icon: Feather.lock,
                              iconColor: MedsKaiColors.accent,
                              title: tr(LocaleKeys.settings_password),
                              onTap: () => Get.toNamed(AppRouter.password),
                            ),
                            _buildDivider(),
                            _buildSettingsItem(
                              icon: Ionicons.language,
                              iconColor: MedsKaiColors.info,
                              title: tr(LocaleKeys.language),
                              onTap: () => Get.toNamed(AppRouter.language),
                            ),
                            _buildDivider(),
                            GetBuilder<ThemeController>(
                              init: _themeController,
                              builder: (themeCtrl) => _buildSettingsItem(
                                icon: themeCtrl.isDarkMode
                                    ? Feather.moon
                                    : Feather.sun,
                                iconColor: MedsKaiColors.primary,
                                title: themeCtrl.isDarkMode
                                    ? tr(LocaleKeys.settings_darkMode)
                                    : tr(LocaleKeys.settings_lightMode),
                                onTap: () => themeCtrl.toggleTheme(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSettingsCard(
                          children: [
                            _buildSettingsItem(
                              icon: Feather.trash_2,
                              iconColor: MedsKaiColors.error,
                              title: tr(LocaleKeys.settings_deleteAccount),
                              onTap: () => Get.toNamed(AppRouter.delete),
                              isDestructive: true,
                            ),
                          ],
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
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    final colors = context.kaiColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B39BF).withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final colors = context.kaiColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color:
                      isDestructive ? MedsKaiColors.error : colors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: colors.textSecondary.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    final colors = context.kaiColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: colors.border.withOpacity(0.5),
      ),
    );
  }
}
