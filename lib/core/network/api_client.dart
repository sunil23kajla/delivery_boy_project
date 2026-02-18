import 'dart:convert';
import 'package:http/http.dart' as http;
import '../error/failure.dart';

class ApiClient {
  final String baseUrl;
  final http.Client client;

  ApiClient({required this.baseUrl, required this.client});

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final response = await client.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw AppException(jsonDecode(response.body)['message'] ?? 'Server Error');
    }
  }

  Future<dynamic> get(String endpoint) async {
    final response = await client.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw AppException(jsonDecode(response.body)['message'] ?? 'Server Error');
    }
  }
}
