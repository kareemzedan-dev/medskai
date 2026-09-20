import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/controller/register_controller.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:indexed/indexed.dart';
import '../controller/social_login_controller.dart';
import '../helper/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterScreen> {
  bool _isVisiblePassword = false;
  bool _isVisibleConfirm = false;
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    double top = MediaQuery.of(context).viewPadding.top;
    return GetBuilder<RegisterController>(builder: (value) {
      return GetBuilder<SocialLoginController>(builder: (socialLoginController) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Stack(
          children: [

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        child: IconButton(
                          onPressed: () => Get.back(),
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
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Logo with gradient background (exact from login)
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
                    const SizedBox(height: 24),
                    // Title
                    Center(
                      child: Text(
                        tr(LocaleKeys.registerScreen_title),
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        tr(LocaleKeys.registerScreen_subtitle),
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Form
                    Form(
                      key: value.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Username field
                          _buildInputField(
                            colors: colors,
                            controller: value.usernameController,
                            label: tr(LocaleKeys.registerScreen_usernamePlaceholder),
                            icon: Icons.person_outline_rounded,
                            validator: (val) => AppValidators.username(val),
                          ),
                          const SizedBox(height: 16),
                          // Email field
                          _buildInputField(
                            colors: colors,
                            controller: value.emailController,
                            label: tr(LocaleKeys.registerScreen_emailPlaceholder),
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) => AppValidators.email(val),
                          ),
                          const SizedBox(height: 16),
                          // Password field
                          _buildInputField(
                            colors: colors,
                            controller: value.passwordController,
                            label: tr(LocaleKeys.registerScreen_passwordPlaceholder),
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            isVisible: _isVisiblePassword,
                            onToggleVisibility: () {
                              setState(() {
                                _isVisiblePassword = !_isVisiblePassword;
                              });
                            },
                            validator: (val) => AppValidators.password(val),
                          ),
                          const SizedBox(height: 16),
                          // Confirm Password field
                          _buildInputField(
                            colors: colors,
                            controller: value.confirmPasswordController,
                            label: tr(LocaleKeys.registerScreen_confirmPasswordPlaceholder),
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            isVisible: _isVisibleConfirm,
                            onToggleVisibility: () {
                              setState(() {
                                _isVisibleConfirm = !_isVisibleConfirm;
                              });
                            },
                            validator: (val) => AppValidators.confirmPassword(val, value.passwordController.text),
                          ),
                          const SizedBox(height: 20),
                          // Terms checkbox
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                value.agreedToTerms = !value.agreedToTerms;
                              });
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: value.agreedToTerms
                                        ? MedsKaiColors.primary
                                        : colors.surface,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: value.agreedToTerms
                                          ? MedsKaiColors.primary
                                          : colors.border,
                                      width: 2,
                                    ),
                                  ),
                                  child: value.agreedToTerms
                                      ? const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: MedsKaiColors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    tr(LocaleKeys.registerScreen_termAndCondition),
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          // Register button (using #673ABF from website)
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: value.isLoading
                                    ? [
                                        MedsKaiColors.buttonColor.withOpacity(0.5),
                                        MedsKaiColors.buttonColor.withOpacity(0.4),
                                      ]
                                    : [
                                        MedsKaiColors.buttonColor,
                                        MedsKaiColors.buttonColor.withOpacity(0.85),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: value.isLoading
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: MedsKaiColors.buttonColor.withOpacity(0.35),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: value.isLoading
                                  ? null
                                  : () {
                                      if (value.formKey.currentState?.validate() ?? false) {
                                        value.register();
                                      }
                                    },
                              child: value.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: MedsKaiColors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      tr(LocaleKeys.registerScreen_btnSubmit),
                                      style: const TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: MedsKaiColors.white,
                                      ),
                                    ),
                            ),
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
                                        colors: [Colors.transparent, colors.border],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: colors.surface,
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
                                        colors: [colors.border, Colors.transparent],
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

                          const SizedBox(height: 24),
                          // Login link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${tr(LocaleKeys.registerScreen_alreadyHaveAccount)} ',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: colors.textSecondary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Get.back(),
                                child: Text(
                                  tr(LocaleKeys.registerScreen_signIn),
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: MedsKaiColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
      });
    });
  }

  Widget _buildInputField({
    required MedsKaiThemeColors colors,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword && !isVisible,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: colors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colors.textSecondary,
          ),
          prefixIcon: Icon(
            icon,
            color: colors.textSecondary,
            size: 22,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: colors.textSecondary,
                    size: 22,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: validator ?? (value) {
          if (value == null || value.isEmpty) {
            return tr(LocaleKeys.alert_notLoggedIn);
          }
          return null;
        },
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
    super.dispose();
  }
}
