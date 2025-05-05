import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/nurse_controller.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/form/app_dropdown_field.dart';
import 'package:ige_hospital/widgets/form/app_text_field.dart';
import 'package:provider/provider.dart';

class NurseFilters extends StatefulWidget {
  final TextEditingController searchController;
  final NurseController nurseController;
  final bool initiallyExpanded;

  const NurseFilters({
    super.key,
    required this.searchController,
    required this.nurseController,
    this.initiallyExpanded = false,
  });

  @override
  State<NurseFilters> createState() => _NurseFiltersState();
}

class _NurseFiltersState extends State<NurseFilters> {
  late bool _isFilterExpanded;

  @override
  void initState() {
    super.initState();
    _isFilterExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
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
                    "Filters & Search",
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
                          widget.searchController.clear();
                          widget.nurseController.resetFilters();
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
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: notifier.getIconColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expandable filter content
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: _buildExpandedFilters(notifier),
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isFilterExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedFilters(ColourNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search box
          AppTextField(
            label: '',
            hintText: "Search by name, email, specialty...",
            controller: widget.searchController,
            prefixIcon: Icons.search,
            suffixIcon:
            widget.searchController.text.isNotEmpty ? Icons.clear : null,
            onSuffixIconPressed: () {
              widget.searchController.clear();
              widget.nurseController.searchQuery.value = '';
              widget.nurseController.loadNurses();
            },
          ),
          const SizedBox(height: 16),

          // Department dropdown
          Obx(() => AppDropdownField<String>(
            label: 'Department',
            value: widget.nurseController.selectedDepartment.value.isEmpty
                ? 'All Departments'
                : widget.nurseController.selectedDepartment.value,
            items: widget.nurseController.departments.map((department) {
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
                widget.nurseController.selectedDepartment.value =
                value == 'All Departments' ? '' : value;
                widget.nurseController.loadNurses();
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
                  value: widget
                      .nurseController.selectedSpecialty.value.isEmpty
                      ? 'All Specialties'
                      : widget.nurseController.selectedSpecialty.value,
                  items:
                  widget.nurseController.specialties.map((specialty) {
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
                      widget.nurseController.selectedSpecialty.value =
                      value == 'All Specialties' ? '' : value;
                      widget.nurseController.loadNurses();
                    }
                  },
                )),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => AppDropdownField<String>(
                  label: 'Status',
                  value:
                  widget.nurseController.selectedStatus.value.isEmpty
                      ? 'All'
                      : widget.nurseController.selectedStatus.value,
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
                      widget.nurseController.selectedStatus.value =
                      value == 'All' ? '' : value.toLowerCase();
                      widget.nurseController.loadNurses();
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
            value: widget.nurseController.sortDirection.value,
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
                widget.nurseController.sortDirection.value = value;
                widget.nurseController.loadNurses();
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