import 'package:flutter/material.dart';
import 'package:ige_hospital/pages/admin_page.dart';
import 'package:ige_hospital/pages/patients_page.dart';
import 'package:ige_hospital/pages/profile_page.dart';
import 'package:ige_hospital/pages/appointments.dart';
import 'package:ige_hospital/pages/home.dart';
import 'package:ige_hospital/pages/in_patient.dart';
import 'package:ige_hospital/pages/doctor_page.dart';
import 'package:ige_hospital/pages/nurse_page.dart';

final Map<String, Widget> pages = {
  '': const DefaultPage(),
  'overview': const DefaultPage(),
  'in-patient': const InPatientPage(),
  'appointments': const AppointmentsPage(),
  'profile': const ProfilePage(),
  'patients': const PatientsPage(),
  'doctors': const DoctorsPage(),
  'nurses': const NursesPage(),
  'admins': const AdminsPage(),
};
