# State Management Documentation

> **Document Version:** 1.0.0
> **Last Updated:** November 2024

## Overview

IGE Hospital uses a **dual state management** approach:

1. **GetX** - Primary state management for controllers, routing, and dependency injection
2. **Provider** - Theme/color management via `ColourNotifier`

This combination leverages GetX's powerful reactive features for business logic while using Provider's simplicity for cross-cutting concerns like theming.

---

## GetX State Management

### Reactive Variables (Rx)

GetX provides reactive types that automatically update the UI when values change.

```dart
// Declaration
final RxBool isLoading = false.obs;
final RxInt count = 0.obs;
final RxString name = ''.obs;
final RxList<PatientModel> patients = <PatientModel>[].obs;
final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

// Update values
isLoading.value = true;
count.value++;
name.value = 'John Doe';
patients.add(newPatient);
currentUser.value = user;

// Read values
if (isLoading.value) { ... }
print(count.value);
```

### Reactive UI with Obx

```dart
// Automatic rebuild when value changes
Obx(() => Text('Count: ${controller.count.value}'))

// Multiple values
Obx(() => Text('${controller.firstName.value} ${controller.lastName.value}'))

// Conditional rendering
Obx(() => controller.isLoading.value
  ? CircularProgressIndicator()
  : PatientList()
)
```

### GetxController

Base class for all controllers with lifecycle methods.

```dart
class PatientController extends GetxController {
  // Reactive state
  var patients = <PatientModel>[].obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  // Pagination
  var currentPage = 1.obs;
  var totalPatients = 0.obs;
  var perPage = 12.obs;

  // Filters
  var searchQuery = ''.obs;
  var selectedGender = ''.obs;

  // Service dependency
  final PatientService _patientService = Get.put(PatientService());

  @override
  void onInit() {
    super.onInit();
    loadPatients();

    // Auto-debounce search
    debounce(
      searchQuery,
      (_) => loadPatients(),
      time: Duration(milliseconds: 500),
    );
  }

  @override
  void onReady() {
    super.onReady();
    // Called after widget is rendered
  }

  @override
  void onClose() {
    // Cleanup
    super.onClose();
  }

  Future<void> loadPatients() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final result = await _patientService.getPatientsWithPagination(
        page: currentPage.value,
        perPage: perPage.value,
        search: searchQuery.value,
      );

      patients.value = result['patients'];
      totalPatients.value = result['total'];
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
```

### Lifecycle Methods

| Method | When Called | Use Case |
|--------|-------------|----------|
| `onInit()` | After controller created | Initialize data, setup listeners |
| `onReady()` | After first frame rendered | Animation triggers, delayed init |
| `onClose()` | Before controller disposed | Cleanup, cancel subscriptions |

---

## Dependency Injection

### Registration Methods

```dart
// Singleton (lazy)
Get.put(PatientService());

// Async singleton
await Get.putAsync<AuthService>(() async {
  final service = AuthService();
  await service.init();
  return service;
});

// Lazy singleton (created on first use)
Get.lazyPut<PatientService>(() => PatientService());

// Factory (new instance each time)
Get.create<PatientService>(() => PatientService());
```

### Retrieval

```dart
// Get instance
final authService = Get.find<AuthService>();
final patientController = Get.find<PatientController>();

// Try to find (returns null if not found)
final maybeService = Get.isRegistered<SomeService>()
  ? Get.find<SomeService>()
  : null;
```

### Initialization Order (main.dart)

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Order matters - dependencies first

  // 1. Core Services (must be first)
  await Get.putAsync<AuthService>(() async {
    final service = AuthService();
    await service.init();
    return service;
  });

  // 2. Permission Service (depends on AuthService)
  Get.put(PermissionService());

  // 3. Dashboard Service (async initialization)
  await Get.putAsync<DashboardService>(() async {
    final service = DashboardService();
    await service.init();
    return service;
  });

  // 4. Other Services
  Get.put(DepartmentService());
  Get.put(ConsultationService());
  Get.put(VitalSignsService());

  // 5. Controllers
  Get.put(AuthController());
  Get.put(AccountingController());
  Get.put(NurseController());
  Get.put(ConsultationController());

  runApp(MyApp());
}
```

---

## GetX Routing

### Route Configuration

```dart
// lib/routes.dart
class Routes {
  static String initial = "/";
  static const String login = "/login";
  static String homepage = "/home";
}

