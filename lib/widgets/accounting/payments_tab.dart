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
                        hintText: 'Search payments...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: notifier!.getBorderColor),
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
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          controller.dateFrom.value =
                              date.toIso8601String().split('T')[0];
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
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          controller.dateTo.value =
                              date.toIso8601String().split('T')[0];
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Add Payment Button
                  ElevatedButton.icon(
                    onPressed: () => _showCreatePaymentDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Payment'),
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

              // Payments List
              Expanded(
                child: Obx(() {
                  if (controller.isPaymentsLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.filteredPayments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.payment,
                            size: 64,
                            color: notifier.getMaingey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No payments found',
                            style: mainTextStyle.copyWith(
                              color: notifier.getMainText,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first payment to get started',
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
                                flex: 2,
                                child: Text(
                                  'Pay To',
                                  style: mediumBlackTextStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: notifier.getMainText,
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
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Amount',
                                  style: mediumBlackTextStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: notifier.getMainText,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Date',
                                  style: mediumBlackTextStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: notifier.getMainText,
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
                              final payment =
                                  controller.filteredPayments[index];
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
                                    // Pay To & Description
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            payment.payTo,
                                            style:
                                                mediumBlackTextStyle.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: notifier.getMainText,
                                            ),
                                          ),
                                          if (payment
                                              .description.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              payment.description,
                                              style:
                                                  mediumGreyTextStyle.copyWith(
                                                color: notifier.getMaingey,
                                                fontSize: 12,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            payment.account?.name ??
                                                'Unknown Account',
                                            style:
                                                mediumBlackTextStyle.copyWith(
                                              color: notifier.getMainText,
                                            ),
                                          ),
                                          if (payment.account != null) ...[
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getTypeColor(
                                                        payment.account!.type)
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                payment.account!.typeDisplay,
                                                style: mediumGreyTextStyle
                                                    .copyWith(
                                                  color: _getTypeColor(
                                                      payment.account!.type),
                                                  fontSize: 10,
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
                                        controller
                                            .formatCurrency(payment.amount),
                                        style: mediumBlackTextStyle.copyWith(
                                          color: notifier.getMainText,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    // Date
                                    Expanded(
                                      child: Text(
                                        payment.paymentDateFormatted,
                                        style: mediumBlackTextStyle.copyWith(
                                          color: notifier.getMainText,
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
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreatePaymentDialog(BuildContext context) {
    final AccountingController controller = Get.find<AccountingController>();

    // Simple dialog for demo - you can make this more sophisticated
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Payment'),
        content: const Text('Payment creation dialog form'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Create'),
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
