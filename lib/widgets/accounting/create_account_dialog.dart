import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/accounting_controller.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';

class CreateAccountDialog extends StatefulWidget {
  const CreateAccountDialog({super.key});

  @override
  State<CreateAccountDialog> createState() => _CreateAccountDialogState();
}

class _CreateAccountDialogState extends State<CreateAccountDialog> {
  final AccountingController controller = Get.find<AccountingController>();
  final _formKey = GlobalKey<FormState>();
  String selectedType = 'revenue';

  @override
  void initState() {
    super.initState();
    controller.clearAccountForm();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ColourNotifier>(
      builder: (context, notifier, child) {
        return Dialog(
          backgroundColor: notifier!.getContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance,
                        color: appMainColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Create New Account',
                        style: mainTextStyle.copyWith(
                          color: notifier.getMainText,
                          fontSize: 20,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Account Name Field
                  TextFormField(
                    controller: controller.accountNameController,
                    decoration: InputDecoration(
                      labelText: 'Account Name *',
                      hintText: 'Enter account name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: notifier.getBgColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Account name is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Account Type Field
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: InputDecoration(
                      labelText: 'Account Type *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: notifier.getBgColor,
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'revenue', child: Text('Revenue')),
                      DropdownMenuItem(
                          value: 'expense', child: Text('Expense')),
                      DropdownMenuItem(value: 'asset', child: Text('Asset')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedType = value ?? 'revenue';
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Account type is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Description Field
                  TextFormField(
                    controller: controller.accountDescriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter account description (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: notifier.getBgColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Account Type Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getTypeColor(selectedType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getTypeColor(selectedType).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getTypeIcon(selectedType),
                          color: _getTypeColor(selectedType),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getTypeDescription(selectedType),
                            style: mediumGreyTextStyle.copyWith(
                              color: _getTypeColor(selectedType),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: mediumBlackTextStyle.copyWith(
                            color: notifier.getMainText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Obx(() => ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      controller.selectedAccountType.value =
                                          selectedType;
                                      controller.createAccount();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appMainColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text('Create Account'),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'revenue':
        return Colors.green;
      case 'expense':
        return Colors.red;
      case 'asset':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'revenue':
        return Icons.trending_up;
      case 'expense':
        return Icons.trending_down;
      case 'asset':
        return Icons.account_balance_wallet;
      default:
        return Icons.account_balance;
    }
  }

  String _getTypeDescription(String type) {
    switch (type.toLowerCase()) {
      case 'revenue':
        return 'Revenue accounts track income and earnings from hospital operations';
      case 'expense':
        return 'Expense accounts track costs and expenditures for hospital operations';
      case 'asset':
        return 'Asset accounts track valuable resources owned by the hospital';
      default:
        return 'Select an account type';
    }
  }
}