final getPage = [
  GetPage(
    name: Routes.initial,
    page: () => SplashScreen(),
  ),
  GetPage(
    name: Routes.login,
    page: () => LoginPage(),
    middlewares: [AuthMiddleware()],
  ),
  GetPage(
    name: Routes.homepage,
    page: () => MyHomepage(),
    middlewares: [AuthMiddleware(), PermissionMiddleware()],
  ),
];
```

### Navigation

```dart
// Navigate to named route
Get.toNamed(Routes.homepage);

// Replace current route
Get.offNamed(Routes.login);

// Clear stack and navigate
Get.offAllNamed(Routes.login);

// Navigate with arguments
Get.toNamed(Routes.patientDetails, arguments: patientId);

// Get arguments
final patientId = Get.arguments as String;

// Navigate back
Get.back();

// Navigate back with result
Get.back(result: true);
```

---

## Reactive Workers

GetX provides workers for reacting to state changes.

### Debounce

Triggers callback after delay with no changes.

```dart
@override
void onInit() {
  super.onInit();

  // Search after 500ms of no typing
  debounce(
    searchQuery,
    (value) => loadPatients(),
    time: Duration(milliseconds: 500),
  );
}
```

### Interval

Triggers at most once per time period.

```dart
// Max once per second
interval(
  scrollPosition,
  (_) => loadMore(),
  time: Duration(seconds: 1),
);
```

### Ever

Triggers on every change.

```dart
// React to every auth state change
ever(
  authService.isAuthenticated,
  (isAuth) {
    if (!isAuth) Get.offAllNamed(Routes.login);
  },
);
```

### Once

Triggers only on first change.

```dart
// One-time initialization
once(
  dataLoaded,
  (_) => showWelcomeDialog(),
);
```

---

## Provider for Theme Management

### ColourNotifier

```dart
// lib/provider/colors_provider.dart
class ColourNotifier with ChangeNotifier {
  bool _isDark = false;

  void isAvaliable(bool value) {
    _isDark = value;
    notifyListeners();
  }

  // Getters for colors
  Color get getPrimaryColor =>
    _isDark ? darkPrimaryColor : primaryColor;

  Color get getBgColor =>
    _isDark ? darkBgColor : bgColor;

  Color get getMainText =>
    _isDark ? Colors.white : Colors.black;

  Color get getContainer =>
    _isDark ? darkContainer : lightContainer;

  // ... more color getters
}
```

### Provider Setup

```dart
// lib/main.dart
runApp(
  ChangeNotifierProvider(
    create: (_) => ColourNotifier(),
    child: MyApp(),
  ),
);
```

### Consuming Theme

```dart
// Method 1: Consumer widget
Consumer<ColourNotifier>(
  builder: (context, notifier, child) {
    return Container(
      color: notifier.getContainer,
      child: Text(
        'Hello',
        style: TextStyle(color: notifier.getMainText),
      ),
    );
  },
)

// Method 2: Provider.of
final notifier = Provider.of<ColourNotifier>(context);
Container(
  color: notifier.getBgColor,
)

// Method 3: Context extension
final notifier = context.watch<ColourNotifier>();
```

---

## State Management Patterns

### Controller Pattern

```dart
// Controller handles logic
class PatientController extends GetxController {
  var patients = <PatientModel>[].obs;
  var isLoading = false.obs;

  final PatientService _service = Get.find();

  Future<void> addPatient(Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      await _service.createPatient(data);
      await loadPatients();  // Refresh list
      Get.back();  // Close dialog
      SnackBarUtils.showSuccess('Patient added');
    } catch (e) {
      SnackBarUtils.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

// Widget uses controller
class AddPatientButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PatientController>();

    return Obx(() => ElevatedButton(
      onPressed: controller.isLoading.value
        ? null
        : () => showAddDialog(context),
      child: controller.isLoading.value
        ? CircularProgressIndicator()
        : Text('Add Patient'),
    ));
  }
}
```

### Service Pattern

```dart
// Service handles API communication
class PatientService extends GetxController {
  final HttpClient _http = HttpClient();

  Future<List<PatientModel>> getPatients({
    int page = 1,
    int perPage = 12,
    String? search,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'per_page': perPage.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final url = Uri.parse(ApiEndpoints.patients)
      .replace(queryParameters: queryParams);

    final response = await _http.get(url.toString());
    final json = jsonDecode(response.body);

    return (json['data'] as List)
      .map((p) => PatientModel.fromJson(p))
      .toList();
  }
}
```

### Reactive List Pattern

```dart
// Controller with reactive list
class ConsultationController extends GetxController {
  var consultations = <LiveConsultation>[].obs;

