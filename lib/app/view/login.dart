import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/session_store.dart';
import 'package:flutter_app/app/controller/login_controller.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/app/util/toast.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';

import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/app/backend/mobx-store/init_store.dart';

import '../controller/social_login_controller.dart';
import '../helper/validators.dart';

class LoginScreen extends StatefulWidget with GetItStatefulWidgetMixin {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
  bool _isVisible = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late LoginController loginController;

  void onRegister() {
    Future.delayed(Duration.zero, () {
      Get.toNamed(AppRouter.getRegisterRoute());
    });
  }

  void onForgotPassword() {
    Future.delayed(Duration.zero, () {
      Get.toNamed(AppRouter.forgotPassword);
    });
  }

  @override
  void initState() {
    super.initState();
    final sessionStore = locator<SessionStore>();
    loginController = Get.put(
      LoginController(sessionStore: sessionStore, parser: Get.find()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colors = context.kaiColors;

    return GetBuilder<SocialLoginController>(builder: (socialLoginController) {
      return Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // Back Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Get.offAllNamed(AppRouter.getTabsBarRoute()),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.sectionBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: colors.border,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: colors.textPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.06),

                    // Logo with gradient background (exact from website)
                    Center(
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              MedsKaiColors.primary, // #707BED
                              MedsKaiColors.purpleAccent, // #3A2374
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  MedsKaiColors.purpleAccent.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Image.asset(
                          'assets/images/logo-white.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    Text(
                      tr(LocaleKeys.loginScreen_title),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Subtitle
                    Text(
                      tr(LocaleKeys.loginScreen_subtitle),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Username Field
                    _buildInputField(
                      controller: usernameController,
                      label: tr(LocaleKeys.loginScreen_emailOrUsername),
                      hint: tr(LocaleKeys.loginScreen_usernamePlaceholder),
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => AppValidators.required(
                          value, tr(LocaleKeys.loginScreen_emailOrUsername)),
                    ),

                    const SizedBox(height: 20),

                    // Password Field
                    _buildInputField(
                      controller: passwordController,
                      label: tr(LocaleKeys.loginScreen_password),
                      hint: tr(LocaleKeys.loginScreen_passwordPlaceholder),
                      icon: Icons.lock_outline,
                      isPassword: true,
                      isPasswordVisible: _isVisible,
                      onTogglePassword: () =>
                          setState(() => _isVisible = !_isVisible),
                      validator: (value) => AppValidators.required(
                          value, tr(LocaleKeys.loginScreen_password)),
                    ),

                    const SizedBox(height: 16),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: onForgotPassword,
                        child: Text(
                          tr(LocaleKeys.loginScreen_forgotPassword),
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: MedsKaiColors.primary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Login Button
                    _buildPrimaryButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (!(_formKey.currentState?.validate() ?? false))
                                return;
                              setState(() => _isLoading = true);
                              try {
                                // Add client-side timeout as failsafe (45 seconds)
                                await loginController
                                    .login(
                                  usernameController.text,
                                  passwordController.text,
                                )
                                    .timeout(
                                  const Duration(seconds: 45),
                                  onTimeout: () {
                                    showToast(tr(LocaleKeys.toast_networkError),
                                        isError: true);
                                  },
                                );
                              } catch (e) {
                                debugPrint('Login view error: $e');
                                showToast(tr(LocaleKeys.toast_networkError),
                                    isError: true);
                              } finally {
                                // Always reset loading state
                                if (mounted) {
                                  setState(() => _isLoading = false);
                                }
                              }
                            },
                      isLoading: _isLoading,
                      label: tr(LocaleKeys.loginScreen_btnLogin),
                    ),

                    // Social Login Section
                    if (socialLoginController.isEnableSocialLogin) ...[
                      const SizedBox(height: 36),

                      // Divider with OR
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    colors.border,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: colors.sectionBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              tr(LocaleKeys.loginScreen_or),
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colors.border,
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Social Login Buttons
                      _buildSocialButton(
                        icon: 'G',
                        label: 'Continue with Google',
                        color: const Color(0xFFDB4437),
                        bgColor: const Color(0xFFFEECEB),
                        onTap: () => socialLoginController.signInGoogle(),
                      ),
                    ],

                    const SizedBox(height: 48),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tr(LocaleKeys.loginScreen_registerText),
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: onRegister,
                          child: Text(
                            tr(LocaleKeys.loginScreen_register),
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: MedsKaiColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
  }) {
    final colors = context.kaiColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: colors.sectionBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.border,
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: isPassword && !isPasswordVisible,
            validator: validator,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: colors.textHint,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  icon,
                  color: colors.textSecondary,
                  size: 22,
                ),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: colors.textSecondary,
                        size: 22,
                      ),
                      onPressed: onTogglePassword,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 0, vertical: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback? onPressed,
    required bool isLoading,
    required String label,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            MedsKaiColors.buttonColor, // #673ABF from website
            MedsKaiColors.buttonColor.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(10), // 8-10px from website
        boxShadow: [
          BoxShadow(
            color: MedsKaiColors.buttonColor.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // 8-10px from website
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: MedsKaiColors.white,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
    Widget? iconWidget,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget ??
                Text(
                  icon,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
