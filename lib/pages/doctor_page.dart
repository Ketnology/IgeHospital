import 'package:flutter/material.dart';
import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/doctor_service.dart';
import 'package:ige_hospital/static_data.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/widgets/common_button.dart';
import 'package:ige_hospital/widgets/text_field.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/common_title.dart';
import 'dart:math';

class DoctorsPage extends StatefulWidget {
  const DoctorsPage({super.key});

  @override
  State<DoctorsPage> createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
  AppConst obj = AppConst();
  final AppConst controller = Get.put(AppConst());
  ColourNotifier notifier = ColourNotifier();

  // Initialize the DoctorsService
  final DoctorsService doctorsService = Get.put(DoctorsService());

  late List<ExpandableColumn<dynamic>> headers;
  late List<ExpandableRow> rows;

  int currentPage = 0;
  final int pageSize = 10;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController specialistController = TextEditingController();

  @override
  void initState() {
    super.initState();
    createDataSource();
    doctorsService.fetchDoctors();

    // Add listener to update data source when doctors change
    ever(doctorsService.doctors, (_) {
      createDataSource();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    departmentController.dispose();
    specialistController.dispose();
    super.dispose();
  }

  void createDataSource() {
    headers = [
      ExpandableColumn<String>(columnTitle: "Doctor Name", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Email", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Phone", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Gender", columnFlex: 1),
      ExpandableColumn<String>(columnTitle: "Department", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Specialist", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Status", columnFlex: 1),
      ExpandableColumn<Widget>(columnTitle: "Profile Image", columnFlex: 2),
      ExpandableColumn<Widget>(columnTitle: "Actions", columnFlex: 2),
    ];

    // Check if we have doctors to display
    if (doctorsService.doctors.isEmpty) {
      rows = [];
      return;
    }

    // Map the doctors to expandable rows
    rows = doctorsService.doctors.map<ExpandableRow>((doctor) {
      return ExpandableRow(cells: [
        ExpandableCell<String>(
            columnTitle: "Doctor Name",
            value: doctor.fullName),
        ExpandableCell<String>(
            columnTitle: "Email", value: doctor.email),
        ExpandableCell<String>(
            columnTitle: "Phone", value: doctor.phone),
        ExpandableCell<String>(
            columnTitle: "Gender", value: doctor.gender),
        ExpandableCell<String>(
            columnTitle: "Department", value: doctor.departmentName),
        ExpandableCell<String>(
            columnTitle: "Specialist", value: doctor.specialist),
        ExpandableCell<String>(
            columnTitle: "Status", value: doctor.status),
        ExpandableCell<Widget>(
          columnTitle: "Profile Image",
          value: doctor.profileImage.isNotEmpty
              ? ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              doctor.profileImage,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(
                Icons.person,
                size: 40,
              ),
            ),
          )
              : const Icon(Icons.person, size: 40),
        ),
        ExpandableCell<Widget>(
          columnTitle: "Actions",
          value: Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: notifier.getIconColor),
                onPressed: () {
                  // Open edit dialog
                  // _showEditDialog(doctor);
                },
              ),
              IconButton(
                icon: Icon(Icons.visibility, color: Colors.blue),
                onPressed: () {
                  // Show view doctor detail
                  // _showDoctorDetail(doctor);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  // Show delete confirmation
                  // _showDeleteConfirmation(doctor);
                },
              ),
            ],
          ),
        ),
      ]);
    }).toList();

    // Force UI update
    if (mounted) setState(() {});
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'blocked':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColourNotifier>(context, listen: true);

    return Scaffold(
      backgroundColor: notifier.getBgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            int visibleCount = 2;
            if (constraints.maxWidth < 600) {
              visibleCount = 2;
            } else if (constraints.maxWidth < 800) {
              visibleCount = 4;
            } else {
              visibleCount = 5;
            }

            return Column(
              children: [
                const CommonTitle(
                    title: 'Doctors', path: "Hospital Operations"),
                // _buildPageTopBar(),
                // _buildFilterSection(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Obx(() {
                      if (doctorsService.isLoading.value) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: notifier.getIconColor,
                          ),
                        );
                      }

                      if (doctorsService.hasError.value) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                doctorsService.errorMessage.value,
                                style: TextStyle(color: notifier.getMainText),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () =>
                                    doctorsService.fetchDoctors(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: notifier.getIconColor,
                                ),
                                child: const Text(
                                  "Retry",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (doctorsService.doctors.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.medical_services_outlined,
                                color: notifier.getIconColor,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No doctors found",
                                style: TextStyle(
                                  color: notifier.getMainText,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Try adjusting your filters or add a new doctor",
                                style: TextStyle(
                                  color: notifier.getMaingey,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return ExpandableTheme(
                        data: ExpandableThemeData(
                          context,
                          contentPadding: const EdgeInsets.all(15),
                          expandedBorderColor: notifier.getBorderColor,
                          paginationSize: 48,
                          headerHeight: 76,
                          headerColor: notifier.getPrimaryColor,
                          headerBorder: BorderSide(
                            color: notifier.getBgColor,
                            width: 8,
                          ),
                          evenRowColor: notifier.getContainer,
                          oddRowColor: notifier.getBgColor,
                          rowBorder: BorderSide(
                            color: notifier.getBorderColor,
                            width: 0.3,
                          ),
                          headerTextMaxLines: 4,
                          headerSortIconColor: notifier.getMainText,
                          headerTextStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: notifier.getMainText,
                          ),
                          rowTextStyle: TextStyle(
                            color: notifier.getMainText,
                          ),
                          expansionIcon: Icon(
                            Icons.keyboard_arrow_down,
                            color: notifier.getIconColor,
                          ),
                          editIcon: Icon(
                            Icons.edit,
                            color: notifier.getMainText,
                          ),
                        ),
                        child: ExpandableDataTable(
                          headers: headers,
                          rows: rows,
                          multipleExpansion: true,
                          isEditable: false,
                          visibleColumnCount: visibleCount,
                          pageSize: pageSize,
                          onPageChanged: (page) {
                            setState(() {
                              currentPage = page;
                            });
                          },
                          renderExpansionContent: (row) {
                            // Find the corresponding doctor
                            int index = rows.indexOf(row);
                            if (index == -1 ||
                                index >= doctorsService.doctors.length) {
                              return const SizedBox(); // Fallback
                            }

                            // Get the doctor data
                            final doctor = doctorsService.doctors[index];

                            return Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Doctor header with profile image and status
                                  Row(
                                    children: [
                                      // Profile image
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.grey.shade200,
                                        child: doctor.profileImage.isNotEmpty
                                            ? ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(30),
                                          child: Image.network(
                                            doctor.profileImage,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error,
                                                stackTrace) =>
                                                Icon(
                                                  Icons.person,
                                                  size: 30,
                                                  color:
                                                  notifier.getIconColor,
                                                ),
                                          ),
                                        )
                                            : Icon(
                                          Icons.person,
                                          size: 30,
                                          color: notifier.getIconColor,
                                        ),
                                      ),

                                      const SizedBox(width: 15),

                                      // Doctor name and ID
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              doctor.fullName,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: notifier.getMainText,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              "Doctor ID: ${doctor.id}",
                                              style: TextStyle(
                                                color: notifier.getMaingey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Status badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(doctor.status),
                                          borderRadius:
                                          BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          doctor.status.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const Divider(height: 30),

                                  // Doctor details in a grid layout
                                  Wrap(
                                    spacing: 30,
                                    runSpacing: 15,
                                    children: [
                                      // _detailItem(
                                      //     "Email",
                                      //     doctor.email,
                                      //     Icons.email),
                                      // _detailItem(
                                      //     "Phone",
                                      //     doctor.phone,
                                      //     Icons.phone),
                                      // _detailItem(
                                      //     "Gender",
                                      //     doctor.gender,
                                      //     Icons.person),
                                      // _detailItem(
                                      //     "Department",
                                      //     doctor.departmentName,
                                      //     Icons.business),
                                      // _detailItem(
                                      //     "Specialist",
                                      //     doctor.specialist,
                                      //     Icons.local_hospital),
                                      // _detailItem(
                                      //     "Qualification",
                                      //     doctor.qualification,
                                      //     Icons.school),
                                      // _detailItem(
                                      //     "Created At",
                                      //     doctor.createdAt,
                                      //     Icons.calendar_today),
                                      // _detailItem(
                                      //     "Updated At",
                                      //     doctor.updatedAt,
                                      //     Icons.update),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  // Doctor description
                                  Text(
                                    "Description",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: notifier.getMainText,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    doctor.description,
                                    style: TextStyle(
                                      color: notifier.getMainText,
                                      fontSize: 14,
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // Action buttons at the bottom
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          // Navigate to detailed doctor view or open in a new tab
                                          // _showDoctorDetail(doctor);
                                        },
                                        icon: const Icon(Icons.visibility,
                                            size: 16),
                                        label: const Text("View Details"),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                          notifier.getIconColor,
                                          side: BorderSide(
                                              color: notifier.getIconColor),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          // Show edit dialog
                                          // _showEditDialog(doctor);
                                        },
                                        icon: const Icon(Icons.edit, size: 16),
                                        label: const Text("Edit"),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.blue,
                                          side: const BorderSide(
                                              color: Colors.blue),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          // Show delete confirmation
                                          // _showDeleteConfirmation(doctor);
                                        },
                                        icon: const Icon(Icons.delete,
                                            size: 16),
                                        label: const Text("Delete"),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: const BorderSide(
                                              color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                          renderCustomPagination:
                              (totalPages, currentPage, onPageChanged) =>
                              _buildCustomPagination(
                                  totalPages, currentPage, onPageChanged),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomPagination(
      int totalPages, int currentPage, void Function(int) onPageChanged) {
    return Obx(
          () {
        final calculatedTotalPages = (doctorsService.totalDoctors.value /
            doctorsService.perPage.value)
            .ceil();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // First page button
              IconButton(
                icon: Icon(Icons.first_page,
                    color:
                    currentPage == 0 ? Colors.grey : notifier.getMainText),
                onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
              ),

              // Previous page button
              IconButton(
                icon: Icon(Icons.chevron_left,
                    color:
                    currentPage > 0 ? notifier.getMainText : Colors.grey),
                onPressed: currentPage > 0
                    ? () => onPageChanged(currentPage - 1)
                    : null,
              ),

              // Page counter
              Text(
                "Page ${currentPage + 1} of $totalPages",
                style: TextStyle(fontSize: 14, color: notifier.getMainText),
              ),

              // Next page button
              IconButton(
                icon: Icon(Icons.chevron_right,
                    color: currentPage < calculatedTotalPages - 1
                        ? notifier.getMainText
                        : Colors.grey),
                onPressed: currentPage < totalPages - 1
                    ? () => onPageChanged(currentPage + 1)
                    : null,
              ),

              // Last page button
              IconButton(
                icon: Icon(Icons.last_page,
                    color: currentPage < calculatedTotalPages - 1
                        ? notifier.getMainText
                        : Colors.grey),
                onPressed: currentPage < calculatedTotalPages - 1
                    ? () => onPageChanged(calculatedTotalPages - 1)
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}