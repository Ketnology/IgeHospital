import 'package:flutter/material.dart';
import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/nurse_service.dart';
import 'package:ige_hospital/static_data.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/widgets/common_button.dart';
import 'package:ige_hospital/widgets/nurse_components/add_nurse_dialog.dart';
import 'package:ige_hospital/widgets/nurse_components/edit_nurse_dialog.dart';
import 'package:ige_hospital/widgets/nurse_components/nurse_detail_dialog.dart';
import 'package:ige_hospital/widgets/nurse_components/nurse_pagination.dart';
import 'package:ige_hospital/widgets/text_field.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/common_title.dart';

class NursesPage extends StatefulWidget {
  const NursesPage({super.key});

  @override
  State<NursesPage> createState() => _NursesPageState();
}

class _NursesPageState extends State<NursesPage> {
  AppConst obj = AppConst();
  final AppConst controller = Get.put(AppConst());
  ColourNotifier notifier = ColourNotifier();

  // Initialize the NursesService
  final NursesService nursesService = Get.put(NursesService());

  late List<ExpandableColumn<dynamic>> headers;
  late List<ExpandableRow> rows;

  int currentPage = 0;
  final int pageSize = 1;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController specialtyController = TextEditingController();

  final tableKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    createDataSource();
    nursesService.fetchNurses();

