import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ige_hospital/constants/api_endpoints.dart';
import 'package:ige_hospital/routes.dart';
import 'package:ige_hospital/utils/snack_bar_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String designation;
  final String gender;
  final String userType;
  final String? profileImage;
  final Map<String, dynamic>? additionalData;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.designation,
    required this.gender,
    required this.userType,
    this.profileImage,
    this.additionalData,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'] ?? '',
      name: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      designation: json['designation'] ?? '',
      gender: json['gender'] ?? '',
      userType: json['user_type'] ?? '',
      profileImage: null,
      additionalData: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'full_name': name,
      'email': email,
      'phone': phone,
      'designation': designation,
      'gender': gender,
      'user_type': userType,
      'profile_image': profileImage,
      'additional_data': additionalData,
    };
  }
}

class AuthService extends GetxService {
  final RxBool isAuthenticated = false.obs;
  final RxString token = ''.obs;
  final RxString tokenExpiration = ''.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isRefreshing = false.obs;

  Future<AuthService> init() async {
    await loadToken();
    await loadUser();

    // Check token validity on startup
    if (isAuthenticated.value) {
      checkTokenExpiration();
    }

    return this;
  }

  Future<void> login(String email, String password) async {
    Get.log("Attempting login with email: $email");

    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      Get.log("Login response status: ${response.statusCode}");

      final data = jsonDecode(response.body);
      final int status = data["status"] ?? 500;
      final String message = data["message"] ?? 'An error occurred';

      if (response.statusCode == 200) {
        if (status == 200) {
          final String accessToken = data["data"]["access_token"] ?? "";
          final String tokenExpiration =
              data["data"]["token_expiration"]?.toString() ?? "";

          UserModel? user;
          if (data["data"]["user"] != null) {
            user = UserModel.fromJson(data["data"]["user"]);
          }

          await _saveSession(accessToken, tokenExpiration, user);

          Get.offAllNamed(Routes.homepage);
          SnackBarUtils.showSuccessSnackBar(message);
        } else {
          SnackBarUtils.showErrorSnackBar(message);
        }
      } else {
        SnackBarUtils.showErrorSnackBar(message);
      }
    } catch (e) {
      Get.log("Login error: $e");
      SnackBarUtils.showErrorSnackBar("Something went wrong");
    }
  }

  Future<bool> validateToken() async {
    if (isRefreshing.value) return false;

    isRefreshing.value = true;
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.validateToken),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${token.value}",
        },
      );

      Get.log("Token validation response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["status"] == 200) {
          final String newTokenExpiration =
              data["data"]["token_expiration"] ?? "";

          if (newTokenExpiration.isNotEmpty) {
            await updateTokenExpiration(newTokenExpiration);
            isRefreshing.value = false;
            return true;
          }
        }
      }

      isRefreshing.value = false;
      return false;
    } catch (e) {
      Get.log("Token validation error: $e");
      isRefreshing.value = false;
      return false;
    }
  }

  Future<void> updateTokenExpiration(String newExpiration) async {
    Get.log("Updating token expiration to: $newExpiration");
    tokenExpiration.value = newExpiration;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token_expiration", newExpiration);
  }

  void checkTokenExpiration() {
    if (tokenExpiration.value.isEmpty) {
      logout();
      return;
    }

    try {
      // Convert Unix timestamp (seconds since epoch) to DateTime
      final int timestamp = int.parse(tokenExpiration.value);
      final expirationDate =
          DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      final now = DateTime.now();

      if (now.isAfter(expirationDate)) {
        Get.log("Token expired at: $expirationDate, current time: $now");
        logout();
        SnackBarUtils.showWarningSnackBar(
            "Your session has expired. Please login again.");
      } else {
        // If token expires in less than 10 minutes, try to refresh it
        final tenMinutesBeforeExpiry =
            expirationDate.subtract(const Duration(minutes: 10));
        if (now.isAfter(tenMinutesBeforeExpiry)) {
          Get.log("Token expiring soon. Refreshing...");
          validateToken();
        }
      }
    } catch (e) {
      Get.log("Error checking token expiration: $e");
      logout();
    }
  }

  Future<bool> isTokenValid() {
    if (token.value.isEmpty) return Future.value(false);

    try {
      // Convert Unix timestamp (seconds since epoch) to DateTime
      final int timestamp = int.parse(tokenExpiration.value);
      final expirationDate =
          DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      final now = DateTime.now();

      // Token is valid if it has not expired
      return Future.value(now.isBefore(expirationDate));
    } catch (e) {
      Get.log("Error checking token validity: $e");
      return Future.value(false);
    }
  }

  Future<void> logout() async {
    // Attempt to call logout endpoint if we have a token
    if (token.value.isNotEmpty) {
      try {
        await http.post(
          Uri.parse(ApiEndpoints.logout),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${token.value}"
          },
        );
      } catch (e) {
        Get.log("Logout API error: $e");
      }
    }

    await _clearSession();
    Get.offAllNamed(Routes.login);
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token.value = prefs.getString("access_token") ?? "";
    tokenExpiration.value = prefs.getString("token_expiration") ?? "";
    isAuthenticated.value = token.isNotEmpty;
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString("user");

    if (userJson != null && userJson.isNotEmpty) {
      try {
        final userData = jsonDecode(userJson);
        currentUser.value = UserModel.fromJson(userData);
      } catch (e) {
        Get.log("Error parsing user data: $e");
      }
    }
  }

  Future<void> _saveSession(
      String accessToken, String tokenExpiration, UserModel? user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", accessToken);
    await prefs.setString("token_expiration", tokenExpiration);

    if (user != null) {
      await prefs.setString("user", jsonEncode(user.toJson()));
      currentUser.value = user;
    }

    token.value = accessToken;
    this.tokenExpiration.value = tokenExpiration;
    isAuthenticated.value = true;
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("user");
    await prefs.remove("access_token");
    await prefs.remove("token_expiration");

    token.value = "";
    tokenExpiration.value = "";
    isAuthenticated.value = false;
    currentUser.value = null;
  }

  String getUserName() {
    return currentUser.value?.name ?? "Guest User";
  }

  String getUserEmail() {
    return currentUser.value?.email ?? "";
  }

  String getUserType() {
    return currentUser.value?.userType ?? "";
  }
}
