import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/consultation_controller.dart';
import 'package:ige_hospital/models/consultation_model.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ConsultationFormDialog extends StatefulWidget {
  final LiveConsultation? consultation;
  final bool isEdit;

  const ConsultationFormDialog({
    super.key,
    this.consultation,
    this.isEdit = false,
  });

  @override
  State<ConsultationFormDialog> createState() => _ConsultationFormDialogState();
}

class _ConsultationFormDialogState extends State<ConsultationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final ConsultationController consultationController =
      Get.find<ConsultationController>();

  // Text controllers
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController doctorIdController;
  late final TextEditingController patientIdController;

  // Selected values
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  late int selectedDuration;
  late String selectedType;
  late String selectedTimeZone;
  late bool hostVideo;
  late bool participantVideo;

  // Loading state
  bool isLoading = false;

  // Options
  final List<int> durationOptions = [15, 30, 45, 60, 90, 120];
  final List<String> typeOptions = [
    'scheduled',
    'follow-up',
    'emergency',
    'comprehensive'
  ];
  final List<String> timeZoneOptions = [
    'UTC',
    'America/New_York',
    'Europe/London',
    'Asia/Tokyo'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (widget.isEdit && widget.consultation != null) {
      final consultation = widget.consultation!;
      titleController =
          TextEditingController(text: consultation.consultationTitle);
      descriptionController =
          TextEditingController(text: consultation.description ?? '');
      doctorIdController = TextEditingController(text: consultation.doctor.id);
      patientIdController =
          TextEditingController(text: consultation.patient.id);

      selectedDate = consultation.consultationDate;
      selectedTime = TimeOfDay.fromDateTime(consultation.consultationDate);
      selectedDuration = consultation.consultationDurationMinutes;
      selectedType = consultation.type;
      selectedTimeZone = consultation.timeZone;
      hostVideo = consultation.hostVideo;
      participantVideo = consultation.participantVideo;
    } else {
      titleController = TextEditingController();
      descriptionController = TextEditingController();
      doctorIdController = TextEditingController();
      patientIdController = TextEditingController();

      selectedDate = DateTime.now().add(const Duration(days: 1));
      selectedTime = const TimeOfDay(hour: 9, minute: 0);
      selectedDuration = 30;
      selectedType = 'scheduled';
      selectedTimeZone = 'UTC';
      hostVideo = true;
      participantVideo = true;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    doctorIdController.dispose();
    patientIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: notifier.getContainer,
      child: Container(
        width: 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: notifier.getContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: notifier.getBorderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, notifier),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Basic Information', notifier),
                      const SizedBox(height: 16),

                      // Title
                      TextFormField(
                        controller: titleController,
                        decoration: _inputDecoration(
                            'Consultation Title', notifier, Icons.title),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                        style: TextStyle(color: notifier.getMainText),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: descriptionController,
                        decoration: _inputDecoration('Description (Optional)',
                            notifier, Icons.description),
                        maxLines: 3,
                        style: TextStyle(color: notifier.getMainText),
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle('Scheduling', notifier),
                      const SizedBox(height: 16),

                      // Date and Time
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context, notifier),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  decoration: _inputDecoration(
                                      'Date', notifier, Icons.calendar_today),
                                  controller: TextEditingController(
                                    text: DateFormat('MMM dd, yyyy')
                                        .format(selectedDate),
                                  ),
                                  style: TextStyle(color: notifier.getMainText),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectTime(context, notifier),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  decoration: _inputDecoration(
                                      'Time', notifier, Icons.access_time),
                                  controller: TextEditingController(
                                    text: selectedTime.format(context),
                                  ),
                                  style: TextStyle(color: notifier.getMainText),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Duration and Type
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              isExpanded: true,
                              value: selectedDuration,
                              decoration: _inputDecoration(
                                  'Duration (minutes)', notifier, Icons.timer),
                              items: durationOptions.map((duration) {
                                return DropdownMenuItem(
                                  value: duration,
                                  child: Text('$duration minutes',
                                      style: TextStyle(
                                          color: notifier.getMainText)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedDuration = value;
                                  });
                                }
                              },
                              dropdownColor: notifier.getContainer,
                              style: TextStyle(color: notifier.getMainText),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: selectedType,
                              decoration: _inputDecoration(
                                  'Type', notifier, Icons.category),
                              items: typeOptions.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type.capitalizeFirst!,
                                      style: TextStyle(
                                          color: notifier.getMainText)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedType = value;
                                  });
                                }
                              },
                              dropdownColor: notifier.getContainer,
                              style: TextStyle(color: notifier.getMainText),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Time Zone
                      DropdownButtonFormField<String>(
                        value: selectedTimeZone,
                        decoration: _inputDecoration(
                            'Time Zone', notifier, Icons.public),
                        items: timeZoneOptions.map((timeZone) {
                          return DropdownMenuItem(
                            value: timeZone,
                            child: Text(timeZone,
                                style: TextStyle(color: notifier.getMainText)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedTimeZone = value;
                            });
                          }
                        },
                        dropdownColor: notifier.getContainer,
                        style: TextStyle(color: notifier.getMainText),
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle('Participants', notifier),
                      const SizedBox(height: 16),

                      // Doctor and Patient IDs
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: doctorIdController,
                              decoration: _inputDecoration('Doctor ID',
                                  notifier, Icons.medical_services),
                              validator: (value) =>
                                  value!.isEmpty ? 'Required' : null,
                              style: TextStyle(color: notifier.getMainText),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: patientIdController,
                              decoration: _inputDecoration(
                                  'Patient ID', notifier, Icons.person),
                              validator: (value) =>
                                  value!.isEmpty ? 'Required' : null,
                              style: TextStyle(color: notifier.getMainText),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle('Video Settings', notifier),
                      const SizedBox(height: 16),

                      // Video options
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              title: Text('Host Video',
                                  style:
                                      TextStyle(color: notifier.getMainText)),
                              value: hostVideo,
                              onChanged: (value) {
                                setState(() {
                                  hostVideo = value ?? true;
                                });
                              },
                              activeColor: notifier.getIconColor,
                              checkColor: Colors.white,
                            ),
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              title: Text('Participant Video',
                                  style:
                                      TextStyle(color: notifier.getMainText)),
                              value: participantVideo,
                              onChanged: (value) {
                                setState(() {
                                  participantVideo = value ?? true;
                                });
                              },
                              activeColor: notifier.getIconColor,
                              checkColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildFooter(context, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColourNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifier.getIconColor.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            widget.isEdit ? Icons.edit : Icons.add,
            color: notifier.getIconColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.isEdit ? 'Edit Consultation' : 'Create New Consultation',
              style: TextStyle(
                color: notifier.getMainText,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: notifier.getMainText),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ColourNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: notifier.getContainer,
        border: Border(top: BorderSide(color: notifier.getBorderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              foregroundColor: notifier.getMainText,
            ),
            child:
                Text('Cancel', style: TextStyle(color: notifier.getMainText)),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: isLoading ? null : _saveConsultation,
            style: ElevatedButton.styleFrom(
              backgroundColor: appMainColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(widget.isEdit
                    ? 'Update Consultation'
                    : 'Create Consultation'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColourNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: notifier.getIconColor,
          ),
        ),
        const SizedBox(height: 5),
        Divider(color: notifier.getBorderColor),
      ],
    );
  }

  InputDecoration _inputDecoration(
      String label, ColourNotifier notifier, IconData icon) {
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

  Future<void> _selectDate(
      BuildContext context, ColourNotifier notifier) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: notifier.getIconColor),
            dialogBackgroundColor: notifier.getContainer,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime(
      BuildContext context, ColourNotifier notifier) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: notifier.getIconColor),
            dialogBackgroundColor: notifier.getContainer,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _saveConsultation() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        final Map<String, dynamic> consultationData = {
          'consultation_title': titleController.text,
          'consultation_date': selectedDate.toIso8601String(),
          'consultation_duration_minutes': selectedDuration,
          'host_video': hostVideo,
          'participant_video': participantVideo,
          'description': descriptionController.text.isEmpty
              ? null
              : descriptionController.text,
          'time_zone': selectedTimeZone,
          'type': selectedType,
          'doctor_id': doctorIdController.text,
          'patient_id': patientIdController.text,
          'meta': {
            'created_via': 'admin_panel',
          },
        };

        if (widget.isEdit && widget.consultation != null) {
          await consultationController.updateConsultation(
            widget.consultation!.id,
            consultationData,
          );
        } else {
          await consultationController.createConsultation(consultationData);
        }

        Navigator.pop(context);
      } catch (e) {
        // Error handling is done in the controller
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }
}
