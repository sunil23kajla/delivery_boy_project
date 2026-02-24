import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../error/failure.dart';
import '../services/session_service.dart';
import '../constants/app_routes.dart';

class ApiClient {
  final String baseUrl;
  final http.Client client;
  final Duration timeout = const Duration(seconds: 30);

  ApiClient({required this.baseUrl, required this.client});

  Map<String, String> _getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> post(String endpoint,
      {Map<String, dynamic>? body, String? token}) async {
    final url = '$baseUrl$endpoint';
    final headers = _getHeaders(token);
    final encodedBody = body != null ? jsonEncode(body) : null;

    try {
      final response = await client
          .post(
            Uri.parse(url),
            headers: headers,
            body: encodedBody,
          )
          .timeout(timeout);
      return _processResponse(response);
    } on SocketException {
      throw AppException("No Internet connection or server unreachable");
    } on TimeoutException {
      throw AppException("Request timed out. Please try again.");
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException("An unexpected error occurred");
    }
  }

  Future<dynamic> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    Map<String, File>? files,
    String? token,
  }) async {
    final url = '$baseUrl$endpoint';

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers['Accept'] = 'application/json';
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields.addAll(fields);

      if (files != null) {
        for (var entry in files.entries) {
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, entry.value.path),
          );
        }
      }

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } on SocketException {
      throw AppException("No Internet connection or server unreachable");
    } on TimeoutException {
      throw AppException("Request timed out. Please try again.");
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException("An unexpected error occurred");
    }
  }

  Future<dynamic> get(String endpoint, {String? token}) async {
    final url = '$baseUrl$endpoint';
    final headers = _getHeaders(token);

    try {
      final response = await client
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(timeout);
      return _processResponse(response);
    } on SocketException {
      throw AppException("No Internet connection or server unreachable");
    } on TimeoutException {
      throw AppException("Request timed out. Please try again.");
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException("An unexpected error occurred");
    }
  }

  dynamic _processResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {
      // If server returns HTML instead of JSON (common on 500 errors)
      throw AppException("Invalid server response format");
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else if (response.statusCode == 401) {
      // Global Unauthorized Handling
      Get.find<SessionService>().clearSession();
      Get.offAllNamed(AppRoutes.login);
      throw AppException("Session expired. Please login again.");
    } else {
      final errorMsg =
          body['message'] ?? 'Server Error (${response.statusCode})';
      throw AppException(errorMsg);
    }
  }
}
