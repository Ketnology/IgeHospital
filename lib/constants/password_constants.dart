/// Constants for password field configuration
/// Follows Dependency Inversion Principle - depends on abstractions
class PasswordFieldConstants {
  // Icon paths
  static const String lockIcon = "assets/lock.svg";
  static const String eyeIcon = "assets/eye.svg";
  static const String eyeOffIcon = "assets/eye-off.svg";

  // Default values
  static const double defaultBorderRadius = 25.0;
  static const double defaultIconSize = 18.0;
  static const double defaultPrefixIconWidth = 50.0;
  static const double defaultPrefixIconHeight = 20.0;

  // Hint texts
  static const String passwordHint = "Password";
  static const String confirmPasswordHint = "Confirm Password";
  static const String currentPasswordHint = "Current Password";
  static const String newPasswordHint = "New Password";

  // Controller tags for multiple password fields
  static const String loginPasswordTag = "login_password";
  static const String confirmPasswordTag = "confirm_password";
  static const String currentPasswordTag = "current_password";
  static const String newPasswordTag = "new_password";
}