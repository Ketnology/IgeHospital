import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/vital_signs_controller.dart';
import 'package:ige_hospital/models/vital_signs_model.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/text_field.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';

class EditVitalSignsDialog extends StatefulWidget {
  final VitalSignsController controller;
  final VitalSignModel vitalSign;

  const EditVitalSignsDialog({
    super.key,
    required this.controller,
    required this.vitalSign,
  });

  @override
  State<EditVitalSignsDialog> createState() => _EditVitalSignsDialogState();
}

class _EditVitalSignsDialogState extends State<EditVitalSignsDialog> {
  @override
  void initState() {
    super.initState();
    // Fill form with existing data
    widget.controller.fillFormForEdit(widget.vitalSign);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Dialog(
      backgroundColor: notifier.getContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.edit,
                  color: notifier.getIconColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Vital Signs',
                        style: TextStyle(
                          color: notifier.getMainText,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Recorded: ${widget.vitalSign.recordedDate} at ${widget.vitalSign.recordedTime}',
                        style: TextStyle(
                          color: notifier.getMaingey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: notifier.getMainText,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Form
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Blood Pressure Section
                    _buildSectionHeader('Blood Pressure', Icons.favorite, notifier),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberField(
                            'Systolic',
                            'e.g., 120',
                            widget.controller.systolicController,
                            notifier,
                            suffix: 'mmHg',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildNumberField(
                            'Diastolic',
                            'e.g., 80',
                            widget.controller.diastolicController,
                            notifier,
                            suffix: 'mmHg',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Heart Rate and Temperature
                    _buildSectionHeader('Heart Rate & Temperature', Icons.monitor_heart, notifier),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberField(
                            'Heart Rate',
                            'e.g., 72',
                            widget.controller.heartRateController,
                            notifier,
                            suffix: 'bpm',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildNumberField(
                            'Temperature',
                            'e.g., 36.5',
                            widget.controller.temperatureController,
                            notifier,
                            suffix: '°C',
                            isDecimal: true,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Respiratory Rate and Oxygen Saturation
                    _buildSectionHeader('Respiratory & Oxygen', Icons.air, notifier),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberField(
                            'Respiratory Rate',
                            'e.g., 16',
                            widget.controller.respiratoryRateController,
                            notifier,
                            suffix: '/min',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildNumberField(
                            'Oxygen Saturation',
                            'e.g., 98',
                            widget.controller.oxygenSaturationController,
                            notifier,
                            suffix: '%',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Body Measurements
                    _buildSectionHeader('Body Measurements', Icons.monitor_weight, notifier),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberField(
                            'Weight',
                            'e.g., 70.0',
                            widget.controller.weightController,
                            notifier,
                            suffix: 'kg',
                            isDecimal: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildNumberField(
                            'Height',
                            'e.g., 175',
                            widget.controller.heightController,
                            notifier,
                            suffix: 'cm',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Notes
                    _buildSectionHeader('Additional Notes', Icons.note_alt_outlined, notifier),
                    const SizedBox(height: 12),
                    MyTextField(
                      title: 'Notes (Optional)',
                      hinttext: 'Any additional observations or notes...',
                      controller: widget.controller.notesController,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 20),

                    // Original recording info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: notifier.getBgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: notifier.getBorderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: notifier.getMaingey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Original Recording Info',
                                style: TextStyle(
                                  color: notifier.getMaingey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Recorded by: ${widget.vitalSign.recordedBy.name} (${widget.vitalSign.recordedBy.type})',
                            style: TextStyle(
                              color: notifier.getMainText,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Date & Time: ${widget.vitalSign.recordedDate} at ${widget.vitalSign.recordedTime}',
                            style: TextStyle(
                              color: notifier.getMainText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: notifier.getBorderColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: notifier.getMainText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => ElevatedButton(
                    onPressed: widget.controller.isLoading.value
                        ? null
                        : () => widget.controller.updateVitalSigns(widget.vitalSign.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appMainColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: widget.controller.isLoading.value
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Update Vital Signs',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ColourNotifier notifier) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: notifier.getIconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: notifier.getIconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: notifier.getMainText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField(
      String label,
      String hint,
      TextEditingController controller,
      ColourNotifier notifier, {
        String? suffix,
        bool isDecimal = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: notifier.getMainText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: isDecimal
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.number,
          inputFormatters: [
            if (isDecimal)
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
            else
              FilteringTextInputFormatter.digitsOnly,
          ],
          style: TextStyle(color: notifier.getMainText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: notifier.getMaingey),
            suffixText: suffix,
            suffixStyle: TextStyle(
              color: notifier.getMaingey,
              fontSize: 12,
            ),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            filled: true,
            fillColor: notifier.getPrimaryColor,
          ),
        ),
      ],
    );
  }
}