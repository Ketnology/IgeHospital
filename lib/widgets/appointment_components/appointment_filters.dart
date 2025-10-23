import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/provider/appointment_service.dart';

class AppointmentFilters extends StatelessWidget {
  final ColourNotifier notifier;
  final AppointmentsService appointmentsService;

  const AppointmentFilters({
    super.key,
    required this.notifier,
    required this.appointmentsService,
  });

  @override
  Widget build(BuildContext context) {
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSearchBox(context),
                const SizedBox(height: 16),
                _buildDateRangeFilter(context),
                const SizedBox(height: 16),
                _buildStatusAndSortRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBox(BuildContext context) {
    final searchController = TextEditingController(
        text: appointmentsService.searchQuery.value);

    return TextFormField(
      controller: searchController,
      style: TextStyle(color: notifier.getMainText),
      decoration: InputDecoration(
        hintText: "Search by doctor, patient, problem...",
        hintStyle: TextStyle(color: notifier.getMaingey),
        prefixIcon: Icon(Icons.search, color: notifier.getIconColor),
        filled: true,
        fillColor: notifier.getPrimaryColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: notifier.getBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: notifier.getIconColor),
        ),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear,
                    size: 18, color: notifier.getMaingey),
                onPressed: () {
                  searchController.clear();
                  appointmentsService.searchQuery.value = '';
                  appointmentsService.fetchAppointments();
                },
              )
            : null,
      ),
      onFieldSubmitted: (value) {
        appointmentsService.searchQuery.value = value;
        appointmentsService.fetchAppointments();
      },
      onChanged: (value) {
        if (value.isEmpty) {
          appointmentsService.searchQuery.value = '';
          appointmentsService.fetchAppointments();
        }
      },
    );
  }

  Widget _buildDateRangeFilter(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final DateTimeRange? picked = await showDateRangePicker(
          context: context,
          initialDateRange: DateTimeRange(
            start: appointmentsService.dateFrom.value.isNotEmpty
                ? DateTime.parse(appointmentsService.dateFrom.value)
                : DateTime.now().subtract(const Duration(days: 30)),
            end: appointmentsService.dateTo.value.isNotEmpty
                ? DateTime.parse(appointmentsService.dateTo.value)
                : DateTime.now(),
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
          appointmentsService.dateFrom.value =
              DateFormat('yyyy-MM-dd').format(picked.start);
          appointmentsService.dateTo.value =
              DateFormat('yyyy-MM-dd').format(picked.end);
          appointmentsService.fetchAppointments();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: notifier.getBorderColor),
          borderRadius: BorderRadius.circular(8),
          color: notifier.getPrimaryColor,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today,
                size: 20, color: notifier.getIconColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                appointmentsService.dateFrom.value.isNotEmpty &&
                        appointmentsService.dateTo.value.isNotEmpty
                    ? "${appointmentsService.dateFrom.value} to ${appointmentsService.dateTo.value}"
                    : "Select Date Range",
                style: TextStyle(color: notifier.getMainText),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: notifier.getMainText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusAndSortRow() {
    return Row(
      children: [
        // Completed Status Dropdown
        Expanded(
          child: DropdownButtonFormField<bool>(
            isExpanded: true,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              isDense: true,
              filled: true,
              fillColor: notifier.getPrimaryColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: notifier.getBorderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: notifier.getBorderColor),
              ),
            ),
            value: appointmentsService.filterCompleted.value,
            dropdownColor: notifier.getContainer,
            style: TextStyle(color: notifier.getMainText),
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
                        style: TextStyle(color: notifier.getMainText)),
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
                        style: TextStyle(color: notifier.getMainText)),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                appointmentsService.filterCompleted.value = value;
                appointmentsService.fetchAppointments();
              }
            },
          ),
        ),
        const SizedBox(width: 10),

        // Sort Direction Dropdown
        Expanded(
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              isDense: true,
              filled: true,
              fillColor: notifier.getPrimaryColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: notifier.getBorderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: notifier.getBorderColor),
              ),
            ),
            value: appointmentsService.sortDirection.value,
            dropdownColor: notifier.getContainer,
            style: TextStyle(color: notifier.getMainText),
            items: [
              DropdownMenuItem(
                value: 'asc',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward,
                        size: 14, color: notifier.getIconColor),
                    const SizedBox(width: 8),
                    Text('Oldest First',
                        style: TextStyle(color: notifier.getMainText)),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'desc',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward,
                        size: 14, color: notifier.getIconColor),
                    const SizedBox(width: 8),
                    Text('Newest First',
                        style: TextStyle(color: notifier.getMainText)),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                appointmentsService.sortDirection.value = value;
                appointmentsService.fetchAppointments();
              }
            },
          ),
        ),
      ],
    );
  }
}