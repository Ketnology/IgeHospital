import 'package:flutter/material.dart';
import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/nurse_service.dart';
import 'package:ige_hospital/static_data.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/widgets/common_button.dart';
import 'package:ige_hospital/widgets/text_field.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/common_title.dart';

class NursesPageV2 extends StatefulWidget {
  const NursesPageV2({super.key});

  @override
  State<NursesPageV2> createState() => _NursesPageV2State();
}

class _NursesPageV2State extends State<NursesPageV2> {
  AppConst obj = AppConst();
  final AppConst controller = Get.put(AppConst());
  ColourNotifier notifier = ColourNotifier();

  // Initialize the NursesService
  final NursesService nursesService = Get.put(NursesService());

  late List<ExpandableColumn<dynamic>> headers;
  late List<ExpandableRow> rows;

  int currentPage = 0;
  final int pageSize = 10;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController specialtyController = TextEditingController();

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
      ExpandableColumn<String>(columnTitle: "Full Name", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Email", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Phone", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Department", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Specialty", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Gender", columnFlex: 1),
      ExpandableColumn<String>(columnTitle: "Qualification", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "ID", columnFlex: 1),
      ExpandableColumn<Widget>(columnTitle: "Profile Image", columnFlex: 1),
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
        ExpandableCell<String>(columnTitle: "Full Name", value: nurse.fullName),
        ExpandableCell<String>(columnTitle: "Email", value: nurse.email),
        ExpandableCell<String>(columnTitle: "Phone", value: nurse.phone),
        ExpandableCell<String>(
            columnTitle: "Department", value: nurse.departmentName),
        ExpandableCell<String>(
            columnTitle: "Specialty", value: nurse.specialty ?? 'N/A'),
        ExpandableCell<String>(columnTitle: "Gender", value: nurse.gender),
        ExpandableCell<String>(
            columnTitle: "Qualification", value: nurse.qualification),
        ExpandableCell<String>(columnTitle: "ID", value: nurse.id),
        ExpandableCell<Widget>(
          columnTitle: "Profile Image",
          value: nurse.profileImage.isNotEmpty
              ? ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              nurse.profileImage,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
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
                  _showEditDialog(nurse);
                },
              ),
              IconButton(
                icon: Icon(Icons.visibility, color: Colors.blue),
                onPressed: () {
                  _showNurseDetail(nurse);
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
                    title: 'Nursing Staff', path: "Hospital Staff"),
                _buildPageTopBar(),
                _buildFilterSection(),
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
                                Icons.medical_services_outlined,
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
                          renderExpansionContent: (row) {
                            // Find the corresponding nurse
                            int index = rows.indexOf(row);
                            if (index == -1 ||
                                index >= nursesService.nurses.length) {
                              return const SizedBox(); // Fallback
                            }

                            // Get the nurse data
                            final nurse = nursesService.nurses[index];

                            return _buildExpandedContent(nurse);
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

  Widget _buildFilterSection() {
    bool _isFilterExpanded = false;

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
          child: StatefulBuilder(builder: (context, setState) {
            return Column(
              children: [
                // Header with toggle button
                InkWell(
                  onTap: () {
                    setState(() {
                      _isFilterExpanded = !_isFilterExpanded;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
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
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                nursesService.resetFilters();
                              },
                              icon: Icon(Icons.refresh,
                                  size: 16, color: notifier.getIconColor),
                              label: Text(
                                "Reset Filters",
                                style: TextStyle(color: notifier.getIconColor),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _isFilterExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: notifier.getIconColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Expandable filter section
                AnimatedCrossFade(
                  firstChild: const SizedBox(height: 0),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0, 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: specialtyController,
                                style: TextStyle(color: notifier.getMainText),
                                decoration: InputDecoration(
                                  labelText: "Specialty",
                                  labelStyle:
                                  TextStyle(color: notifier.getMainText),
                                  hintText: "Enter specialty field",
                                  hintStyle: mediumGreyTextStyle,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: notifier.getBorderColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: notifier.getBorderColor),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.search,
                                        color: notifier.getIconColor),
                                    onPressed: () {
                                      nursesService.specialty.value =
                                          specialtyController.text;
                                      nursesService.fetchNurses();
                                    },
                                  ),
                                ),
                                onFieldSubmitted: (value) {
                                  nursesService.specialty.value = value;
                                  nursesService.fetchNurses();
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: "Sort Direction",
                                  labelStyle:
                                  TextStyle(color: notifier.getMainText),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: notifier.getBorderColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: notifier.getBorderColor),
                                  ),
                                ),
                                value: nursesService.sortDirection.value,
                                dropdownColor: notifier.getContainer,
                                style: TextStyle(color: notifier.getMainText),
                                items: [
                                  DropdownMenuItem(
                                    value: 'asc',
                                    child: Text('Oldest First',
                                        style: TextStyle(
                                            color: notifier.getMainText)),
                                  ),
                                  DropdownMenuItem(
                                    value: 'desc',
                                    child: Text('Newest First',
                                        style: TextStyle(
                                            color: notifier.getMainText)),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    nursesService.sortDirection.value = value;
                                    nursesService.fetchNurses();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: "Department",
                                  labelStyle:
                                  TextStyle(color: notifier.getMainText),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: notifier.getBorderColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: notifier.getBorderColor),
                                  ),
                                ),
                                value: nursesService.departmentId.value.isEmpty
                                    ? null
                                    : nursesService.departmentId.value,
                                dropdownColor: notifier.getContainer,
                                style: TextStyle(color: notifier.getMainText),
                                items: [
                                  DropdownMenuItem(
                                    value: '',
                                    child: Text('All Departments',
                                        style: TextStyle(
                                            color: notifier.getMainText)),
                                  ),
                                  DropdownMenuItem(
                                    value: '1',
                                    child: Text('Cardiology',
                                        style: TextStyle(
                                            color: notifier.getMainText)),
                                  ),
                                  DropdownMenuItem(
                                    value: '2',
                                    child: Text('Neurology',
                                        style: TextStyle(
                                            color: notifier.getMainText)),
                                  ),
                                  DropdownMenuItem(
                                    value: '3',
                                    child: Text('Orthopedics',
                                        style: TextStyle(
                                            color: notifier.getMainText)),
                                  ),
                                  DropdownMenuItem(
                                    value: '4',
                                    child: Text('Pediatrics',
                                        style: TextStyle(
                                            color: notifier.getMainText)),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    nursesService.departmentId.value = value;
                                    nursesService.fetchNurses();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: "Sort By",
                                  labelStyle:
                                  TextStyle(color: notifier.getMainText),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: notifier.getBorderColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: notifier.getBorderColor),
                                  ),
                                ),
                                value: nursesService.sortBy.value,
                                dropdownColor: notifier.getContainer,
                                style: TextStyle(color: notifier.getMainText),
                                items: [
                                  DropdownMenuItem(
                                    value: 'created_at',
                                    child: Text('Registration Date',
                                        style: TextStyle(
                                            color: notifier.getMainText)),
                                  ),
                                  DropdownMenuItem(
                                    value: 'first_name',
                                    child: Text('First Name',
                                        style: TextStyle(
                                            color: notifier.getMainText)),
                                  ),
                                  DropdownMenuItem(
                                    value: 'last_name',
                                    child: Text('Last Name',
                                        style: TextStyle(
                                            color: notifier.getMainText)),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    nursesService.sortBy.value = value;
                                    nursesService.fetchNurses();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _isFilterExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                ),
              ],
            );
          }),
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

  Widget _buildExpandedContent(NurseModel nurse) {
    // Format dates
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
          // Nurse header with profile image
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

              // Nurse details
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
                        Text(
                          nurse.specialty ?? 'General Nursing',
                          style: TextStyle(
                            fontSize: 16,
                            color: notifier.getMainText,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            nurse.departmentName,
                            style: TextStyle(
                              color: Colors.green.shade800,
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
            ],
          ),
          const Divider(height: 30),

          // Nurse details in grid layout
          Wrap(
            spacing: 30,
            runSpacing: 15,
            children: [
              _detailItem("Email", nurse.email, Icons.email),
              _detailItem("Phone", nurse.phone, Icons.phone),
              _detailItem("Gender", nurse.gender, Icons.person),
              _detailItem(
                  "Qualification", nurse.qualification, Icons.school),
              _detailItem("Department", nurse.departmentName, Icons.business),
              _detailItem("Specialty",
                  nurse.specialty ?? 'General Nursing', Icons.medical_services),
              _detailItem("User ID", nurse.userId, Icons.perm_identity),
              _detailItem("Created At", createdAtFormatted, Icons.calendar_today),
              _detailItem("Updated At", updatedAtFormatted, Icons.update),
            ],
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  _showEditDialog(nurse);
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text("Edit"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () {
                  _showDeleteConfirmation(nurse);
                },
                icon: const Icon(Icons.delete, size: 16),
                label: const Text("Delete"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value, IconData icon) {
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

  Widget _buildCustomPagination(
      int totalPages, int currentPage, void Function(int) onPageChanged) {
    return Obx(
          () {
        final calculatedTotalPages =
        (nursesService.totalNurses.value / nursesService.perPage.value)
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

  void _showAddNurseDialog() {
    // You'll implement this dialog to add a new nurse
    // Similar to AddPatientDialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Add Nurse",
          style: TextStyle(color: notifier.getMainText),
        ),
        backgroundColor: notifier.getContainer,
        content: Text(
          "Nurse creation feature coming soon!",
          style: TextStyle(color: notifier.getMainText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: TextStyle(color: notifier.getIconColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(NurseModel nurse) {
    // You'll implement this dialog to edit a nurse
    // Similar to EditPatientDialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Edit Nurse",
          style: TextStyle(color: notifier.getMainText),
        ),
        backgroundColor: notifier.getContainer,
        content: Text(
          "Nurse editing feature coming soon!",
          style: TextStyle(color: notifier.getMainText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: TextStyle(color: notifier.getIconColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showNurseDetail(NurseModel nurse) {
    // You'll implement this dialog to show nurse details
    // Similar to PatientDetailDialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Nurse Details",
          style: TextStyle(color: notifier.getMainText),
        ),
        backgroundColor: notifier.getContainer,
        content: Text(
          "Detailed view feature coming soon!",
          style: TextStyle(color: notifier.getMainText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: TextStyle(color: notifier.getIconColor),
            ),
          ),
        ],
      ),
    );
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
}