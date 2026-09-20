import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../backend/models/cart_model.dart';
import '../backend/parse/cart_parse.dart';

class CartController extends GetxController implements GetxService {
  final CartParser parser;

  CartController({required this.parser});

  CartModel? _cart;
  CartModel? get cart => _cart;

  bool isLoading = false;
  bool isAddingItem = false;
  bool isApplyingCoupon = false;
  bool isCheckingOut = false;
  bool hasError = false;
  String errorMessage = '';
  String couponMessage = '';
  bool couponSuccess = false;

  int get itemCount => _cart?.itemsCount ?? 0;
  bool get isEmpty => _cart?.isEmpty ?? true;

  Future<void> loadCart() async {
    isLoading = true;
    hasError = false;
    update();

    try {
      final response = await parser.getCart();
      if (response.statusCode == 200 && response.body is Map) {
        _cart = CartModel.fromJson(response.body);
      }
    } catch (e) {
      hasError = true;
      errorMessage = e.toString();
      debugPrint('loadCart error: $e');
    }

    isLoading = false;
    update();
  }

  Future<bool> addItem(int productId) async {
    isAddingItem = true;
    update();

    try {
      final response = await parser.addItem(productId);
      if (response.statusCode == 200 && response.body is Map) {
        _cart = CartModel.fromJson(response.body);
        isAddingItem = false;
        update();
        return true;
      }
    } catch (e) {
      debugPrint('addItem error: $e');
    }

    isAddingItem = false;
    update();
    return false;
  }

  Future<bool> removeItem(String key) async {
    try {
      final response = await parser.removeItem(key);
      if (response.statusCode == 200 && response.body is Map) {
        _cart = CartModel.fromJson(response.body);
        update();
        return true;
      }
    } catch (e) {
      debugPrint('removeItem error: $e');
    }
    return false;
  }

  Future<void> applyCoupon(String code) async {
    isApplyingCoupon = true;
    couponMessage = '';
    update();

    try {
      final response = await parser.applyCoupon(code);
      if (response.statusCode == 200 && response.body is Map) {
        _cart = CartModel.fromJson(response.body);
        couponSuccess = true;
        couponMessage = 'Coupon applied successfully';
      } else {
        couponSuccess = false;
        final body = response.body;
        couponMessage = body is Map ? (body['message']?.toString() ?? 'Invalid coupon') : 'Invalid coupon';
      }
    } catch (e) {
      couponSuccess = false;
      couponMessage = 'Failed to apply coupon';
      debugPrint('applyCoupon error: $e');
    }

    isApplyingCoupon = false;
    update();
  }

  Future<void> removeCoupon(String code) async {
    try {
      final response = await parser.removeCoupon(code);
      if (response.statusCode == 200 && response.body is Map) {
        _cart = CartModel.fromJson(response.body);
        couponMessage = '';
        update();
      }
    } catch (e) {
      debugPrint('removeCoupon error: $e');
    }
  }

  Future<bool> checkout(Map<String, dynamic> checkoutData) async {
    isCheckingOut = true;
    update();

    try {
      final response = await parser.checkout(checkoutData);
      if (response.statusCode == 200) {
        _cart = CartModel();
        isCheckingOut = false;
        update();
        return true;
      }
    } catch (e) {
      debugPrint('checkout error: $e');
    }

    isCheckingOut = false;
    update();
    return false;
  }
}
