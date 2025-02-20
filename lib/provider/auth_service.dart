import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ige_hospital/static_data/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends GetxService {
  final RxBool isAuthenticated = false.obs;
  final RxString token = ''.obs;

  Future<AuthService> init() async {
    await loadToken();
    return this;
  }

  Future<void> login(String email, String password) async {
    Get.log("Attempting login with email: $email");

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/api/admin/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      Get.log("Login response status: ${response.statusCode}");
      Get.log("Login response body: ${response.body}");

      final data = jsonDecode(response.body);
      final int status = data["status"] ?? 500;
      final String message = data["message"] ?? 'An error occurred';

      if (response.statusCode == 200) {
        if (status == 200) {
          final String accessToken = data["data"]["token"] ?? "";
          final String tokenExpiration = "";

          final user = {
            "id": data["data"]["admin"]["id"].toString(),
            "name": data["data"]["admin"]["name"] ?? "",
            "email": data["data"]["admin"]["email"] ?? "",
            "phone_number": data["data"]["admin"]["phone_number"] ?? "",
            "otp_generated_at": data["data"]["admin"]["otp_generated_at"] ?? "",
          };

          await _saveSession(accessToken, tokenExpiration, user);

          Get.offAllNamed(Routes.homepage);
          Get.snackbar("Success", message, snackPosition: SnackPosition.BOTTOM);
        } else {
          Get.snackbar("Error", message, snackPosition: SnackPosition.BOTTOM);
        }
      } else {
        Get.snackbar("Error", message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.log("Login error: $e");
      Get.snackbar("Error", "Something went wrong", snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> logout() async {
    await _clearSession();

    Get.offAllNamed('/login');
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token.value = prefs.getString("token") ?? "";
    isAuthenticated.value = token.isNotEmpty;
  }

  Future<void> _saveSession(String accessToken, String tokenExpiration, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", accessToken);
    await prefs.setString("access_token", accessToken);
    await prefs.setString("token_expiration", tokenExpiration);
    await prefs.setString("user", jsonEncode(user));

    token.value = accessToken;
    isAuthenticated.value = true;
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("access_token");
    await prefs.remove("token_expiration");
    await prefs.remove("user");

    token.value = "";
    isAuthenticated.value = false;
  }
}
