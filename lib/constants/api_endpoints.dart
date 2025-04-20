class ApiEndpoints {
  static const String baseUrl = "https://api.healthcentre.ng/api";

  static const String login = "$baseUrl/auth/login";
  static const String validateToken = "$baseUrl/auth/validate-token";
  static const String logout = "$baseUrl/auth/logout";

  static const String dashboard = "$baseUrl/admin/dashboard";

  static const String appointmentEndpoint = "$baseUrl/appointments";

  static const String patientEndpoint = "$baseUrl/patient";

  static const String adminsEndpoint = "$baseUrl/admin";

  static const String nursesEndpoint = "$baseUrl/receptionist";

  static const String doctorEndpoint = "$baseUrl/doctor";
  static const String doctorDepartmentsEndpoint = "$baseUrl/doctor-departments";

  static const String staffEndpoint = "$baseUrl/staff";

  static const String userProfile = "$baseUrl/user/profile";
  static const String updateProfile = "$baseUrl/user/profile/update";
}
