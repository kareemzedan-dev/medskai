import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/api/api.dart';
import 'package:flutter_app/app/helper/shared_pref.dart';
import 'package:get/get.dart';

class CartParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  CartParser(
      {required this.apiService, required this.sharedPreferencesManager});

  String _getCartToken() {
    return sharedPreferencesManager.getString('cart_token') ?? '';
  }

  Future<void> _saveCartToken(String token) async {
    await sharedPreferencesManager.putString('cart_token', token);
  }

  Future<void> _captureCartToken(Response response) async {
    final headers = response.headers;
    if (headers == null) return;
    final token = headers['cart-token'] ??
        headers['Cart-Token'] ??
        headers['woocommerce-cart-token'];
    if (token != null && token.toString().isNotEmpty) {
      await _saveCartToken(token.toString());
    }
  }

  Map<String, String> _cartHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final cartToken = _getCartToken();
    if (cartToken.isNotEmpty) {
      headers['Cart-Token'] = cartToken;
    }
    return headers;
  }

  Future<Response> getCart() async {
    try {
      var response = await apiService.getPublic(
        ApiEndpoints.cart.get,
        null,
        headers: _cartHeaders(),
      );
      await _captureCartToken(response);
      return response;
    } catch (e) {
      debugPrint('getCart error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> addItem(int productId, {int quantity = 1}) async {
    try {
      var response = await apiService.postPublic(
        ApiEndpoints.cart.addItem,
        jsonEncode({'id': productId, 'quantity': quantity}),
        headers: _cartHeaders(),
      );
      await _captureCartToken(response);
      return response;
    } catch (e) {
      debugPrint('addItem error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> removeItem(String key) async {
    try {
      var response = await apiService.postPublic(
        ApiEndpoints.cart.removeItem,
        jsonEncode({'key': key}),
        headers: _cartHeaders(),
      );
      await _captureCartToken(response);
      return response;
    } catch (e) {
      debugPrint('removeItem error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> applyCoupon(String code) async {
    try {
      var response = await apiService.postPublic(
        ApiEndpoints.cart.applyCoupon,
        jsonEncode({'code': code}),
        headers: _cartHeaders(),
      );
      await _captureCartToken(response);
      return response;
    } catch (e) {
      debugPrint('applyCoupon error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> removeCoupon(String code) async {
    try {
      var response = await apiService.postPublic(
        ApiEndpoints.cart.removeCoupon,
        jsonEncode({'code': code}),
        headers: _cartHeaders(),
      );
      await _captureCartToken(response);
      return response;
    } catch (e) {
      debugPrint('removeCoupon error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> checkout(Map<String, dynamic> checkoutData) async {
    try {
      var response = await apiService.postPublic(
        ApiEndpoints.cart.checkout,
        jsonEncode(checkoutData),
        headers: _cartHeaders(),
      );
      await _captureCartToken(response);
      return response;
    } catch (e) {
      debugPrint('checkout error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  String getToken() {
    return sharedPreferencesManager.getString('token') ?? "";
  }
}
