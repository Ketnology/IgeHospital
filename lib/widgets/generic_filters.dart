import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ige_hospital/provider/colors_provider.dart';

class FilterField {
  final String name;
  final String label;
  final String? value;
  final List<DropdownMenuItem<String>>? items;
  final IconData? icon;
  final bool isDate;
  final bool isDateRange;
  final bool isTextField;
  final bool isDropdown;

  FilterField({
    required this.name,
    required this.label,
    this.value,
    this.items,
    this.icon,
    this.isDate = false,
    this.isDateRange = false,
    this.isTextField = false,
    this.isDropdown = false,
  });
}

class GenericFilters extends StatefulWidget {
  final ColourNotifier notifier;
  final List<FilterField> filters;
  final Function(Map<String, String>) onApplyFilters;
  final VoidCallback onResetFilters;
  final Map<String, String> initialValues;

  const GenericFilters({
    super.key,
    required this.notifier,
    required this.filters,
    required this.onApplyFilters,
    required this.onResetFilters,
    this.initialValues = const {},
  });

  @override
  State<GenericFilters> createState() => _GenericFiltersState();
}

class _GenericFiltersState extends State<GenericFilters> {
  bool _isFilterExpanded = false;
  Map<String, String> filterValues = {};
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize filter values from initialValues or set defaults
    filterValues = Map.from(widget.initialValues);

    // Initialize text controllers for text fields
    for (var filter in widget.filters) {
      if (filter.isTextField) {
        _controllers[filter.name] = TextEditingController(
          text: widget.initialValues[filter.name] ?? '',
        );
      }
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                      _controllers.forEach((_, controller) => controller.clear());
                      widget.onResetFilters();
                    },
                    icon: Icon(Icons.refresh,
                        size: 16, color: widget.notifier.getIconColor),
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
              secondChild: _buildExpandedFilters(),
              duration: const Duration(milliseconds: 300),
              crossFadeState: _isFilterExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          // Generate filter fields dynamically
          ...widget.filters.map((filter) {
            if (filter.isTextField) {
              return _buildTextField(filter);
            } else if (filter.isDropdown) {
              return _buildDropdown(filter);
            } else if (filter.isDateRange) {
              return _buildDateRangeField(filter);
            } else if (filter.isDate) {
              return _buildDateField(filter);
            } else {
              return const SizedBox.shrink();
            }
          }).toList(),

          const SizedBox(height: 16),

          // Apply filters button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Collect values from text controllers
                  for (var entry in _controllers.entries) {
                    filterValues[entry.key] = entry.value.text;
                  }
                  widget.onApplyFilters(filterValues);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.notifier.getIconColor,
                ),
                child: const Text(
                  "Apply Filters",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(FilterField filter) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: _controllers[filter.name],
        style: TextStyle(color: widget.notifier.getMainText),
        decoration: InputDecoration(
          labelText: filter.label,
          labelStyle: TextStyle(color: widget.notifier.getMainText),
          hintText: "Enter ${filter.label.toLowerCase()}",
          prefixIcon: filter.icon != null
              ? Icon(filter.icon, color: widget.notifier.getIconColor)
              : null,
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
        ),
        onChanged: (value) {
          filterValues[filter.name] = value;
        },
      ),
    );
  }

  Widget _buildDropdown(FilterField filter) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: filterValues[filter.name] ?? '',
        decoration: InputDecoration(
          labelText: filter.label,
          labelStyle: TextStyle(color: widget.notifier.getMainText),
          filled: true,
          fillColor: widget.notifier.getPrimaryColor,
          prefixIcon: filter.icon != null
              ? Icon(filter.icon, color: widget.notifier.getIconColor)
              : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: widget.notifier.getBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: widget.notifier.getIconColor),
          ),
        ),
        dropdownColor: widget.notifier.getContainer,
        style: TextStyle(color: widget.notifier.getMainText),
        items: filter.items,
        onChanged: (value) {
          if (value != null) {
            setState(() {
              filterValues[filter.name] = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildDateRangeField(FilterField filter) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
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
            setState(() {
              final fromDate = DateFormat('yyyy-MM-dd').format(picked.start);
              final toDate = DateFormat('yyyy-MM-dd').format(picked.end);
              filterValues['${filter.name}_from'] = fromDate;
              filterValues['${filter.name}_to'] = toDate;
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: widget.notifier.getBorderColor),
            borderRadius: BorderRadius.circular(8),
            color: widget.notifier.getPrimaryColor,
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: widget.notifier.getIconColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  filterValues.containsKey('${filter.name}_from') &&
                      filterValues.containsKey('${filter.name}_to')
                      ? "${filterValues['${filter.name}_from']} to ${filterValues['${filter.name}_to']}"
                      : filter.label,
                  style: TextStyle(color: widget.notifier.getMainText),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(FilterField filter) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
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
            setState(() {
              filterValues[filter.name] = DateFormat('yyyy-MM-dd').format(picked);
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: widget.notifier.getBorderColor),
            borderRadius: BorderRadius.circular(8),
            color: widget.notifier.getPrimaryColor,
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: widget.notifier.getIconColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  filterValues.containsKey(filter.name)
                      ? filterValues[filter.name]!
                      : filter.label,
                  style: TextStyle(color: widget.notifier.getMainText),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}