import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/nurse_controller.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/form/app_dropdown_field.dart';
import 'package:ige_hospital/widgets/form/app_text_field.dart';
import 'package:provider/provider.dart';

class NurseFilters extends StatelessWidget {
  final TextEditingController searchController;
  final NurseController nurseController;

  const NurseFilters({
    super.key,
    required this.searchController,
    required this.nurseController,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(15.0),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search box
          AppTextField(
            label: '',
            hintText: "Search by name, email, specialty...",
            controller: searchController,
            prefixIcon: Icons.search,
            suffixIcon:
            searchController.text.isNotEmpty ? Icons.clear : null,
            onSuffixIconPressed: () {
              searchController.clear();
              nurseController.searchQuery.value = '';
              nurseController.loadNurses();
            },
          ),
          const SizedBox(height: 16),

          // Department dropdown
          Obx(() => AppDropdownField<String>(
            label: 'Department',
            value: nurseController.selectedDepartment.value.isEmpty
                ? 'All Departments'
                : nurseController.selectedDepartment.value,
            items: nurseController.departments.map((department) {
              return DropdownMenuItem(
                value: department,
                child: Text(
                  department,
                  style: TextStyle(color: notifier.getMainText),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                nurseController.selectedDepartment.value =
                value == 'All Departments' ? '' : value;
                nurseController.loadNurses();
              }
            },
          )),
          const SizedBox(height: 16),

          // Specialty & Status
          Row(
            children: [
              Expanded(
                child: Obx(() => AppDropdownField<String>(
                  label: 'Specialty',
                  value: nurseController.selectedSpecialty.value.isEmpty
                      ? 'All Specialties'
                      : nurseController.selectedSpecialty.value,
                  items:
                  nurseController.specialties.map((specialty) {
                    return DropdownMenuItem(
                      value: specialty,
                      child: Text(
                        specialty,
                        style: TextStyle(color: notifier.getMainText),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      nurseController.selectedSpecialty.value =
                      value == 'All Specialties' ? '' : value;
                      nurseController.loadNurses();
                    }
                  },
                )),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => AppDropdownField<String>(
                  label: 'Status',
                  value:
                  nurseController.selectedStatus.value.isEmpty
                      ? 'All'
                      : nurseController.selectedStatus.value,
                  items:
                  ['All', 'Active', 'Pending', 'Blocked'].map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: status == 'All'
                                  ? Colors.grey
                                  : _getStatusColor(status.toLowerCase()),
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
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      nurseController.selectedStatus.value =
                      value == 'All' ? '' : value.toLowerCase();
                      nurseController.loadNurses();
                    }
                  },
                )),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sort Direction
          Obx(() => AppDropdownField<String>(
            label: 'Sort Order',
            value: nurseController.sortDirection.value,
            items: [
              DropdownMenuItem(
                value: 'desc',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward,
                        size: 14, color: notifier.getIconColor),
                    const SizedBox(width: 8),
                    Text(
                      'Newest First',
                      style: TextStyle(color: notifier.getMainText),
                    ),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'asc',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward,
                        size: 14, color: notifier.getIconColor),
                    const SizedBox(width: 8),
                    Text(
                      'Oldest First',
                      style: TextStyle(color: notifier.getMainText),
                    ),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                nurseController.sortDirection.value = value;
                nurseController.loadNurses();
              }
            },
          )),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
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
}