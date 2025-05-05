import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ige_hospital/controllers/patient_controller.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/form/app_text_field.dart';
import 'package:ige_hospital/widgets/form/app_dropdown_field.dart';
import 'package:provider/provider.dart';

class PatientFilters extends StatefulWidget {
  final PatientController controller;
  final TextEditingController searchController;
  final bool initiallyExpanded;

  const PatientFilters({
    super.key,
    required this.controller,
    required this.searchController,
    this.initiallyExpanded = false,
  });

  @override
  State<PatientFilters> createState() => _PatientFiltersState();
}

class _PatientFiltersState extends State<PatientFilters> {
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
                          widget.controller.resetFilters();
                        },
                        icon: Icon(Icons.refresh, size: 16, color: notifier.getIconColor),
                        label: Text(
                          "Reset",
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
            hintText: "Search by name, email, or phone...",
            controller: widget.searchController,
            prefixIcon: Icons.search,
            suffixIcon: widget.searchController.text.isNotEmpty ? Icons.clear : null,
            onSuffixIconPressed: () {
              widget.searchController.clear();
              widget.controller.searchQuery.value = '';
              widget.controller.loadPatients();
            },
          ),
          const SizedBox(height: 16),

          // Date range picker
          GestureDetector(
            onTap: () async {
              final DateTimeRange? picked = await showDateRangePicker(
                context: context,
                initialDateRange: DateTimeRange(
                  start: DateTime.now().subtract(const Duration(days: 30)),
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
                      dialogBackgroundColor: notifier.getContainer,
                    ),
                    child: child!,
                  );
                },
              );

              if (picked != null) {
                widget.controller.dateFrom.value =
                    DateFormat('yyyy-MM-dd').format(picked.start);
                widget.controller.dateTo.value =
                    DateFormat('yyyy-MM-dd').format(picked.end);
                widget.controller.loadPatients();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: notifier.getBorderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 18, color: notifier.getIconColor),
                  const SizedBox(width: 8),
                  Obx(() => Expanded(
                    child: Text(
                      widget.controller.dateFrom.value.isNotEmpty &&
                          widget.controller.dateTo.value.isNotEmpty
                          ? "${widget.controller.dateFrom.value} to ${widget.controller.dateTo.value}"
                          : "Select Date Range",
                      style: TextStyle(color: notifier.getMainText),
                    ),
                  )),
                  Icon(Icons.arrow_drop_down, color: notifier.getMainText),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Gender & Blood Group dropdowns
          Row(
            children: [
              Expanded(
                child: Obx(() => AppDropdownField<String>(
                  label: 'Gender',
                  value: widget.controller.selectedGender.value.isEmpty
                      ? 'All'
                      : widget.controller.selectedGender.value,
                  items: widget.controller.genders.map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      widget.controller.selectedGender.value = value;
                      widget.controller.loadPatients();
                    }
                  },
                )),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => AppDropdownField<String>(
                  label: 'Blood Group',
                  value: widget.controller.selectedBloodGroup.value.isEmpty
                      ? 'All'
                      : widget.controller.selectedBloodGroup.value,
                  items: widget.controller.bloodGroups.map((group) {
                    return DropdownMenuItem(
                      value: group,
                      child: Text(group),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      widget.controller.selectedBloodGroup.value = value;
                      widget.controller.loadPatients();
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
            value: widget.controller.sortDirection.value,
            items: [
              DropdownMenuItem(
                value: 'desc',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward, size: 14, color: notifier.getIconColor),
                    const SizedBox(width: 8),
                    Text('Newest First'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'asc',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward, size: 14, color: notifier.getIconColor),
                    const SizedBox(width: 8),
                    Text('Oldest First'),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                widget.controller.sortDirection.value = value;
                widget.controller.loadPatients();
              }
            },
          )),
        ],
      ),
    );
  }
}