import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/provider/patient_service.dart';
import 'package:ige_hospital/models/patient_model.dart';
import 'package:ige_hospital/widgets/common_title.dart';
import 'package:ige_hospital/static_data.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Import generic components
import 'package:ige_hospital/widgets/generic_pagination.dart';
import 'package:ige_hospital/widgets/generic_filters.dart';
import 'package:ige_hospital/widgets/generic_add_dialog.dart';
import 'package:ige_hospital/widgets/generic_edit_dialog.dart';
import 'package:ige_hospital/widgets/generic_detail_dialog.dart';
import 'package:ige_hospital/widgets/generic_data_table.dart';

class PatientsPageRefactored extends StatefulWidget {
  const PatientsPageRefactored({super.key});

  @override
  State<PatientsPageRefactored> createState() => _PatientsPageRefactoredState();
}

class _PatientsPageRefactoredState extends State<PatientsPageRefactored> {
  final AppConst controller = Get.put(AppConst());
  final PatientsService patientsService = Get.put(PatientsService());

  int currentPage = 0;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    patientsService.fetchPatients();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Define column definitions for the patients table
  List<ColumnDefinition<PatientModel>> getPatientColumns(
      ColourNotifier notifier) {
    return [
      ColumnDefinition<PatientModel>(
        title: "Name",
        valueGetter: (patient) => patient.user['full_name'] ?? 'N/A',
        flex: 2,
      ),
      ColumnDefinition<PatientModel>(
        title: "ID",
        valueGetter: (patient) => patient.patientUniqueId,
        flex: 1,
      ),
      ColumnDefinition<PatientModel>(
        title: "Email",
        valueGetter: (patient) => patient.user['email'] ?? 'N/A',
        flex: 2,
      ),
      ColumnDefinition<PatientModel>(
        title: "Phone",
        valueGetter: (patient) => patient.user['phone'] ?? 'N/A',
        flex: 2,
      ),
      ColumnDefinition<PatientModel>(
        title: "Gender",
        valueGetter: (patient) => patient.user['gender'] ?? 'N/A',
        flex: 1,
      ),
      ColumnDefinition<PatientModel>(
        title: "Blood Group",
        valueGetter: (patient) => patient.user['blood_group'] ?? 'N/A',
        flex: 1,
      ),
      ColumnDefinition<PatientModel>(
        title: "Status",
        valueGetter: (patient) => patient.user['status'] ?? 'N/A',
        flex: 1,
      ),
      ColumnDefinition<PatientModel>(
        title: "Profile",
        valueGetter: (patient) => _buildProfileImage(patient, notifier),
        flex: 1,
        isWidget: true,
      ),
    ];
  }

  // Define filter fields
  List<FilterField> getPatientFilters(ColourNotifier notifier) {
    return [
      FilterField(
        name: 'search',
        label: 'Search',
        isTextField: true,
        icon: Icons.search,
      ),
      FilterField(
        name: 'gender',
        label: 'Gender',
        isDropdown: true,
        items: [
          DropdownMenuItem(
            value: '',
            child: Text(
                'All Genders', style: TextStyle(color: notifier.getMainText)),
          ),
          DropdownMenuItem(
            value: 'male',
            child: Text('Male', style: TextStyle(color: notifier.getMainText)),
          ),
          DropdownMenuItem(
            value: 'female',
            child: Text(
                'Female', style: TextStyle(color: notifier.getMainText)),
          ),
        ],
        icon: Icons.people,
      ),
      FilterField(
        name: 'blood_group',
        label: 'Blood Group',
        isDropdown: true,
        items: [
          DropdownMenuItem(
            value: '',
            child: Text('All Blood Groups',
                style: TextStyle(color: notifier.getMainText)),
          ),
          DropdownMenuItem(
            value: 'A+',
            child: Text('A+', style: TextStyle(color: notifier.getMainText)),
          ),
          DropdownMenuItem(
            value: 'A-',
            child: Text('A-', style: TextStyle(color: notifier.getMainText)),
          ),
          DropdownMenuItem(
            value: 'B+',
            child: Text('B+', style: TextStyle(color: notifier.getMainText)),
          ),
          DropdownMenuItem(
            value: 'B-',
            child: Text('B-', style: TextStyle(color: notifier.getMainText)),
          ),
          DropdownMenuItem(
            value: 'AB+',
            child: Text('AB+', style: TextStyle(color: notifier.getMainText)),
          ),
          DropdownMenuItem(
            value: 'AB-',
            child: Text('AB-', style: TextStyle(color: notifier.getMainText)),
          ),
          DropdownMenuItem(
            value: 'O+',
            child: Text('O+', style: TextStyle(color: notifier.getMainText)),
          ),
          DropdownMenuItem(
            value: 'O-',
            child: Text('O-', style: TextStyle(color: notifier.getMainText)),
          ),
        ],
        icon: Icons.bloodtype,
      ),
      FilterField(
        name: 'date',
        label: 'Date Range',
        isDateRange: true,
        icon: Icons.calendar_today,
      ),
      FilterField(
        name: 'sort_direction',
        label: 'Sort By',
        isDropdown: true,
        items: [
          DropdownMenuItem(
            value: 'asc',
            child: Text(
                'Oldest First', style: TextStyle(color: notifier.getMainText)),
          ),
          DropdownMenuItem(
            value: 'desc',
            child: Text(
                'Newest First', style: TextStyle(color: notifier.getMainText)),
          ),
        ],
        icon: Icons.sort,
      ),
    ];
  }

