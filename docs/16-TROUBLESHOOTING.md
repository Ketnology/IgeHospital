# Troubleshooting Guide

> **Document Version:** 1.0.0
> **Last Updated:** November 2024

## Common Issues and Solutions

---

## Authentication Issues

### "Not authenticated" Error

**Symptoms:**
- API calls fail with 401 status
- User redirected to login unexpectedly
- "Not authenticated" error message

**Solutions:**

1. **Check AuthService initialization**
```dart
// Ensure AuthService is initialized before other services in main.dart
await Get.putAsync<AuthService>(() async {
  final service = AuthService();
  await service.init();  // Must call init()
  return service;
});
```

2. **Verify token storage**
```dart
// Check if token is saved correctly
final prefs = await SharedPreferences.getInstance();
final token = prefs.getString('auth_token');
print('Stored token: $token');
```

3. **Check token expiration**
```dart
// Verify token hasn't expired
final expiration = prefs.getString('token_expiration');
final expiryTime = int.parse(expiration);
final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTime * 1000);
print('Token expires: $expiryDate');
print('Is expired: ${DateTime.now().isAfter(expiryDate)}');
```

### Token Refresh Failing

**Symptoms:**
- Token expires and user is logged out
- "Session expired" message appears frequently

**Solutions:**

1. **Verify validate-token endpoint**
```dart
// Test endpoint manually
final response = await http.post(
  Uri.parse('https://api.igehospital.com/api/auth/validate-token'),
  headers: {'Authorization': 'Bearer $token'},
);
print('Status: ${response.statusCode}');
print('Body: ${response.body}');
```

2. **Check token format**
- Ensure token is JWT format
- Verify expiration is Unix timestamp (seconds)

---

## Permission Issues

### Blank Screen / Access Denied

**Symptoms:**
- Page shows blank or loading forever
- User can't access expected pages
- No error messages shown

**Solutions:**

1. **Verify user role normalization**
```dart
// Check role is normalized correctly
final userType = authService.currentUser.value?.userType;
print('Raw type: $userType');
print('Normalized: ${UserRoles.normalizeRole(userType)}');
```

2. **Check role permissions**
```dart
// Verify permissions for role
final role = permissionService.currentUserRole;
final permissions = RolePermissions.getPermissionsForRole(role);
print('Role: $role');
print('Permissions: $permissions');
```

3. **Verify page access**
```dart
// Test specific page access
final canAccess = permissionService.canAccessPage('patients');
print('Can access patients: $canAccess');
```

4. **Check PermissionService canAccessPage mapping**
```dart
// Ensure page key is mapped in permission_service.dart
case 'your-page-key':
  return hasPermission(Permissions.viewYourPage);
```

### PermissionWrapper Not Working

**Symptoms:**
- Protected elements still visible
- Permission checks seem ignored

**Solutions:**

1. **Verify permission constant exists**
```dart
// Check in permissions.dart
static const String viewFeature = 'view_feature';
```

2. **Verify role has permission**
```dart
// Check in role_permissions.dart
UserRoles.admin: [
  Permissions.viewFeature,  // Should be listed
],
```

3. **Use correct wrapper property**
```dart
// Single permission
PermissionWrapper(permission: 'view_feature', ...)

// Multiple (any)
PermissionWrapper(anyOf: ['perm1', 'perm2'], ...)

// Multiple (all)
PermissionWrapper(allOf: ['perm1', 'perm2'], ...)
```

---

## GetX Issues

### "Get.find() not found" Error

**Symptoms:**
- Exception: "Service X not found"
- App crashes on startup or navigation

**Solutions:**

1. **Check initialization order in main.dart**
```dart
// Services must be registered before use
Get.put(AuthService());           // First
Get.put(PermissionService());     // Depends on AuthService
Get.put(PatientController());     // Depends on services
```

2. **Use Get.putAsync for async initialization**
```dart
await Get.putAsync<AuthService>(() async {
  final service = AuthService();
  await service.init();
  return service;
});
```

3. **Check service is registered before access**
```dart
if (Get.isRegistered<AuthService>()) {
  final service = Get.find<AuthService>();
}
```

### Reactive Variables Not Updating UI

**Symptoms:**
- Data changes but UI doesn't update
- Obx widget not rebuilding

**Solutions:**

1. **Use .value to update Rx variables**
```dart
// ✓ Correct
isLoading.value = true;
patients.value = newList;

// ✗ Wrong
isLoading = true.obs;  // Creates new observable
```

2. **Wrap UI in Obx**
```dart
// ✓ Correct
Obx(() => Text('${controller.count.value}'))

// ✗ Wrong - not reactive
Text('${controller.count.value}')
```

3. **Use .obs for reactive lists**
```dart
var patients = <PatientModel>[].obs;

// Update correctly
patients.add(newPatient);
patients.value = newList;
patients.assignAll(newList);
```

---

## API Issues

### CORS Errors (Web)

**Symptoms:**
- Network request blocked
- "Access-Control-Allow-Origin" error in console

**Solutions:**

1. **Server-side fix (recommended)**
```
Add CORS headers to API responses:
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
```

