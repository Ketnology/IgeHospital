import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/common_button.dart';
import 'package:ige_hospital/widgets/text_field.dart';

class DialogField {
  final String name;
  final String label;
  final String hintText;
  final IconData? icon;
  final bool isRequired;
  final bool isPassword;
  final bool isEmail;
  final bool isPhone;
  final bool isDate;
  final bool isDropdown;
  final bool isCheckbox;
  final List<DropdownMenuItem<String>>? items;
  final String? initialValue;
  final bool obscureText;
  final TextInputType keyboardType;
  final int? maxLines;
  final String? Function(String?)? validator;

  DialogField({
    required this.name,
    required this.label,
    required this.hintText,
    this.icon,
    this.isRequired = true,
    this.isPassword = false,
    this.isEmail = false,
    this.isPhone = false,
    this.isDate = false,
    this.isDropdown = false,
    this.isCheckbox = false,
    this.items,
    this.initialValue,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
  });
}

class GenericAddDialog extends StatefulWidget {
  final String title;
  final ColourNotifier notifier;
  final List<DialogField> fields;
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback? onCancel;
  final String saveButtonText;
  final String cancelButtonText;
  final bool showDividers;
  final List<String>? sections;

  const GenericAddDialog({
    super.key,
    required this.title,
    required this.notifier,
    required this.fields,
    required this.onSave,
    this.onCancel,
    this.saveButtonText = "Save",
    this.cancelButtonText = "Cancel",
    this.showDividers = true,
    this.sections,
  });

  @override
  State<GenericAddDialog> createState() => _GenericAddDialogState();
}

class _GenericAddDialogState extends State<GenericAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, dynamic> _values = {};

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers and values
    for (var field in widget.fields) {
      if (!field.isCheckbox && !field.isDropdown) {
        _controllers[field.name] =
            TextEditingController(text: field.initialValue ?? '');
      }

      if (field.isDropdown && field.initialValue != null) {
        _values[field.name] = field.initialValue;
      } else if (field.isCheckbox) {
        _values[field.name] =
            field.initialValue == 'true' || field.initialValue == '1';
      } else if (field.isDate && field.initialValue != null) {
        _values[field.name] = field.initialValue;
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
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: widget.notifier.getContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: Container(
        width: 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery
              .of(context)
              .size
              .height * 0.8,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.notifier.getContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: widget.notifier.getMainText,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: widget.notifier.getIconColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Form content
            Flexible(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: _buildFormFields(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CommonButton(
                  title: widget.cancelButtonText,
                  color: const Color(0xfff73164),
                  onTap: widget.onCancel ?? () => Navigator.pop(context),
                ),
                const SizedBox(width: 10),
                CommonButton(
                  title: _isLoading ? "Processing..." : widget.saveButtonText,
                  color: appMainColor,
                  onTap: _isLoading ? null : _handleSubmit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    // If sections are defined, group fields by section
    if (widget.sections != null && widget.sections!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.sections!.map((section) {
            final sectionFields = widget.fields.where((field) =>
                field.name.startsWith(
                    "${section.toLowerCase().replaceAll(' ', '_')}_")).toList();

            if (sectionFields.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(section),
                const SizedBox(height: 10),
                ...sectionFields.map(_buildField).toList(),
                if (widget.showDividers) const Divider(height: 30),
              ],
            );
          }).toList(),
        ],
      );
    } else {
      // If no sections, just list all fields
      return Column(
        children: widget.fields.map(_buildField).toList(),
      );
    }
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: widget.notifier.getMainText,
      ),
    );
  }

  Widget _buildField(DialogField field) {
    if (field.isDropdown) {
      return _buildDropdownField(field);
    } else if (field.isCheckbox) {
      return _buildCheckboxField(field);
    } else if (field.isDate) {
      return _buildDateField(field);
    } else {
      return _buildTextField(field);
    }
  }

  Widget _buildTextField(DialogField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: _controllers[field.name],
        obscureText: field.obscureText,
        keyboardType: field.keyboardType,
        maxLines: field.maxLines,
        style: TextStyle(color: widget.notifier.getMainText),
        decoration: InputDecoration(
          labelText: field.label,
          labelStyle: TextStyle(color: widget.notifier.getMainText),
          hintText: field.hintText,
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
          prefixIcon: field.icon != null ? Icon(
              field.icon, color: widget.notifier.getIconColor) : null,
        ),
        validator: (value) {
          if (field.isRequired && (value == null || value.isEmpty)) {
            return 'This field is required';
          }
          if (field.isEmail && value != null && value.isNotEmpty &&
              !GetUtils.isEmail(value)) {
            return 'Please enter a valid email address';
          }
          if (field.validator != null) {
            return field.validator!(value);
          }
          return null;
        },
        onChanged: (value) {
          _values[field.name] = value;
        },
      ),
    );
  }

  Widget _buildDropdownField(DialogField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: _values[field.name] as String?,
        decoration: InputDecoration(
          labelText: field.label,
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
          prefixIcon: field.icon != null ? Icon(
              field.icon, color: widget.notifier.getIconColor) : null,
        ),
        dropdownColor: widget.notifier.getContainer,
        style: TextStyle(color: widget.notifier.getMainText),
        items: field.items,
        validator: field.isRequired
            ? (value) =>
        value == null || value.isEmpty
            ? 'This field is required'
            : null
            : null,
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _values[field.name] = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildCheckboxField(DialogField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Checkbox(
            value: _values[field.name] as bool? ?? false,
            activeColor: widget.notifier.getIconColor,
            onChanged: (value) {
              setState(() {
                _values[field.name] = value ?? false;
              });
            },
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              field.label,
              style: TextStyle(
                color: widget.notifier.getMainText,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(DialogField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: () async {
          final DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: _values[field.name] != null &&
                _values[field.name].isNotEmpty
                ? DateFormat('yyyy-MM-dd').parse(_values[field.name])
                : DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
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

          if (pickedDate != null) {
            final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
            setState(() {
              _values[field.name] = formattedDate;
              if (_controllers.containsKey(field.name)) {
                _controllers[field.name]!.text = formattedDate;
              }
            });
          }
        },
        child: AbsorbPointer(
          child: TextFormField(
            controller: _controllers[field.name],
            style: TextStyle(color: widget.notifier.getMainText),
            decoration: InputDecoration(
              labelText: field.label,
              labelStyle: TextStyle(color: widget.notifier.getMainText),
              hintText: field.hintText,
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
              prefixIcon: Icon(
                  Icons.calendar_today, color: widget.notifier.getIconColor),
            ),
            validator: field.isRequired
                ? (value) =>
            value == null || value.isEmpty
                ? 'This field is required'
                : null
                : null,
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Collect all values from controllers
      for (var field in widget.fields) {
        if (!field.isCheckbox && !field.isDropdown &&
            !_values.containsKey(field.name)) {
          _values[field.name] = _controllers[field.name]?.text ?? '';
        }
      }

      // Submit the form
      widget.onSave(_values);

      // We don't set _isLoading back to false here since this component
      // will typically be popped from the navigation stack after submission
    }
  }
}