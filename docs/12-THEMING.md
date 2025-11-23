# Theming Documentation

> **Document Version:** 1.0.0
> **Last Updated:** November 2024

## Overview

IGE Hospital uses Provider-based theme management with support for light and dark modes. The theme system provides consistent colors, typography, and styling across the application.

---

## Theme Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     ColourNotifier                          │
│                  (ChangeNotifier)                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  _isDark: bool                                       │   │
│  │  getPrimaryColor, getBgColor, getMainText, etc.     │   │
│  └─────────────────────────────────────────────────────┘   │
└──────────────────────────────┬──────────────────────────────┘
                               │ notifyListeners()
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                       Consumer<ColourNotifier>              │
│                            Widgets                          │
└─────────────────────────────────────────────────────────────┘
```

---

## Color Theme Constants

### Location: `lib/constants/color_theme.dart`

```dart
// Light Mode Colors
Color primaryColor = const Color(0xffffffff);
Color bgColor = const Color(0xfff2f2f5);
Color borderColor = Colors.grey.shade200;
Color iconColor = const Color(0xFFF44C46);
Color container = const Color(0xffffffff);
Color mainText = Colors.black;
Color secondaryText = Colors.grey.shade600;
Color successColor = const Color(0xFF4CAF50);
Color errorColor = const Color(0xFFF44336);
Color warningColor = const Color(0xFFFF9800);

// Dark Mode Colors
Color darkPrimaryColor = const Color(0xff262932);
Color darkBgColor = const Color(0xff1d1e25);
Color darkBorderColor = const Color(0xff2a323f);
Color darkIconColor = const Color(0xFFFFDB37);
Color darkContainer = const Color(0xff262932);
Color darkMainText = Colors.white;
Color darkSecondaryText = Colors.grey.shade400;
```

---

## ColourNotifier Provider

### Location: `lib/provider/colors_provider.dart`

```dart
class ColourNotifier with ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  /// Toggle theme mode
  void isAvaliable(bool value) {
    _isDark = value;
    notifyListeners();
  }

  // Primary colors
  Color get getPrimaryColor => _isDark ? darkPrimaryColor : primaryColor;
  Color get getBgColor => _isDark ? darkBgColor : bgColor;
  Color get getBorderColor => _isDark ? darkBorderColor : borderColor;
  Color get getIconColor => _isDark ? darkIconColor : iconColor;
  Color get getContainer => _isDark ? darkContainer : container;

  // Text colors
  Color get getMainText => _isDark ? darkMainText : mainText;
  Color get getSecondaryText => _isDark ? darkSecondaryText : secondaryText;
  Color get getHintText => _isDark ? Colors.grey.shade500 : Colors.grey.shade400;

  // Status colors (same for both modes)
  Color get getSuccessColor => successColor;
  Color get getErrorColor => errorColor;
  Color get getWarningColor => warningColor;
  Color get getInfoColor => const Color(0xFF2196F3);

  // UI Element colors
  Color get getCardColor => _isDark ? darkContainer : container;
  Color get getDividerColor => _isDark ? darkBorderColor : borderColor;
  Color get getShadowColor => _isDark
      ? Colors.black.withOpacity(0.3)
      : Colors.grey.withOpacity(0.1);

  // Input field colors
  Color get getInputBg => _isDark
      ? darkContainer
      : Colors.grey.shade50;
  Color get getInputBorder => _isDark ? darkBorderColor : borderColor;

  // Button colors
  Color get getButtonText => Colors.white;
  Color get getButtonDisabled => _isDark
      ? Colors.grey.shade700
      : Colors.grey.shade300;
}
```

---

## Provider Setup

### Location: `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ... service initialization ...

  runApp(
    ChangeNotifierProvider(
      create: (_) => ColourNotifier(),
      child: const MyApp(),
    ),
  );
}
```

---

## Using Theme in Widgets

### Method 1: Consumer Widget

```dart
class ThemedContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ColourNotifier>(
      builder: (context, notifier, child) {
        return Container(
          color: notifier.getContainer,
          child: Text(
            'Hello World',
            style: TextStyle(color: notifier.getMainText),
          ),
        );
      },
    );
  }
}
```

### Method 2: Provider.of

```dart
class ThemedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Container(
      decoration: BoxDecoration(
        color: notifier.getCardColor,
        border: Border.all(color: notifier.getBorderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'Title',
            style: TextStyle(
              color: notifier.getMainText,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Subtitle',
            style: TextStyle(color: notifier.getSecondaryText),
          ),
        ],
      ),
    );
  }
}
```

### Method 3: Context Extension (Recommended)

```dart
// Define extension
extension ThemeContext on BuildContext {
  ColourNotifier get theme => Provider.of<ColourNotifier>(this);
}

