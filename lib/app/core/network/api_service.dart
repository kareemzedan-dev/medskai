/// API Service
///
/// Clean, organized HTTP client for API communication.
/// Uses GetX Response for backwards compatibility.
///
/// Usage:
/// ```dart
/// final api = Get.find<ApiService>();
/// final response = await api.get(ApiEndpoints.courses.list);
/// ```
library api_service;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

/// API Service - HTTP Client
class ApiService extends GetxService {
  /// Base URL for API requests
  final String appBaseUrl;

  /// Connection error status text (internal — not shown to users directly)
  static const String connectionError = 'connection_error';

  /// Create ApiService with base URL
  ApiService({required this.appBaseUrl});

  /// Create ApiService with current config
  factory ApiService.fromConfig() {
    return ApiService(appBaseUrl: ApiConfig.baseUrl);
  }

  // ============================================================
  // GET Requests
  // ============================================================

  /// GET request with full URL (no base URL prepended)
  Future<Response> get(String uri, Map<String, dynamic>? params) async {
    final queryString = _buildQueryString(params);
    final url = Uri.parse(uri + queryString);

    ApiConfig.logRequest('GET', url.toString());

    try {
      final response = await http.get(url, headers: {
        'Content-Type': ApiConfig.contentTypeJson
      }).timeout(Duration(seconds: ApiConfig.timeoutSeconds));
      return _parseResponse(response, uri);
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// GET request to public endpoint (no auth required)
  Future<Response> getPublic(String uri, Map<String, dynamic>? params) async {
    final queryString = _buildQueryString(params);
    final url = Uri.parse(appBaseUrl + uri + queryString);

    ApiConfig.logRequest('GET', url.toString());

    try {
      final response = await http
          .get(url, headers: ApiConfig.publicHeaders)
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));
      return _parseResponse(response, uri);
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// GET request to private endpoint (auth required)
  Future<Response> getPrivate(
    String uri,
    String token,
    Map<String, dynamic>? params,
  ) async {
    final queryString = _buildQueryString(params);
    final url = Uri.parse('$appBaseUrl$uri$queryString');

    ApiConfig.logRequest('GET', url.toString());

    try {
      final response = await http
          .get(url, headers: ApiConfig.authHeaders(token))
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));
      return _parseResponse(response, uri);
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// GET request to private endpoint v2 (with learned parameter)
  Future<Response> getPrivateV2(
    String uri,
    String token,
    Map<String, dynamic>? params,
  ) async {
    final queryString = _buildQueryString(params);
    final url = Uri.parse('$appBaseUrl$uri?learned=true$queryString');

    ApiConfig.logRequest('GET', url.toString());

    try {
      final response = await http
          .get(url, headers: ApiConfig.authHeaders(token))
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));
      return _parseResponse(response, uri);
    } catch (e) {
      return _errorResponse(e);
    }
  }

  // ============================================================
  // POST Requests
  // ============================================================

  /// POST request to public endpoint
  Future<Response> postPublic(
    String uri,
    dynamic body, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse(appBaseUrl + uri);

    ApiConfig.logRequest('POST', url.toString());

    try {
      final response = await http
          .post(
            url,
            headers: ApiConfig.publicHeaders,
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));
      return _parseResponse(response, uri);
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// POST request to private endpoint
  Future<Response> postPrivate(
    String uri,
    dynamic body,
    String token,
  ) async {
    final url = Uri.parse(appBaseUrl + uri);

    ApiConfig.logRequest('POST', url.toString());

    try {
      final response = await http
          .post(
            url,
            headers: ApiConfig.authHeaders(token),
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));
      return _parseResponse(response, uri);
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// POST multipart request (for file uploads)
  Future<Response> postPrivateMultipart(
    String uri,
    dynamic body,
    String token,
  ) async {
    final url = Uri.parse(appBaseUrl + uri);

    ApiConfig.logRequest('POST MULTIPART', url.toString());

    try {
      var request = http.MultipartRequest('POST', url);
      request = _jsonToFormData(request, body);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'x-platform': ApiConfig.platformHeader,
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _parseResponse(response, uri);
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// Upload files for assignment
  Future<Response> uploadFilesAssignment(
    String uri,
    Map<String, dynamic>? param,
    String token,
  ) async {
    final url = Uri.parse(appBaseUrl + uri);

    ApiConfig.logRequest('UPLOAD', url.toString());

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(ApiConfig.authHeaders(token));

      // Add form fields
      request.fields['id'] = param!['id'].toString();
      request.fields['note'] = param['note'];
      request.fields['action'] = param['action'];

      // Add files
      if (param['files'] != null && param['files'] is List && (param['files'] as List).isNotEmpty) {
        for (int i = 0; i < param['files'].length; i++) {
          request.files.add(
            await http.MultipartFile.fromPath('file[]', param['files'][i].path),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _parseResponse(response, uri);
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// Logout request
  Future<Response> logout(String uri, String token) async {
    final url = Uri.parse(appBaseUrl + uri);

    ApiConfig.logRequest('POST', url.toString());

    try {
      final response = await http
          .post(url, headers: ApiConfig.authHeaders(token))
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));
      return _parseResponse(response, uri);
    } catch (e) {
      return _errorResponse(e);
    }
  }

  // ============================================================
  // Helper Methods
  // ============================================================

  /// Build query string from parameters
  String _buildQueryString(Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) return '';
    return '?${Uri(queryParameters: params).query}';
  }

  /// Convert JSON body to form data for multipart requests
  http.MultipartRequest _jsonToFormData(
    http.MultipartRequest request,
    Map<String, dynamic> data,
  ) {
    for (var key in data.keys) {
      if (key != 'lp_avatar_file') {
        request.fields[key] = data[key].toString();
      } else {
        File file = data[key];
        request.files.add(http.MultipartFile(
          key,
          file.readAsBytes().asStream(),
          file.lengthSync(),
          filename: file.path.split('/').last,
        ));
      }
    }
    return request;
  }

  /// Parse HTTP response to GetX Response
  Response _parseResponse(http.Response res, String uri) {
    dynamic body;
    try {
      body = jsonDecode(res.body);
    } catch (e) {
      // Body is not JSON
    }

    ApiConfig.logResponse(res.statusCode, uri);

    var response = Response(
      body: body ?? res.body,
      bodyString: res.body,
      headers: res.headers,
      statusCode: res.statusCode,
      statusText: res.reasonPhrase,
    );

    // Handle error responses
    if (response.statusCode != 200 &&
        response.body != null &&
        response.body is! String) {
      final bodyStr = response.body.toString();
      if (bodyStr.startsWith('{errors: [{code:')) {
        response = Response(
          statusCode: response.statusCode,
          body: response.body,
          statusText: 'error',
        );
      } else if (bodyStr.startsWith('{message')) {
        final bodyMap = response.body as Map<String, dynamic>?;
        response = Response(
          statusCode: response.statusCode,
          body: response.body,
          statusText: bodyMap?['message']?.toString(),
        );
      }
    } else if (response.statusCode != 200 && response.body == null) {
      response = const Response(statusCode: 0, statusText: connectionError);
    }

    return response;
  }

  /// Create error response
  Response _errorResponse(Object e) {
    if (ApiConfig.enableLogging) {
      debugPrint('API Error: $e');
    }
    return const Response(statusCode: 1, statusText: connectionError);
  }
}

/// Multipart body for file uploads
class MultipartBody {
  final String key;
  final dynamic file;

  MultipartBody(this.key, this.file);
}
