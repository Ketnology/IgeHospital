import 'package:flutter/material.dart';
import 'package:ige_hospital/pages/accounting_page.dart';
import 'package:ige_hospital/pages/admin_page.dart';
import 'package:ige_hospital/pages/live_consultations_page.dart';
import 'package:ige_hospital/pages/patients_page.dart';
import 'package:ige_hospital/pages/profile_page.dart';
import 'package:ige_hospital/pages/appointments.dart';
import 'package:ige_hospital/widgets/role_based_dashboard.dart'; // Updated import
import 'package:ige_hospital/pages/doctor_page.dart';
import 'package:ige_hospital/pages/nurse_page.dart';

final Map<String, Widget> pages = {
  '': const RoleBasedDashboard(), // Updated to use role-based dashboard
  'overview': const RoleBasedDashboard(), // Updated to use role-based dashboard
  'appointments': const AppointmentsPage(),
  'profile': const ProfilePage(),

  // Hospital Operations
  'patients': const PatientsPage(),
  'doctors': DoctorsPage(),
  'nurses': const NursesPage(),
  'admins': const AdminsPage(),

  // Medical Services
  'live-consultations': const LiveConsultationsPage(),

  // Accounting & Finance
  'accounting': const AccountingPage(),
};