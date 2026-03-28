import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constants/app_routes.dart';
import '../services/session_service.dart';

class ApiClient {
  final String baseUrl;
  final http.Client client;
  final Duration timeout = const Duration(seconds: 30);

  ApiClient({required this.baseUrl, required this.client});

  Map<String, String> _getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Connection': 'close',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> post(String endpoint,
      {Map<String, dynamic>? body, String? token}) async {
    final url = '$baseUrl$endpoint';
    final headers = _getHeaders(token);
    final encodedBody = body != null ? jsonEncode(body) : null;

    try {
      _logRequest('POST', url, headers, encodedBody);
      final response = await client
          .post(
            Uri.parse(url),
            headers: headers,
            body: encodedBody,
          )
          .timeout(timeout);
      _logResponse(response);
      return _processResponse(response);
    } on SocketException catch (e) {
      return {
        'success': false,
        'message': "Network Error (${e.message}). Please check ISP/WiFi."
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': "Request timed out. Please try again."
      };
    } catch (e) {
      return {
        'success': false,
        'message': "An unexpected error occurred: ${e.toString()}"
      };
    }
  }

  Future<dynamic> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    List<MapEntry<String, File>>? files,
    String? token,
  }) async {
    final url = '$baseUrl$endpoint';

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers['Accept'] = 'application/json, text/plain, */*';
      request.headers['User-Agent'] = 'insomnia/11.0.0';
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields.addAll(fields);

      if (files != null) {
        for (var fileEntry in files) {
          final file = fileEntry.value;
          if (await file.exists()) {
            final size = await file.length();
            debugPrint(
                "📤 [Multipart] Adding File: ${fileEntry.key} -> ${file.path} ($size bytes)");
            request.files.add(
              await http.MultipartFile.fromPath(
                fileEntry.key,
                file.path,
              ),
            );
          }
        }
      }

      _logRequest('POST (Multipart)', url, request.headers, fields,
          files: files?.map((e) => "${e.key}: ${e.value.path}").toList());

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);
      _logResponse(response);
      return _processResponse(response);
    } on SocketException catch (e) {
      return {
        'success': false,
        'message': "Network Error (${e.message}). Please check ISP/WiFi."
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': "Request timed out. Please try again."
      };
    } catch (e) {
      return {
        'success': false,
        'message': "An unexpected error occurred: ${e.toString()}"
      };
    }
  }

  Future<dynamic> get(String endpoint, {String? token}) async {
    final url = '$baseUrl$endpoint';
    final headers = _getHeaders(token);

    int retries = 0;
    while (true) {
      try {
        if (retries == 0) _logRequest('GET', url, headers, null);
        final response = await client
            .get(
              Uri.parse(url),
              headers: headers,
            )
            .timeout(timeout);
        _logResponse(response);
        return _processResponse(response);
      } on SocketException catch (e) {
        return {
          'success': false,
          'message': "Network Error (${e.message}). Please check ISP/WiFi."
        };
      } on TimeoutException {
        return {
          'success': false,
          'message': "Request timed out. Please try again."
        };
      } catch (e) {
        if (e.toString().contains('Connection closed before full header') &&
            retries < 2) {
          retries++;
          await Future.delayed(const Duration(milliseconds: 500));
          continue; // Retry the request
        }
        return {
          'success': false,
          'message': "An unexpected error occurred: ${e.toString()}"
        };
      }
    }
  }

  dynamic _processResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {
      // If server returns HTML instead of JSON (common on 500 errors)
      return {'success': false, 'message': "Invalid server response format"};
    }

    if (response.statusCode >= 200 && response.statusCode < 500) {
      if (response.statusCode == 401) {
        // Global Unauthorized Handling
        Get.find<SessionService>().clearSession();
        Get.offAllNamed(AppRoutes.login);
        return {'success': false, 'message': "SESSION_EXPIRED"};
      }
      return body;
    } else {
      final errorMsg = body != null && body is Map<String, dynamic>
          ? (body['message'] ?? 'Server Error (${response.statusCode})')
          : 'Server Error (${response.statusCode})';
      return {'success': false, 'message': errorMsg};
    }
  }

  void _logRequest(
      String method, String url, Map<String, String> headers, dynamic body,
      {List<String>? files}) {
    debugPrint('🚀 [API REQ] $method: $url');
    // debugPrint('Headers: $headers'); // Optional
    if (body != null) debugPrint('Body: $body');
    if (files != null && files.isNotEmpty) debugPrint('Files: $files');
  }

  void _logResponse(http.Response response) {
    debugPrint('✅ [API RES] ${response.statusCode} | ${response.request?.url}');
    dev.log(response.body, name: 'API_RESPONSE');
    dev.log('--- API RESPONSE END ---');
  }

  String _getMimeType(String filePath) {
    if (filePath.endsWith('.jpg') || filePath.endsWith('.jpeg')) {
      return 'image/jpeg';
    } else if (filePath.endsWith('.png')) {
      return 'image/png';
    } else if (filePath.endsWith('.gif')) {
      return 'image/gif';
    } else if (filePath.endsWith('.pdf')) {
      return 'application/pdf';
    }
    return 'application/octet-stream';
  }
}
