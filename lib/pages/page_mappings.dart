import 'package:flutter/material.dart';
import 'package:ige_hospital/pages/accounting_page.dart';
import 'package:ige_hospital/pages/admin_page.dart';
import 'package:ige_hospital/pages/patients_page.dart';
import 'package:ige_hospital/pages/profile_page.dart';
import 'package:ige_hospital/pages/appointments.dart';
import 'package:ige_hospital/pages/home.dart';
import 'package:ige_hospital/pages/doctor_page.dart';
import 'package:ige_hospital/pages/nurse_page.dart';

final Map<String, Widget> pages = {
  '': const DefaultPage(),
  'overview': const DefaultPage(),
  'appointments': const AppointmentsPage(),
  'profile': const ProfilePage(),

  // Hospital Operations
  'patients': const PatientsPage(),
  'doctors': DoctorsPage(),
  'nurses': const NursesPage(),
  'admins': const AdminsPage(),

  // Medical Services
  // 'live-consultations': const LiveConsultationsPage(),

  // Accounting & Finance
  'accounting': const AccountingPage(),
};
