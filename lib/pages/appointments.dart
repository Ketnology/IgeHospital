import 'package:flutter/material.dart';
import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/static_data.dart';
import 'package:ige_hospital/static_data/static_data.dart';
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
                _buildPageTopBar(),
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
                        multipleExpansion: false,
                        isEditable: true,
                        visibleColumnCount: visibleCount,
                        pageSize: pageSize,
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
                        style: mediumBlackTextStyle.copyWith(
                          color: notifier.getMainText,
                        ),
                        decoration: InputDecoration(
                          hintText: "Search...",
                          isDense: true,
                          suffixIcon: SizedBox(
                            height: 20,
                            width: 20,
                            child: Center(
                              child: SvgPicture.asset(
                                "assets/search.svg",
                                height: 20,
                                width: 20,
                                color: appGreyColor,
                              ),
                            ),
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

                  if (!isMobile)
                    const SizedBox(
                        width: 200), // Add spacing for larger screens

                  Expanded(
                    flex: isDesktop ? 1 : (isTablet ? 2 : 3),
                    child: ElevatedButton(
                      onPressed: () {
                        // controller.changePage(5);
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

  Widget _buildSearchField() {
    return SizedBox(
      height: 40,
      child: TextField(
        style: TextStyle(color: notifier.getMainText),
        decoration: InputDecoration(
          hintText: "Search..",
          isDense: true,
          suffixIcon: Icon(Icons.search, color: Colors.grey),
          hintStyle: TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return ElevatedButton(
      onPressed: () {
        //
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: appMainColor,
        fixedSize: const Size.fromHeight(40),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_circle, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          const Text(
            "Create New",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditDialog(
      ExpandableRow row, void Function(ExpandableRow) onSuccess) {
    int index = rows.indexOf(row);
    if (index == -1) return const SizedBox(); // Fallback widget

    final editableData = recentAppointments[index];

    TextEditingController doctorNameController =
        TextEditingController(text: editableData["doctor_name"]);
    TextEditingController patientNameController =
        TextEditingController(text: editableData["patient_name"]);
    TextEditingController problemController =
        TextEditingController(text: editableData["problem"]);
    String priority = editableData["custom_field"]["priority"];

    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    if (editableData["opd_date"] != null &&
        editableData["opd_date"].isNotEmpty) {
      try {
        DateTime parsedDate =
            DateFormat("yyyy-MM-dd hh:mm a").parse(editableData["opd_date"]);
        selectedDate = parsedDate;
        selectedTime = TimeOfDay.fromDateTime(parsedDate);
      } catch (e) {
        print("Error parsing date: ${editableData["opd_date"]} - $e");
      }
    }

    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: notifier.getContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: Container(
        width: 500,
        decoration: BoxDecoration(
            color: notifier.getContainer,
            borderRadius: BorderRadius.circular(10)),
        child: Material(
          color: notifier.getContainer,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: StatefulBuilder(builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "Edit Appointment",
                    style: TextStyle(
                        color: notifier.getMainText,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
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
                              initialDate: selectedDate ?? DateTime.now(),
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
                                style:
                                    TextStyle(color: Colors.red, fontSize: 14)),
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
                      setState(() {
                        priority = value!;
                      });
                    },
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
                          ExpandableRow updatedRow = ExpandableRow(cells: []);

                          setState(() {
                            recentAppointments[index] = {
                              "doctor_name": doctorNameController.text,
                              "patient_name": patientNameController.text,
                              "appointment_date": selectedDate != null
                                  ? DateFormat('MMM dd, yyyy')
                                      .format(selectedDate!)
                                  : "",
                              "appointment_time": selectedTime != null
                                  ? selectedTime!.format(context)
                                  : "",
                              "problem": problemController.text,
                              "custom_field": {"priority": priority}
                            };
                          });

                          onSuccess(updatedRow);
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
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.delete, color: Color(0xfffc4438)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Confirm Delete"),
                      content: Text(
                          "Are you sure you want to delete this appointment?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            print("Deleted: ${expandableRow["doctor"]}");
                            Navigator.pop(context);
                          },
                          child: Text("Delete",
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
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
