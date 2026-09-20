import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Retries failed API calls with exponential backoff.
class RetryPolicy {
  /// Retry a request up to [maxRetries] times with exponential backoff.
  /// Only retries on connection errors (statusCode == 1 or -1).
  static Future<Response> execute(
    Future<Response> Function() request, {
    int maxRetries = 2,
  }) async {
    Response response = await request();
    int attempt = 0;
    while ((response.statusCode == 1 || response.statusCode == -1) && attempt < maxRetries) {
      attempt++;
      final delay = Duration(milliseconds: 1000 * (1 << attempt)); // 2s, 4s
      debugPrint('RetryPolicy: Attempt $attempt after ${delay.inSeconds}s');
      await Future.delayed(delay);
      response = await request();
    }
    return response;
  }
}
