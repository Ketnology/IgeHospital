import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ige_hospital/controllers/patient_controller.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/form/app_text_field.dart';
import 'package:ige_hospital/widgets/form/app_dropdown_field.dart';
import 'package:provider/provider.dart';

class PatientFilters extends StatelessWidget {
  final PatientController controller;
  final TextEditingController searchController;
  final bool showFilters;

  const PatientFilters({
    super.key,
    required this.controller,
    required this.searchController,
    required this.showFilters,
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
            hintText: "Search by name, email, or phone...",
            controller: searchController,
            prefixIcon: Icons.search,
            suffixIcon:
                searchController.text.isNotEmpty ? Icons.clear : null,
            onSuffixIconPressed: () {
              searchController.clear();
              controller.searchQuery.value = '';
              controller.loadPatients();
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
                controller.dateFrom.value =
                    DateFormat('yyyy-MM-dd').format(picked.start);
                controller.dateTo.value =
                    DateFormat('yyyy-MM-dd').format(picked.end);
                controller.loadPatients();
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
                  Icon(Icons.calendar_today,
                      size: 18, color: notifier.getIconColor),
                  const SizedBox(width: 8),
                  Obx(() => Expanded(
                        child: Text(
                          controller.dateFrom.value.isNotEmpty &&
                                  controller.dateTo.value.isNotEmpty
                              ? "${controller.dateFrom.value} to ${controller.dateTo.value}"
                              : "Select Date Range",
                          style: TextStyle(
                            color: controller
                                        .dateFrom.value.isNotEmpty &&
                                    controller.dateTo.value.isNotEmpty
                                ? notifier.getMainText
                                : notifier.getMaingey,
                          ),
                        ),
                      )),
                  Icon(Icons.arrow_drop_down, color: notifier.getIconColor),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                      menuMaxHeight: 400,
                      isExpanded: true,
                      value: controller.selectedGender.value.isEmpty
                          ? 'All'
                          : controller
                              .selectedGender.value.capitalizeFirst,
                      decoration: InputDecoration(
                        labelText: 'Gender',
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
                            horizontal: 12, vertical: 16),
                        filled: true,
                        fillColor: notifier.getPrimaryColor,
                      ),
                      dropdownColor: notifier.getContainer,
                      style: TextStyle(color: notifier.getMainText),
                      items: controller.genders.map((gender) {
                        return DropdownMenuItem(
                          value: gender,
                          child: SizedBox(
                            width: 200,
                            child: Text(
                              gender,
                              style: TextStyle(color: notifier.getMainText),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.selectedGender.value =
                              value == 'All' ? '' : value.toLowerCase();
                          controller.loadPatients();
                        }
                      },
                    )),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                      menuMaxHeight: 400,
                      isExpanded: true,
                      value: controller.selectedBloodGroup.value.isEmpty
                          ? 'All'
                          : controller.selectedBloodGroup.value,
                      decoration: InputDecoration(
                        labelText: 'Blood Group',
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
                            horizontal: 12, vertical: 16),
                        filled: true,
                        fillColor: notifier.getPrimaryColor,
                      ),
                      dropdownColor: notifier.getContainer,
                      style: TextStyle(color: notifier.getMainText),
                      items: controller.bloodGroups.map((group) {
                        return DropdownMenuItem(
                          value: group,
                          child: SizedBox(
                            width: 200,
                            child: Text(
                              group,
                              style: TextStyle(color: notifier.getMainText),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.selectedBloodGroup.value =
                              value == 'All' ? '' : value;
                          controller.loadPatients();
                        }
                      },
                    )),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sort Direction
          Obx(() => DropdownButtonFormField<String>(
                menuMaxHeight: 400,
                isExpanded: true,
                value: controller.sortDirection.value,
                decoration: InputDecoration(
                  labelText: 'Sort Order',
                  labelStyle: TextStyle(color: notifier.getMainText),
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  filled: true,
                  fillColor: notifier.getPrimaryColor,
                ),
                dropdownColor: notifier.getContainer,
                style: TextStyle(color: notifier.getMainText, fontSize: 14),
                items: [
                  DropdownMenuItem(
                    value: 'desc',
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.25,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_downward,
                              size: 14, color: notifier.getIconColor),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Newest First',
                              style: TextStyle(
                                  color: notifier.getMainText, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'asc',
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.25,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_upward,
                              size: 14, color: notifier.getIconColor),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Oldest First',
                              style: TextStyle(
                                  color: notifier.getMainText, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    controller.sortDirection.value = value;
                    controller.loadPatients();
                  }
                },
              )),
        ],
      ),
    );
  }
}
