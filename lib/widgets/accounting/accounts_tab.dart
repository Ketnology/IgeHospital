import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/accounting_controller.dart';
import 'package:ige_hospital/widgets/accounting/create_account_dialog.dart';
import 'package:ige_hospital/widgets/accounting/edit_account_dialog.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';

class AccountsTab extends StatelessWidget {
  const AccountsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final AccountingController controller = Get.find<AccountingController>();

    return Consumer<ColourNotifier>(
      builder: (context, notifier, child) {
        return Padding(
          padding: const EdgeInsets.all(padding),
          child: Column(
            children: [
              // Filter Row
              Row(
                children: [
                  // Search Field
                  Expanded(
                    flex: 2,
                    child: TextField(
                      onChanged: (value) =>
                          controller.searchQuery.value = value,
                      decoration: InputDecoration(
                        hintText: 'Search accounts...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: notifier.getBorderColor),
                        ),
                        filled: true,
                        fillColor: notifier.getContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Type Filter
                  Expanded(
                    child: Obx(() => DropdownButtonFormField<String>(
                          value: controller.selectedAccountType.value,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: notifier.getContainer,
                          ),
                          items: controller.accountTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            controller.selectedAccountType.value =
                                value ?? 'All Types';
                          },
                        )),
                  ),
                  const SizedBox(width: 12),

                  // Status Filter
                  Expanded(
                    child: Obx(() => DropdownButtonFormField<String>(
                          value: controller.selectedAccountStatus.value,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: notifier.getContainer,
                          ),
                          items: controller.accountStatuses.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (value) {
                            controller.selectedAccountStatus.value =
                                value ?? 'All Statuses';
                          },
                        )),
                  ),
                  const SizedBox(width: 12),

                  // Add Account Button
                  ElevatedButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => const CreateAccountDialog(),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Account'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appMainColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Reset Filters Button
                  IconButton(
                    onPressed: controller.resetFilters,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Reset Filters',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Accounts List
              Expanded(
                child: Obx(() {
                  if (controller.isAccountsLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.filteredAccounts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance,
                            size: 64,
                            color: notifier.getMaingey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No accounts found',
                            style: mainTextStyle.copyWith(
                              color: notifier.getMainText,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first account to get started',
                            style: mediumGreyTextStyle.copyWith(
                              color: notifier.getMaingey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: notifier.getContainer,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: boxShadow,
                    ),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom:
                                  BorderSide(color: notifier.getBorderColor),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Account Name',
                                  style: mediumBlackTextStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: notifier.getMainText,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Type',
                                  style: mediumBlackTextStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: notifier.getMainText,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Status',
                                  style: mediumBlackTextStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: notifier.getMainText,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Balance',
                                  style: mediumBlackTextStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: notifier.getMainText,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 100), // Actions column
                            ],
                          ),
                        ),

                        // Account Items
                        Expanded(
                          child: ListView.builder(
                            itemCount: controller.filteredAccounts.length,
                            itemBuilder: (context, index) {
                              final account =
                                  controller.filteredAccounts[index];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: notifier.getBorderColor
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Account Name & Description
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            account.name,
                                            style:
                                                mediumBlackTextStyle.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: notifier.getMainText,
                                            ),
                                          ),
                                          if (account
                                              .description.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              account.description,
                                              style:
                                                  mediumGreyTextStyle.copyWith(
                                                color: notifier.getMaingey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),

                                    // Type
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getTypeColor(account.type)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          account.typeDisplay,
                                          style: mediumBlackTextStyle.copyWith(
                                            color: _getTypeColor(account.type),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Status
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: controller
                                              .getStatusColor(account.status)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          account.statusDisplay,
                                          style: mediumBlackTextStyle.copyWith(
                                            color: controller
                                                .getStatusColor(account.status),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Balance
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        controller.formatCurrency(account
                                            .totalPaymentsAmount
                                            .toString()),
                                        style: mediumBlackTextStyle.copyWith(
                                          color: notifier.getMainText,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    // Actions
                                    SizedBox(
                                      width: 100,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            onPressed: () => showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  EditAccountDialog(
                                                      account: account),
                                            ),
                                            icon: const Icon(Icons.edit),
                                            iconSize: 18,
                                            tooltip: 'Edit',
                                          ),
                                          IconButton(
                                            onPressed: () =>
                                                controller.toggleAccountStatus(
                                                    account.id),
                                            icon: Icon(
                                              account.isActive
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                            ),
                                            iconSize: 18,
                                            tooltip: account.isActive
                                                ? 'Deactivate'
                                                : 'Activate',
                                          ),
                                          // IconButton(
                                          //   onPressed: () => _showDeleteDialog(
                                          //       context,
                                          //       account.id,
                                          //       account.name),
                                          //   icon: const Icon(Icons.delete),
                                          //   iconSize: 18,
                                          //   color: Colors.red,
                                          //   tooltip: 'Delete',
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
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
}
