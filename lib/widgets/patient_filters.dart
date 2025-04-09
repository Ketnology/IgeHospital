import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/provider/patient_service.dart';

class PatientFilters extends StatefulWidget {
  final ColourNotifier notifier;
  final PatientsService patientsService;

  const PatientFilters({
    super.key,
    required this.notifier,
    required this.patientsService,
  });

  @override
  State<PatientFilters> createState() => _PatientFiltersState();
}

class _PatientFiltersState extends State<PatientFilters> {
  bool _isFilterExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Card(
          color: widget.notifier.getContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: widget.notifier.getBorderColor),
          ),
          elevation: 0,
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
                        "Filters",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: widget.notifier.getMainText,
                        ),
                      ),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              widget.patientsService.resetFilters();
                            },
                            icon: Icon(Icons.refresh,
                                size: 16, color: widget.notifier.getIconColor),
                            label: Text(
                              "Reset Filters",
                              style: TextStyle(color: widget.notifier.getIconColor),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.filter_list,
                            color: widget.notifier.getIconColor,
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
                secondChild: _buildExpandedFilters(),
                duration: const Duration(milliseconds: 300),
                crossFadeState: _isFilterExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0, 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildDateFilter(),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildGenderFilter()),
              const SizedBox(width: 10),
              Expanded(child: _buildBloodGroupFilter()),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildSortByFilter()),
              const SizedBox(width: 10),
              Expanded(child: _buildSortDirectionFilter()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return GestureDetector(
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
                  primary: widget.notifier.getIconColor,
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          widget.patientsService.dateFrom.value =
              DateFormat('yyyy-MM-dd').format(picked.start);
          widget.patientsService.dateTo.value =
              DateFormat('yyyy-MM-dd').format(picked.end);
          widget.patientsService.fetchPatients();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: widget.notifier.getBorderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: widget.notifier.getIconColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.patientsService.dateFrom.value.isNotEmpty &&
                    widget.patientsService.dateTo.value.isNotEmpty
                    ? "${widget.patientsService.dateFrom.value} to ${widget.patientsService.dateTo.value}"
                    : "Select Date Range",
                style: TextStyle(color: widget.notifier.getMainText),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderFilter() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        isDense: true,
        labelText: "Gender",
        labelStyle: TextStyle(color: widget.notifier.getMainText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.notifier.getBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.notifier.getBorderColor),
        ),
      ),
      value: widget.patientsService.selectedGender.value.isEmpty
          ? null
          : widget.patientsService.selectedGender.value,
      dropdownColor: widget.notifier.getContainer,
      style: TextStyle(color: widget.notifier.getMainText),
      items: [
        DropdownMenuItem(
          value: '',
          child: Text('All Genders', style: TextStyle(color: widget.notifier.getMainText)),
        ),
        DropdownMenuItem(
          value: 'male',
          child: Text('Male', style: TextStyle(color: widget.notifier.getMainText)),
        ),
        DropdownMenuItem(
          value: 'female',
          child: Text('Female', style: TextStyle(color: widget.notifier.getMainText)),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          widget.patientsService.selectedGender.value = value;
          widget.patientsService.fetchPatients();
        }
      },
    );
  }

  Widget _buildBloodGroupFilter() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        isDense: true,
        labelText: "Blood Group",
        labelStyle: TextStyle(color: widget.notifier.getMainText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.notifier.getBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.notifier.getBorderColor),
        ),
      ),
      value: widget.patientsService.selectedBloodGroup.value.isEmpty
          ? null
          : widget.patientsService.selectedBloodGroup.value,
      dropdownColor: widget.notifier.getContainer,
      style: TextStyle(color: widget.notifier.getMainText),
      items: [
        DropdownMenuItem(
          value: '',
          child: Text('All Blood Groups', style: TextStyle(color: widget.notifier.getMainText)),
        ),
        DropdownMenuItem(
          value: 'A+',
          child: Text('A+', style: TextStyle(color: widget.notifier.getMainText)),
        ),
        DropdownMenuItem(
          value: 'A-',
          child: Text('A-', style: TextStyle(color: widget.notifier.getMainText)),
        ),
        DropdownMenuItem(
          value: 'B+',
          child: Text('B+', style: TextStyle(color: widget.notifier.getMainText)),
        ),
        DropdownMenuItem(
          value: 'B-',
          child: Text('B-', style: TextStyle(color: widget.notifier.getMainText)),
        ),
        DropdownMenuItem(
          value: 'AB+',
          child: Text('AB+', style: TextStyle(color: widget.notifier.getMainText)),
        ),
        DropdownMenuItem(
          value: 'AB-',
          child: Text('AB-', style: TextStyle(color: widget.notifier.getMainText)),
        ),
        DropdownMenuItem(
          value: 'O+',
          child: Text('O+', style: TextStyle(color: widget.notifier.getMainText)),
        ),
        DropdownMenuItem(
          value: 'O-',
          child: Text('O-', style: TextStyle(color: widget.notifier.getMainText)),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          widget.patientsService.selectedBloodGroup.value = value;
          widget.patientsService.fetchPatients();
        }
      },
    );
  }

  Widget _buildSortByFilter() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        isDense: true,
        labelText: "Sort By",
        labelStyle: TextStyle(color: widget.notifier.getMainText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.notifier.getBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.notifier.getBorderColor),
        ),
      ),
      value: widget.patientsService.sortBy.value,
      dropdownColor: widget.notifier.getContainer,
      style: TextStyle(color: widget.notifier.getMainText),
      items: [
        DropdownMenuItem(
          value: 'created_at',
          child: Text('Registration Date', style: TextStyle(color: widget.notifier.getMainText)),
        ),
        DropdownMenuItem(
          value: 'first_name',
          child: Text('First Name', style: TextStyle(color: widget.notifier.getMainText)),
        ),
        DropdownMenuItem(
          value: 'last_name',
          child: Text('Last Name', style: TextStyle(color: widget.notifier.getMainText)),
        ),
        DropdownMenuItem(
          value: 'email',
          child: Text('Email', style: TextStyle(color: widget.notifier.getMainText)),
        ),
        DropdownMenuItem(
          value: 'patient_unique_id',
          child: Text('Patient ID', style: TextStyle(color: widget.notifier.getMainText)),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          widget.patientsService.sortBy.value = value;
          widget.patientsService.fetchPatients();
        }
      },
    );
  }

  Widget _buildSortDirectionFilter() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        isDense: true,
        labelText: "Sort Direction",
        labelStyle: TextStyle(color: widget.notifier.getMainText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.notifier.getBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.notifier.getBorderColor),
        ),
      ),
      value: widget.patientsService.sortDirection.value,
      dropdownColor: widget.notifier.getContainer,
      style: TextStyle(color: widget.notifier.getMainText),
      items: [
        DropdownMenuItem(
          value: 'asc',
          child: Text('Ascending', style: TextStyle(color: widget.notifier.getMainText)),
        ),
        DropdownMenuItem(
          value: 'desc',
          child: Text('Descending', style: TextStyle(color: widget.notifier.getMainText)),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          widget.patientsService.sortDirection.value = value;
          widget.patientsService.fetchPatients();
        }
      },
    );
  }
}