import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:flutter_app/app/helper/dialog_helper.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:rate_limiter/rate_limiter.dart';

import '../backend/parse/payment_parse.dart';
import '../util/theme.dart';
import '../util/toast.dart';
import '../helper/router.dart';

class PaymentController extends GetxController implements GetxService {
  final PaymentParser parser;
  StreamSubscription<dynamic>? _subscription;
  final InAppPurchase _connection = InAppPurchase.instance;
  String receiptData = "";
  String _productId = "";

  PaymentController({required this.parser});

  void _setupPurchaseListener() {
    _subscription?.cancel();
    Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (error) {
      debugPrint('Purchase stream error: $error');
      DialogHelper.hideLoading();
      showToast(tr(LocaleKeys.toast_purchaseError), isError: true);
    });
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    final context = Get.context;
    if (context == null) return;
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        DialogHelper.showLoading();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          Alert(
                  context: context,
                  title: tr(LocaleKeys.error),
                  desc: tr(LocaleKeys.toast_unexpectedResponse))
              .show();
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          DialogHelper.hideLoading();

          bool valid = await verifyPurchase(purchaseDetails);

          if (valid) {
            final throttledFunction = handleCheckVerifyReceipt.throttled(
              const Duration(seconds: 5),
            );
            throttledFunction();
          }
        }
        if (purchaseDetails.status == PurchaseStatus.canceled) {
          DialogHelper.hideLoading();
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    });
  }

  Future<void> handleCheckVerifyReceipt() async {
    final context = Get.context;
    try {
      final response = await parser.checkCourse(
        receiptData,
        defaultTargetPlatform == TargetPlatform.iOS,
        _productId,
      );
      if (response.statusCode == 200 &&
          response.body is Map &&
          response.body['status'] == "success") {
        // Success - navigate to course
        showToast(tr(LocaleKeys.toast_purchaseSuccess), isError: false);
        Get.toNamed(AppRouter.getCourseDetailRoute(),
            arguments: [_productId.toString(), "reloadPage"],
            preventDuplicates: false);
      } else {
        // Verification failed
        debugPrint('Receipt verification failed: ${response.body}');
        if (context != null) {
          Alert(
            context: context,
            title: tr(LocaleKeys.error),
            desc: tr(LocaleKeys.toast_purchaseVerificationFailed),
            buttons: [
              DialogButton(
                child: Text(tr(LocaleKeys.common_ok),
                    style: const TextStyle(color: MedsKaiColors.white)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ).show();
        }
      }
    } catch (e) {
      debugPrint('handleCheckVerifyReceipt error: $e');
      showToast(tr(LocaleKeys.toast_purchaseError), isError: true);
    } finally {
      if (!isClosed) {
        refresh();
        update();
      }
    }
  }

  Future<bool> verifyPurchase(PurchaseDetails purchaseDetails) async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final localDataVerification =
            json.decode(purchaseDetails.verificationData.localVerificationData)
                as Map<String, dynamic>;
        final productId = localDataVerification['productId'] as String;
        receiptData = purchaseDetails.verificationData.localVerificationData;
        _productId = productId;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final appStorePurchaseDetails =
            purchaseDetails as AppStorePurchaseDetails;
        final paymentToken =
            appStorePurchaseDetails.verificationData.localVerificationData;

        final productId = purchaseDetails.productID;
        receiptData = paymentToken;
        _productId = productId;
      }
    } catch (e) {
      debugPrint('verifyPurchase error: $e');
      return Future<bool>.value(false);
    }

    return Future<bool>.value(true);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<void> handleRestoreCourse() async {
    final context = Get.context;
    if (context == null) return;
    if (parser.getToken() == "") {
      Alert(
        context: context,
        title: tr(LocaleKeys.alert_notLoggedIn),
        desc: tr(LocaleKeys.alert_loggedIn),
        buttons: [
          DialogButton(
            color: MedsKaiColors.error,
            child: Text(
              tr(LocaleKeys.alert_cancel),
              style: TextStyle(
                color: MedsKaiColors.white,
              ),
            ),
            onPressed: () => {Navigator.pop(context)},
          ),
          DialogButton(
            child: Text(
              tr(LocaleKeys.alert_btnLogin),
              style: TextStyle(
                color: MedsKaiColors.white,
              ),
            ),
            onPressed: () => {
              Navigator.pop(context),
              Get.offAllNamed(AppRouter.getLoginRoute())
            },
          ),
        ],
      ).show();
    } else {
      // Setup listener first, then restore
      _setupPurchaseListener();
      DialogHelper.showLoading();

      try {
        await InAppPurchase.instance.restorePurchases();
        // Note: Results will come through the purchase stream listener
        // Show info message that restore is in progress
        DialogHelper.hideLoading();
        showToast(tr(LocaleKeys.toast_restoreInProgress), isError: false);
      } catch (e) {
        DialogHelper.hideLoading();
        debugPrint('Restore purchases error: $e');
        Alert(
          context: context,
          title: tr(LocaleKeys.error),
          desc: tr(LocaleKeys.alert_restorePurchasesError),
          buttons: [
            DialogButton(
              child: Text(
                tr(LocaleKeys.common_ok),
                style: const TextStyle(color: MedsKaiColors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ).show();
      }
    }
  }

  Future<void> buyProduct(ProductDetails prod) async {
    final context = Get.context;
    if (context == null) return;
    if (parser.getToken() == "") {
      Alert(
        context: context,
        title: tr(LocaleKeys.alert_notLoggedIn),
        desc: tr(LocaleKeys.alert_loggedIn),
        buttons: [
          DialogButton(
            color: MedsKaiColors.error,
            child: Text(
              tr(LocaleKeys.alert_cancel),
              style: TextStyle(
                color: MedsKaiColors.white,
              ),
            ),
            onPressed: () => {Navigator.pop(context)},
          ),
          DialogButton(
            child: Text(
              tr(LocaleKeys.alert_btnLogin),
              style: TextStyle(
                color: MedsKaiColors.white,
              ),
            ),
            onPressed: () => {
              Navigator.pop(context),
              Get.offAllNamed(AppRouter.getLoginRoute())
            },
          ),
        ],
      ).show();
    } else {
      final bool isAvailable = await InAppPurchase.instance.isAvailable();
      final Set<String> ids = {prod.id.toString()};
      final ProductDetailsResponse response =
          await InAppPurchase.instance.queryProductDetails(ids);
      _setupPurchaseListener();
      if (response.notFoundIDs.isNotEmpty) {
        final context = Get.context;
        if (context == null) return;
        Alert(
                context: context,
                title: tr(LocaleKeys.error),
                desc: tr(LocaleKeys.toast_unexpectedResponse))
            .show();
      } else {
        final bool isAvailable = await _connection.isAvailable();

        if (isAvailable) {
          if (defaultTargetPlatform == TargetPlatform.iOS) {
            final PurchaseParam purchaseParam =
                PurchaseParam(productDetails: prod);
            await _connection.buyConsumable(purchaseParam: purchaseParam);
          } else {
            final PurchaseParam purchaseParam =
                PurchaseParam(productDetails: prod);
            await InAppPurchase.instance.buyConsumable(
                purchaseParam: purchaseParam, autoConsume: false);
          }
        }
      }
    }
  }
}
