import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ige_hospital/constants/api_endpoints.dart';
import 'package:ige_hospital/provider/auth_service.dart';
import 'package:ige_hospital/routes.dart';

/// A custom HTTP client that handles authentication and token refreshing
class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  HttpClient._internal();

  final AuthService _authService = Get.find<AuthService>();

  /// Checks if the token is expired or about to expire (within 5 minutes)
  bool _isTokenExpired() {
    if (_authService.tokenExpiration.value.isEmpty) return true;

    try {
      final int timestamp = int.parse(_authService.tokenExpiration.value);
      final expiration = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      final now = DateTime.now();

      return now.isAfter(expiration.subtract(const Duration(minutes: 5)));
    } catch (e) {
      Get.log("Error parsing token expiration: $e");
      return true;
    }
  }

  /// Attempts to validate and refresh the token
  Future<bool> _validateToken() async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.validateToken),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${_authService.token.value}",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["status"] == 200 && data["data"] != null) {
          // Update token expiration time
          await _authService.updateTokenExpiration(data["data"]["token_expiration"] ?? "");
          return true;
        }
      }
      return false;
    } catch (e) {
      Get.log("Token validation failed: $e");
      return false;
    }
  }

  /// Make a GET request with authentication
  Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    return _executeRequest(() => http.get(
      Uri.parse(url),
      headers: _addAuthHeader(headers),
    ));
  }

  /// Make a POST request with authentication
  Future<http.Response> post(String url, {Map<String, String>? headers, dynamic body}) async {
    return _executeRequest(() => http.post(
      Uri.parse(url),
      headers: _addAuthHeader(headers),
      body: body,
    ));
  }

  /// Make a PUT request with authentication
  Future<http.Response> put(String url, {Map<String, String>? headers, dynamic body}) async {
    return _executeRequest(() => http.put(
      Uri.parse(url),
      headers: _addAuthHeader(headers),
      body: body,
    ));
  }

  /// Make a DELETE request with authentication
  Future<http.Response> delete(String url, {Map<String, String>? headers}) async {
    return _executeRequest(() => http.delete(
      Uri.parse(url),
      headers: _addAuthHeader(headers),
    ));
  }

  /// Add authorization header to request headers
  Map<String, String> _addAuthHeader(Map<String, String>? headers) {
    final Map<String, String> authHeaders = headers ?? {};
    if (_authService.token.value.isNotEmpty) {
      authHeaders["Authorization"] = "Bearer ${_authService.token.value}";
    }
    return authHeaders;
  }

  /// Execute HTTP request with token validation and error handling
  Future<http.Response> _executeRequest(Future<http.Response> Function() requestFunc) async {
    if (_authService.token.value.isEmpty || !_authService.isAuthenticated.value) {
      throw Exception("Not authenticated");
    }

    // Check if token is expired or about to expire
    if (_isTokenExpired()) {
      // Try to refresh the token
      final refreshed = await _validateToken();
      if (!refreshed) {
        // If refresh failed, logout and redirect to login
        await _authService.logout();
        Get.offAllNamed(Routes.login);
        throw Exception("Authentication expired");
      }
    }

    // Execute the actual request
    final response = await requestFunc();

    // Handle authentication errors
    if (response.statusCode == 401 || response.statusCode == 403) {
      // Try to refresh token one more time
      final refreshed = await _validateToken();
      if (refreshed) {
        // Retry the request
        return await requestFunc();
      } else {
        // If refresh failed, logout and redirect to login
        await _authService.logout();
        Get.offAllNamed(Routes.login);
        throw Exception("Authentication expired during request");
      }
    }

    return response;
  }
}