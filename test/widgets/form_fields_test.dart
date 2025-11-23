import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Form Fields Widget Tests', () {
    group('Text Field', () {
      testWidgets('should accept text input', (WidgetTester tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter your name',
                ),
              ),
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), 'John Doe');
        expect(controller.text, equals('John Doe'));

        controller.dispose();
      });

      testWidgets('should display label text', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
            ),
          ),
        );

        expect(find.text('Email'), findsOneWidget);
      });

      testWidgets('should display hint text', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextField(
                decoration: const InputDecoration(
                  hintText: 'Enter email address',
                ),
              ),
            ),
          ),
        );

        expect(find.text('Enter email address'), findsOneWidget);
      });

      testWidgets('should display error text when provided',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextField(
                decoration: const InputDecoration(
                  labelText: 'Password',
                  errorText: 'Password is required',
                ),
              ),
            ),
          ),
        );

        expect(find.text('Password is required'), findsOneWidget);
      });

      testWidgets('should toggle obscure text for password field',
          (WidgetTester tester) async {
        bool isObscured = true;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return TextField(
                    obscureText: isObscured,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          isObscured ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            isObscured = !isObscured;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        // Initially obscured
        expect(find.byIcon(Icons.visibility), findsOneWidget);

        // Tap to toggle
        await tester.tap(find.byType(IconButton));
        await tester.pump();

        // Now visible
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      });

      testWidgets('should be enabled by default', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextField(
                decoration: const InputDecoration(
                  labelText: 'Test Field',
                ),
              ),
            ),
          ),
        );

        final TextField textField = tester.widget(find.byType(TextField));
        expect(textField.enabled, isTrue);
      });

      testWidgets('should be disabled when specified',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextField(
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Disabled Field',
                ),
              ),
            ),
          ),
        );

        final TextField textField = tester.widget(find.byType(TextField));
        expect(textField.enabled, isFalse);
      });
    });

    group('Dropdown Field', () {
      testWidgets('should display dropdown items', (WidgetTester tester) async {
        String selectedValue = 'Option 1';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DropdownButton<String>(
                value: selectedValue,
                items: const [
                  DropdownMenuItem(value: 'Option 1', child: Text('Option 1')),
                  DropdownMenuItem(value: 'Option 2', child: Text('Option 2')),
                  DropdownMenuItem(value: 'Option 3', child: Text('Option 3')),
                ],
                onChanged: (value) {},
              ),
            ),
          ),
        );

        expect(find.text('Option 1'), findsOneWidget);
      });

      testWidgets('should open dropdown and show all options',
          (WidgetTester tester) async {
        String selectedValue = 'Option 1';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DropdownButton<String>(
                value: selectedValue,
                items: const [
                  DropdownMenuItem(value: 'Option 1', child: Text('Option 1')),
                  DropdownMenuItem(value: 'Option 2', child: Text('Option 2')),
                  DropdownMenuItem(value: 'Option 3', child: Text('Option 3')),
                ],
                onChanged: (value) {},
              ),
            ),
          ),
        );

        await tester.tap(find.byType(DropdownButton<String>));
        await tester.pumpAndSettle();

        // All options should now be visible
        expect(find.text('Option 1'), findsWidgets);
        expect(find.text('Option 2'), findsOneWidget);
        expect(find.text('Option 3'), findsOneWidget);
      });
    });

    group('Date Picker Field', () {
      testWidgets('should display initial date text',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextField(
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  hintText: 'Select a date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Select a date'), findsOneWidget);
        expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      });

      testWidgets('should have calendar icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextField(
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Birth Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      });
    });

    group('Search Field', () {
      testWidgets('should display search icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.search), findsOneWidget);
        expect(find.text('Search...'), findsOneWidget);
      });

      testWidgets('should accept search input', (WidgetTester tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Search patients...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), 'John');
        expect(controller.text, equals('John'));

        controller.dispose();
      });

      testWidgets('should show clear button when text is entered',
          (WidgetTester tester) async {
        final controller = TextEditingController(text: 'Search text');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  controller.clear();
                                });
                              },
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.clear), findsOneWidget);

        controller.dispose();
      });
    });

    group('Currency Field', () {
      test('should format currency correctly', () {
        String formatCurrency(double value, {String symbol = '\$'}) {
          return '$symbol${value.toStringAsFixed(2)}';
        }

        expect(formatCurrency(100), equals('\$100.00'));
        expect(formatCurrency(1234.56), equals('\$1234.56'));
        expect(formatCurrency(0), equals('\$0.00'));
        expect(formatCurrency(99.9), equals('\$99.90'));
      });

      test('should parse currency string correctly', () {
        double parseCurrency(String value) {
          final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
          return double.tryParse(cleaned) ?? 0.0;
        }

        expect(parseCurrency('\$100.00'), equals(100.00));
        expect(parseCurrency('1,234.56'), equals(1234.56));
        expect(parseCurrency('invalid'), equals(0.0));
      });
    });

    group('Form Validation', () {
      test('email validation should work correctly', () {
        bool isValidEmail(String email) {
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          return emailRegex.hasMatch(email);
        }

        expect(isValidEmail('test@example.com'), isTrue);
        expect(isValidEmail('user.name@domain.org'), isTrue);
        expect(isValidEmail('invalid-email'), isFalse);
        expect(isValidEmail('missing@domain'), isFalse);
        expect(isValidEmail('@nodomain.com'), isFalse);
        expect(isValidEmail(''), isFalse);
      });

      test('phone validation should work correctly', () {
        bool isValidPhone(String phone) {
          final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
          return phoneRegex.hasMatch(phone);
        }

        expect(isValidPhone('1234567890'), isTrue);
        expect(isValidPhone('+1 234 567 8900'), isTrue);
        expect(isValidPhone('123-456-7890'), isTrue);
        expect(isValidPhone('123'), isFalse);
      });

      test('required field validation should work correctly', () {
        String? validateRequired(String? value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        }

        expect(validateRequired(null), equals('This field is required'));
        expect(validateRequired(''), equals('This field is required'));
        expect(validateRequired('value'), isNull);
      });

      test('password validation should work correctly', () {
        String? validatePassword(String? value) {
          if (value == null || value.isEmpty) {
            return 'Password is required';
          }
          if (value.length < 8) {
            return 'Password must be at least 8 characters';
          }
          return null;
        }

        expect(validatePassword(null), equals('Password is required'));
        expect(validatePassword(''), equals('Password is required'));
        expect(validatePassword('short'), equals('Password must be at least 8 characters'));
        expect(validatePassword('validpassword'), isNull);
      });
    });
  });
}
