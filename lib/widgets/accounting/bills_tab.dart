import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/accounting_controller.dart';
// import 'package:ige_hospital/widgets/accounting/create_bill_dialog.dart';
// import 'package:ige_hospital/widgets/accounting/bill_details_dialog.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';

class BillsTab extends StatelessWidget {
  const BillsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final AccountingController controller = Get.find<AccountingController>();

    return Consumer<ColourNotifier>(
      builder: (context, notifier, child) {
        return Padding(
          padding: const EdgeInsets.all(padding),
          child: Column(
            children: [
              // Filter and Action Row
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: notifier!.getContainer,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: boxShadow,
                ),
                child: Column(
                  children: [
                    // Main Filter Row
                    Row(
                      children: [
                        // Search Field
                        Expanded(
                          flex: 3,
                          child: TextField(
                            onChanged: (value) =>
                                controller.searchQuery.value = value,
                            decoration: InputDecoration(
                              hintText:
                                  'Search by bill reference or patient name...',
                              prefixIcon: Icon(Icons.search,
                                  color: notifier.getIconColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: notifier.getBorderColor),
                              ),
                              filled: true,
                              fillColor: notifier.getBgColor,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Status Filter
                        Expanded(
                          child: Obx(() => DropdownButtonFormField<String>(
                                value: controller.selectedBillStatus.value,
                                decoration: InputDecoration(
                                  labelText: 'Status',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: notifier.getBgColor,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                                items: controller.billStatuses.map((status) {
                                  return DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  controller.selectedBillStatus.value =
                                      value ?? 'All Statuses';
                                },
                              )),
                        ),
                        const SizedBox(width: 12),

                        // Payment Mode Filter
                        Expanded(
                          child: Obx(() => DropdownButtonFormField<String>(
                                value: controller.selectedPaymentMode.value,
                                decoration: InputDecoration(
                                  labelText: 'Payment Mode',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: notifier.getBgColor,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                                items: controller.paymentModes.map((mode) {
                                  return DropdownMenuItem(
                                    value: mode,
                                    child: Text(mode),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  controller.selectedPaymentMode.value =
                                      value ?? 'All Modes';
                                },
                              )),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Date Filters and Actions Row
                    Row(
                      children: [
                        // Date From
                        Expanded(
                          child: Obx(() => TextField(
                                decoration: InputDecoration(
                                  labelText: 'From Date',
                                  hintText: controller.dateFrom.value.isEmpty
                                      ? 'Select date'
                                      : controller.dateFrom.value,
                                  suffixIcon: Icon(Icons.calendar_today,
                                      color: notifier.getIconColor),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: notifier.getBgColor,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
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
                                    controller.loadBills();
                                  }
                                },
                              )),
                        ),
                        const SizedBox(width: 12),

                        // Date To
                        Expanded(
                          child: Obx(() => TextField(
                                decoration: InputDecoration(
                                  labelText: 'To Date',
                                  hintText: controller.dateTo.value.isEmpty
                                      ? 'Select date'
                                      : controller.dateTo.value,
                                  suffixIcon: Icon(Icons.calendar_today,
                                      color: notifier.getIconColor),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: notifier.getBgColor,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
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
                                    controller.loadBills();
                                  }
                                },
                              )),
                        ),
                        const SizedBox(width: 16),

                        // Action Buttons
                        ElevatedButton.icon(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => const CreateBillDialog(),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('Create Bill'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appMainColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
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
                ),
              ),

              const SizedBox(height: 16),

              // Bills Summary Cards
              Obx(() {
                final totalBills = controller.totalItems.value;
                final paidBills = controller.filteredBills
                    .where((bill) => bill.isPaid)
                    .length;
                final pendingBills = controller.filteredBills
                    .where((bill) => bill.isPending)
                    .length;
                final unpaidBills = controller.filteredBills
                    .where((bill) => !bill.isPaid && !bill.isPending)
                    .length;

                return Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Bills',
                        totalBills.toString(),
                        Icons.receipt_long,
                        Colors.blue,
                        notifier,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Paid',
                        paidBills.toString(),
                        Icons.check_circle,
                        Colors.green,
                        notifier,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Pending',
                        pendingBills.toString(),
                        Icons.pending,
                        Colors.orange,
                        notifier,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Unpaid',
                        unpaidBills.toString(),
                        Icons.cancel,
                        Colors.red,
                        notifier,
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 16),

              // Bills List
              Expanded(
                child: Obx(() {
                  if (controller.isBillsLoading.value) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: appMainColor),
                          const SizedBox(height: 16),
                          Text(
                            'Loading bills...',
                            style: mediumGreyTextStyle.copyWith(
                              color: notifier.getMaingey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (controller.filteredBills.isEmpty) {
                    return Container(
                      decoration: BoxDecoration(
                        color: notifier.getContainer,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: boxShadow,
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: appMainColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.receipt_long,
                                  size: 48,
                                  color: appMainColor,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'No bills found',
                                style: mainTextStyle.copyWith(
                                  color: notifier.getMainText,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create your first bill or adjust your filters to see results',
                                style: mediumGreyTextStyle.copyWith(
                                  color: notifier.getMaingey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) =>
                                      const CreateBillDialog(),
                                ),
                                icon: const Icon(Icons.add),
                                label: const Text('Create First Bill'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: appMainColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                        // Table Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: notifier.getBgColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            border: Border(
                              bottom:
                                  BorderSide(color: notifier.getBorderColor),
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 60), // For avatar
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Bill Information',
                                  style: mediumBlackTextStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: notifier.getMainText,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Patient Details',
                                  style: mediumBlackTextStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: notifier.getMainText,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Amount',
                                  style: mediumBlackTextStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: notifier.getMainText,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Status',
                                  style: mediumBlackTextStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: notifier.getMainText,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 80), // For actions
                            ],
                          ),
                        ),

                        // Bill Items
                        Expanded(
                          child: ListView.builder(
                            itemCount: controller.filteredBills.length,
                            itemBuilder: (context, index) {
                              final bill = controller.filteredBills[index];
                              return InkWell(
                                onTap: () => showDialog(
                                  context: context,
                                  builder: (context) =>
                                      BillDetailsDialog(bill: bill),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 16),
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
                                      // Bill Avatar
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(bill.status)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                        child: Icon(
                                          _getStatusIcon(bill.status),
                                          color: _getStatusColor(bill.status),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Bill Information
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              bill.reference,
                                              style:
                                                  mediumBlackTextStyle.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: notifier.getMainText,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  size: 12,
                                                  color: notifier.getMaingey,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  bill.billDateFormatted,
                                                  style: mediumGreyTextStyle
                                                      .copyWith(
                                                    color: notifier.getMaingey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getPaymentModeColor(
                                                            bill.paymentMode)
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Text(
                                                    bill.paymentMode
                                                        .toUpperCase(),
                                                    style: mediumGreyTextStyle
                                                        .copyWith(
                                                      color:
                                                          _getPaymentModeColor(
                                                              bill.paymentMode),
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (bill.billItems.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                '${bill.billItems.length} item${bill.billItems.length > 1 ? 's' : ''}',
                                                style: mediumGreyTextStyle
                                                    .copyWith(
                                                  color: notifier.getMaingey,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),

                                      // Patient Details
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              bill.patient?.fullName ??
                                                  'Unknown Patient',
                                              style:
                                                  mediumBlackTextStyle.copyWith(
                                                color: notifier.getMainText,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 13,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (bill.patient?.phone
                                                    .isNotEmpty ==
                                                true) ...[
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.phone,
                                                    size: 12,
                                                    color: notifier.getMaingey,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      bill.patient!.phone,
                                                      style: mediumGreyTextStyle
                                                          .copyWith(
                                                        color:
                                                            notifier.getMaingey,
                                                        fontSize: 12,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                            if (bill.patient?.patientUniqueId
                                                    .isNotEmpty ==
                                                true) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                'ID: ${bill.patient!.patientUniqueId}',
                                                style: mediumGreyTextStyle
                                                    .copyWith(
                                                  color: notifier.getMaingey,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),

                                      // Amount
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Text(
                                              controller
                                                  .formatCurrency(bill.amount),
                                              style:
                                                  mediumBlackTextStyle.copyWith(
                                                color: notifier.getMainText,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Status
                                      Expanded(
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  _getStatusColor(bill.status)
                                                      .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color:
                                                    _getStatusColor(bill.status)
                                                        .withOpacity(0.3),
                                              ),
                                            ),
                                            child: Text(
                                              bill.statusDisplay,
                                              style:
                                                  mediumBlackTextStyle.copyWith(
                                                color: _getStatusColor(
                                                    bill.status),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Actions
                                      SizedBox(
                                        width: 80,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            PopupMenuButton<String>(
                                              onSelected: (value) {
                                                switch (value) {
                                                  case 'view':
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          BillDetailsDialog(
                                                              bill: bill),
                                                    );
                                                    break;
                                                  case 'paid':
                                                  case 'unpaid':
                                                  case 'pending':
                                                    controller.updateBillStatus(
                                                        bill.id, value);
                                                    break;
                                                  case 'delete':
                                                    _showDeleteDialog(
                                                        context,
                                                        bill.id,
                                                        bill.reference);
                                                    break;
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                const PopupMenuItem(
                                                  value: 'view',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.visibility,
                                                          size: 16),
                                                      SizedBox(width: 8),
                                                      Text('View Details'),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuDivider(),
                                                const PopupMenuItem(
                                                  value: 'paid',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.check_circle,
                                                          color: Colors.green,
                                                          size: 16),
                                                      SizedBox(width: 8),
                                                      Text('Mark as Paid'),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'pending',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.pending,
                                                          color: Colors.orange,
                                                          size: 16),
                                                      SizedBox(width: 8),
                                                      Text('Mark as Pending'),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'unpaid',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.cancel,
                                                          color: Colors.red,
                                                          size: 16),
                                                      SizedBox(width: 8),
                                                      Text('Mark as Unpaid'),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuDivider(),
                                                const PopupMenuItem(
                                                  value: 'delete',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.delete,
                                                          color: Colors.red,
                                                          size: 16),
                                                      SizedBox(width: 8),
                                                      Text('Delete Bill'),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: notifier.getBgColor,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: notifier
                                                        .getBorderColor
                                                        .withOpacity(0.3),
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.more_vert,
                                                  size: 16,
                                                  color: notifier.getIconColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Pagination
                        if (controller.totalPages.value > 1)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: notifier.getBgColor,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                              border: Border(
                                top: BorderSide(color: notifier.getBorderColor),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Showing ${controller.filteredBills.length} of ${controller.totalItems.value} bills',
                                  style: mediumGreyTextStyle.copyWith(
                                    color: notifier.getMaingey,
                                    fontSize: 13,
                                  ),
                                ),
                                Row(
                                  children: [
                                    // Items per page
                                    DropdownButton<int>(
                                      value: controller.perPage.value,
                                      items: [10, 15, 20, 50].map((count) {
                                        return DropdownMenuItem(
                                          value: count,
                                          child: Text('$count per page'),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          controller.changePerPage(value);
                                        }
                                      },
                                      underline: const SizedBox(),
                                    ),
                                    const SizedBox(width: 16),

                                    // Previous button
                                    IconButton(
                                      onPressed: controller.currentPage.value >
                                              1
                                          ? () => controller.changePage(
                                              controller.currentPage.value - 1)
                                          : null,
                                      icon: const Icon(Icons.chevron_left),
                                      style: IconButton.styleFrom(
                                        backgroundColor:
                                            controller.currentPage.value > 1
                                                ? appMainColor.withOpacity(0.1)
                                                : Colors.transparent,
                                      ),
                                    ),

                                    // Page numbers
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: appMainColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Page ${controller.currentPage.value} of ${controller.totalPages.value}',
                                        style: mediumBlackTextStyle.copyWith(
                                          color: appMainColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    // Next button
                                    IconButton(
                                      onPressed: controller.currentPage.value <
                                              controller.totalPages.value
                                          ? () => controller.changePage(
                                              controller.currentPage.value + 1)
                                          : null,
                                      icon: const Icon(Icons.chevron_right),
                                      style: IconButton.styleFrom(
                                        backgroundColor:
                                            controller.currentPage.value <
                                                    controller.totalPages.value
                                                ? appMainColor.withOpacity(0.1)
                                                : Colors.transparent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    ColourNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifier.getContainer,
        borderRadius: BorderRadius.circular(8),
        boxShadow: boxShadow,
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: mainTextStyle.copyWith(
                    color: notifier.getMainText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: mediumGreyTextStyle.copyWith(
                    color: notifier.getMaingey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'unpaid':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Icons.check_circle;
      case 'unpaid':
        return Icons.cancel;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.receipt;
    }
  }

  Color _getPaymentModeColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'cash':
        return Colors.green;
      case 'card':
        return Colors.blue;
      case 'online':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteDialog(
      BuildContext context, String billId, String billReference) {
    final AccountingController controller = Get.find<AccountingController>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 24),
            const SizedBox(width: 12),
            const Text('Delete Bill'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete bill "$billReference"?'),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone and will permanently remove all bill data.',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteBill(billId);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Create Bill Dialog (simplified version - you can expand this)
class CreateBillDialog extends StatelessWidget {
  const CreateBillDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: appMainColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Create New Bill',
                  style: mainTextStyle.copyWith(fontSize: 20),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Bill creation form '),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appMainColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create Bill'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Bill Details Dialog (simplified version - you can expand this)
class BillDetailsDialog extends StatelessWidget {
  final dynamic bill;

  const BillDetailsDialog({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: appMainColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Bill Details',
                  style: mainTextStyle.copyWith(fontSize: 20),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Bill Reference: ${bill.reference}'),
            const SizedBox(height: 8),
            Text('Patient: ${bill.patient?.fullName ?? 'Unknown'}'),
            const SizedBox(height: 8),
            Text(
                'Amount: ${Get.find<AccountingController>().formatCurrency(bill.amount)}'),
            const SizedBox(height: 8),
            Text('Status: ${bill.statusDisplay}'),
            const SizedBox(height: 8),
            Text('Date: ${bill.billDateFormatted}'),
            const SizedBox(height: 24),
            if (bill.billItems.isNotEmpty) ...[
              const Text('Bill Items:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...bill.billItems.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                        '${item.itemName} - Qty: ${item.qty} - ${Get.find<AccountingController>().formatCurrency(item.amount)}'),
                  )),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appMainColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
