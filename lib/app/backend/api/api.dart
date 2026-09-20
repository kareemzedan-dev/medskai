// API Service - Legacy File
//
// This file maintains backwards compatibility.
// New code should use:
// ```dart
// import 'package:flutter_app/app/core/network/network.dart';
// ```

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// Re-export from core for new imports
export '../../core/network/api_service.dart';
export '../../core/network/api_config.dart';
export '../../core/network/api_endpoints.dart';

/// @Deprecated('Use ApiService from core/network instead')
class ApiService extends GetxService {
  final String appBaseUrl;
  static const String connectionIssue = 'Connection failed!';
  final int timeoutInSeconds = 30;

  ApiService({required this.appBaseUrl});

  Future<Response> get(String uri, Map<String, dynamic>? params) async {
    String queryString = '';
    if (params != null && params.isNotEmpty) {
      final bool hasQueryParams = uri.contains('?');
      final String separator = hasQueryParams ? '&' : '?';
      queryString = "$separator${Uri(queryParameters: params).query}";
    }
    final Uri url = Uri.parse(uri + queryString);

    try {
      http.Response response = await http.get(url, headers: {
        'Content-Type': 'application/json;'
      }).timeout(Duration(seconds: timeoutInSeconds));
      return parseResponse(response, uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: connectionIssue);
    }
  }

  Future<Response> getPublic(String uri, Map<String, dynamic>? params,
      {Map<String, String>? headers}) async {
    String queryString = '';
    if (params != null && params.isNotEmpty) {
      final bool hasQueryParams = uri.contains('?');
      final String separator = hasQueryParams ? '&' : '?';
      queryString = "$separator${Uri(queryParameters: params).query}";
    }
    final Uri url = Uri.parse(appBaseUrl + uri + queryString);
    debugPrint('uri: $url');

    try {
      http.Response response = await http.get(url, headers: {
        'Content-Type': 'application/json;',
        'x-platform': 'flutter',
        ...?headers,
      }).timeout(Duration(seconds: timeoutInSeconds));
      return parseResponse(response, uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: connectionIssue);
    }
  }

  Future<Response> getPrivate(
      String uri, String token, Map<String, dynamic>? params) async {
    String queryString = '';
    if (params != null && params.isNotEmpty) {
      final bool hasQueryParams = uri.contains('?');
      final String separator = hasQueryParams ? '&' : '?';
      queryString = "$separator${Uri(queryParameters: params).query}";
    }
    final Uri url = Uri.parse(appBaseUrl + uri + queryString);
    try {
      http.Response response = await http.get(url, headers: {
        'Content-Type': 'application/json;',
        'x-platform': 'flutter',
        'Authorization': 'Bearer $token'
      }).timeout(Duration(seconds: timeoutInSeconds));
      return parseResponse(response, uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: connectionIssue);
    }
  }

  Future<Response> getPrivateV2(String uri, String token, var params) async {
    // Check if uri already has query parameters
    final bool hasQueryParams = uri.contains('?');
    final String separator = hasQueryParams ? '&' : '?';
    String queryString = "${separator}learned=true";
    if (params != null && params is Map && params.isNotEmpty) {
      final Map<String, dynamic> typedParams =
          Map<String, dynamic>.from(params);
      queryString += "&${Uri(queryParameters: typedParams).query}";
    }
    String uriTemp = appBaseUrl + uri + queryString;
    final Uri url = Uri.parse(uriTemp);
    try {
      http.Response response = await http.get(url, headers: {
        'Content-Type': 'application/json;',
        'x-platform': 'flutter',
        'Authorization': 'Bearer $token'
      }).timeout(Duration(seconds: timeoutInSeconds));
      return parseResponse(response, uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: connectionIssue);
    }
  }

  Future<Response> uploadFilesAssignment(
      String uri, Map<String, dynamic>? param, String token) async {
    try {
      http.MultipartRequest request =
          http.MultipartRequest('POST', Uri.parse(appBaseUrl + uri));
      request.headers.addAll({
        'Content-Type': 'application/json;',
        'x-platform': 'flutter',
        'Authorization': 'Bearer $token'
      });

      request.fields['id'] = param!['id'].toString();
      request.fields['note'] = param['note'];
      request.fields['action'] = param['action'];
      if (param['files'] != null && !param['files'].isEmpty) {
        for (int i = 0; i < param['files'].length; i++) {
          request.files.add(await http.MultipartFile.fromPath(
              'file[]', param['files'][i].path));
        }
      }

      http.Response response =
          await http.Response.fromStream(await request.send());
      return parseResponse(response, uri);
    } catch (e) {
      debugPrint('$e');
      return const Response(statusCode: 1, statusText: connectionIssue);
    }
  }