2. **Development workaround**
```bash
# Run Chrome with disabled security (dev only!)
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

### Request Timeout

**Symptoms:**
- Requests hang indefinitely
- No response from server

**Solutions:**

1. **Add timeout to requests**
```dart
final response = await http.get(url)
    .timeout(Duration(seconds: 30));
```

2. **Check network connectivity**
```dart
// Add connectivity check
final result = await InternetAddress.lookup('api.igehospital.com');
if (result.isEmpty) {
  throw Exception('No internet connection');
}
```

### JSON Parsing Errors

**Symptoms:**
- "FormatException: Unexpected character"
- Model fromJson fails

**Solutions:**

1. **Check response is JSON**
```dart
print('Response content-type: ${response.headers['content-type']}');
print('Response body: ${response.body}');
```

2. **Handle malformed responses**
```dart
try {
  final json = jsonDecode(response.body);
} catch (e) {
  print('JSON parse error: $e');
  print('Raw body: ${response.body}');
}
```

3. **Validate model fields**
```dart
factory Model.fromJson(Map<String, dynamic> json) {
  // Use null-safe access
  return Model(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
  );
}
```

---

## UI Issues

### Theme Not Applying

**Symptoms:**
- Colors not matching theme
- Dark/light mode not switching

**Solutions:**

1. **Verify Provider setup**
```dart
// Must wrap app with ChangeNotifierProvider
runApp(
  ChangeNotifierProvider(
    create: (_) => ColourNotifier(),
    child: MyApp(),
  ),
);
```

2. **Use Provider correctly**
```dart
// ✓ Correct
final notifier = Provider.of<ColourNotifier>(context);
Container(color: notifier.getContainer)

// ✗ Wrong - direct color reference
Container(color: Colors.white)
```

### Responsive Layout Issues

**Symptoms:**
- Layout breaks on different screen sizes
- Drawer not showing/hiding correctly

**Solutions:**

1. **Check breakpoint**
```dart
// Breakpoint is 600px
if (MediaQuery.of(context).size.width >= 600) {
  // Desktop layout
} else {
  // Mobile layout
}
```

2. **Use LayoutBuilder**
```dart
LayoutBuilder(
  builder: (context, constraints) {
    print('Width: ${constraints.maxWidth}');
    // Adapt layout based on constraints
  },
)
```

### Overflow Errors

**Symptoms:**
- Yellow/black stripes on screen
- "RenderFlex overflowed" error

**Solutions:**

1. **Wrap in scrollable**
```dart
SingleChildScrollView(
  child: Column(children: [...]),
)
```

2. **Use Flexible/Expanded**
```dart
Row(
  children: [
    Expanded(child: Text('Long text...')),
    Icon(Icons.arrow),
  ],
)
```

3. **Constrain size**
```dart
SizedBox(
  width: 200,
  child: Text('Long text...', overflow: TextOverflow.ellipsis),
)
```

---

## Build Issues

### Flutter Build Failing

**Symptoms:**
- Build errors
- Missing dependencies

**Solutions:**

1. **Clean and rebuild**
```bash
flutter clean
flutter pub get
flutter build web
```

2. **Update dependencies**
```bash
flutter pub upgrade
```

3. **Check Flutter version**
```bash
flutter --version
flutter doctor
```

### iOS Build Issues

**Symptoms:**
- Pod install fails
- Signing errors

**Solutions:**

1. **Update pods**
```bash
cd ios
pod deintegrate
pod install --repo-update
cd ..
flutter clean
flutter build ios
```

2. **Fix signing**
- Open Xcode
- Select correct team
- Enable automatic signing

### Android Build Issues

**Symptoms:**
- Gradle errors
- Minify/ProGuard issues

**Solutions:**

1. **Clean Gradle cache**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter build apk
```

2. **Check Gradle version**
- Update `android/gradle/wrapper/gradle-wrapper.properties`
- Match Gradle plugin in `android/build.gradle`

---

## Performance Issues

### Slow App Startup

**Solutions:**
1. Lazy-load services
2. Defer non-critical initialization
3. Use splash screen effectively

### Memory Leaks

**Solutions:**
1. Dispose controllers properly
2. Cancel subscriptions in onClose
3. Use weak references for callbacks

### Slow List Rendering

**Solutions:**
1. Use `ListView.builder` instead of `ListView`
2. Implement pagination
3. Use `const` constructors

---

## Debugging Tips

### Enable Verbose Logging

```dart
Get.log('Debug: $message');
print('HTTP Response: ${response.body}');
```

### Check State

```dart
// Print current state
print('Auth: ${authService.isAuthenticated.value}');
print('User: ${authService.currentUser.value?.toJson()}');
print('Token: ${authService.token.value}');
```

### Network Debugging

```dart
// Log all requests
print('URL: $url');
print('Headers: $headers');
print('Body: $body');
print('Response: ${response.statusCode} - ${response.body}');
```

---

## Getting Help

1. Check this troubleshooting guide
2. Review relevant documentation
3. Search existing issues
4. Check Flutter/GetX documentation
5. Contact development team
