import 'package:flutter/material.dart';
import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/static_data.dart';
import 'package:ige_hospital/static_data/static_data.dart';
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

  final List<Map<String, String>> recentAppointments = [
    {
      "doctor": "Dr. James Smith",
      "patient": "Emily Johnson",
      "date": "29/1/2023",
      "time": "10:30 AM",
      "doctorImage": "assets/icons8-figma.svg",
    },
    {
      "doctor": "Dr. Sarah Williams",
      "patient": "Michael Brown",
      "date": "19/6/2023",
      "time": "2:15 PM",
      "doctorImage": "assets/icons8-adobe-creative-cloud.svg",
    },
    {
      "doctor": "Dr. David Martinez",
      "patient": "Sophia Davis",
      "date": "1/2/2023",
      "time": "9:00 AM",
      "doctorImage": "assets/icons8-starbucks.svg",
    },
    {
      "doctor": "Dr. Olivia Taylor",
      "patient": "James Wilson",
      "date": "9/4/2023",
      "time": "11:45 AM",
      "doctorImage": "assets/icons8-apple-logo.svg",
    },
    {
      "doctor": "Dr. William Anderson",
      "patient": "Isabella Thomas",
      "date": "12/6/2023",
      "time": "4:30 PM",
      "doctorImage": "assets/icons8-facebook29.svg",
    },
  ];

  @override
  void initState() {
    super.initState();
    createDataSource();
  }

  void createDataSource() {
    headers = [
      ExpandableColumn<String>(columnTitle: "Doctor", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Doctor", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Patient", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Date", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Time", columnFlex: 1),
      ExpandableColumn<String>(columnTitle: "Dates", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Times", columnFlex: 1),
      ExpandableColumn<Widget>(columnTitle: "Image", columnFlex: 2),
      ExpandableColumn<Widget>(columnTitle: "Actions", columnFlex: 1),
    ];

    rows = recentAppointments.map<ExpandableRow>((appointment) {
      return ExpandableRow(cells: [
        ExpandableCell<String>(
            columnTitle: "Doctor", value: appointment["doctor"]!),
        ExpandableCell<String>(
            columnTitle: "Doctor", value: appointment["doctor"]!),
        ExpandableCell<String>(
            columnTitle: "Patient", value: appointment["patient"]!),
        ExpandableCell<String>(
            columnTitle: "Date", value: appointment["date"]!),
        ExpandableCell<String>(
            columnTitle: "Time", value: appointment["time"]!),
        ExpandableCell<String>(
            columnTitle: "Dates", value: appointment["date"]!),
        ExpandableCell<String>(
            columnTitle: "Times", value: appointment["time"]!),
        ExpandableCell<Widget>(
          columnTitle: "Image",
          value: SvgPicture.asset(
            appointment["doctorImage"]!,
            width: 40,
            height: 40,
            color: notifier.getMainText,
          ),
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
    final appointment = recentAppointments[rows.indexOf(row)];

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (appointment["doctorImage"] != null)
            Align(
              alignment: Alignment.centerLeft,
              child: SvgPicture.asset(
                appointment["doctorImage"]!,
                height: 50,
                width: 50,
              ),
            ),

          const SizedBox(height: 10),

          for (var cell in row.cells.sublist(visibleCount))
            if (cell.columnTitle != "Image" && cell.columnTitle != "Actions")
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Row(
                  children: [
                    Text(
                      "${cell.columnTitle}: ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14,
                        color: notifier.getMainText,),
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
                  print("Edit appointment: ${appointment["doctor"]}");
                },
              ),
              IconButton(
                icon: Icon(Icons.visibility, color: notifier.getMainText),
                onPressed: () {
                  print("View details of: ${appointment["doctor"]}");
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