  Future<Response> postPublic(String uri, dynamic body,
      {Map<String, String>? headers}) async {
    final url = appBaseUrl + uri;
    debugPrint('postPublic: Calling $url');
    if (kDebugMode) debugPrint('postPublic: Calling $url');

    try {
      // Use dart:io HttpClient directly for better control
      final httpClient = HttpClient()
        ..connectionTimeout = const Duration(seconds: 30);
      if (kDebugMode) {
        httpClient.badCertificateCallback = (cert, host, port) => true;
      }

      final request = await httpClient.postUrl(Uri.parse(url));
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');
      request.headers.set('x-platform', 'flutter');
      headers?.forEach((key, value) {
        request.headers.set(key, value);
      });
      request.write(body is String ? body : jsonEncode(body));

      final httpResponse = await request.close().timeout(
            Duration(seconds: timeoutInSeconds),
          );

      final responseBody = await httpResponse.transform(utf8.decoder).join();
      debugPrint('postPublic: Response received - ${httpResponse.statusCode}');
      if (kDebugMode) debugPrint('postPublic: ${httpResponse.statusCode}');

      httpClient.close();

      final responseHeaders = <String, String>{};
      httpResponse.headers.forEach((name, values) {
        responseHeaders[name] = values.join(',');
      });

      // Convert to http.Response for parseResponse
      final response = http.Response(
        responseBody,
        httpResponse.statusCode,
        headers: responseHeaders,
      );
      return parseResponse(response, url);
    } on SocketException catch (e) {
      debugPrint('postPublic: SocketException - $e');
      return const Response(
          statusCode: 1, statusText: 'No internet connection');
    } on HandshakeException catch (e) {
      debugPrint('postPublic: HandshakeException (SSL) - $e');
      return const Response(statusCode: 1, statusText: 'SSL Error');
    } on HttpException catch (e) {
      debugPrint('postPublic: HttpException - $e');
      return const Response(statusCode: 1, statusText: connectionIssue);
    } catch (e, stackTrace) {
      debugPrint('postPublic: Error Type - ${e.runtimeType}');
      debugPrint('postPublic: Error - $e');
      debugPrint('postPublic: Stack - $stackTrace');
      return const Response(statusCode: 1, statusText: connectionIssue);
    }
  }

  Future<Response> postPrivate(
    String uri,
    dynamic body,
    String token,
  ) async {
    try {
      http.Response response = await http
          .post(Uri.parse(appBaseUrl + uri), body: jsonEncode(body), headers: {
        'Content-Type': 'application/json',
        'x-platform': 'flutter',
        'Authorization': 'Bearer $token'
      }).timeout(Duration(seconds: timeoutInSeconds));
      return parseResponse(response, uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: connectionIssue);
    }
  }

  Future<Response> postPrivateMultipart(
    String uri,
    dynamic body,
    String token,
  ) async {
    try {
      final url = Uri.parse(appBaseUrl + uri);
      var request = http.MultipartRequest('POST', url);
      request = jsonToFormData(request, body);
      var headers = {
        // 'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $token',
        'x-platform': 'flutter',
      };
      request.headers.addAll(headers);
      http.Response response =
          await http.Response.fromStream(await request.send());

      return parseResponse(response, appBaseUrl + uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: connectionIssue);
    }
  }

  jsonToFormData(http.MultipartRequest request, Map<String, dynamic> data) {
    for (var key in data.keys) {
      if (key != "lp_avatar_file") {
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

  Future<Response> logout(
    String uri,
    String token,
  ) async {
    try {
      http.Response response =
          await http.post(Uri.parse(appBaseUrl + uri), headers: {
        'Content-Type': 'application/json',
        'x-platform': 'flutter',
        'Authorization': 'Bearer $token'
      }).timeout(Duration(seconds: timeoutInSeconds));
      return parseResponse(response, uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: connectionIssue);
    }
  }

  Response parseResponse(http.Response res, String uri) {
    dynamic body;
    try {
      body = jsonDecode(res.body);
    } catch (e) {
      debugPrint('$e');
    }
    Response response = Response(
      body: body != '' ? body : res.body,
      bodyString: res.body.toString(),
      headers: res.headers,
      statusCode: res.statusCode,
      statusText: res.reasonPhrase,
    );

    if (response.statusCode != 200 &&
        response.body != null &&
        response.body is! String) {
      if (response.body.toString().startsWith('{errors: [{code:')) {
        response = Response(
            statusCode: response.statusCode,
            body: response.body,
            statusText: 'error');
      } else if (response.body.toString().startsWith('{message')) {
        response = Response(
            statusCode: response.statusCode,
            body: response.body,
            statusText: response.body['message']);
      }
    } else if (response.statusCode != 200 && response.body == null) {
      response = const Response(statusCode: 0, statusText: connectionIssue);
    }
    return response;
  }
}

class MultipartBody {
  String key;
  XFile file;

  MultipartBody(this.key, this.file);
}
