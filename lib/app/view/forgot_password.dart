import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/session_store.dart';
import 'package:flutter_app/app/controller/forgot_password_controller.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/app/helper/validators.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/app/backend/mobx-store/init_store.dart';

class ForgotPasswordScreen extends StatefulWidget
    with GetItStatefulWidgetMixin {
  ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  late ForgotPasswordController controller;
  late SessionStore sessionStore;

  @override
  void initState() {
    super.initState();
    sessionStore = locator<SessionStore>();
    controller = Get.put(
      ForgotPasswordController(sessionStore: sessionStore, parser: Get.find()),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  void onRegister() {
    Future.delayed(Duration.zero, () {
      Get.toNamed(AppRouter.getRegisterRoute());
    });
  }

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SizedBox(
        height: screenHeight,
        child: Stack(
          children: <Widget>[
            // Background image
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Center(
                child: Container(
                  width: (1120 / 1500) * screenWidth,
                  height: (1272 / 1500) * screenWidth,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/banner-login2.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            // Scrollable form content
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(40, screenHeight * 0.15, 40, 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: (98 / 375) * screenWidth,
                        width: (73 / 375) * screenWidth,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/logo.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: Text(
                          tr(LocaleKeys.forgot_title),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            fontSize: 28,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          tr(LocaleKeys.forgot_description),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          hintText: tr(LocaleKeys.forgot_emailPlaceholder),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: MedsKaiColors.primary, width: 2),
                          ),
                        ),
                        validator: (value) => AppValidators.email(value),
                      ),
                      const SizedBox(height: 24),
                      // Submit button
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            controller.forgotPassword(usernameController.text);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MedsKaiColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        child: Text(
                          tr(LocaleKeys.forgot_btnSubmit),
                          style: const TextStyle(
                            color: MedsKaiColors.white,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Back button
            Positioned(
              left: 16,
              top: MediaQuery.of(context).padding.top + 8,
              child: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: colors.textPrimary,
                iconSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
    // });
  }
}
