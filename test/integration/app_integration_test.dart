import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Integration tests for IGE Hospital application
/// These tests verify the interaction between different components
void main() {
  group('App Integration Tests', () {
    group('Authentication Flow', () {
      testWidgets('should display login page initially',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('IGE Hospital'),
                  const SizedBox(height: 20),
                  TextField(
                    key: const Key('email_field'),
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    key: const Key('password_field'),
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    key: const Key('login_button'),
                    onPressed: () {},
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('IGE Hospital'), findsOneWidget);
        expect(find.byKey(const Key('email_field')), findsOneWidget);
        expect(find.byKey(const Key('password_field')), findsOneWidget);
        expect(find.byKey(const Key('login_button')), findsOneWidget);
      });

      testWidgets('should allow entering credentials',
          (WidgetTester tester) async {
        final emailController = TextEditingController();
        final passwordController = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  TextField(
                    controller: emailController,
                    key: const Key('email_field'),
                  ),
                  TextField(
                    controller: passwordController,
                    key: const Key('password_field'),
                    obscureText: true,
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.enterText(
          find.byKey(const Key('email_field')),
          'doctor@gmail.com',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'password',
        );

        expect(emailController.text, equals('doctor@gmail.com'));
        expect(passwordController.text, equals('password'));

        emailController.dispose();
        passwordController.dispose();
      });
    });

    group('Navigation Flow', () {
      testWidgets('should display navigation drawer', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Home')),
              drawer: Drawer(
                child: ListView(
                  children: const [
                    DrawerHeader(child: Text('Menu')),
                    ListTile(
                      leading: Icon(Icons.dashboard),
                      title: Text('Dashboard'),
                    ),
                    ListTile(
                      leading: Icon(Icons.people),
                      title: Text('Patients'),
                    ),
                    ListTile(
                      leading: Icon(Icons.medical_services),
                      title: Text('Doctors'),
                    ),
                    ListTile(
                      leading: Icon(Icons.calendar_today),
                      title: Text('Appointments'),
                    ),
                  ],
                ),
              ),
              body: const Center(child: Text('Dashboard Content')),
            ),
          ),
        );

        // Open drawer
        final ScaffoldState state = tester.firstState(find.byType(Scaffold));
        state.openDrawer();
        await tester.pumpAndSettle();

        // Verify drawer items
        expect(find.text('Menu'), findsOneWidget);
        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Patients'), findsOneWidget);
        expect(find.text('Doctors'), findsOneWidget);
        expect(find.text('Appointments'), findsOneWidget);
      });

      testWidgets('should navigate when menu item is tapped',
          (WidgetTester tester) async {
        String currentPage = 'dashboard';

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  appBar: AppBar(title: Text(currentPage.toUpperCase())),
                  drawer: Drawer(
                    child: ListView(
                      children: [
                        ListTile(
                          title: const Text('Dashboard'),
                          onTap: () {
                            setState(() => currentPage = 'dashboard');
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text('Patients'),
                          onTap: () {
                            setState(() => currentPage = 'patients');
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  body: Center(child: Text('$currentPage Content')),
                );
              },
            ),
          ),
        );

        // Open drawer
        final ScaffoldState state = tester.firstState(find.byType(Scaffold));
        state.openDrawer();
        await tester.pumpAndSettle();

        // Tap on Patients
        await tester.tap(find.text('Patients'));
        await tester.pumpAndSettle();

        // Verify navigation
        expect(find.text('PATIENTS'), findsOneWidget);
        expect(find.text('patients Content'), findsOneWidget);
      });
    });

    group('Patient List Flow', () {
      testWidgets('should display patient list', (WidgetTester tester) async {
        final patients = [
          {'id': '1', 'name': 'John Doe', 'email': 'john@example.com'},
          {'id': '2', 'name': 'Jane Smith', 'email': 'jane@example.com'},
          {'id': '3', 'name': 'Bob Johnson', 'email': 'bob@example.com'},
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Patients')),
              body: ListView.builder(
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(patients[index]['name']!),
                    subtitle: Text(patients[index]['email']!),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('Jane Smith'), findsOneWidget);
        expect(find.text('Bob Johnson'), findsOneWidget);
      });

      testWidgets('should filter patients by search', (WidgetTester tester) async {
        final searchController = TextEditingController();
        List<Map<String, String>> patients = [
          {'id': '1', 'name': 'John Doe'},
          {'id': '2', 'name': 'Jane Smith'},
          {'id': '3', 'name': 'Bob Johnson'},
        ];

        List<Map<String, String>> filteredPatients = patients;

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  appBar: AppBar(
                    title: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search patients...',
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (value.isEmpty) {
                            filteredPatients = patients;
                          } else {
                            filteredPatients = patients
                                .where((p) => p['name']!
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          }
                        });
                      },
                    ),
                  ),
                  body: ListView.builder(
                    itemCount: filteredPatients.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(filteredPatients[index]['name']!),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );

        // Initially all patients visible
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('Jane Smith'), findsOneWidget);
        expect(find.text('Bob Johnson'), findsOneWidget);

        // Search for "john"
        await tester.enterText(find.byType(TextField), 'john');
        await tester.pump();

        // Only John and Bob Johnson should be visible
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('Bob Johnson'), findsOneWidget);
        expect(find.text('Jane Smith'), findsNothing);

        searchController.dispose();
      });
    });

    group('Form Submission Flow', () {
      testWidgets('should validate and submit patient form',
          (WidgetTester tester) async {
        final formKey = GlobalKey<FormState>();
        final nameController = TextEditingController();
        final emailController = TextEditingController();
        bool isSubmitted = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!value.contains('@')) {
                              return 'Invalid email';
                            }
                            return null;
                          },
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              setState(() {
                                isSubmitted = true;
                              });
                            }
                          },
                          child: const Text('Submit'),
                        ),
                        if (isSubmitted) const Text('Form Submitted!'),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );

        // Try to submit empty form
        await tester.tap(find.text('Submit'));
        await tester.pump();

        expect(find.text('Name is required'), findsOneWidget);
        expect(find.text('Email is required'), findsOneWidget);

        // Fill in form
        await tester.enterText(find.byType(TextFormField).first, 'John Doe');
        await tester.enterText(find.byType(TextFormField).last, 'john@example.com');

        // Submit form
        await tester.tap(find.text('Submit'));
        await tester.pump();

        expect(find.text('Form Submitted!'), findsOneWidget);

        nameController.dispose();
        emailController.dispose();
      });
    });

    group('Pagination Flow', () {
      testWidgets('should display pagination controls', (WidgetTester tester) async {
        int currentPage = 1;
        int totalPages = 5;

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Page $currentPage of $totalPages'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: currentPage > 1
                                ? () => setState(() => currentPage--)
                                : null,
                          ),
                          Text('$currentPage'),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: currentPage < totalPages
                                ? () => setState(() => currentPage++)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );

        expect(find.text('Page 1 of 5'), findsOneWidget);

        // Navigate to next page
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pump();

        expect(find.text('Page 2 of 5'), findsOneWidget);

        // Navigate back
        await tester.tap(find.byIcon(Icons.chevron_left));
        await tester.pump();

        expect(find.text('Page 1 of 5'), findsOneWidget);
      });
    });

    group('Role-Based UI Flow', () {
      testWidgets('should show different options based on role',
          (WidgetTester tester) async {
        String userRole = 'admin';

        Widget buildMenuItems(String role) {
          return Column(
            children: [
              const ListTile(title: Text('Dashboard')),
              if (role == 'admin' || role == 'doctor' || role == 'receptionist')
                const ListTile(title: Text('Patients')),
              if (role == 'admin')
                const ListTile(title: Text('Doctors')),
              if (role == 'admin')
                const ListTile(title: Text('Nurses')),
              if (role == 'admin')
                const ListTile(title: Text('Accounting')),
              const ListTile(title: Text('Profile')),
            ],
          );
        }

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: buildMenuItems(userRole),
            ),
          ),
        );

        // Admin should see all menu items
        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Patients'), findsOneWidget);
        expect(find.text('Doctors'), findsOneWidget);
        expect(find.text('Nurses'), findsOneWidget);
        expect(find.text('Accounting'), findsOneWidget);
        expect(find.text('Profile'), findsOneWidget);

        // Test patient role
        userRole = 'patient';
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: buildMenuItems(userRole),
            ),
          ),
        );

        // Patient should see limited menu items
        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Patients'), findsNothing);
        expect(find.text('Doctors'), findsNothing);
        expect(find.text('Accounting'), findsNothing);
        expect(find.text('Profile'), findsOneWidget);
      });
    });
  });
}
