import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/add_doctor_dialog.dart';
import 'package:ige_hospital/controllers/doctor_card.dart';
import 'package:ige_hospital/controllers/doctor_controller.dart';
import 'package:ige_hospital/controllers/doctor_detail_dialog.dart';
import 'package:ige_hospital/controllers/edit_doctor_dialog.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/widgets/common_title.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DoctorsPage extends StatefulWidget {
  // Make sure the controller is properly registered with GetX
  // We use Get.put to ensure the controller is initialized and accessible globally

  const DoctorsPage({super.key});

  @override
  State<DoctorsPage> createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
  bool _showFilters = false;
  static final DoctorController controller = Get.put(DoctorController());

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Scaffold(
      backgroundColor: notifier.getBgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommonTitle(title: 'Doctors', path: "Hospital Staff"),
            _buildPageTopBar(context, notifier),
            if (_showFilters) _buildFilters(context, notifier),
            _buildDoctorsList(notifier),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: notifier.getIconColor,
        onPressed: () {
          setState(() {
            _showFilters = !_showFilters;
          });
        },
        child: Icon(
          _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
          color: notifier.getBgColor,
        ),
      ),
    );
  }

  Widget _buildPageTopBar(BuildContext context, ColourNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Toggle Filters Button
          IconButton(
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            icon: Icon(
              _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
              color: notifier.getIconColor,
            ),
            tooltip: _showFilters ? 'Hide filters' : 'Show filters',
          ),

          // Add Doctor Button
          ElevatedButton(
            onPressed: () {
              _showAddDoctorDialog(context);
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
                  color: Colors.white,
                  width: 18,
                  height: 18,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Add Doctor",
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
      ),
    );
  }

  Widget _buildFilters(BuildContext context, ColourNotifier notifier) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifier.getContainer,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(color: notifier.getMainText),
                  onChanged: (value) => controller.searchQuery.value = value,
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, specialty...',
                    hintStyle: TextStyle(color: notifier.getMaingey),
                    prefixIcon:
                        Icon(Icons.search, color: notifier.getIconColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: notifier.getBorderColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: notifier.getBorderColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: notifier.getIconColor,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    filled: true,
                    fillColor: notifier.getPrimaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () => controller.resetFilters(),
                icon: Icon(Icons.refresh, color: notifier.getIconColor),
                tooltip: 'Reset filters',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                      menuMaxHeight: 400,
                      isExpanded: true,
                      value: controller.selectedDepartment.value.isEmpty
                          ? 'All Departments'
                          : controller.selectedDepartment.value,
                      decoration: InputDecoration(
                          // ... your existing decoration
                          ),
                      dropdownColor: notifier.getContainer,
                      style: TextStyle(color: notifier.getMainText),
                      items: controller.departments.map((department) {
                        return DropdownMenuItem(
                          value: department,
                          child: SizedBox(
                            width: 200, // Adjust this value as needed
                            child: Text(
                              department,
                              style: TextStyle(color: notifier.getMainText),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.selectedDepartment.value =
                              value == 'All Departments' ? '' : value;
                        }
                      },
                    )),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                      menuMaxHeight: 400,
                      isExpanded: true,
                      value: controller.selectedStatus.value.isEmpty
                          ? 'All'
                          : controller.selectedStatus.value,
                      decoration: InputDecoration(
                          // ... your existing decoration
                          ),
                      dropdownColor: notifier.getContainer,
                      style: TextStyle(color: notifier.getMainText),
                      items:
                          ['All', 'Active', 'Pending', 'Blocked'].map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: SizedBox(
                            width: 200, // Adjust this value as needed
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: status == 'All'
                                        ? Colors.grey
                                        : controller.getStatusColor(status),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  status,
                                  style: TextStyle(color: notifier.getMainText),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.selectedStatus.value =
                              value == 'All' ? '' : value;
                        }
                      },
                    )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                      menuMaxHeight: 400,
                      isExpanded: true,
                      value: controller.selectedSpecialty.value.isEmpty
                          ? 'All Specialties'
                          : controller.selectedSpecialty.value,
                      decoration: InputDecoration(
                          // ... your existing decoration
                          ),
                      dropdownColor: notifier.getContainer,
                      style: TextStyle(color: notifier.getMainText),
                      items: controller.specialties.map((specialty) {
                        return DropdownMenuItem(
                          value: specialty,
                          child: SizedBox(
                            width: 200, // Adjust this value as needed
                            child: Text(
                              specialty,
                              style: TextStyle(color: notifier.getMainText),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.selectedSpecialty.value =
                              value == 'All Specialties' ? '' : value;
                        }
                      },
                    )),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                      menuMaxHeight: 400,
                      isExpanded: true,
                      value: controller.sortDirection.value,
                      decoration: InputDecoration(
                        labelText: 'Sort By',
                        labelStyle: TextStyle(color: notifier.getMainText),
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
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: notifier.getIconColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12), // Reduced horizontal padding
                        filled: true,
                        fillColor: notifier.getPrimaryColor,
                      ),
                      dropdownColor: notifier.getContainer,
                      style: TextStyle(
                        color: notifier.getMainText,
                        fontSize: 14, // Reduced font size
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'desc',
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width *
                                  0.25, // Responsive width
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.arrow_downward,
                                    size: 14, // Reduced icon size
                                    color: notifier.getIconColor),
                                const SizedBox(width: 6), // Reduced spacing
                                Flexible(
                                  child: Text('Newest First',
                                      style: TextStyle(
                                        color: notifier.getMainText,
                                        fontSize: 13, // Reduced font size
                                      ),
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'asc',
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width *
                                  0.25, // Same responsive width
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.arrow_upward,
                                    size: 14, // Reduced icon size
                                    color: notifier.getIconColor),
                                const SizedBox(width: 6), // Reduced spacing
                                Flexible(
                                  child: Text('Oldest First',
                                      style: TextStyle(
                                        color: notifier.getMainText,
                                        fontSize: 13, // Reduced font size
                                      ),
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          controller.sortDirection.value = value;
                        }
                      },
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsList(ColourNotifier notifier) {
    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(
              child: CircularProgressIndicator(color: notifier.getIconColor));
        }

        if (controller.filteredDoctors.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: notifier.getMaingey),
                const SizedBox(height: 16),
                Text(
                  'No doctors found',
                  style: TextStyle(
                    fontSize: 18,
                    color: notifier.getMainText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your filters or add a new doctor',
                  style: TextStyle(
                    color: notifier.getMaingey,
                  ),
                ),
              ],
            ),
          );
        }

        // Need to update DoctorCard to use notifier colors too
        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 380,
            childAspectRatio: 0.85,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: controller.filteredDoctors.length,
          itemBuilder: (context, index) {
            final doctor = controller.filteredDoctors[index];
            return DoctorCard(
              doctor: doctor,
              onView: () => _showDoctorDetail(context, doctor),
              onEdit: () => _showEditDoctorDialog(context, doctor),
              onDelete: () =>
                  _showDeleteConfirmation(context, doctor, notifier),
            );
          },
        );
      }),
    );
  }

  void _showDoctorDetail(BuildContext context, Doctor doctor) {
    showDialog(
      context: context,
      builder: (context) => DoctorDetailDialog(doctor: doctor),
    );
  }

  void _showAddDoctorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddDoctorDialog(),
    );
  }

  void _showEditDoctorDialog(BuildContext context, Doctor doctor) {
    showDialog(
      context: context,
      builder: (context) => EditDoctorDialog(doctor: doctor),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, Doctor doctor, ColourNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: notifier.getContainer,
        title: Text(
          'Delete Doctor',
          style: TextStyle(color: notifier.getMainText),
        ),
        content: Text(
          'Are you sure you want to delete Dr. ${doctor.fullName}?',
          style: TextStyle(color: notifier.getMainText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: notifier.getMainText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteDoctor(doctor.id);
              Navigator.pop(context);
              Get.snackbar(
                'Success',
                'Doctor deleted successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
