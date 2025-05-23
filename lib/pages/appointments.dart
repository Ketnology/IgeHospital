import 'package:flutter/material.dart';
import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/models/appointment_model.dart';
import 'package:ige_hospital/static_data.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/provider/appointment_service.dart';
import 'package:provider/provider.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/common_title.dart';

import 'package:ige_hospital/widgets/appointment_components/appointment_filters.dart';
import 'package:ige_hospital/widgets/appointment_components/appointment_pagination.dart';
import 'package:ige_hospital/widgets/appointment_components/create_appointment_dialog.dart';
import 'package:ige_hospital/widgets/appointment_components/edit_appointment_dialog.dart';
import 'package:ige_hospital/widgets/appointment_components/appointment_detail_dialog.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final AppConst controller = Get.put(AppConst());
  ColourNotifier notifier = ColourNotifier();

  // Integrate the AppointmentsService
  final AppointmentsService appointmentsService =
      Get.put(AppointmentsService());

  late List<ExpandableColumn<dynamic>> headers;
  late List<ExpandableRow> rows;

  int currentPage = 0;
  final int pageSize = 10;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    createDataSource();

    // Fetch initial data
    appointmentsService.fetchAppointments();

    // Add listener to update data source when appointments change
    ever(appointmentsService.appointments, (_) {
      createDataSource();
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void createDataSource() {
    headers = [
      ExpandableColumn<String>(columnTitle: "Doctor Name", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Patient Name", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Appointment Date", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Appointment Time", columnFlex: 1),
      ExpandableColumn<String>(columnTitle: "Problem", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Status", columnFlex: 1),
      ExpandableColumn<Widget>(columnTitle: "Actions", columnFlex: 2),
    ];

    // Check if we have appointments to display
    if (appointmentsService.appointments.isEmpty) {
      rows = [];
      return;
    }

    // Map the appointments to expandable rows
    rows = appointmentsService.appointments.map<ExpandableRow>((appointment) {
      return ExpandableRow(cells: [
        ExpandableCell<String>(
            columnTitle: "Doctor Name", value: appointment.doctorName),
        ExpandableCell<String>(
            columnTitle: "Patient Name", value: appointment.patientName),
        ExpandableCell<String>(
            columnTitle: "Appointment Date",
            value: appointment.appointmentDate),
        ExpandableCell<String>(
            columnTitle: "Appointment Time",
            value: appointment.appointmentTime),
        ExpandableCell<String>(
            columnTitle: "Problem", value: appointment.problem),
        ExpandableCell<String>(
            columnTitle: "Status",
            value: appointment.isCompleted ? "Completed" : "Pending"),
        ExpandableCell<Widget>(
          columnTitle: "Actions",
          value: Row(
            children: [
              IconButton(
                icon: Icon(Icons.visibility, color: notifier.getIconColor),
                onPressed: () {
                  _showAppointmentDetail(appointment);
                },
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  _showEditDialog(appointment);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _showDeleteConfirmation(appointment);
                },
              ),
            ],
          ),
        ),
      ]);
    }).toList();
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
                    title: 'Appointments', path: "Hospital Operations"),
                _buildPageTopBar(),
                AppointmentFilters(
                  notifier: notifier,
                  appointmentsService: appointmentsService,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Obx(() {
                      if (appointmentsService.isLoading.value) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: notifier.getIconColor,
                          ),
                        );
                      }

                      if (appointmentsService.hasError.value) {
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
                                appointmentsService.errorMessage.value,
                                style: TextStyle(color: notifier.getMainText),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () =>
                                    appointmentsService.fetchAppointments(),
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

                      if (appointmentsService.appointments.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: notifier.getIconColor,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No appointments found",
                                style: TextStyle(
                                  color: notifier.getMainText,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Try adjusting your filters or create a new appointment",
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
                            // Find the corresponding appointment
                            int index = rows.indexOf(row);
                            if (index == -1 ||
                                index >=
                                    appointmentsService.appointments.length) {
                              return const SizedBox(); // Fallback
                            }

                            final appointment =
                                appointmentsService.appointments[index];

                            // Show appointment detail in a dialog
                            return InkWell(
                              onTap: () => _showAppointmentDetail(appointment),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                color:
                                    notifier.getPrimaryColor.withOpacity(0.05),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Appointment Details",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: notifier.getMainText,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Click to view complete details",
                                            style: TextStyle(
                                              color: notifier.getMaingey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: notifier.getIconColor,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          renderCustomPagination:
                              (totalPages, currentPage, onPageChanged) =>
                                  AppointmentPagination(
                            notifier: notifier,
                            appointmentsService: appointmentsService,
                            totalPages: totalPages,
                            currentPage: currentPage,
                            onPageChanged: onPageChanged,
                          ),
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

  Widget _buildPageTopBar() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  _showCreateDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appMainColor,
                  fixedSize: const Size.fromHeight(40),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      "assets/plus-circle.svg",
                      width: 18,
                      height: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Create New",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w200,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Dialog methods using our new components
  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateAppointmentDialog(
        notifier: notifier,
        appointmentsService: appointmentsService,
      ),
    );
  }

  void _showEditDialog(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => EditAppointmentDialog(
        appointment: appointment,
        notifier: notifier,
        appointmentsService: appointmentsService,
      ),
    );
  }

  void _showAppointmentDetail(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => AppointmentDetailDialog(
        appointment: appointment,
        notifier: notifier,
      ),
    ).then((result) {
      if (result == 'edit') {
        _showEditDialog(appointment);
      }
    });
  }

  void _showDeleteConfirmation(AppointmentModel appointment) {}
}
