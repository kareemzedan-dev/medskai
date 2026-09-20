import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/controller/settings_controller.dart';
import 'package:flutter_app/app/helper/validators.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';
import 'package:indexed/indexed.dart';
import 'input-password.dart';

class Password extends StatefulWidget {
  @override
  State<Password> createState() => _PasswordState();

  Password({super.key});
}

class _PasswordState extends State<Password> {
  final SettingsController settingController = Get.find<SettingsController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

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
                  width: screenWidth,
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                          tr(LocaleKeys.settings_password),
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
                    child: Container(
                      padding: const EdgeInsets.all(16),
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPasswordField(
                              label: tr(LocaleKeys.settings_currentPassword),
                              controller: settingController.currentPasswordController,
                              validator: (v) => AppValidators.required(v, 'Current password'),
                            ),
                            _buildPasswordField(
                              label: tr(LocaleKeys.settings_newPassword),
                              controller: settingController.newPasswordController,
                              validator: (v) => AppValidators.password(v),
                            ),
                            _buildPasswordField(
                              label: tr(LocaleKeys.settings_confirmNewPassword),
                              controller: settingController.confirmPasswordController,
                              validator: (v) => AppValidators.confirmPassword(v, settingController.newPasswordController.text),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (!_formKey.currentState!.validate()) return;
                                  settingController.submitPassword();
                                },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MedsKaiColors.primary,
                                foregroundColor: MedsKaiColors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
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
                          ],
                        ),
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
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    final colors = context.kaiColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InputPassword(controller: controller, validator: validator),
      ],
    );
  }
}
