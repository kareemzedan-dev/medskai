import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/session_store.dart';
import 'package:flutter_app/app/backend/parse/settings_parse.dart';
import 'package:flutter_app/app/controller/profile_controller.dart';
import 'package:flutter_app/app/helper/function_helper.dart';
import 'package:flutter_app/app/view/tabs.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../backend/models/user_info_model.dart';
import '../helper/dialog_helper.dart';
import '../helper/router.dart';

class SettingsController extends GetxController {
  final SessionStore sessionStore;
  final SettingsParser parser;
  String st = "{}";

  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController deletePasswordController = TextEditingController();

  TextEditingController nicknameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  XFile? selectedImage;
  int currentPage = 0;

  SettingsController({required this.parser, required this.sessionStore});

  @override
  void onInit() {
    super.onInit();
    handleGetUserData();
  }

  handleGetUserData() {
    var userData = getUser();
    nicknameController.text = userData.nickname ?? "";
    bioController.text = userData.description ?? "";
    firstNameController.text = userData.first_name ?? "";
    lastNameController.text = userData.last_name ?? "";
    if (userData.avatar_url.isNotEmpty) {
      selectedImage = XFile(userData.avatar_url);
    }
    update();
  }

  void activePage(int value) {
    currentPage = value;
    update();
  }

  UserInfoModel getUser() {
    return parser.getUserInfo();
  }

  Future<void> submitPassword() async {
    final context = Get.context;
    if (context == null) return;
    final value = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController(
            sessionStore: sessionStore, myProfileParser: Get.find()));
    if (currentPasswordController.text.trim() == "") {
      Alert(
              context: context,
              title: tr(LocaleKeys.error),
              desc: tr(LocaleKeys.settings_currentPasswordIsRequired))
          .show();
      return;
    }
    if (newPasswordController.text.trim() == "") {
      Alert(
              context: context,
              title: tr(LocaleKeys.error),
              desc: tr(LocaleKeys.settings_newPasswordIsRequired))
          .show();
      return;
    }

    if (newPasswordController.text.trim().length < 6) {
      Alert(
          context: context,
          title: tr(LocaleKeys.error),
          desc: tr(LocaleKeys.validation_passwordMinLength,
              namedArgs: {'count': '6'})).show();
      return;
    }

    if (newPasswordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      Alert(
              context: context,
              title: tr(LocaleKeys.error),
              desc: tr(LocaleKeys.settings_passwordNotMatch))
          .show();
      return;
    }

