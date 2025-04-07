class ApiEndpoints {
  static const String baseUrl = "http://127.0.0.1:8000/api";
  // static const String baseUrl = "https://api.healthcentre.ng/api";

  static const String login = "$baseUrl/auth/login";
  static const String validateToken = "$baseUrl/auth/validate-token";
  static const String logout = "$baseUrl/auth/logout";

  static const String dashboard = "$baseUrl/admin/dashboard";

  static const String appointments = "$baseUrl/appointments";
  static const String appointmentDetails = "$baseUrl/appointments/";

  static const String patientEndpoint = "$baseUrl/patient/";

  static const String doctors = "$baseUrl/doctors";
  static const String doctorDetails = "$baseUrl/doctors/";

  static const String staff = "$baseUrl/staff";
  static const String staffDetails = "$baseUrl/staff/";

  static const String userProfile = "$baseUrl/user/profile";
  static const String updateProfile = "$baseUrl/user/profile/update";
}