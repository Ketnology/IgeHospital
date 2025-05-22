import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/accounting_controller.dart';
import 'package:ige_hospital/models/account_model.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';

class EditAccountDialog extends StatefulWidget {
  final Account account;

  const EditAccountDialog({super.key, required this.account});

  @override
  State<EditAccountDialog> createState() => _EditAccountDialogState();
}

class _EditAccountDialogState extends State<EditAccountDialog> {
  final AccountingController controller = Get.find<AccountingController>();
  final _formKey = GlobalKey<FormState>();
  late String selectedType;
  late String selectedStatus;

  @override
  void initState() {
    super.initState();
    controller.fillAccountForm(widget.account);
    selectedType = widget.account.type;
    selectedStatus = widget.account.status;
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
                        Icons.edit,
                        color: appMainColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Edit Account',
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

                  // Account Status Field
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Status *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: notifier.getBgColor,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(
                          value: 'inactive', child: Text('Inactive')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value ?? 'active';
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Status is required';
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

                  // Account Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: notifier.getBgColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: notifier.getBorderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Information',
                          style: mediumBlackTextStyle.copyWith(
                            fontWeight: FontWeight.w600,
                            color: notifier.getMainText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Expanded(
                            //   child: Text(
                            //     'Created: ${controller.formatDate(widget.account.createdAt)}',
                            //     style: mediumGreyTextStyle.copyWith(
                            //       color: notifier.getMaingey,
                            //       fontSize: 12,
                            //     ),
                            //   ),
                            // ),
                            Expanded(
                              child: Text(
                                'Balance: ${controller.formatCurrency(widget.account.totalPaymentsAmount.toString())}',
                                style: mediumGreyTextStyle.copyWith(
                                  color: notifier.getMaingey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
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
                                      controller.selectedAccountStatus.value =
                                          selectedStatus;
                                      controller
                                          .updateAccount(widget.account.id);
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
                                : const Text('Update Account'),
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
}
