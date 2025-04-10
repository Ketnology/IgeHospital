import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/provider/doctor_service.dart';
import 'package:ige_hospital/provider/department_service.dart';
import 'package:ige_hospital/constants/static_data.dart';

class DoctorFilters extends StatefulWidget {
  final ColourNotifier notifier;
  final DoctorsService doctorsService;

  const DoctorFilters({
    super.key,
    required this.notifier,
    required this.doctorsService,
  });

  @override
  State<DoctorFilters> createState() => _DoctorFiltersState();
}

class _DoctorFiltersState extends State<DoctorFilters> {
  bool _isFilterExpanded = false;
  final TextEditingController specialtyController = TextEditingController();
  late DepartmentService _departmentService;
  bool _departmentServiceInitialized = false;

  @override
  void initState() {
    super.initState();
    specialtyController.text = widget.doctorsService.specialist.value;
    _initDepartmentService();
  }

  void _initDepartmentService() {
    try {
      _departmentService = Get.find<DepartmentService>();
      _departmentServiceInitialized = true;
    } catch (e) {
      // Service not found, create it
      _departmentServiceInitialized = false;
      // Create and initialize the department service
      _departmentService = Get.put(DepartmentService());
      _departmentServiceInitialized = true;
      // Trigger a refresh after fetching data
      _departmentService.fetchDepartments().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    specialtyController.dispose();
    super.dispose();
  }

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
                        specialtyController.clear();
                        widget.doctorsService.resetFilters();
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
                      _buildFilterRow(),
                      const SizedBox(height: 16),
                      _buildStatusAndSortRow(),
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
      controller: specialtyController,
      style: TextStyle(color: widget.notifier.getMainText),
      decoration: InputDecoration(
        hintText: "Search by name, email, specialty...",
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
        suffixIcon: specialtyController.text.isNotEmpty
            ? IconButton(
          icon: Icon(Icons.clear, size: 18, color: widget.notifier.getMaingey),
          onPressed: () {
            specialtyController.clear();
            widget.doctorsService.searchQuery.value = '';
            widget.doctorsService.fetchDoctors();
          },
        )
            : null,
      ),
      onFieldSubmitted: (value) {
        widget.doctorsService.searchQuery.value = value;
        widget.doctorsService.fetchDoctors();
      },
      onChanged: (value) {
        if (value.isEmpty) {
          widget.doctorsService.searchQuery.value = '';
          widget.doctorsService.fetchDoctors();
        }
      },
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        Expanded(
          child: _buildDepartmentDropdown(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            style: TextStyle(color: widget.notifier.getMainText),
            decoration: InputDecoration(
              labelText: "Specialty",
              labelStyle: TextStyle(color: widget.notifier.getMainText),
              hintText: "e.g. Cardiologist",
              hintStyle: TextStyle(color: widget.notifier.getMaingey),
              prefixIcon: Icon(Icons.local_hospital, color: widget.notifier.getIconColor),
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
            onFieldSubmitted: (value) {
              widget.doctorsService.specialist.value = value;
              widget.doctorsService.fetchDoctors();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDepartmentDropdown() {
    // If department service is not initialized yet, show loading
    if (!_departmentServiceInitialized) {
      return _buildDropdown(
        labelText: "Department (Loading...)",
        value: '',
        items: const [
          DropdownMenuItem(value: '', child: Text("Loading departments...")),
        ],
        onChanged: (value) {},
        icon: Icons.business,
      );
    }

    // Get department items from service
    return Obx(() {
      final dropdownItems = [
        const DropdownMenuItem(value: '', child: Text('All Departments')),
      ];

      // Add departments from service
      if (_departmentService.departments.isNotEmpty) {
        for (var dept in _departmentService.departments) {
          if (dept.status.toLowerCase() == 'active') {
            dropdownItems.add(DropdownMenuItem(
              value: dept.id,
              child: Text(dept.title),
            ));
          }
        }
      }

      return _buildDropdown(
        labelText: "Department",
        value: widget.doctorsService.departmentId.value,
        items: dropdownItems,
        onChanged: (value) {
          if (value != null) {
            widget.doctorsService.departmentId.value = value;
            widget.doctorsService.fetchDoctors();
          }
        },
        icon: Icons.business,
      );
    });
  }

  Widget _buildStatusAndSortRow() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            labelText: "Status",
            value: widget.doctorsService.searchQuery.value.contains('status:')
                ? widget.doctorsService.searchQuery.value.split('status:')[1].trim()
                : 'all',
            items: [
              const DropdownMenuItem(value: 'all', child: Text('All Statuses')),
              DropdownMenuItem(
                value: 'active',
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
                    const Text('Active'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'pending',
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
                    const Text('Pending'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'blocked',
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Blocked'),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                if (value == 'all') {
                  if (widget.doctorsService.searchQuery.value.contains('status:')) {
                    widget.doctorsService.searchQuery.value =
                        widget.doctorsService.searchQuery.value.replaceAll(RegExp(r'status:\w+\s*'), '');
                  }
                } else {
                  // Add or update status filter
                  if (widget.doctorsService.searchQuery.value.contains('status:')) {
                    widget.doctorsService.searchQuery.value =
                        widget.doctorsService.searchQuery.value.replaceAll(
                            RegExp(r'status:\w+'), 'status:$value');
                  } else {
                    if (widget.doctorsService.searchQuery.value.isNotEmpty) {
                      widget.doctorsService.searchQuery.value += ' status:$value';
                    } else {
                      widget.doctorsService.searchQuery.value = 'status:$value';
                    }
                  }
                }
                widget.doctorsService.fetchDoctors();
              }
            },
            icon: Icons.inventory_2_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDropdown(
            labelText: "Sort By",
            value: widget.doctorsService.sortDirection.value,
            items: const [
              DropdownMenuItem(value: 'asc', child: Text('Oldest First')),
              DropdownMenuItem(value: 'desc', child: Text('Newest First')),
            ],
            onChanged: (value) {
              if (value != null) {
                widget.doctorsService.sortDirection.value = value;
                widget.doctorsService.fetchDoctors();
              }
            },
            icon: Icons.sort,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String labelText,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: widget.notifier.getMainText),
        filled: true,
        fillColor: widget.notifier.getPrimaryColor,
        prefixIcon: Icon(icon, color: widget.notifier.getIconColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.notifier.getBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.notifier.getIconColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      ),
      dropdownColor: widget.notifier.getContainer,
      style: TextStyle(color: widget.notifier.getMainText),
      itemHeight: 50,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item.value,
          child: DefaultTextStyle(
            style: TextStyle(color: widget.notifier.getMainText),
            child: item.child,
          ),
        );
      }).toList(),
      onChanged: onChanged,
      icon: Icon(Icons.arrow_drop_down, color: widget.notifier.getIconColor),
    );
  }
}