// Usage
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.theme.getContainer,
      child: Text(
        'Hello',
        style: TextStyle(color: context.theme.getMainText),
      ),
    );
  }
}
```

---

## Theme Toggle

### In Drawer

```dart
// lib/drawer.dart
class DrawerCode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Column(
      children: [
        // ... menu items ...

        // Theme toggle
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.light_mode,
                color: !notifier.isDark ? Colors.amber : Colors.grey,
              ),
              Switch(
                value: notifier.isDark,
                onChanged: (value) => notifier.isAvaliable(value),
                activeColor: Colors.amber,
              ),
              Icon(
                Icons.dark_mode,
                color: notifier.isDark ? Colors.amber : Colors.grey,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

### Standalone Toggle Button

```dart
class ThemeToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return IconButton(
      icon: Icon(
        notifier.isDark ? Icons.light_mode : Icons.dark_mode,
        color: notifier.getIconColor,
      ),
      onPressed: () => notifier.isAvaliable(!notifier.isDark),
      tooltip: notifier.isDark ? 'Switch to light mode' : 'Switch to dark mode',
    );
  }
}
```

---

## Typography

### Font Configuration

```dart
// lib/main.dart
ThemeData(
  fontFamily: "Gilroy",
  // ...
)
```

### Text Styles

```dart
class AppTextStyles {
  static TextStyle heading1(ColourNotifier notifier) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: notifier.getMainText,
  );

  static TextStyle heading2(ColourNotifier notifier) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: notifier.getMainText,
  );

  static TextStyle body(ColourNotifier notifier) => TextStyle(
    fontSize: 14,
    color: notifier.getMainText,
  );

  static TextStyle caption(ColourNotifier notifier) => TextStyle(
    fontSize: 12,
    color: notifier.getSecondaryText,
  );

  static TextStyle button(ColourNotifier notifier) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: notifier.getButtonText,
  );
}
```

---

## Common UI Patterns

### Themed Card

```dart
Widget buildThemedCard(BuildContext context, {required Widget child}) {
  final notifier = Provider.of<ColourNotifier>(context);

  return Container(
    decoration: BoxDecoration(
      color: notifier.getCardColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: notifier.getShadowColor,
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );
}
```

### Themed Input Field

```dart
InputDecoration themedInputDecoration(ColourNotifier notifier, {String? hint}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: notifier.getHintText),
    filled: true,
    fillColor: notifier.getInputBg,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: notifier.getInputBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: notifier.getInputBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
    ),
  );
}
```

### Themed Button

```dart
Widget themedElevatedButton({
  required BuildContext context,
  required String label,
  required VoidCallback onPressed,
  bool isLoading = false,
}) {
  return ElevatedButton(
    onPressed: isLoading ? null : onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          )
        : Text(label),
  );
}
```

---

## Status Colors

### Status Badge Colors

```dart
class StatusColors {
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'completed':
      case 'success':
        return const Color(0xFF4CAF50); // Green

      case 'pending':
      case 'scheduled':
      case 'waiting':
        return const Color(0xFFFF9800); // Orange

      case 'blocked':
      case 'cancelled':
      case 'error':
        return const Color(0xFFF44336); // Red

      case 'ongoing':
      case 'in_progress':
        return const Color(0xFF9C27B0); // Purple

      case 'inactive':
      case 'disabled':
        return Colors.grey;

      default:
        return Colors.grey;
    }
  }

  static Color getStatusTextColor(String status) {
    return getStatusColor(status);
  }

  static Color getStatusBgColor(String status) {
    return getStatusColor(status).withOpacity(0.1);
  }
}
```

---

## Best Practices

### 1. Consistent Color Access

```dart
// ✓ Good - Use provider
final notifier = Provider.of<ColourNotifier>(context);
Container(color: notifier.getContainer)

// ✗ Avoid - Direct color reference
Container(color: Colors.white)
```

### 2. Rebuild Optimization

```dart
// ✓ Good - Only rebuild what needs to change
Consumer<ColourNotifier>(
  builder: (context, notifier, child) {
    return Container(
      color: notifier.getContainer,
      child: child, // child doesn't rebuild
    );
  },
  child: ExpensiveWidget(), // Passed as child
)
```

### 3. Theme-Aware Components

```dart
// Create reusable themed components
class ThemedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);
    return Divider(color: notifier.getDividerColor);
  }
}
```

### 4. Semantic Color Naming

```dart
// ✓ Good - Semantic names
Color get getErrorColor => ...
Color get getSuccessColor => ...
Color get getWarningColor => ...

// ✗ Avoid - Raw color names
Color get getRed => ...
Color get getGreen => ...
```