  // Filter computed list
  List<LiveConsultation> get upcomingConsultations =>
    consultations.where((c) => c.statusInfo.isUpcoming).toList();

  List<LiveConsultation> get ongoingConsultations =>
    consultations.where((c) => c.status == 'ongoing').toList();
}

// UI
Obx(() {
  final upcoming = controller.upcomingConsultations;
  if (upcoming.isEmpty) {
    return Text('No upcoming consultations');
  }
  return ListView.builder(
    itemCount: upcoming.length,
    itemBuilder: (_, i) => ConsultationCard(upcoming[i]),
  );
})
```

### Filter State Pattern

```dart
class AppointmentController extends GetxController {
  // Data
  var appointments = <AppointmentModel>[].obs;

  // Pagination
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var perPage = 12.obs;

  // Filters
  var searchQuery = ''.obs;
  var selectedDoctorId = ''.obs;
  var selectedPatientId = ''.obs;
  var dateFrom = ''.obs;
  var dateTo = ''.obs;
  var filterCompleted = RxnBool();

  // Sorting
  var sortBy = 'appointment_date'.obs;
  var sortDirection = 'desc'.obs;

  @override
  void onInit() {
    super.onInit();

    // Debounce search
    debounce(searchQuery, (_) => _applyFilters());

    // React to filter changes
    ever(selectedDoctorId, (_) => _applyFilters());
    ever(dateFrom, (_) => _applyFilters());
    ever(dateTo, (_) => _applyFilters());
  }

  void _applyFilters() {
    currentPage.value = 1;  // Reset to first page
    loadAppointments();
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedDoctorId.value = '';
    selectedPatientId.value = '';
    dateFrom.value = '';
    dateTo.value = '';
    filterCompleted.value = null;
    _applyFilters();
  }
}
```

---

## Best Practices

### 1. Single Source of Truth

```dart
// ✓ Good: Single source in service
class AuthService extends GetxController {
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
}

class AuthController extends GetxController {
  final _authService = Get.find<AuthService>();

  // Delegate to service
  UserModel? get currentUser => _authService.currentUser.value;
}

// ✗ Bad: Duplicated state
class AuthController extends GetxController {
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);  // Duplicate!
}
```

### 2. Clean Controller Disposal

```dart
class PatientController extends GetxController {
  Worker? _searchDebouncer;
  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    _searchDebouncer = debounce(searchQuery, (_) => loadPatients());
    _subscription = someStream.listen(handleEvent);
  }

  @override
  void onClose() {
    _searchDebouncer?.dispose();
    _subscription?.cancel();
    super.onClose();
  }
}
```

### 3. Proper Loading States

```dart
class DataController extends GetxController {
  var isLoading = false.obs;
  var isLoadingMore = false.obs;  // Separate for pagination
  var isRefreshing = false.obs;    // Separate for pull-to-refresh
  var hasError = false.obs;
  var errorMessage = ''.obs;

  Future<void> loadData() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      // Load data
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
```

### 4. Computed Properties

```dart
class PatientController extends GetxController {
  var patients = <PatientModel>[].obs;
  var searchQuery = ''.obs;

  // Computed property (not stored separately)
  List<PatientModel> get filteredPatients {
    if (searchQuery.value.isEmpty) return patients;

    return patients.where((p) {
      final query = searchQuery.value.toLowerCase();
      return p.name.toLowerCase().contains(query) ||
             p.email.toLowerCase().contains(query);
    }).toList();
  }
}

// Usage
Obx(() {
  final filtered = controller.filteredPatients;
  return ListView.builder(
    itemCount: filtered.length,
    itemBuilder: (_, i) => PatientCard(filtered[i]),
  );
})
```

### 5. Separation of Concerns

```dart
// Service: API only
class PatientService {
  Future<List<PatientModel>> getPatients() async { ... }
  Future<void> createPatient(Map data) async { ... }
}

// Controller: State + UI logic
class PatientController extends GetxController {
  final PatientService _service = Get.find();

  var patients = <PatientModel>[].obs;
  var isLoading = false.obs;

  Future<void> addPatient(Map data) async {
    isLoading.value = true;
    try {
      await _service.createPatient(data);
      await loadPatients();
      Get.back();
      SnackBarUtils.showSuccess('Created!');
    } finally {
      isLoading.value = false;
    }
  }
}

// Widget: UI only
class PatientList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PatientController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return CircularProgressIndicator();
      }
      return ListView.builder(...);
    });
  }
}
```
