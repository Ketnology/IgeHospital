import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/provider/appointment_service.dart';
import 'package:ige_hospital/models/appointment_model.dart';
import 'package:ige_hospital/widgets/common_button.dart';
import 'package:ige_hospital/widgets/text_field.dart';
import 'package:ige_hospital/constants/static_data.dart';

class EditAppointmentDialog extends StatefulWidget {
  final AppointmentModel appointment;
  final ColourNotifier notifier;
  final AppointmentsService appointmentsService;

  const EditAppointmentDialog({
    super.key,
    required this.appointment,
    required this.notifier,
    required this.appointmentsService,
  });

  @override
  State<EditAppointmentDialog> createState() => _EditAppointmentDialogState();
}

class _EditAppointmentDialogState extends State<EditAppointmentDialog> {
  late TextEditingController problemController;
  // late String priority;
  late bool isCompleted;

  // Date and time fields
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    problemController = TextEditingController(text: widget.appointment.problem);
    // priority = widget.appointment.customField ?? "Medium";
    isCompleted = widget.appointment.isCompleted;

    // Parse date and time from appointment
    _initializeDateAndTime();
  }

  void _initializeDateAndTime() {
    try {
      // Try to parse from appointment date field first
      if (widget.appointment.appointmentDate.isNotEmpty &&
          widget.appointment.appointmentTime.isNotEmpty) {
        final dateStr = widget.appointment.appointmentDate;
        final timeStr = widget.appointment.appointmentTime;

        // Parse date
        final dateParts = dateStr.split('/');
        if (dateParts.length == 3) {
          // Handle dd/mm/yyyy format
          final day = int.tryParse(dateParts[0]) ?? 1;
          final month = int.tryParse(dateParts[1]) ?? 1;
          final year = int.tryParse(dateParts[2]) ?? 2025;
          selectedDate = DateTime(year, month, day);
        } else {
          // Try parsing as ISO date
          selectedDate = DateTime.tryParse(dateStr);
        }

        // Parse time
        final timeParts = timeStr.split(':');
        if (timeParts.length >= 2) {
          final hour = int.tryParse(timeParts[0]) ?? 0;
          final minute = int.tryParse(timeParts[1].split(' ')[0]) ?? 0;

          // Check for AM/PM
          bool isPM = timeStr.toLowerCase().contains('pm');
          int adjustedHour = hour;
          if (isPM && hour < 12) adjustedHour += 12;
          if (!isPM && hour == 12) adjustedHour = 0;

          selectedTime = TimeOfDay(hour: adjustedHour, minute: minute);
        }
      }

      // Fallback to opdDate if appointment date/time parsing failed
      if (selectedDate == null || selectedTime == null) {
        final opdDateTime = widget.appointment.opdDate;
        if (opdDateTime is DateTime) {
          // selectedDate = opdDateTime;
          // selectedTime = TimeOfDay.fromDateTime(opdDateTime);
        } else if (opdDateTime.toString().isNotEmpty) {
          try {
            final parsedDate = DateTime.parse(opdDateTime.toString());
            selectedDate = parsedDate;
            selectedTime = TimeOfDay.fromDateTime(parsedDate);
          } catch (e) {
            print("Error parsing opdDate string: $e");
          }
        }
      }
    } catch (e) {
      print("Error parsing appointment date/time: $e");
    }

    // Set default values if parsing failed
    selectedDate ??= DateTime.now();
    selectedTime ??= TimeOfDay.now();
  }

  @override
  void dispose() {
    problemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: widget.notifier.getContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: Container(
        width: 500,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.notifier.getContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "Edit Appointment",
              style: TextStyle(
                color: widget.notifier.getMainText,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 15),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: selectedDate!,
                                firstDate: DateTime(2010),
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

                              if (pickedDate != null) {
                                setState(() {
                                  selectedDate = pickedDate;
                                });
                              }
                            },
                            child: AbsorbPointer(
                              child: MyTextField(
                                title: 'Date',
                                hinttext: selectedDate != null
                                    ? DateFormat('MMM dd, yyyy').format(selectedDate!)
                                    : "Pick a date",
                                controller: TextEditingController(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: selectedTime ?? TimeOfDay.now(),
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

                              if (pickedTime != null) {
                                setState(() {
                                  selectedTime = pickedTime;
                                });
                              }
                            },
                            child: AbsorbPointer(
                              child: MyTextField(
                                title: 'Time',
                                hinttext: selectedTime != null
                                    ? selectedTime!.format(context)
                                    : "Pick a time",
                                controller: TextEditingController(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // MyTextField(
                    //   title: 'Problem',
                    //   hinttext: "Describe the Problem",
                    //   controller: problemController,
                    //   maxLines: 2,
                    // ),
                    // const SizedBox(height: 10),
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     Text(
                    //       "Priority",
                    //       style: mediumBlackTextStyle.copyWith(
                    //         color: widget.notifier.getMainText,
                    //       ),
                    //     ),
                    //     const SizedBox(height: 10),
                    //     Builder(
                    //         builder: (context) {
                    //           // Standard priority options
                    //           final standardPriorities = ["High", "Medium", "Low"];
                    //
                    //           // Check if current priority is not one of the standard options
                    //           if (!standardPriorities.contains(priority)) {
                    //             // Add the custom priority to the list of options
                    //             standardPriorities.add(priority);
                    //           }
                    //
                    //           return DropdownButtonFormField<String>(
                    //             value: priority,
                    //             decoration: InputDecoration(
                    //               filled: true,
                    //               fillColor: widget.notifier.getContainer,
                    //               enabledBorder: OutlineInputBorder(
                    //                 borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    //                 borderRadius: const BorderRadius.all(Radius.circular(10)),
                    //               ),
                    //               focusedBorder: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(8),
                    //                 borderSide: BorderSide(
                    //                   color: widget.notifier.getIconColor,
                    //                   width: 1.5,
                    //                 ),
                    //               ),
                    //               contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    //             ),
                    //             dropdownColor: widget.notifier.getContainer,
                    //             items: standardPriorities.map((String value) {
                    //               IconData icon;
                    //               Color color;
                    //
                    //               switch (value) {
                    //                 case "High":
                    //                   icon = Icons.priority_high;
                    //                   color = Colors.red;
                    //                   break;
                    //                 case "Medium":
                    //                   icon = Icons.warning_amber_rounded;
                    //                   color = Colors.orange;
                    //                   break;
                    //                 case "Low":
                    //                   icon = Icons.low_priority;
                    //                   color = Colors.green;
                    //                   break;
                    //                 default:
                    //                   icon = Icons.label;
                    //                   color = Colors.blue;
                    //               }
                    //
                    //               return DropdownMenuItem<String>(
                    //                 value: value,
                    //                 child: Row(
                    //                   children: [
                    //                     Icon(icon, color: color, size: 18),
                    //                     const SizedBox(width: 10),
                    //                     Text(value,
                    //                         style: TextStyle(
                    //                             color: standardPriorities.contains(value) ? color : widget.notifier.getMainText,
                    //                             fontSize: 14
                    //                         )
                    //                     ),
                    //                   ],
                    //                 ),
                    //               );
                    //             }).toList(),
                    //             onChanged: (value) {
                    //               if (value != null) {
                    //                 setState(() {
                    //                   priority = value;
                    //                 });
                    //               }
                    //             },
                    //           );
                    //         }
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: isCompleted,
                          activeColor: widget.notifier.getIconColor,
                          onChanged: (value) {
                            setState(() {
                              isCompleted = value ?? false;
                            });
                          },
                        ),
                        Text(
                          "Mark as Completed",
                          style: TextStyle(color: widget.notifier.getMainText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CommonButton(
                  title: "Cancel",
                  color: const Color(0xfff73164),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 10),
                CommonButton(
                  title: "Save Changes",
                  color: appMainColor,
                  onTap: () {
                    if (problemController.text.isEmpty) {
                      Get.snackbar(
                        "Error",
                        "Please fill all required fields",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    final appointmentData = {
                      "problem": problemController.text,
                      "opd_date": DateFormat("yyyy-MM-dd HH:mm:ss").format(
                        DateTime(
                          selectedDate!.year,
                          selectedDate!.month,
                          selectedDate!.day,
                          selectedTime!.hour,
                          selectedTime!.minute,
                        ),
                      ),
                      // "custom_field": priority,
                      "is_completed": isCompleted,
                    };

                    widget.appointmentsService.updateAppointment(
                        widget.appointment.id, appointmentData);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}