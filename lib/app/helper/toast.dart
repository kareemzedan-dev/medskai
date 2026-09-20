import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_app/app/util/theme.dart';

void showToast(String message, {bool isError = true}) {
  HapticFeedback.lightImpact();
  Get.showSnackbar(GetSnackBar(
    backgroundColor: isError ? MedsKaiColors.error : MedsKaiColors.textPrimary,
    message: message.tr,
    duration: const Duration(seconds: 3),
    snackStyle: SnackStyle.FLOATING,
    margin: const EdgeInsets.all(10),
    borderRadius: 10,
    isDismissible: true,
    dismissDirection: DismissDirection.horizontal,
  ));
}

void successToast(String message) {
  HapticFeedback.lightImpact();
  Get.showSnackbar(GetSnackBar(
    backgroundColor: MedsKaiColors.success,
    message: message.tr,
    duration: const Duration(seconds: 3),
    snackStyle: SnackStyle.FLOATING,
    margin: const EdgeInsets.all(10),
    borderRadius: 10,
    isDismissible: true,
    dismissDirection: DismissDirection.horizontal,
  ));
}

Future<bool> clearCartAlert() async {
  HapticFeedback.lightImpact();
  bool clean = false;
  await Get.generalDialog(
      pageBuilder: (context, __, ___) => AlertDialog(
            title: const Text('Warning'),
            content: const Text(
                "You already have item's in cart with different grocery store"),
            actions: [
              TextButton(
                onPressed: () {
                  // Navigator.pop(context);
                  clean = false;
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                      color: MedsKaiColors.black,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w500),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigator.pop(context);
                  clean = true;
                },
                child: const Text(
                  'Clear Cart',
                  style: TextStyle(
                      color: MedsKaiColors.primary,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700),
                ),
              )
            ],
          ));
  return clean;
}
