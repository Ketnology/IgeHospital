# Performance Optimization Guide

> **Document Version:** 1.0.0
> **Last Updated:** November 2024

## Overview

This guide covers performance optimization strategies for IGE Hospital, including rendering optimizations, state management efficiency, network performance, and memory management.

---

## Rendering Optimizations

### 1. Use const Constructors

```dart
// ✓ Good - const constructor prevents rebuilds
const SizedBox(height: 16);
const Divider();
const Icon(Icons.person);

// Use const for widget parameters
child: const Text('Static text'),
```

### 2. Efficient List Rendering

```dart
// ✓ Good - ListView.builder creates items on demand
ListView.builder(
  itemCount: patients.length,
  itemBuilder: (context, index) => PatientCard(patients[index]),
)

// ✗ Avoid - ListView with children loads all items
ListView(
  children: patients.map((p) => PatientCard(p)).toList(),
)
```

### 3. Avoid Unnecessary Rebuilds

```dart
// ✓ Good - Separate widgets that rebuild independently
class ParentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StaticHeader(),  // Never rebuilds
        DynamicContent(),  // Rebuilds with Obx
      ],
    );
  }
}

class DynamicContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Text('${controller.count.value}'));
  }
}
```

### 4. Use RepaintBoundary

```dart
// Isolate complex animations
RepaintBoundary(
  child: AnimatedWidget(),
)
```

---

## State Management Optimization

### 1. Minimize Observable Scope

```dart
// ✓ Good - Only rebuild what changes
class PatientCard extends StatelessWidget {
  final PatientModel patient;

  @override
  Widget build(BuildContext context) {
    // Static content - no Obx needed
    return Card(
      child: Column(
        children: [
          Text(patient.name),
          // Only wrap reactive parts
          Obx(() => Text('Status: ${controller.status.value}')),
        ],
      ),
    );
  }
}
```

### 2. Use GetX Workers Efficiently

```dart
@override
void onInit() {
  super.onInit();

  // Debounce search to reduce API calls
  debounce(
    searchQuery,
    (_) => loadPatients(),
    time: Duration(milliseconds: 500),
  );

  // Throttle scroll events
  interval(
    scrollPosition,
    (_) => loadMore(),
    time: Duration(seconds: 1),
  );
}
```

### 3. Computed Properties vs Stored State

```dart
// ✓ Good - Computed when needed
List<PatientModel> get activePatients {
  return patients.where((p) => p.isActive).toList();
}

// ✗ Avoid - Storing derived data
var activePatients = <PatientModel>[].obs;  // Duplicate state
```

### 4. Lazy Controller Loading

```dart
// Load controller only when needed
Get.lazyPut<HeavyController>(() => HeavyController());

// Access creates instance
final controller = Get.find<HeavyController>();
```

---

## Network Optimization

### 1. Implement Pagination

```dart
class PatientController extends GetxController {
  var currentPage = 1.obs;
  var isLoadingMore = false.obs;
  var hasMore = true.obs;

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;
    try {
      final result = await _service.getPatients(page: currentPage.value + 1);

      patients.addAll(result['patients']);
      currentPage.value++;
      hasMore.value = result['currentPage'] < result['lastPage'];
    } finally {
      isLoadingMore.value = false;
    }
  }
}
```

### 2. Cache Network Images

```dart
// Use cached_network_image package
CachedNetworkImage(
  imageUrl: patient.profileImage ?? '',
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.person),
  memCacheWidth: 200,  // Resize for memory efficiency
)
```

### 3. Minimize API Calls

```dart
// Batch updates
Future<void> updateMultiple(List<PatientModel> patients) async {
  // ✓ Single API call
  await _service.batchUpdate(patients);

  // ✗ Avoid - Multiple calls
  // for (final p in patients) {
  //   await _service.update(p);
  // }
}
```

### 4. Request Deduplication

```dart
class PatientService extends GetxController {
  Future<List<PatientModel>>? _pendingRequest;

  Future<List<PatientModel>> getPatients() async {
    // Return existing request if in progress
    if (_pendingRequest != null) {
      return _pendingRequest!;
    }

    _pendingRequest = _fetchPatients();
    try {
      return await _pendingRequest!;
    } finally {
      _pendingRequest = null;
    }
  }
}
```

---

## Memory Management

### 1. Dispose Controllers Properly

```dart
class MyController extends GetxController {
  StreamSubscription? _subscription;
  TextEditingController? _textController;

  @override
  void onInit() {
    super.onInit();
    _textController = TextEditingController();
    _subscription = stream.listen(handleEvent);
  }

  @override
  void onClose() {
    _textController?.dispose();
    _subscription?.cancel();
    super.onClose();
  }
}
```

### 2. Clear Large Lists

```dart
@override
void onClose() {
  patients.clear();
  appointments.clear();
  super.onClose();
}
```

### 3. Use Efficient Data Structures

```dart
// For lookup by ID - use Map
final patientsById = <String, PatientModel>{};

// Fast lookup
final patient = patientsById[id];

// Vs iterating list
// final patient = patients.firstWhere((p) => p.id == id);
```

### 4. Image Memory Management

```dart
// Limit image cache size
PaintingBinding.instance.imageCache.maximumSize = 100;
PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 50MB
```

---

## Build Performance

### 1. Tree Shaking

Ensure unused code is removed:

```bash
flutter build web --release --tree-shake-icons
```

### 2. Deferred Loading (Web)

```dart
// Load feature on demand
import 'heavy_feature.dart' deferred as heavy;

Future<void> loadHeavyFeature() async {
  await heavy.loadLibrary();
  heavy.showHeavyWidget();
}
```

### 3. Split App Bundles (Android)

```bash
flutter build apk --release --split-per-abi
```

---

## Profiling Tools

### Flutter DevTools

```bash
# Run app in profile mode
flutter run --profile

# Open DevTools
# URL shown in terminal
```

### Performance Overlay

```dart
MaterialApp(
  showPerformanceOverlay: true,  // Enable in debug
  ...
)
```

### Memory Profiling

1. Open Flutter DevTools
2. Go to Memory tab
3. Take snapshots before/after operations
4. Identify leaks

---

## Performance Checklist

### Rendering
- [ ] Use const constructors where possible
- [ ] Implement ListView.builder for long lists
- [ ] Minimize widget tree depth
- [ ] Use RepaintBoundary for animations

### State Management
- [ ] Debounce search inputs
- [ ] Use computed properties instead of derived state
- [ ] Lazy load controllers
- [ ] Minimize Obx scope

### Network
- [ ] Implement pagination for lists
- [ ] Cache network images
- [ ] Debounce/throttle API calls
- [ ] Handle offline gracefully

### Memory
- [ ] Dispose controllers properly
- [ ] Cancel subscriptions
- [ ] Clear large collections
- [ ] Limit image cache

---

## Performance Metrics

### Target Metrics

| Metric | Target | Tool |
|--------|--------|------|
| First Paint | < 1s | DevTools |
| Time to Interactive | < 3s | DevTools |
| Frame Rate | 60 fps | Performance Overlay |
| Memory Usage | < 100MB | DevTools Memory |
| API Response Time | < 500ms | Network Tab |

### Monitoring

1. **Development:** Use Flutter DevTools
2. **Production:** Implement error/performance tracking
3. **User Feedback:** Monitor user-reported issues
