class UserRoles {
  static const String admin = 'admin';
  static const String doctor = 'doctor';
  static const String receptionist = 'receptionist'; // Updated from 'nurse'
  static const String nurse = 'receptionist'; // Alias for backward compatibility
  static const String patient = 'patient';

  static const List<String> allRoles = [admin, doctor, receptionist, patient];

  // Helper method to normalize role names
  static String normalizeRole(String role) {
    switch (role.toLowerCase()) {
      case 'nurse':
      case 'receptionist':
        return receptionist;
      case 'admin':
        return admin;
      case 'doctor':
        return doctor;
      case 'patient':
        return patient;
      default:
        return role.toLowerCase();
    }
  }
}