import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/provider/appointment_service.dart';
import 'package:ige_hospital/constants/static_data.dart';

class AppointmentFilters extends StatefulWidget {
  final ColourNotifier notifier;
  final AppointmentsService appointmentsService;
  final TextEditingController searchController;

  const AppointmentFilters({
    super.key,
    required this.notifier,
    required this.appointmentsService,
    required this.searchController,
  });

  @override
  State<AppointmentFilters> createState() => _AppointmentFiltersState();
}

class _AppointmentFiltersState extends State<AppointmentFilters> {
  bool _isFilterExpanded = true;

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
              ListTile(
                onTap: () {
                  setState(() {
                    _isFilterExpanded = !_isFilterExpanded;
                  });
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  "Filters & Search",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: widget.notifier.getMainText,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        widget.searchController.clear();
                        widget.appointmentsService.resetFilters();
                      },
                      icon: Icon(Icons.refresh, size: 16, color: widget.notifier.getIconColor),
                      label: Text(
                        "Reset",
                        style: TextStyle(color: widget.notifier.getIconColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _isFilterExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: widget.notifier.getIconColor,
                    ),
                  ],
                ),
              ),

              // Expandable filter content
              AnimatedCrossFade(
                firstChild: const SizedBox(height: 0),
                secondChild: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildSearchBox(),
                      const SizedBox(height: 16),
                      _buildDateFilter(),
                      const SizedBox(height: 16),
                      _buildDropdownFilters(),
                    ],
                  ),
                ),
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

  Widget _buildSearchBox() {
    return TextFormField(
      controller: widget.searchController,
      style: TextStyle(color: widget.notifier.getMainText),
      decoration: InputDecoration(
        hintText: "Search by doctor, patient, ID or problem...",
        hintStyle: TextStyle(color: widget.notifier.getMaingey),
        prefixIcon: Icon(Icons.search, color: widget.notifier.getIconColor),
        filled: true,
        fillColor: widget.notifier.getPrimaryColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.notifier.getBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.notifier.getIconColor),
        ),
        suffixIcon: widget.searchController.text.isNotEmpty
            ? IconButton(
          icon: Icon(Icons.clear, size: 18, color: widget.notifier.getMaingey),
          onPressed: () {
            widget.searchController.clear();
            widget.appointmentsService.searchQuery.value = '';
            widget.appointmentsService.fetchAppointments();
          },
        )
            : null,
      ),
      onFieldSubmitted: (value) {
        widget.appointmentsService.searchQuery.value = value;
        widget.appointmentsService.fetchAppointments();
      },
      onChanged: (value) {
        if (value.isEmpty) {
          widget.appointmentsService.searchQuery.value = '';
          widget.appointmentsService.fetchAppointments();
        }
      },
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
                dialogBackgroundColor: widget.notifier.getContainer,
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          widget.appointmentsService.dateFrom.value =
              DateFormat('yyyy-MM-dd').format(picked.start);
          widget.appointmentsService.dateTo.value =
              DateFormat('yyyy-MM-dd').format(picked.end);
          widget.appointmentsService.fetchAppointments();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12
        ),
        decoration: BoxDecoration(
          border: Border.all(color: widget.notifier.getBorderColor),
          borderRadius: BorderRadius.circular(8),
          color: widget.notifier.getPrimaryColor,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today,
                size: 20, color: widget.notifier.getIconColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.appointmentsService.dateFrom.value.isNotEmpty &&
                    widget.appointmentsService.dateTo.value.isNotEmpty
                    ? "${widget.appointmentsService.dateFrom.value} to ${widget.appointmentsService.dateTo.value}"
                    : "Select Date Range",
                style: TextStyle(color: widget.notifier.getMainText),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: widget.notifier.getMainText),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFilters() {
    return Row(
      children: [
        // Sort Direction Dropdown
        Expanded(
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: InputDecoration(
              labelText: "Sort Order",
              labelStyle: TextStyle(color: widget.notifier.getMainText),
              filled: true,
              fillColor: widget.notifier.getPrimaryColor,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: widget.notifier.getBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: widget.notifier.getIconColor),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            value: widget.appointmentsService.sortDirection.value,
            dropdownColor: widget.notifier.getContainer,
            style: TextStyle(color: widget.notifier.getMainText),
            items: [
              DropdownMenuItem(
                value: 'asc',
                child: Text('Oldest First',
                    style: TextStyle(color: widget.notifier.getMainText)),
              ),
              DropdownMenuItem(
                value: 'desc',
                child: Text('Newest First',
                    style: TextStyle(color: widget.notifier.getMainText)),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                widget.appointmentsService.sortDirection.value = value;
                widget.appointmentsService.fetchAppointments();
              }
            },
          ),
        ),
        const SizedBox(width: 16),

        // Status Dropdown
        Expanded(
          child: DropdownButtonFormField<bool>(
            isExpanded: true,
            decoration: InputDecoration(
              labelText: "Status",
              labelStyle: TextStyle(color: widget.notifier.getMainText),
              filled: true,
              fillColor: widget.notifier.getPrimaryColor,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: widget.notifier.getBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: widget.notifier.getIconColor),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            value: widget.appointmentsService.filterCompleted.value,
            dropdownColor: widget.notifier.getContainer,
            style: TextStyle(color: widget.notifier.getMainText),
            items: [
              DropdownMenuItem(
                value: false,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Pending',
                        style: TextStyle(color: widget.notifier.getMainText)),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: true,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Completed',
                        style: TextStyle(color: widget.notifier.getMainText)),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                widget.appointmentsService.filterCompleted.value = value;
                widget.appointmentsService.fetchAppointments();
              }
            },
          ),
        ),
      ],
    );
  }
}