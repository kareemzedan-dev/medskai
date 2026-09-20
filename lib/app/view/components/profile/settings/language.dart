import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/controller/language_controller.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';
import 'package:indexed/indexed.dart';
import '../../../../helper/shared_pref.dart';

class MultiLanguage extends StatefulWidget {
  const MultiLanguage({super.key});

  @override
  State<MultiLanguage> createState() => _MultiLanguageState();
}

class _MultiLanguageState extends State<MultiLanguage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  LanguageController languageController = Get.find<LanguageController>();
  SharedPreferencesManager sharedPreferencesManager = Get.find();

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  void initState() {
    languageController.handleChoiceLanguage(
        sharedPreferencesManager.getString('language') ?? 'en');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageController>(builder: (value) {
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
                        MedsKaiColors.info.withOpacity(0.12),
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
                    width: screenWidth,
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: colors.surface,
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
                        Expanded(
                          child: Text(
                            tr(LocaleKeys.language),
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                              color: colors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 52),
                      ],
                    ),
                  ),
                  // Language list
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
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
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        controller: ScrollController(),
                        itemCount: value.listLanguage.length,
                        separatorBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(
                            height: 1,
                            color: colors.border.withOpacity(0.5),
                          ),
                        ),
                        itemBuilder: (context, index) {
                          final isActive =
                              value.listLanguage[index]['isActive'] == true;
                          return InkWell(
                            onTap: () => value.handleChoiceLanguage(
                                value.listLanguage[index]['key']),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? MedsKaiColors.primary.withOpacity(0.12)
                                              : colors.sectionBg,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.language,
                                          size: 18,
                                          color: isActive
                                              ? MedsKaiColors.primary
                                              : colors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        value.listLanguage[index]['value'].toString(),
                                        style: TextStyle(
                                          fontFamily: 'Manrope',
                                          fontWeight: isActive
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          fontSize: 15,
                                          color: isActive
                                              ? MedsKaiColors.primary
                                              : colors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isActive)
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: MedsKaiColors.primary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.check_rounded,
                                        color: MedsKaiColors.white, // icon on primary bg
                                        size: 16,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Update button
            Positioned(
              right: 16,
              bottom: 30,
              left: 16,
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: () {
                    var currentLanguage = languageController.handleChoiceLanguage(
                        languageController.currentKeyLanguage.isNotEmpty
                            ? languageController.currentKeyLanguage
                            : sharedPreferencesManager.getString('language') ?? 'en');
                    languageController.handleUpdate(currentLanguage);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MedsKaiColors.primary,
                    foregroundColor: MedsKaiColors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    tr(LocaleKeys.settings_update),
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
