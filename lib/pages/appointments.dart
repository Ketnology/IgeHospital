import 'package:flutter/material.dart';
import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/static_data.dart';
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

  late List<ExpandableColumn<dynamic>> headers;
  late List<ExpandableRow> rows;
  int currentPage = 0;
  final int pageSize = 3;

  final List<Map<String, dynamic>> recentAppointments = [
    {
      "id": 1,
      "patient_id": 101,
      "doctor_id": 201,
      "department_id": 301,
      "opd_date": "2025-02-20 10:30 AM",
      "problem": "Routine checkup",
      "is_completed": 0,
      "custom_field": {"priority": "High"},
      "doctor_name": "Dr. James Smith",
      "patient_name": "Emily Johnson",
      "appointment_date": "20 Feb, 2025",
      "appointment_time": "10:30 AM",
      "doctor_department": "Cardiology",
      "patient_image": "https://example.com/emily_johnson.jpg",
      "doctor": "Dr. James Smith",
      "patient": "Emily Johnson",
      "date": "20/02/2025",
      "time": "10:30 AM",
      "doctor_image": "assets/icons8-figma.svg",
    },
    {
      "id": 2,
      "patient_id": 102,
      "doctor_id": 202,
      "department_id": 302,
      "opd_date": "2025-02-21 2:15 PM",
      "problem": "Back pain",
      "is_completed": 1,
      "custom_field": {"priority": "Medium"},
      "doctor_name": "Dr. Sarah Williams",
      "patient_name": "Michael Brown",
      "appointment_date": "21 Feb, 2025",
      "appointment_time": "2:15 PM",
      "doctor_department": "Orthopedics",
      "patient_image": "https://example.com/michael_brown.jpg",
      "doctor": "Dr. Sarah Williams",
      "patient": "Michael Brown",
      "date": "21/02/2025",
      "time": "2:15 PM",
      "doctor_image": "assets/icons8-adobe-creative-cloud.svg",
    },
    {
      "id": 3,
      "patient_id": 103,
      "doctor_id": 203,
      "department_id": 303,
      "opd_date": "2025-02-22 9:00 AM",
      "problem": "Flu symptoms",
      "is_completed": 0,
      "custom_field": {"priority": "Low"},
      "doctor_name": "Dr. David Martinez",
      "patient_name": "Sophia Davis",
      "appointment_date": "22 Feb, 2025",
      "appointment_time": "9:00 AM",
      "doctor_department": "General Medicine",
      "patient_image": "https://example.com/sophia_davis.jpg",
      "doctor": "Dr. David Martinez",
      "patient": "Sophia Davis",
      "date": "22/02/2025",
      "time": "9:00 AM",
      "doctor_image": "assets/icons8-starbucks.svg",
    },
    {
      "id": 4,
      "patient_id": 104,
      "doctor_id": 204,
      "department_id": 304,
      "opd_date": "2025-02-23 11:45 AM",
      "problem": "Skin allergy",
      "is_completed": 1,
      "custom_field": {"priority": "High"},
      "doctor_name": "Dr. Olivia Taylor",
      "patient_name": "James Wilson",
      "appointment_date": "23 Feb, 2025",
      "appointment_time": "11:45 AM",
      "doctor_department": "Dermatology",
      "patient_image": "https://example.com/james_wilson.jpg",
      "doctor": "Dr. Olivia Taylor",
      "patient": "James Wilson",
      "date": "23/02/2025",
      "time": "11:45 AM",
      "doctor_image": "assets/icons8-apple-logo.svg",
    },
    {
      "id": 5,
      "patient_id": 105,
      "doctor_id": 205,
      "department_id": 305,
      "opd_date": "2025-02-24 4:30 PM",
      "problem": "Follow-up consultation",
      "is_completed": 0,
      "custom_field": {"priority": "Medium"},
      "doctor_name": "Dr. William Anderson",
      "patient_name": "Isabella Thomas",
      "appointment_date": "24 Feb, 2025",
      "appointment_time": "4:30 PM",
      "doctor_department": "Internal Medicine",
      "patient_image": "https://example.com/isabella_thomas.jpg",
      "doctor": "Dr. William Anderson",
      "patient": "Isabella Thomas",
      "date": "24/02/2025",
      "time": "4:30 PM",
      "doctor_image": "assets/icons8-facebook29.svg",
    },
  ];

  @override
  void initState() {
    super.initState();
    createDataSource();
  }

  void createDataSource() {
    headers = [
      ExpandableColumn<String>(columnTitle: "Doctor Name", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Patient Name", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Appointment Date", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Appointment Time", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Problem", columnFlex: 2),
      ExpandableColumn<int>(columnTitle: "ID", columnFlex: 1),
      ExpandableColumn<int>(columnTitle: "Patient ID", columnFlex: 2),
      ExpandableColumn<int>(columnTitle: "Doctor ID", columnFlex: 2),
      ExpandableColumn<int>(columnTitle: "Department ID", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "OPD Date", columnFlex: 2),
      ExpandableColumn<int>(columnTitle: "Completed", columnFlex: 1),
      ExpandableColumn<String>(columnTitle: "Priority", columnFlex: 1),
      ExpandableColumn<String>(columnTitle: "Doctor Department", columnFlex: 2),
      ExpandableColumn<Widget>(columnTitle: "Patient Image", columnFlex: 2),
      ExpandableColumn<Widget>(columnTitle: "Doctor Image", columnFlex: 2),
      ExpandableColumn<Widget>(columnTitle: "Actions", columnFlex: 2),
    ];

    rows = recentAppointments.map<ExpandableRow>((appointment) {
      return ExpandableRow(cells: [
        ExpandableCell<String>(
            columnTitle: "Doctor Name", value: appointment["doctor_name"]),
        ExpandableCell<String>(
            columnTitle: "Patient Name", value: appointment["patient_name"]),
        ExpandableCell<String>(
            columnTitle: "Appointment Date",
            value: appointment["appointment_date"]),
        ExpandableCell<String>(
            columnTitle: "Appointment Time",
            value: appointment["appointment_time"]),
        ExpandableCell<String>(
            columnTitle: "Problem", value: appointment["problem"]),
        ExpandableCell<int>(columnTitle: "ID", value: appointment["id"]),
        ExpandableCell<int>(
            columnTitle: "Patient ID", value: appointment["patient_id"]),
        ExpandableCell<int>(
            columnTitle: "Doctor ID", value: appointment["doctor_id"]),
        ExpandableCell<int>(
            columnTitle: "Department ID", value: appointment["department_id"]),
        ExpandableCell<String>(
            columnTitle: "OPD Date", value: appointment["opd_date"]),
        ExpandableCell<int>(
            columnTitle: "Completed", value: appointment["is_completed"]),
        ExpandableCell<String>(
            columnTitle: "Priority",
            value: appointment["custom_field"]["priority"]),
        ExpandableCell<String>(
            columnTitle: "Doctor Department",
            value: appointment["doctor_department"]),
        ExpandableCell<Widget>(
          columnTitle: "Patient Image",
          value: Image.network(appointment["patient_image"],
              width: 40, height: 40),
        ),
        ExpandableCell<Widget>(
          columnTitle: "Doctor Image",
          value: SvgPicture.asset(appointment["doctor_image"],
              width: 40, height: 40),
        ),
        ExpandableCell<Widget>(
          columnTitle: "Actions",
          value: IconButton(
            icon: Icon(Icons.more_vert, color: notifier.getIconColor),
            onPressed: () {
              print("Expand actions for: ${appointment["doctor"]}");
            },
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
                const CommonTitle(title: 'Overview', path: "Dashboards"),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ExpandableTheme(
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
                        headerSortIconColor: notifier.getBgColor,
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
                      ),
                      child: ExpandableDataTable(
                        headers: headers,
                        rows: rows,
                        multipleExpansion: false,
                        isEditable: false,
                        visibleColumnCount: visibleCount,
                        pageSize: pageSize,
                        onPageChanged: (page) {
                          setState(() {
                            currentPage = page;
                          });
                        },
                        renderExpansionContent: (row) =>
                            _buildExpandedContent(row, visibleCount),
                        renderCustomPagination:
                            (totalPages, currentPage, onPageChanged) =>
                                _buildCustomPagination(
                                    totalPages, currentPage, onPageChanged),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildExpandedContent(ExpandableRow row, int visibleCount) {
    final expandableRow = recentAppointments[rows.indexOf(row)];
    List<String> hiddenKeys = [
      "id",
      "doctor_id",
      "patient_id",
      "department_id"
    ];
    List<String> mageKeys = [
      "doctor_image",
      "patient_image",
    ];

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
                for (int i = 0; i < mageKeys.length; i++)
                  if (expandableRow[mageKeys[i]] != null)
                    Positioned(
                      left: i * 25.0,
                      child:
                          expandableRow[mageKeys[i]].toString().contains("http")
                              ? Image.network(
                                  expandableRow[mageKeys[i]],
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Opacity(
                                    opacity: 0.7,
                                    child: Icon(Icons.error,
                                        size: 50, color: notifier.getIconColor),
                                  ),
                                )
                              : SvgPicture.asset(
                                  expandableRow[mageKeys[i]],
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                ),
                    ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          for (var cell in row.cells.sublist(visibleCount))
            if (cell is! ExpandableCell<Widget> &&
                !expandableRow.entries.any((entry) =>
                    hiddenKeys.contains(entry.key) &&
                    entry.value == cell.value))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Row(
                  children: [
                    Text(
                      "${cell.columnTitle}: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: notifier.getMainText,
                      ),
                    ),
                    Text(
                      cell.value.toString(),
                      style:
                          TextStyle(fontSize: 14, color: notifier.getMainText),
                    ),
                  ],
                ),
              ),

          const SizedBox(height: 10),

          // Action buttons aligned to left
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: notifier.getMainText),
                onPressed: () {
                  print("Edit expandableRow: ${expandableRow["doctor"]}");
                },
              ),
              IconButton(
                icon: Icon(Icons.visibility, color: notifier.getMainText),
                onPressed: () {
                  print("View details of: ${expandableRow["doctor"]}");
                },
              ),
            ],
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