    if (newPasswordController.text.trim() ==
        currentPasswordController.text.trim()) {
      Alert(
              context: context,
              title: tr(LocaleKeys.error),
              desc: tr(LocaleKeys.settings_passwordAlreadyExists))
          .show();
      return;
    }
    var param = {
      "old_password": currentPasswordController.text,
      "new_password": newPasswordController.text,
    };
    try {
      DialogHelper.showLoading();
      Response response = await parser.changePassword(param);
      DialogHelper.hideLoading();

      await Future.delayed(Duration(seconds: 1), () {
        if (isClosed) return;
        final ctx = Get.context;
        if (ctx == null) return;
        if (response.statusCode == 200) {
          if (response.body != null &&
              response.body is Map &&
              response.body["code"] == "success") {
            Alert(
                    context: ctx,
                    title: tr(LocaleKeys.common_success),
                    desc: response.body["message"]?.toString() ??
                        tr(LocaleKeys.common_success))
                .show();
            Future.delayed(Duration(seconds: 3), () {
              if (isClosed) return;
              value.logout();
              currentPasswordController.text = "";
              newPasswordController.text = "";
              confirmPasswordController.text = "";
              Get.toNamed(AppRouter.home);
              update();
            });
          } else {
            Alert(
                    context: context,
                    title: tr(LocaleKeys.error),
                    desc: response.body["message"]?.toString() ??
                        tr(LocaleKeys.error))
                .show();
          }
        } else {
          Alert(
                  context: context,
                  title: tr(LocaleKeys.error),
                  desc: response.body?["message"]?.toString() ??
                      tr(LocaleKeys.error))
              .show();
        }
      });
    } catch (e) {
      DialogHelper.hideLoading();
      debugPrint('submitPassword error: $e');
    }
  }

  Future<void> deleteAccount() async {
    final context = Get.context;
    if (context == null) return;
    final value = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController(
            sessionStore: sessionStore, myProfileParser: Get.find()));
    var userInfo = getUser();
    if (deletePasswordController.text.trim() == "") {
      Alert(
              context: context,
              title: tr(LocaleKeys.error),
              desc: tr(LocaleKeys.settings_currentPasswordIsRequired))
          .show();
      return;
    }

    var param = {
      "id": userInfo.id,
      "password": deletePasswordController.text,
    };
    try {
      context.loaderOverlay.show();
      Response response = await parser.deleteAccount(param);
      context.loaderOverlay.hide();
      await Future.delayed(Duration(seconds: 1), () {
        if (isClosed) return;
        final ctx = Get.context;
        if (ctx == null) return;
        if (response.statusCode == 200) {
          if (response.body is Map && response.body["code"] == "success") {
            Alert(
                    context: ctx,
                    title: tr(LocaleKeys.common_success),
                    desc: response.body["message"]?.toString() ??
                        tr(LocaleKeys.common_success))
                .show();
            Future.delayed(Duration(seconds: 2), () {
              if (isClosed) return;
              value.logout();
              Get.offAll(TabScreen());
              deletePasswordController.text = "";
              update();
            });
          } else {
            Alert(
                    context: context,
                    title: tr(LocaleKeys.error),
                    desc: response.body["message"]?.toString() ??
                        tr(LocaleKeys.error))
                .show();
          }
        } else {
          Alert(
                  context: context,
                  title: tr(LocaleKeys.error),
                  desc: response.body?["message"]?.toString() ??
                      tr(LocaleKeys.error))
              .show();
        }
      });
    } catch (e) {
      context.loaderOverlay.hide();
      debugPrint('deleteAccount error: $e');
    }
  }

  void selectFromGallery(String kind) async {
    try {
      var file = await ImagePicker().pickImage(
        maxWidth: 1080,
        maxHeight: 1080,
        source: kind == 'gallery' ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 25,
      );
      if (file != null) {
        final croppedFile = await ImageCropper().cropImage(
            sourcePath: file.path,
            maxWidth: 250,
            maxHeight: 250,
            aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
            compressQuality: 100,
            uiSettings: [
              AndroidUiSettings(
                  toolbarTitle: tr(LocaleKeys.settings_cropImage),
                  toolbarColor: Colors.deepOrange,
                  toolbarWidgetColor: Colors.white,
                  lockAspectRatio: false),
              IOSUiSettings(
                  title: tr(LocaleKeys.settings_cropImage),
                  aspectRatioLockEnabled: true,
                  resetAspectRatioEnabled: true,
                  rotateButtonsHidden: true,
                  rectWidth: 400,
                  rectHeight: 400),
            ]);
        if (croppedFile != null) selectedImage = XFile(croppedFile.path);
      }
      update();
    } catch (e) {
      debugPrint('selectFromGallery error: $e');
    }
  }

  void saveGeneral() async {
    final context = Get.context;
    if (context == null) return;
    try {
      DialogHelper.showLoading();
      var map = <String, dynamic>{};
      map['first_name'] = firstNameController.text;
      map['last_name'] = lastNameController.text;
      map['nickname'] = nicknameController.text;
      map['description'] = bioController.text;
      if (!kIsWeb &&
          selectedImage != null &&
          !Helper.checkHttpOrHttps(selectedImage!.path)) {
        map['lp_avatar_file'] = File(selectedImage!.path);
      }
      Response response = await parser.submitGeneral(map);
      await Future.delayed(Duration(seconds: 1), () {
        if (response.status.isOk) {
          DialogHelper.hideLoading();
          if (response.body["code"] != null) {
            Alert(
              context: context,
              title: response.body['message'],
              buttons: [
                DialogButton(
                  child: Text(
                    tr(LocaleKeys.alert_cancel),
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500),
                  ),
                  onPressed: () => {Navigator.pop(context)},
                ),
              ],
            ).show();
          } else {
            parser.updateUserDataSharedPreferencesManager();
            refresh();
            update();
            Alert(
              context: context,
              title: tr(LocaleKeys.settings_save),
              buttons: [
                DialogButton(
                  child: Text(
                    tr(LocaleKeys.alert_cancel),
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500),
                  ),
                  onPressed: () => {Navigator.pop(context)},
                ),
              ],
            ).show();
          }
        } else {
          DialogHelper.hideLoading();
          Alert(
            context: context,
            title: response.body['message'],
            buttons: [
              DialogButton(
                child: Text(
                  tr(LocaleKeys.alert_cancel),
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w500),
                ),
                onPressed: () => {Navigator.pop(context)},
              ),
            ],
          ).show();
        }
      });
    } catch (e) {
      debugPrint('$e');
    } finally {
      DialogHelper.hideLoading();
    }
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    deletePasswordController.dispose();
    nicknameController.dispose();
    bioController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.onClose();
  }
}
