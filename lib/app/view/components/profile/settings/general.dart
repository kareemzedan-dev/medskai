import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/controller/settings_controller.dart';
import 'package:flutter_app/app/helper/validators.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';
import 'package:indexed/indexed.dart';

class GeneralAccount extends StatefulWidget {
  @override
  State<GeneralAccount> createState() => _GeneralAccountState();

  GeneralAccount({super.key});
}

class _GeneralAccountState extends State<GeneralAccount> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    settingController.handleGetUserData();
    super.initState();
  }

  final SettingsController settingController = Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final screenWidth = MediaQuery.of(context).size.width;

    return GetBuilder<SettingsController>(builder: (value) {
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
                children: [
                  // Header
                  Container(
                    width: screenWidth,
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
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
                        Expanded(
                          child: Text(
                            tr(LocaleKeys.settings_general),
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
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile image section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colors.cardBg,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF6B39BF).withOpacity(0.15),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                if (value.selectedImage != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: value.selectedImage!.path
                                                .contains("https") ||
                                            kIsWeb
                                        ? Image.network(
                                            value.selectedImage!.path)
                                        : Image.file(
                                            File(value.selectedImage!.path)),
                                  )
                                else
                                  Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: colors.sectionBg,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image,
                                            size: 40,
                                            color: colors.textSecondary
                                                .withOpacity(0.5),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            tr(LocaleKeys
                                                .empty_noImageSelected),
                                            style: TextStyle(
                                              fontFamily: 'Manrope',
                                              fontSize: 14,
                                              color: colors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      showCupertinoModalPopup<void>(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            CupertinoActionSheet(
                                          title: Text(tr(
                                              LocaleKeys.settings_chooseFrom)),
                                          actions: <CupertinoActionSheetAction>[
                                            CupertinoActionSheetAction(
                                              isDefaultAction: true,
                                              onPressed: () {
                                                Navigator.pop(context);
                                                settingController
                                                    .selectFromGallery(
                                                        'camera');
                                              },
                                              child: Text(tr(
                                                  LocaleKeys.settings_camera)),
                                            ),
                                            CupertinoActionSheetAction(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                settingController
                                                    .selectFromGallery(
                                                        'gallery');
                                              },
                                              child: Text(tr(
                                                  LocaleKeys.settings_general)),
                                            ),
                                            CupertinoActionSheetAction(
                                              isDestructiveAction: true,
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(tr(
                                                  LocaleKeys.settings_cancel)),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.upload,
                                        size: 18),
                                    label: Text(
                                      tr(LocaleKeys.settings_upload),
                                      style: const TextStyle(
                                        fontFamily: 'Manrope',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: MedsKaiColors.primary,
                                      foregroundColor: MedsKaiColors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Form fields
                          Form(
                            key: _formKey,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6B39BF)
                                        .withOpacity(0.15),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTextField(
                                    label: tr(LocaleKeys.settings_bio),
                                    controller: value.bioController,
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    label: tr(LocaleKeys.settings_firstName),
                                    controller: value.firstNameController,
                                    validator: (v) =>
                                        AppValidators.required(v, 'First name'),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    label: tr(LocaleKeys.settings_lastName),
                                    controller: value.lastNameController,
                                    validator: (v) =>
                                        AppValidators.required(v, 'Last name'),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    label: tr(LocaleKeys.settings_nickName),
                                    controller: value.nicknameController,
                                    validator: (v) =>
                                        AppValidators.required(v, 'Nickname'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Save button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (!_formKey.currentState!.validate()) return;
                                value.saveGeneral();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MedsKaiColors.primary,
                                foregroundColor: MedsKaiColors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                tr(LocaleKeys.settings_save),
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
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
    });
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final colors = context.kaiColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            Icon(
              Icons.edit,
              color: colors.textSecondary.withOpacity(0.4),
              size: 16,
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            color: colors.textPrimary,
          ),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: colors.sectionBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.border),
            ),
          ),
        ),
      ],
    );
  }
}