    // Add listener to update data source when nurses change
    ever(nursesService.nurses, (_) {
      createDataSource();
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    specialtyController.dispose();
    super.dispose();
  }

  void createDataSource() {
    headers = [
      ExpandableColumn<String>(columnTitle: "Name", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Email", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Phone", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Gender", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Status", columnFlex: 1),
      ExpandableColumn<Widget>(columnTitle: "Actions", columnFlex: 2),
    ];

    // Check if we have nurses to display
    if (nursesService.nurses.isEmpty) {
      rows = [];
      return;
    }

    // Map the nurses to expandable rows
    rows = nursesService.nurses.map<ExpandableRow>((nurse) {
      return ExpandableRow(cells: [
        ExpandableCell<String>(
            columnTitle: "Name", value: nurse.fullName),
        ExpandableCell<String>(columnTitle: "Email", value: nurse.email),
        ExpandableCell<String>(columnTitle: "Phone", value: nurse.phone),
        ExpandableCell<String>(columnTitle: "Gender", value: nurse.gender),
        ExpandableCell<String>(columnTitle: "Status", value: nurse.status),
        ExpandableCell<Widget>(
          columnTitle: "Actions",
          value: Row(
            children: [
              IconButton(
                icon: Icon(Icons.visibility, color: notifier.getIconColor),
                onPressed: () {
                  _showNurseDetail(nurse);
                },
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  _showEditDialog(nurse);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _showDeleteConfirmation(nurse);
                },
              ),
            ],
          ),
        ),
      ]);
    }).toList();
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
                    title: 'Nurses', path: "Hospital Staff"),
                _buildPageTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Obx(() {
                      if (nursesService.isLoading.value) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: notifier.getIconColor,
                          ),
                        );
                      }

                      if (nursesService.hasError.value) {
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
                                nursesService.errorMessage.value,
                                style: TextStyle(color: notifier.getMainText),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => nursesService.fetchNurses(),
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

                      if (nursesService.nurses.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_alt_outlined,
                                color: notifier.getIconColor,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No nurses found",
                                style: TextStyle(
                                  color: notifier.getMainText,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Try adjusting your filters or add a new nurse",
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
                          renderExpansionContent: (row) => _buildExpandedContent(row),
                          renderCustomPagination:
                              (totalPages, currentPage, onPageChanged) =>
                              NursePagination(
                                notifier: notifier,
                                nursesService: nursesService,
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
                          nursesService.searchQuery.value = value;
                          nursesService.fetchNurses();
                        },
                        decoration: InputDecoration(
                          hintText: "Search by name, email, specialty...",
                          isDense: true,
                          suffixIcon: IconButton(
                            icon: SvgPicture.asset(
                              "assets/search.svg",
                              height: 20,
                              width: 20,
                              color: appGreyColor,
                            ),
                            onPressed: () {
                              nursesService.searchQuery.value =
                                  searchController.text;
                              nursesService.fetchNurses();
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
                        _showAddNurseDialog();
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
                            "Add Nurse",
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

  void _showAddNurseDialog() {
    showDialog(
      context: context,
      builder: (context) => AddNurseDialog(
        notifier: notifier,
        nursesService: nursesService,
      ),
    ).then((_) {
      // Refresh data after dialog is closed
      nursesService.fetchNurses();
    });
  }

  void _showEditDialog(NurseModel nurse) {
    showDialog(
      context: context,
      builder: (context) => EditNurseDialog(
        nurse: nurse,
        notifier: notifier,
        nursesService: nursesService,
      ),
    ).then((_) {
      if (mounted) {
        nursesService.fetchNurses();
        // Trigger UI update
        setState(() {});
      }
    });
  }

  void _showNurseDetail(NurseModel nurse) {
    showDialog(
      context: context,
      builder: (context) => NurseDetailDialog(
        nurse: nurse,
        notifier: notifier,
      ),
    ).then((result) {
      if (result == 'edit') {
        _showEditDialog(nurse);
      }
    });
  }

  void _showDeleteConfirmation(NurseModel nurse) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: notifier.getContainer,
        title: Text(
          "Confirm Delete",
          style: TextStyle(color: notifier.getMainText),
        ),
        content: Text(
          "Are you sure you want to delete ${nurse.fullName}?",
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
              nursesService.deleteNurse(nurse.id);
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

  Widget _buildExpandedContent(ExpandableRow row) {
    // Find the corresponding nurse
    int index = rows.indexOf(row);
    if (index == -1 || index >= nursesService.nurses.length) {
      return const SizedBox(); // Fallback
    }

    // Get the nurse data
    final nurse = nursesService.nurses[index];

    // Format dates for display
    String createdAtFormatted = 'N/A';
    String updatedAtFormatted = 'N/A';

    try {
      if (nurse.createdAt.isNotEmpty) {
        final createdDate = DateTime.parse(nurse.createdAt);
        createdAtFormatted = DateFormat('MMM dd, yyyy').format(createdDate);
      }
      if (nurse.updatedAt.isNotEmpty) {
        final updatedDate = DateTime.parse(nurse.updatedAt);
        updatedAtFormatted = DateFormat('MMM dd, yyyy').format(updatedDate);
      }
    } catch (e) {
      print("Error parsing dates: $e");
    }

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nurse header with profile image and status
          Row(
            children: [
              // Profile image
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade200,
                child: nurse.profileImage.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                    nurse.profileImage,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
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
                ),
              ),
              const SizedBox(width: 20),

              // Nurse name and status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nurse.fullName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: notifier.getMainText,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(nurse.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            nurse.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.visibility, color: notifier.getIconColor),
                    onPressed: () => _showNurseDetail(nurse),
                    tooltip: "View Details",
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showEditDialog(nurse),
                    tooltip: "Edit",
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirmation(nurse),
                    tooltip: "Delete",
                  ),
                ],
              ),
            ],
          ),

          const Divider(height: 30),

          // Nurse details
          Wrap(
            spacing: 30,
            runSpacing: 15,
            children: [
              _buildDetailItem("Email", nurse.email, Icons.email),
              _buildDetailItem("Phone", nurse.phone, Icons.phone),
              _buildDetailItem("Gender", nurse.gender, Icons.person),
              _buildDetailItem("Qualification", nurse.qualification, Icons.school),
              _buildDetailItem("Created At", createdAtFormatted, Icons.calendar_today),
              _buildDetailItem("Updated At", updatedAtFormatted, Icons.update),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return SizedBox(
      width: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: notifier.getIconColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: notifier.getMaingey,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(color: notifier.getMainText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}