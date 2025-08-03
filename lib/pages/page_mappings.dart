import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/pages/accounting_page.dart';
import 'package:ige_hospital/pages/admin_page.dart';
import 'package:ige_hospital/pages/live_consultations_page.dart';
import 'package:ige_hospital/pages/patients_page.dart';
import 'package:ige_hospital/pages/profile_page.dart';
import 'package:ige_hospital/pages/vital_signs_page.dart';
import 'package:ige_hospital/pages/appointments.dart';
import 'package:ige_hospital/widgets/role_based_dashboard.dart';
import 'package:ige_hospital/pages/doctor_page.dart';
import 'package:ige_hospital/pages/nurse_page.dart';
import 'package:ige_hospital/static_data.dart';

final Map<String, Widget> pages = {
  '': const RoleBasedDashboard(),
  'overview': const RoleBasedDashboard(),
  'appointments': const AppointmentsPage(),
  'profile': const ProfilePage(),

  // Hospital Operations
  'patients': const PatientsPage(),
  'doctors': DoctorsPage(),
  'nurses': const NursesPage(),
  'admins': const AdminsPage(),

  // Medical Services
  'live-consultations': const LiveConsultationsPage(),

  // Vital Signs - uses data from AppConst
  'vital-signs': Builder(
    builder: (context) {
      final appConst = Get.find<AppConst>();
      return VitalSignsPage(
        patientId: appConst.selectedPatientId,
        patientName: appConst.selectedPatientName,
      );
    },
  ),

  // Accounting & Finance
  'accounting': const AccountingPage(),
};
