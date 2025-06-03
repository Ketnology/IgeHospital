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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Consumer<ColourNotifier>(
      builder: (context, notifier, child) {
        return Padding(
          padding: EdgeInsets.all(isMobile ? 8 : padding),
          child: Column(
            children: [
              // Filter Row - Responsive
              _buildFilterSection(controller, notifier, isMobile, isTablet),

              SizedBox(height: isMobile ? 12 : 16),

              // Accounts List - Responsive
              Expanded(
                child: Obx(() {
                  if (controller.isAccountsLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.filteredAccounts.isEmpty) {
                    return _buildEmptyState(notifier, isMobile);
                  }

                  // Mobile: Card layout, Desktop: Table layout
                  return isMobile
                      ? _buildMobileAccountsList(controller, notifier)
                      : _buildDesktopAccountsTable(controller, notifier, isTablet);
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterSection(AccountingController controller,
      ColourNotifier notifier, bool isMobile, bool isTablet) {
    if (isMobile) {
      return Column(
        children: [
          // Search field - full width on mobile
          TextField(
            onChanged: (value) => controller.searchQuery.value = value,
            decoration: InputDecoration(
              hintText: 'Search accounts...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: notifier.getBorderColor),
              ),
              filled: true,
              fillColor: notifier.getContainer,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),

          // Filters row
          Row(
            children: [
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedAccountType.value,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: notifier.getContainer,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  items: controller.accountTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Container(
                        width: double.infinity,
                        child: Text(
                          type,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedAccountType.value = value ?? 'All Types';
                  },
                )),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedAccountStatus.value,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: notifier.getContainer,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  items: controller.accountStatuses.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Container(
                        width: double.infinity,
                        child: Text(
                          status,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedAccountStatus.value = value ?? 'All Statuses';
                  },
                )),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => showDialog(
                    context: Get.context!,
                    builder: (context) => const CreateAccountDialog(),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Account', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appMainColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: controller.resetFilters,
                icon: const Icon(Icons.refresh),
                tooltip: 'Reset Filters',
                style: IconButton.styleFrom(
                  backgroundColor: notifier.getBgColor,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Desktop layout
      return Row(
        children: [
          // Search Field
          Expanded(
            flex: 2,
            child: TextField(
              onChanged: (value) => controller.searchQuery.value = value,
              decoration: InputDecoration(
                hintText: 'Search accounts...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: notifier.getBorderColor),
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
              isExpanded: true,
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
                  child: Container(
                    width: double.infinity,
                    child: Text(
                      type,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                controller.selectedAccountType.value = value ?? 'All Types';
              },
            )),
          ),
          const SizedBox(width: 12),

          // Status Filter
          Expanded(
            child: Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedAccountStatus.value,
              isExpanded: true,
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
                  child: Container(
                    width: double.infinity,
                    child: Text(
                      status,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                controller.selectedAccountStatus.value = value ?? 'All Statuses';
              },
            )),
          ),
          const SizedBox(width: 12),

          // Add Account Button
          ElevatedButton.icon(
            onPressed: () => showDialog(
              context: Get.context!,
              builder: (context) => const CreateAccountDialog(),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add Account'),
            style: ElevatedButton.styleFrom(
              backgroundColor: appMainColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      );
    }
  }

  Widget _buildEmptyState(ColourNotifier notifier, bool isMobile) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance,
              size: isMobile ? 48 : 64,
              color: notifier.getMaingey,
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              'No accounts found',
              style: mainTextStyle.copyWith(
                color: notifier.getMainText,
                fontSize: isMobile ? 16 : 18,
              ),
            ),
            SizedBox(height: isMobile ? 6 : 8),
            Text(
              'Create your first account to get started',
              style: mediumGreyTextStyle.copyWith(
                color: notifier.getMaingey,
                fontSize: isMobile ? 13 : 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileAccountsList(AccountingController controller, ColourNotifier notifier) {
    return ListView.separated(
      itemCount: controller.filteredAccounts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final account = controller.filteredAccounts[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: notifier.getBorderColor),
          ),
          color: notifier.getContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with name and actions
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.name,
                            style: mediumBlackTextStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: notifier.getMainText,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTypeColor(account.type).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
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
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: controller.getStatusColor(account.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  account.statusDisplay,
                                  style: mediumBlackTextStyle.copyWith(
                                    color: controller.getStatusColor(account.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            showDialog(
                              context: Get.context!,
                              builder: (context) => EditAccountDialog(account: account),
                            );
                            break;
                          case 'toggle':
                            controller.toggleAccountStatus(account.id);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Row(
                            children: [
                              Icon(
                                account.isActive ? Icons.visibility_off : Icons.visibility,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(account.isActive ? 'Deactivate' : 'Activate'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Description
                if (account.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    account.description,
                    style: mediumGreyTextStyle.copyWith(
                      color: notifier.getMaingey,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 12),

                // Balance
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Balance:',
                      style: mediumGreyTextStyle.copyWith(
                        color: notifier.getMaingey,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      controller.formatCurrency(account.totalPaymentsAmount.toString()),
                      style: mediumBlackTextStyle.copyWith(
                        color: notifier.getMainText,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopAccountsTable(AccountingController controller,
      ColourNotifier notifier, bool isTablet) {
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
                bottom: BorderSide(color: notifier.getBorderColor),
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
                      fontSize: isTablet ? 13 : 14,
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
                      fontSize: isTablet ? 13 : 14,
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
                      fontSize: isTablet ? 13 : 14,
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
                      fontSize: isTablet ? 13 : 14,
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
                final account = controller.filteredAccounts[index];
                return Container(
                  padding: EdgeInsets.all(isTablet ? 12 : 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: notifier.getBorderColor.withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Account Name & Description
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account.name,
                              style: mediumBlackTextStyle.copyWith(
                                fontWeight: FontWeight.w600,
                                color: notifier.getMainText,
                                fontSize: isTablet ? 13 : 14,
                              ),
                            ),
                            if (account.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                account.description,
                                style: mediumGreyTextStyle.copyWith(
                                  color: notifier.getMaingey,
                                  fontSize: isTablet ? 11 : 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                            color: _getTypeColor(account.type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            account.typeDisplay,
                            style: mediumBlackTextStyle.copyWith(
                              color: _getTypeColor(account.type),
                              fontSize: isTablet ? 11 : 12,
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
                            color: controller.getStatusColor(account.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            account.statusDisplay,
                            style: mediumBlackTextStyle.copyWith(
                              color: controller.getStatusColor(account.status),
                              fontSize: isTablet ? 11 : 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      // Balance
                      Expanded(
                        flex: 2,
                        child: Text(
                          controller.formatCurrency(account.totalPaymentsAmount.toString()),
                          style: mediumBlackTextStyle.copyWith(
                            color: notifier.getMainText,
                            fontWeight: FontWeight.w600,
                            fontSize: isTablet ? 13 : 14,
                          ),
                        ),
                      ),

                      // Actions
                      SizedBox(
                        width: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () => showDialog(
                                context: Get.context!,
                                builder: (context) => EditAccountDialog(account: account),
                              ),
                              icon: Icon(Icons.edit, size: isTablet ? 16 : 18),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              onPressed: () => controller.toggleAccountStatus(account.id),
                              icon: Icon(
                                account.isActive ? Icons.visibility_off : Icons.visibility,
                                size: isTablet ? 16 : 18,
                              ),
                              tooltip: account.isActive ? 'Deactivate' : 'Activate',
                            ),
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