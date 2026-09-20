import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/session_store.dart';
import 'package:flutter_app/app/backend/parse/forgot_password_parse.dart';
import 'package:flutter_app/app/util/toast.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ForgotPasswordController extends GetxController implements GetxService {
  final ForgotPasswordParse parser;
  final SessionStore sessionStore;

  TextEditingController usernameController = TextEditingController();

  ForgotPasswordController({required this.parser, required this.sessionStore});

  Future<void> forgotPassword(username) async {
    final trimmed = username?.toString().trim() ?? '';
    if (trimmed.isEmpty) {
      showToast(tr(LocaleKeys.forgot_emailRequired), isError: true);
      return;
    }

    final context = Get.context;
    if (context == null) return;

    var param = {"user_login": trimmed};
    try {
      context.loaderOverlay.show();
      Response response = await parser.forgotPassword(param);
      context.loaderOverlay.hide();
      if (response.statusCode == 200) {
        Alert(
          context: context,
          title: tr(LocaleKeys.common_success),
          desc: sanitizeToastMessage(
              response.body?["message"]?.toString() ?? ""),
          buttons: [
            DialogButton(
              color: MedsKaiColors.primary,
              child: Text(
                tr(LocaleKeys.alert_ok),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Get.back(); // Go back to login screen
              },
            ),
          ],
        ).show();
      } else {
        showToast(
            response.body?["message"]?.toString() ??
                tr(LocaleKeys.forgot_requestFailed),
            isError: true);
      }
    } catch (e) {
      context.loaderOverlay.hide();
      showToast(tr(LocaleKeys.toast_requestFailed), isError: true);
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    super.onClose();
  }

  final OutlineInputBorder enabledBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(8.0),
      topRight: Radius.circular(8.0),
      bottomLeft: Radius.circular(8.0),
      bottomRight: Radius.circular(8.0),
    ),
    borderSide: BorderSide(color: MedsKaiColors.border),
  );
}
