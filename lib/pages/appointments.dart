import 'package:flutter/material.dart';
import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/static_data.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/provider/appointments_service.dart';
import 'package:ige_hospital/widgets/common_button.dart';
import 'package:ige_hospital/widgets/text_field.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/common_title.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  AppConst obj = AppConst();
  final AppConst controller = Get.put(AppConst());
  ColourNotifier notifier = ColourNotifier();

  // Integrate the AppointmentsService
  final AppointmentsService appointmentsService =
      Get.put(AppointmentsService());

  late List<ExpandableColumn<dynamic>> headers;
  late List<ExpandableRow> rows;

  int currentPage = 0;
  final int pageSize = 3;

  final TextEditingController searchController = TextEditingController();
  final DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    createDataSource();

    // Add listener to update data source when appointments change
    ever(appointmentsService.appointments, (_) {
      createDataSource();
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
      ExpandableColumn<String>(columnTitle: "Appointment Time", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Problem", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "ID", columnFlex: 1),
      ExpandableColumn<String>(columnTitle: "Patient ID", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Doctor ID", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Department ID", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "OPD Date", columnFlex: 2),
      ExpandableColumn<bool>(columnTitle: "Completed", columnFlex: 1),
      ExpandableColumn<String>(columnTitle: "Custom Field", columnFlex: 1),
      ExpandableColumn<String>(columnTitle: "Doctor Department", columnFlex: 2),
      ExpandableColumn<Widget>(columnTitle: "Patient Image", columnFlex: 2),
      ExpandableColumn<Widget>(columnTitle: "Doctor Image", columnFlex: 2),
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
        ExpandableCell<String>(columnTitle: "ID", value: appointment.id),
        ExpandableCell<String>(
            columnTitle: "Patient ID", value: appointment.patientId),
        ExpandableCell<String>(
            columnTitle: "Doctor ID", value: appointment.doctorId),
        ExpandableCell<String>(
            columnTitle: "Department ID", value: appointment.departmentId),
        ExpandableCell<String>(
            columnTitle: "OPD Date", value: appointment.opdDate),
        ExpandableCell<bool>(
            columnTitle: "Completed", value: appointment.isCompleted),
        ExpandableCell<String>(
            columnTitle: "Custom Field", value: appointment.customField),
        ExpandableCell<String>(
            columnTitle: "Doctor Department",
            value: appointment.doctorDepartment),
        ExpandableCell<Widget>(
          columnTitle: "Patient Image",
          value: appointment.patientImage != null
              ? Image.network(
                  appointment.patientImage!,
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.person,
                    size: 40,
                  ),
                )
              : const Icon(Icons.person, size: 40),
        ),
        ExpandableCell<Widget>(
          columnTitle: "Doctor Image",
          value: appointment.doctorImage != null
              ? (appointment.doctorImage!.contains('http')
                  ? Image.network(
                      appointment.doctorImage!,
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        size: 40,
                      ),
                    )
                  : SvgPicture.asset(
                      appointment.doctorImage!,
                      width: 40,
                      height: 40,
                    ))
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
                  // _showEditDialog(appointment);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  // Show delete confirmation
                  _showDeleteConfirmation(appointment);
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
                _buildFilterSection(),
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
                          pageSize: appointmentsService.perPage.value,
                          onPageChanged: (page) {
                            setState(() {
                              currentPage = page;
                            });
                          },
                          renderEditDialog: (row, onSuccess) =>
                              _buildEditDialog(row, onSuccess),
                          renderExpansionContent: (row) =>
                              _buildExpandedContent(row, visibleCount),
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

  Widget _buildFilterSection() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Card(
          color: notifier.getContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: notifier.getBorderColor),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Filters",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: notifier.getMainText,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        appointmentsService.resetFilters();
                      },
                      icon: Icon(Icons.refresh,
                          size: 16, color: notifier.getIconColor),
                      label: Text(
                        "Reset Filters",
                        style: TextStyle(color: notifier.getIconColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () async {
                          final DateTimeRange? picked =
                              await showDateRangePicker(
                            context: context,
                            initialDateRange: DateTimeRange(
                              start: DateTime.now()
                                  .subtract(const Duration(days: 30)),
                              end: DateTime.now(),
                            ),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: notifier.getIconColor,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (picked != null) {
                            appointmentsService.dateFrom.value =
                                DateFormat('yyyy-MM-dd').format(picked.start);
                            appointmentsService.dateTo.value =
                                DateFormat('yyyy-MM-dd').format(picked.end);
                            appointmentsService.fetchAppointments();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: notifier.getBorderColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 16, color: notifier.getIconColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  appointmentsService
                                              .dateFrom.value.isNotEmpty &&
                                          appointmentsService
                                              .dateTo.value.isNotEmpty
                                      ? "${appointmentsService.dateFrom.value} to ${appointmentsService.dateTo.value}"
                                      : "Select Date Range",
                                  style: TextStyle(color: notifier.getMainText),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: notifier.getBorderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: notifier.getBorderColor),
                          ),
                        ),
                        value: appointmentsService.sortDirection.value,
                        dropdownColor: notifier.getContainer,
                        style: TextStyle(color: notifier.getMainText),
                        items: [
                          DropdownMenuItem(
                            value: 'asc',
                            child: Text('Oldest First',
                                style: TextStyle(color: notifier.getMainText)),
                          ),
                          DropdownMenuItem(
                            value: 'desc',
                            child: Text('Newest First',
                                style: TextStyle(color: notifier.getMainText)),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            appointmentsService.sortDirection.value = value;
                            appointmentsService.fetchAppointments();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<bool>(
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: notifier.getBorderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: notifier.getBorderColor),
                          ),
                        ),
                        value: appointmentsService.filterCompleted.value,
                        dropdownColor: notifier.getContainer,
                        style: TextStyle(color: notifier.getMainText),
                        items: [
                          DropdownMenuItem(
                            value: false,
                            child: Text('All Status',
                                style: TextStyle(color: notifier.getMainText)),
                          ),
                          DropdownMenuItem(
                            value: true,
                            child: Text('Completed',
                                style: TextStyle(color: notifier.getMainText)),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            appointmentsService.filterCompleted.value = value;
                            appointmentsService.fetchAppointments();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageTopBar() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          bool isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
          bool isDesktop = constraints.maxWidth >= 1024;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: isMobile
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: isDesktop ? 3 : 2, // More space for desktop
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        controller: searchController,
                        style: mediumBlackTextStyle.copyWith(
                          color: notifier.getMainText,
                        ),
                        onSubmitted: (value) {
                          appointmentsService.searchQuery.value = value;
                          appointmentsService.fetchAppointments();
                        },
                        decoration: InputDecoration(
                          hintText: "Search by name, ID or problem...",
                          isDense: true,
                          suffixIcon: IconButton(
                            icon: SvgPicture.asset(
                              "assets/search.svg",
                              height: 20,
                              width: 20,
                              color: appGreyColor,
                            ),
                            onPressed: () {
                              appointmentsService.searchQuery.value =
                                  searchController.text;
                              appointmentsService.fetchAppointments();
                            },
                          ),
                          hintStyle: mediumGreyTextStyle,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  if (!isMobile) const SizedBox(width: 20),
                  Expanded(
                    flex: isDesktop ? 1 : (isTablet ? 2 : 3),
                    child: ElevatedButton(
                      onPressed: () {
                        _showCreateDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appMainColor,
                        fixedSize: const Size.fromHeight(40),
                        elevation: 0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            "assets/plus-circle.svg",
                            color: Colors.white,
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
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCreateDialog() {
    final doctorNameController = TextEditingController();
    final patientNameController = TextEditingController();
    final problemController = TextEditingController();
    String priority = "Medium";
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        backgroundColor: notifier.getContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: StatefulBuilder(builder: (context, setState) {
          return Container(
            width: 500,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: notifier.getContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "Create New Appointment",
                  style: TextStyle(
                    color: notifier.getMainText,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 15),
                MyTextField(
                  title: 'Doctor Name',
                  hinttext: "Enter Doctor's Name",
                  controller: doctorNameController,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  title: 'Patient Name',
                  hinttext: "Enter Patient's Name",
                  controller: patientNameController,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );

                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: MyTextField(
                            title: 'Date',
                            hinttext:
                                DateFormat('MMM dd, yyyy').format(selectedDate),
                            controller: TextEditingController(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );

                          if (pickedTime != null) {
                            setState(() {
                              selectedTime = pickedTime;
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: MyTextField(
                            title: 'Time',
                            hinttext: selectedTime.format(context),
                            controller: TextEditingController(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                MyTextField(
                  title: 'Problem',
                  hinttext: "Describe the Problem",
                  controller: problemController,
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Priority",
                      style: mediumBlackTextStyle.copyWith(
                        color: notifier.getMainText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: priority,
                      decoration: InputDecoration(
                        labelText: "Priority",
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: notifier.getMainText,
                        ),
                        filled: true,
                        fillColor: notifier.getContainer,
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey.withOpacity(0.3)),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: notifier.getIconColor,
                            width: 1.5,
                          ),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                      ),
                      dropdownColor: notifier.getContainer,
                      items: [
                        DropdownMenuItem(
                          value: "High",
                          child: Row(
                            children: [
                              Icon(Icons.priority_high,
                                  color: Colors.red, size: 18),
                              SizedBox(width: 10),
                              Text("High",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 14)),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Medium",
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: Colors.orange, size: 18),
                              SizedBox(width: 10),
                              Text("Medium",
                                  style: TextStyle(
                                      color: Colors.orange, fontSize: 14)),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Low",
                          child: Row(
                            children: [
                              Icon(Icons.low_priority,
                                  color: Colors.green, size: 18),
                              SizedBox(width: 10),
                              Text("Low",
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            priority = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CommonButton(
                      title: "Cancel",
                      color: const Color(0xfff73164),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 10),
                    CommonButton(
                      title: "Create",
                      color: appMainColor,
                      onTap: () {
                        if (doctorNameController.text.isEmpty ||
                            patientNameController.text.isEmpty ||
                            problemController.text.isEmpty) {
                          Get.snackbar(
                            "Error",
                            "Please fill all required fields",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        final appointmentData = {
                          "doctor_name": doctorNameController.text,
                          "patient_name": patientNameController.text,
                          "problem": problemController.text,
                          "opd_date": DateFormat("yyyy-MM-dd HH:mm:ss").format(
                            DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            ),
                          ),
                          "custom_field": priority,
                        };

                        appointmentsService.createAppointment(appointmentData);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showEditDialog(AppointmentModel appointment) {
    final doctorNameController =
        TextEditingController(text: appointment.doctorName);
    final patientNameController =
        TextEditingController(text: appointment.patientName);
    final problemController = TextEditingController(text: appointment.problem);
    String priority = appointment.customField;

    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    if (appointment.opdDate.isNotEmpty) {
      try {
        DateTime parsedDate = DateTime.parse(appointment.opdDate);
        selectedDate = parsedDate;
        selectedTime = TimeOfDay.fromDateTime(parsedDate);
      } catch (e) {
        print("Error parsing date: ${appointment.opdDate} - $e");
        selectedDate = DateTime.now();
        selectedTime = TimeOfDay.now();
      }
    } else {
      selectedDate = DateTime.now();
      selectedTime = TimeOfDay.now();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        backgroundColor: notifier.getContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: StatefulBuilder(builder: (context, setState) {
          return Container(
            width: 500,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: notifier.getContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "Edit Appointment",
                  style: TextStyle(
                    color: notifier.getMainText,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 15),
                MyTextField(
                  title: 'Doctor Name',
                  hinttext: "Enter Doctor's Name",
                  controller: doctorNameController,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  title: 'Patient Name',
                  hinttext: "Enter Patient's Name",
                  controller: patientNameController,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate!,
                            firstDate: DateTime(2010),
                            lastDate: DateTime(2030),
                          );

                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: MyTextField(
                            title: 'Date',
                            hinttext: selectedDate != null
                                ? DateFormat('MMM dd, yyyy')
                                    .format(selectedDate!)
                                : "Pick a date",
                            controller: TextEditingController(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: selectedTime ?? TimeOfDay.now(),
                          );

                          if (pickedTime != null) {
                            setState(() {
                              selectedTime = pickedTime;
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: MyTextField(
                            title: 'Time',
                            hinttext: selectedTime != null
                                ? selectedTime!.format(context)
                                : "Pick a time",
                            controller: TextEditingController(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                MyTextField(
                  title: 'Problem',
                  hinttext: "Describe the Problem",
                  controller: problemController,
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Priority",
                      style: mediumBlackTextStyle.copyWith(
                        color: notifier.getMainText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: priority,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: notifier.getContainer,
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey.withOpacity(0.3)),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: notifier.getIconColor,
                            width: 1.5,
                          ),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                      ),
                      dropdownColor: notifier.getContainer,
                      items: [
                        DropdownMenuItem(
                          value: "High",
                          child: Row(
                            children: [
                              Icon(Icons.priority_high,
                                  color: Colors.red, size: 18),
                              SizedBox(width: 10),
                              Text("High",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 14)),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Medium",
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: Colors.orange, size: 18),
                              SizedBox(width: 10),
                              Text("Medium",
                                  style: TextStyle(
                                      color: Colors.orange, fontSize: 14)),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Low",
                          child: Row(
                            children: [
                              Icon(Icons.low_priority,
                                  color: Colors.green, size: 18),
                              SizedBox(width: 10),
                              Text("Low",
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            priority = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: appointment.isCompleted,
                      activeColor: notifier.getIconColor,
                      onChanged: (value) {
                        // In a real app, update the isCompleted status
                      },
                    ),
                    Text(
                      "Mark as Completed",
                      style: TextStyle(color: notifier.getMainText),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CommonButton(
                      title: "Cancel",
                      color: const Color(0xfff73164),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 10),
                    CommonButton(
                      title: "Save Changes",
                      color: appMainColor,
                      onTap: () {
                        if (doctorNameController.text.isEmpty ||
                            patientNameController.text.isEmpty ||
                            problemController.text.isEmpty) {
                          Get.snackbar(
                            "Error",
                            "Please fill all required fields",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        final appointmentData = {
                          "doctor_name": doctorNameController.text,
                          "patient_name": patientNameController.text,
                          "problem": problemController.text,
                          "opd_date": DateFormat("yyyy-MM-dd HH:mm:ss").format(
                            DateTime(
                              selectedDate!.year,
                              selectedDate!.month,
                              selectedDate!.day,
                              selectedTime!.hour,
                              selectedTime!.minute,
                            ),
                          ),
                          "custom_field": priority,
                        };

                        appointmentsService.updateAppointment(
                            appointment.id, appointmentData);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showDeleteConfirmation(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: notifier.getContainer,
        title: Text(
          "Confirm Delete",
          style: TextStyle(color: notifier.getMainText),
        ),
        content: Text(
          "Are you sure you want to delete this appointment for ${appointment.patientName} with ${appointment.doctorName}?",
          style: TextStyle(color: notifier.getMainText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: notifier.getMainText),
            ),
          ),
          TextButton(
            onPressed: () {
              appointmentsService.deleteAppointment(appointment.id);
              Navigator.pop(context);
            },
            child: Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditDialog(
      ExpandableRow row, void Function(ExpandableRow) onSuccess) {
    // Find the corresponding appointment
    int index = rows.indexOf(row);
    if (index == -1 || index >= appointmentsService.appointments.length) {
      return const SizedBox(); // Fallback
    }

    // Get the appointment data
    final appointment = appointmentsService.appointments[index];

    // Show the edit dialog
    // _showEditDialog(appointment);

    // Return an empty container since we're handling the dialog separately
    return Container();
  }

  Widget _buildExpandedContent(ExpandableRow row, int visibleCount) {
    // Find the corresponding appointment
    int index = rows.indexOf(row);
    if (index == -1 || index >= appointmentsService.appointments.length) {
      return const SizedBox(); // Fallback
    }

    // Get the appointment data
    final appointment = appointmentsService.appointments[index];

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 60,
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                // Doctor image
                if (appointment.doctorImage != null)
                  Positioned(
                    left: 0,
                    child: appointment.doctorImage!.contains("http")
                        ? Image.network(
                            appointment.doctorImage!,
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.person, size: 50),
                          )
                        : SvgPicture.asset(
                            appointment.doctorImage!,
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                  )
                else
                  const Positioned(
                    left: 0,
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                  ),

                // Patient image
                if (appointment.patientImage != null)
                  Positioned(
                    left: 40,
                    child: Image.network(
                      appointment.patientImage!,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.person, size: 50),
                    ),
                  )
                else
                  const Positioned(
                    left: 40,
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Display appointment details
          _buildDetailRow("ID", appointment.id),
          _buildDetailRow("Doctor", appointment.doctorName),
          _buildDetailRow("Patient", appointment.patientName),
          _buildDetailRow("Department", appointment.doctorDepartment),
          _buildDetailRow("Date", appointment.appointmentDate),
          _buildDetailRow("Time", appointment.appointmentTime),
          _buildDetailRow("Problem", appointment.problem),
          _buildDetailRow(
              "Status", appointment.isCompleted ? "Completed" : "Pending"),
          _buildDetailRow("Priority", appointment.customField),
          _buildDetailRow("Created", appointment.createdAt),
          _buildDetailRow("Updated", appointment.updatedAt),

          const SizedBox(height: 10),

          // Action buttons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  // _showEditDialog(appointment);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _showDeleteConfirmation(appointment);
                },
              ),
              IconButton(
                icon: Icon(
                  appointment.isCompleted
                      ? Icons.check_circle
                      : Icons.pending_actions,
                  color: appointment.isCompleted ? Colors.green : Colors.orange,
                ),
                onPressed: () {
                  // In a real app, toggle the completed status
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: notifier.getMainText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: notifier.getMainText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomPagination(
      int totalPages, int currentPage, void Function(int) onPageChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, color: notifier.getMainText),
          onPressed:
              currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
        ),
        Text(
          "Page ${currentPage + 1} of $totalPages",
          style: TextStyle(fontSize: 14, color: notifier.getMainText),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right, color: notifier.getMainText),
          onPressed: currentPage < totalPages - 1
              ? () => onPageChanged(currentPage + 1)
              : null,
        ),
      ],
    );
  }
}