  // Define add dialog fields
  List<DialogField> getPatientAddFields(ColourNotifier notifier) {
    return [
      DialogField(
        name: 'first_name',
        label: 'First Name',
        hintText: "Enter patient's first name",
        icon: Icons.person,
        isRequired: true,
      ),
      DialogField(
        name: 'last_name',
        label: 'Last Name',
        hintText: "Enter patient's last name",
        icon: Icons.person,
        isRequired: true,
      ),
      DialogField(
        name: 'email',
        label: 'Email',
        hintText: "Enter patient's email",
        icon: Icons.email,
        isRequired: true,
        isEmail: true,
      ),
      DialogField(
        name: 'phone',
        label: 'Phone',
        hintText: "Enter patient's phone number",
        icon: Icons.phone,
        isRequired: true,
        keyboardType: TextInputType.phone,
      ),
      DialogField(
        name: 'gender',
        label: 'Gender',
        hintText: "Select gender",
        icon: Icons.people,
        isRequired: true,
        isDropdown: true,
        items: [
          DropdownMenuItem(
            value: 'male',
            child: Text('Male', style: TextStyle(color: notifier.getMainText)),
          ),
          DropdownMenuItem(
            value: 'female',
            child: Text(
                'Female', style: TextStyle(color: notifier.getMainText)),
          ),
        ],
      ),
      DialogField(
        name: 'dob',
        label: 'Date of Birth',
        hintText: "Select date of birth",
        icon: Icons.calendar_today,
        isDate: true,
      ),
      DialogField(
        name: 'blood_group',
        label: 'Blood Group',
        hintText: "Select blood group",
        icon: Icons.bloodtype,
        isDropdown: true,
        items: [
          DropdownMenuItem(value: 'A+',
              child: Text('A+', style: TextStyle(color: notifier.getMainText))),
          DropdownMenuItem(value: 'A-',
              child: Text('A-', style: TextStyle(color: notifier.getMainText))),
          DropdownMenuItem(value: 'B+',
              child: Text('B+', style: TextStyle(color: notifier.getMainText))),
          DropdownMenuItem(value: 'B-',
              child: Text('B-', style: TextStyle(color: notifier.getMainText))),
          DropdownMenuItem(value: 'AB+',
              child: Text(
                  'AB+', style: TextStyle(color: notifier.getMainText))),
          DropdownMenuItem(value: 'AB-',
              child: Text(
                  'AB-', style: TextStyle(color: notifier.getMainText))),
          DropdownMenuItem(value: 'O+',
              child: Text('O+', style: TextStyle(color: notifier.getMainText))),
          DropdownMenuItem(value: 'O-',
              child: Text('O-', style: TextStyle(color: notifier.getMainText))),
        ],
      ),
      DialogField(
        name: 'address1',
        label: 'Address',
        hintText: "Enter patient's address",
        icon: Icons.location_on,
        maxLines: 2,
      ),
      DialogField(
        name: 'password',
        label: 'Password',
        hintText: "Enter password",
        icon: Icons.lock,
        isRequired: true,
        isPassword: true,
        obscureText: true,
      ),
      DialogField(
        name: 'password_confirmation',
        label: 'Confirm Password',
        hintText: "Confirm password",
        icon: Icons.lock_outline,
        isRequired: true,
        isPassword: true,
        obscureText: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          // Password match validation would be added here
          return null;
        },
      ),
    ];
  }

  // Get edit dialog fields for a specific patient
  List<EditField> getPatientEditFields(PatientModel patient,
      ColourNotifier notifier) {
    // Extract first and last name from full name if available
    String firstName = '';
    String lastName = '';

    if (patient.user['full_name'] != null) {
      List<String> nameParts = patient.user['full_name'].toString().split(' ');
      firstName = nameParts.isNotEmpty ? nameParts.first : '';
      lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    } else {
      firstName = patient.user['first_name'] ?? '';
      lastName = patient.user['last_name'] ?? '';
    }

    return [
      EditField(
        name: 'first_name',
        label: 'First Name',
        hintText: "Enter patient's first name",
        value: firstName,
        icon: Icons.person,
        isRequired: true,
      ),
      EditField(
        name: 'last_name',
        label: 'Last Name',
        hintText: "Enter patient's last name",
        value: lastName,
        icon: Icons.person,
        isRequired: true,
      ),
      EditField(
        name: 'email',
        label: 'Email',
        hintText: "Enter patient's email",
        value: patient.user['email'] ?? '',
        icon: Icons.email,
        isRequired: true,
        isEmail: true,
      ),
      EditField(
        name: 'phone',
        label: 'Phone',
        hintText: "Enter patient's phone number",
        value: patient.user['phone'] ?? '',
        icon: Icons.phone,
        isRequired: true,
        keyboardType: TextInputType.phone,
      ),
      EditField(
        name: 'gender',
        label: 'Gender',
        hintText: "Select gender",
        value: patient.user['gender'] ?? '',
        icon: Icons.people,
        isRequired: true,
        isDropdown: true,
        items: [
          DropdownMenuItem(
            value: 'male',
            child: Text('Male', style: TextStyle(color: notifier.getMainText)),
          ),
          DropdownMenuItem(
            value: 'female',
            child: Text(
                'Female', style: TextStyle(color: notifier.getMainText)),
          ),
        ],
      ),
      EditField(
        name: 'dob',
        label: 'Date of Birth',
        hintText: "Select date of birth",
        value: patient.user['dob'] ?? '',
        icon: Icons.calendar_today,
        isDate: true,
      ),
      EditField(
        name: 'blood_group',
        label: 'Blood Group',
        hintText: "Select blood group",
        value: patient.user['blood_group'] ?? '',
        icon: Icons.bloodtype,
        isDropdown: true,
        items: [
          DropdownMenuItem(value: 'A+',
              child: Text('A+', style: TextStyle(color: notifier.getMainText))),
          DropdownMenuItem(value: 'A-',
              child: Text('A-', style: TextStyle(color: notifier.getMainText))),
          DropdownMenuItem(value: 'B+',
              child: Text('B+', style: TextStyle(color: notifier.getMainText))),
          DropdownMenuItem(value: 'B-',
              child: Text('B-', style: TextStyle(color: notifier.getMainText))),
          DropdownMenuItem(value: 'AB+',
              child: Text(
                  'AB+', style: TextStyle(color: notifier.getMainText))),
          DropdownMenuItem(value: 'AB-',
              child: Text(
                  'AB-', style: TextStyle(color: notifier.getMainText))),
          DropdownMenuItem(value: 'O+',
              child: Text('O+', style: TextStyle(color: notifier.getMainText))),
          DropdownMenuItem(value: 'O-',
              child: Text('O-', style: TextStyle(color: notifier.getMainText))),
        ],
      ),
      EditField(
        name: 'address1',
        label: 'Address',
        hintText: "Enter patient's address",
        value: patient.address != null
            ? patient.address!['address1'] ?? ''
            : '',
        icon: Icons.location_on,
        maxLines: 2,
      ),
      EditField(
        name: 'status',
        label: 'Status',
        hintText: "Select status",
        value: patient.user['status'] ?? 'active',
        icon: Icons.check_circle,
        isDropdown: true,
        items: [
          DropdownMenuItem(
            value: 'active',
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Text('Active', style: TextStyle(color: notifier.getMainText)),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'pending',
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Text('Pending', style: TextStyle(color: notifier.getMainText)),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'blocked',
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Text('Blocked', style: TextStyle(color: notifier.getMainText)),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  // Define detail sections for a patient
  List<DetailSection> getPatientDetailSections(PatientModel patient) {
    // Format dates for display
    String createdAtFormatted = 'N/A';
    String updatedAtFormatted = 'N/A';
    String dobFormatted = 'N/A';

    try {
      if (patient.createdAt.isNotEmpty) {
        final createdDate = DateTime.parse(patient.createdAt);
        createdAtFormatted = DateFormat('MMM dd, yyyy').format(createdDate);
      }
      if (patient.updatedAt.isNotEmpty) {
        final updatedDate = DateTime.parse(patient.updatedAt);
        updatedAtFormatted = DateFormat('MMM dd, yyyy').format(updatedDate);
      }
      if (patient.user['dob'] != null && patient.user['dob']
          .toString()
          .isNotEmpty) {
        final dobDate = DateTime.parse(patient.user['dob']);
        dobFormatted = DateFormat('MMM dd, yyyy').format(dobDate);
      }
    } catch (e) {
      print("Error parsing dates: $e");
    }

    List<DetailSection> sections = [
      DetailSection(
        title: "Personal Information",
        fields: [
          DetailField(
            label: "Email",
            value: patient.user['email'] ?? 'N/A',
            icon: Icons.email,
          ),
          DetailField(
            label: "Phone",
            value: patient.user['phone'] ?? 'N/A',
            icon: Icons.phone,
          ),
          DetailField(
            label: "Gender",
            value: patient.user['gender'] ?? 'N/A',
            icon: Icons.people,
          ),
          DetailField(
            label: "Date of Birth",
            value: dobFormatted,
            icon: Icons.cake,
            isDate: true,
          ),
          DetailField(
            label: "Blood Group",
            value: patient.user['blood_group'] ?? 'N/A',
            icon: Icons.bloodtype,
          ),
          DetailField(
            label: "Status",
            value: patient.user['status'] ?? 'N/A',
            isBadge: true,
          ),
        ],
      ),
      DetailSection(
        title: "Medical Statistics",
        fields: [
          DetailField(
            label: "Appointments",
            value: "${patient.stats['appointments_count'] ?? '0'} total",
            icon: Icons.calendar_today,
          ),
          DetailField(
            label: "Documents",
            value: "${patient.stats['documents_count'] ?? '0'} total",
            icon: Icons.folder,
          ),
        ],
      ),
    ];

    // Add address section if available
    if (patient.address != null && patient.address!.isNotEmpty) {
      sections.add(
          DetailSection(
            title: "Address Information",
            fields: [
              DetailField(
                label: "Address",
                value: patient.address!['address1'] ?? 'N/A',
                icon: Icons.location_on,
              ),
              DetailField(
                label: "City",
                value: patient.address!['city'] ?? 'N/A',
                icon: Icons.location_city,
              ),
              DetailField(
                label: "State",
                value: patient.address!['state'] ?? 'N/A',
                icon: Icons.map,
              ),
              DetailField(
                label: "Country",
                value: patient.address!['country'] ?? 'N/A',
                icon: Icons.flag,
              ),
            ],
          )
      );
    }

    // Add system information section
    sections.add(
        DetailSection(
          title: "System Information",
          fields: [
            DetailField(
              label: "ID",
              value: patient.id,
              icon: Icons.badge,
            ),
            DetailField(
              label: "Patient ID",
              value: patient.patientUniqueId,
              icon: Icons.person_pin,
            ),
            DetailField(
              label: "Registration Date",
              value: createdAtFormatted,
              icon: Icons.event,
              isDate: true,
            ),
            DetailField(
              label: "Last Updated",
              value: updatedAtFormatted,
              icon: Icons.update,
              isDate: true,
            ),
          ],
        )
    );

    // Add recent appointments if available
    if (patient.appointments.isNotEmpty) {
      sections.add(
          DetailSection(
            title: "Recent Appointments",
            fields: [
              ...patient.appointments.take(3).map((appointment) {
                String dateTime = 'N/A';
                if (appointment['date'] != null &&
                    appointment['time'] != null) {
                  dateTime = "${appointment['date']} at ${appointment['time']}";
                }

                return DetailField(
                  label: appointment['doctor_name'] ?? 'Unknown Doctor',
                  value: dateTime,
                  icon: Icons.calendar_today,
                );
              }).toList(),
            ],
          )
      );
    }

    return sections;
  }

  // Helper methods
  Widget _buildProfileImage(PatientModel patient, ColourNotifier notifier) {
    final profileImage = patient.user['profile_image'];

    return profileImage != null && profileImage
        .toString()
        .isNotEmpty
        ? ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        profileImage,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Icon(
              Icons.person,
              size: 40,
              color: notifier.getIconColor,
            ),
      ),
    )
        : Icon(
      Icons.person,
      size: 40,
      color: notifier.getIconColor,
    );
  }
}

