import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/provider/appointment_service.dart';
import 'package:ige_hospital/widgets/common_button.dart';
import 'package:ige_hospital/widgets/text_field.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:intl/intl.dart';

class CreateAppointmentDialog extends StatefulWidget {
  final ColourNotifier notifier;
  final AppointmentsService appointmentsService;

  const CreateAppointmentDialog({
    super.key,
    required this.notifier,
    required this.appointmentsService,
  });

  @override
  State<CreateAppointmentDialog> createState() => _CreateAppointmentDialogState();
}

class _CreateAppointmentDialogState extends State<CreateAppointmentDialog> {
  final doctorNameController = TextEditingController();
  final patientNameController = TextEditingController();
  final problemController = TextEditingController();
  String priority = "Medium";
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    doctorNameController.dispose();
    patientNameController.dispose();
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
              "Create New Appointment",
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
                    MyTextField(
                      title: 'Doctor Name',
                      hinttext: "Enter Doctor's Name",
                      controller: doctorNameController,
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      title: 'Patient Name',
                      hinttext: "Enter Patient's Name",
                      controller: patientNameController,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
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
                                hinttext: DateFormat('MMM dd, yyyy').format(selectedDate),
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
                                initialTime: selectedTime,
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
                                hinttext: selectedTime.format(context),
                                controller: TextEditingController(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      title: 'Problem',
                      hinttext: "Describe the Problem",
                      controller: problemController,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Priority",
                          style: mediumBlackTextStyle.copyWith(
                            color: widget.notifier.getMainText,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: priority,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: widget.notifier.getContainer,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: widget.notifier.getIconColor,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                          ),
                          dropdownColor: widget.notifier.getContainer,
                          items: [
                            DropdownMenuItem(
                              value: "High",
                              child: Row(
                                children: [
                                  Icon(Icons.priority_high, color: Colors.red, size: 18),
                                  SizedBox(width: 10),
                                  Text("High", style: TextStyle(color: Colors.red, fontSize: 14)),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: "Medium",
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                                  SizedBox(width: 10),
                                  Text("Medium", style: TextStyle(color: Colors.orange, fontSize: 14)),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: "Low",
                              child: Row(
                                children: [
                                  Icon(Icons.low_priority, color: Colors.green, size: 18),
                                  SizedBox(width: 10),
                                  Text("Low", style: TextStyle(color: Colors.green, fontSize: 14)),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                priority = value;
                              });
                            }
                          },
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
                  title: "Create",
                  color: appMainColor,
                  onTap: () {
                    if (doctorNameController.text.isEmpty ||
                        patientNameController.text.isEmpty ||
                        problemController.text.isEmpty) {
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
                      "doctor_name": doctorNameController.text,
                      "patient_name": patientNameController.text,
                      "problem": problemController.text,
                      "opd_date": DateFormat("yyyy-MM-dd HH:mm:ss").format(
                        DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        ),
                      ),
                      "custom_field": priority,
                    };

                    widget.appointmentsService.createAppointment(appointmentData);
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