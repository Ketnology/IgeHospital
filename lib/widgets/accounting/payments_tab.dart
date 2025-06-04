import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/accounting_controller.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';

class PaymentsTab extends StatelessWidget {
  const PaymentsTab({super.key});

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

              // Payments List - Responsive
              Expanded(
                child: Obx(() {
                  if (controller.isPaymentsLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.filteredPayments.isEmpty) {
                    return _buildEmptyState(notifier, isMobile);
                  }

                  // Mobile: Card layout, Desktop: Table layout
                  return isMobile
                      ? _buildMobilePaymentsList(controller, notifier)
                      : _buildDesktopPaymentsTable(controller, notifier, isTablet);
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
              hintText: 'Search payments...',
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

          // Date filters row
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'From Date',
                    hintText: 'Select date',
                    suffixIcon: Icon(Icons.calendar_today, color: notifier.getIconColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: notifier.getContainer,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: Get.context!,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      controller.dateFrom.value = date.toIso8601String().split('T')[0];
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'To Date',
                    hintText: 'Select date',
                    suffixIcon: Icon(Icons.calendar_today, color: notifier.getIconColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: notifier.getContainer,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: Get.context!,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      controller.dateTo.value = date.toIso8601String().split('T')[0];
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showCreatePaymentDialog(Get.context!),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Payment', style: TextStyle(fontSize: 12)),
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
                hintText: 'Search payments...',
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

          // Date Range Filters
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'From Date',
                suffixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: notifier.getContainer,
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: Get.context!,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  controller.dateFrom.value = date.toIso8601String().split('T')[0];
                }
              },
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'To Date',
                suffixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: notifier.getContainer,
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: Get.context!,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  controller.dateTo.value = date.toIso8601String().split('T')[0];
                }
              },
            ),
          ),
          const SizedBox(width: 12),

          // Add Payment Button
          ElevatedButton.icon(
            onPressed: () => _showCreatePaymentDialog(Get.context!),
            icon: const Icon(Icons.add),
            label: const Text('Add Payment'),
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
              Icons.payment,
              size: isMobile ? 48 : 64,
              color: notifier.getMaingey,
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              'No payments found',
              style: mainTextStyle.copyWith(
                color: notifier.getMainText,
                fontSize: isMobile ? 16 : 18,
              ),
            ),
            SizedBox(height: isMobile ? 6 : 8),
            Text(
              'Create your first payment to get started',
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

  Widget _buildMobilePaymentsList(AccountingController controller, ColourNotifier notifier) {
    return ListView.separated(
      itemCount: controller.filteredPayments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final payment = controller.filteredPayments[index];
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
                // Header with pay to and amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payment.payTo,
                            style: mediumBlackTextStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: notifier.getMainText,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            payment.paymentDateFormatted,
                            style: mediumGreyTextStyle.copyWith(
                              color: notifier.getMaingey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      controller.formatCurrency(payment.amount),
                      style: mediumBlackTextStyle.copyWith(
                        color: notifier.getMainText,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Account info
                if (payment.account != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: notifier.getBgColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: notifier.getBorderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _getTypeColor(payment.account!.type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            _getTypeIcon(payment.account!.type),
                            color: _getTypeColor(payment.account!.type),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                payment.account!.name,
                                style: mediumBlackTextStyle.copyWith(
                                  color: notifier.getMainText,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                payment.account!.typeDisplay,
                                style: mediumGreyTextStyle.copyWith(
                                  color: _getTypeColor(payment.account!.type),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Description
                if (payment.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Description:',
                    style: mediumGreyTextStyle.copyWith(
                      color: notifier.getMaingey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    payment.description,
                    style: mediumBlackTextStyle.copyWith(
                      color: notifier.getMainText,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopPaymentsTable(AccountingController controller,
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
                  flex: 2,
                  child: Text(
                    'Pay To',
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
                    'Account',
                    style: mediumBlackTextStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      color: notifier.getMainText,
                      fontSize: isTablet ? 13 : 14,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Amount',
                    style: mediumBlackTextStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      color: notifier.getMainText,
                      fontSize: isTablet ? 13 : 14,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Date',
                    style: mediumBlackTextStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      color: notifier.getMainText,
                      fontSize: isTablet ? 13 : 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Payment Items
          Expanded(
            child: ListView.builder(
              itemCount: controller.filteredPayments.length,
              itemBuilder: (context, index) {
                final payment = controller.filteredPayments[index];
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
                      // Pay To & Description
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              payment.payTo,
                              style: mediumBlackTextStyle.copyWith(
                                fontWeight: FontWeight.w600,
                                color: notifier.getMainText,
                                fontSize: isTablet ? 13 : 14,
                              ),
                            ),
                            if (payment.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                payment.description,
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

                      // Account
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              payment.account?.name ?? 'Unknown Account',
                              style: mediumBlackTextStyle.copyWith(
                                color: notifier.getMainText,
                                fontSize: isTablet ? 13 : 14,
                              ),
                            ),
                            if (payment.account != null) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTypeColor(payment.account!.type).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  payment.account!.typeDisplay,
                                  style: mediumGreyTextStyle.copyWith(
                                    color: _getTypeColor(payment.account!.type),
                                    fontSize: isTablet ? 9 : 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Amount
                      Expanded(
                        child: Text(
                          controller.formatCurrency(payment.amount),
                          style: mediumBlackTextStyle.copyWith(
                            color: notifier.getMainText,
                            fontWeight: FontWeight.w600,
                            fontSize: isTablet ? 13 : 14,
                          ),
                        ),
                      ),

                      // Date
                      Expanded(
                        child: Text(
                          payment.paymentDateFormatted,
                          style: mediumBlackTextStyle.copyWith(
                            color: notifier.getMainText,
                            fontSize: isTablet ? 13 : 14,
                          ),
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

  void _showCreatePaymentDialog(BuildContext context) {
    final AccountingController controller = Get.find<AccountingController>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width < 768 ?
          MediaQuery.of(context).size.width * 0.9 : 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.payment, color: appMainColor, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Create Payment',
                    style: mainTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Payment form fields would go here
              const Text(
                'Payment creation form will be implemented here',
                style: TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appMainColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Create Payment'),
                  ),
                ],
              ),
            ],
          ),
        ),
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
}