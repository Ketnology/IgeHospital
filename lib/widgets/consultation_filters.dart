import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/consultation_controller.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/text_field.dart';
import 'package:provider/provider.dart';

class ConsultationFilters extends StatefulWidget {
  final bool initiallyExpanded;

  const ConsultationFilters({
    super.key,
    this.initiallyExpanded = false,
  });

  @override
  State<ConsultationFilters> createState() => _ConsultationFiltersState();
}

class _ConsultationFiltersState extends State<ConsultationFilters> {
  late bool _isFilterExpanded;
  final TextEditingController _searchController = TextEditingController();
  final ConsultationController consultationController = Get.find<ConsultationController>();

  @override
  void initState() {
    super.initState();
    _isFilterExpanded = widget.initiallyExpanded;
    _searchController.text = consultationController.searchQuery.value;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                          _searchController.clear();
                          consultationController.resetFilters();
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
          TextField(
            controller: _searchController,
            style: TextStyle(color: notifier.getMainText),
            onChanged: (value) {
              consultationController.searchQuery.value = value;
            },
            decoration: InputDecoration(
              hintText: 'Search by title, doctor, patient...',
              hintStyle: TextStyle(color: notifier.getMaingey),
              prefixIcon: Icon(Icons.search, color: notifier.getIconColor),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: Icon(Icons.clear, color: notifier.getMaingey),
                onPressed: () {
                  _searchController.clear();
                  consultationController.searchQuery.value = '';
                },
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: notifier.getBorderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: notifier.getBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: notifier.getIconColor),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              filled: true,
              fillColor: notifier.getPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Status and Type filters
          Row(
            children: [
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                  value: consultationController.selectedStatus.value.isEmpty
                      ? 'All'
                      : consultationController.selectedStatus.value.capitalizeFirst,
                  decoration: _inputDecoration('Status', notifier, Icons.circle),
                  dropdownColor: notifier.getContainer,
                  style: TextStyle(color: notifier.getMainText),
                  isExpanded: true,
                  items: consultationController.statusOptions.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        status,
                        style: TextStyle(color: notifier.getMainText),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      consultationController.selectedStatus.value =
                      value == 'All' ? '' : value.toLowerCase();
                    }
                  },
                )),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                  value: consultationController.sortDirection.value,
                  decoration: _inputDecoration('Sort Order', notifier, Icons.sort),
                  dropdownColor: notifier.getContainer,
                  style: TextStyle(color: notifier.getMainText),
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: 'desc',
                      child: Text(
                        'Newest First',
                        style: TextStyle(color: notifier.getMainText),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'asc',
                      child: Text(
                        'Oldest First',
                        style: TextStyle(color: notifier.getMainText),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      consultationController.sortDirection.value = value;
                    }
                  },
                )),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date range filters
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, true),
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: _inputDecoration('From Date', notifier, Icons.calendar_today),
                      controller: TextEditingController(
                        text: consultationController.selectedDateFrom.value.isEmpty
                            ? ''
                            : consultationController.selectedDateFrom.value,
                      ),
                      style: TextStyle(color: notifier.getMainText),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, false),
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: _inputDecoration('To Date', notifier, Icons.calendar_today),
                      controller: TextEditingController(
                        text: consultationController.selectedDateTo.value.isEmpty
                            ? ''
                            : consultationController.selectedDateTo.value,
                      ),
                      style: TextStyle(color: notifier.getMainText),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, ColourNotifier notifier, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: notifier.getMaingey),
      prefixIcon: Icon(icon, color: notifier.getIconColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: notifier.getBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: notifier.getBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: notifier.getIconColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      fillColor: notifier.getPrimaryColor,
      filled: true,
    );
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        final notifier = Provider.of<ColourNotifier>(context);
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
      final String formattedDate = picked.toIso8601String().split('T')[0];
      if (isFromDate) {
        consultationController.selectedDateFrom.value = formattedDate;
      } else {
        consultationController.selectedDateTo.value = formattedDate;
      }
    }
  }
}