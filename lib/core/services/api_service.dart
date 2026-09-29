import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/app_constants.dart';
import '../error/exceptions.dart';

class ApiService {
  final http.Client client;

  ApiService({required this.client});

  /// Generic GET request
  Future<dynamic> get({required String endpoint, String? token}) async {
    try {
      final headers = _getHeaders(token: token);
      final url = Uri.parse(endpoint);

      final response = await client
          .get(url, headers: headers)
          .timeout(
            const Duration(milliseconds: AppConstants.connectionTimeout),
            onTimeout: () => throw NetworkException(message: 'Request timeout'),
          );

      return _handleResponse(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(message: 'Unable to reach the API: $e');
    }
  }

  /// Generic POST request
  Future<dynamic> post({
    required String endpoint,
    required Map<String, dynamic> body,
    String? token,
  }) async {
    try {
      final headers = _getHeaders(token: token);
      final url = Uri.parse(endpoint);

      final response = await client
          .post(url, headers: headers, body: jsonEncode(body))
          .timeout(
            const Duration(milliseconds: AppConstants.connectionTimeout),
            onTimeout: () => throw NetworkException(message: 'Request timeout'),
          );

      return _handleResponse(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(message: 'Unable to reach the API: $e');
    }
  }

  /// Generic PUT request
  Future<dynamic> put({
    required String endpoint,
    required Map<String, dynamic> body,
    String? token,
  }) async {
    try {
      final headers = _getHeaders(token: token);
      final url = Uri.parse(endpoint);

      final response = await client
          .put(url, headers: headers, body: jsonEncode(body))
          .timeout(
            const Duration(milliseconds: AppConstants.connectionTimeout),
            onTimeout: () => throw NetworkException(message: 'Request timeout'),
          );

      return _handleResponse(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(message: 'Unable to reach the API: $e');
    }
  }

  /// Generic DELETE request
  Future<dynamic> delete({required String endpoint, String? token}) async {
    try {
      final headers = _getHeaders(token: token);
      final url = Uri.parse(endpoint);

      final response = await client
          .delete(url, headers: headers)
          .timeout(
            const Duration(milliseconds: AppConstants.connectionTimeout),
            onTimeout: () => throw NetworkException(message: 'Request timeout'),
          );

      return _handleResponse(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(message: 'Unable to reach the API: $e');
    }
  }

  /// Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body);
      case 400:
        throw ServerException(message: 'Bad request', code: '400');
      case 401:
        throw AuthenticationException(message: 'Unauthorized access');
      case 403:
        throw AuthenticationException(message: 'Access forbidden');
      case 404:
        throw ServerException(message: 'Resource not found', code: '404');
      case 500:
        throw ServerException(message: 'Internal server error', code: '500');
      default:
        throw ServerException(
          message: 'Unknown error occurred',
          code: response.statusCode.toString(),
        );
    }
  }

  /// Get headers with optional token
  Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

}
