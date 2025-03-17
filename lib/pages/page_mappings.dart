import 'package:flutter/material.dart';
import 'package:ige_hospital/pages/profile_page.dart';
import 'package:ige_hospital/pages/appointment.dart';
import 'package:ige_hospital/pages/appointments.dart';
import 'package:ige_hospital/pages/home.dart';
import 'package:ige_hospital/pages/in_patient.dart';

final Map<String, Widget> pages = {
  '': const DefaultPage(),
  'overview': const DefaultPage(),
  'appointment': const AppointmentPage(),
  'in-patient': const InPatientPage(),
  'appointments': const AppointmentsPage(),
  'profile': const ProfilePage(),
};
