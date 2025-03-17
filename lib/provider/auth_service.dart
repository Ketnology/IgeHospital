import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ige_hospital/routes.dart';
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
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  Future<AuthService> init() async {
    await loadToken();
    await loadUser();
    return this;
  }

  Future<void> login(String email, String password) async {
    Get.log("Attempting login with email: $email");

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/api/auth/login"),
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
          final String accessToken = data["data"]["access_token"] ?? "";
          final String tokenExpiration = data["data"]["token_expiration"]?.toString() ?? "";

          UserModel? user;
          if (data["data"]["user"] != null) {
            user = UserModel.fromJson(data["data"]["user"]);
            Get.log("Logged-in user details: ${user.toJson()}");
          }

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

  Future<void> _saveSession(String accessToken, String tokenExpiration, UserModel? user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", accessToken);
    await prefs.setString("access_token", accessToken);
    await prefs.setString("token_expiration", tokenExpiration);

    if (user != null) {
      await prefs.setString("user", jsonEncode(user.toJson()));
      currentUser.value = user;
    }

    token.value = accessToken;
    isAuthenticated.value = true;
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("user");
    await prefs.remove("token");
    await prefs.remove("access_token");
    await prefs.remove("token_expiration");

    token.value = "";
    isAuthenticated.value = false;
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
