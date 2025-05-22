import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/accounting_controller.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final AccountingController controller = Get.find<AccountingController>();

    return Consumer<ColourNotifier>(
      builder: (context, notifier, child) {
        return RefreshIndicator(
          onRefresh: () async {
            await controller.loadDashboard();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(padding),
            child: Obx(() {
              if (controller.isDashboardLoading.value) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: appMainColor),
                        const SizedBox(height: 16),
                        Text(
                          'Loading financial dashboard...',
                          style: mediumGreyTextStyle.copyWith(
                            color: notifier!.getMaingey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final dashboardData = controller.dashboardData;
              final accounts = dashboardData['accounts'] ?? {};
              final payments = dashboardData['payments'] ?? {};
              final bills = dashboardData['bills'] ?? {};
              final recentPayments = dashboardData['recent_payments'] ?? [];
              final recentBills = dashboardData['recent_bills'] ?? [];
              final monthlyTrends = dashboardData['monthly_trends'] ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section with Time Period Selector
                  // Container(
                  //   padding: const EdgeInsets.all(20),
                  //   decoration: BoxDecoration(
                  //     gradient: LinearGradient(
                  //       begin: Alignment.topLeft,
                  //       end: Alignment.bottomRight,
                  //       colors: [
                  //         appMainColor.withOpacity(0.1),
                  //         appMainColor.withOpacity(0.05),
                  //       ],
                  //     ),
                  //     borderRadius: BorderRadius.circular(16),
                  //     border: Border.all(color: appMainColor.withOpacity(0.2)),
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       Expanded(
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             Text(
                  //               'Financial Overview',
                  //               style: mainTextStyle.copyWith(
                  //                 color: notifier!.getMainText,
                  //                 fontSize: 24,
                  //                 fontWeight: FontWeight.bold,
                  //               ),
                  //             ),
                  //             const SizedBox(height: 8),
                  //             Text(
                  //               'Monitor your hospital\'s financial performance and key metrics',
                  //               style: mediumGreyTextStyle.copyWith(
                  //                 color: notifier.getMaingey,
                  //                 fontSize: 14,
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //       Container(
                  //         padding: const EdgeInsets.all(16),
                  //         decoration: BoxDecoration(
                  //           color: appMainColor.withOpacity(0.1),
                  //           borderRadius: BorderRadius.circular(12),
                  //         ),
                  //         child: Icon(
                  //           Icons.dashboard,
                  //           color: appMainColor,
                  //           size: 32,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  const SizedBox(height: 24),

                  // Key Metrics Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          'Total Accounts',
                          accounts['total']?.toString() ?? '0',
                          '${accounts['active']?.toString() ?? '0'} active',
                          Icons.account_balance,
                          Colors.blue,
                          notifier,
                          _calculateAccountsGrowth(accounts),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          'Total Revenue',
                          controller.formatCurrency(
                              payments['total_amount']?.toString() ?? '0'),
                          '${payments['total_count']?.toString() ?? '0'} payments',
                          Icons.trending_up,
                          Colors.green,
                          notifier,
                          _calculatePaymentsGrowth(payments),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          'Outstanding Bills',
                          controller.formatCurrency(
                              bills['total_amount']?.toString() ?? '0'),
                          '${bills['total_count']?.toString() ?? '0'} bills',
                          Icons.receipt_long,
                          Colors.orange,
                          notifier,
                          _calculateBillsGrowth(bills),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          'Collection Rate',
                          _calculateCollectionRate(bills),
                          '${bills['paid']?.toString() ?? '0'} paid',
                          Icons.pie_chart,
                          Colors.purple,
                          notifier,
                          0.0, // Static for now
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Charts and Analytics Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Financial Trends Chart
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 350,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: notifier.getContainer,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: boxShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Financial Trends',
                                    style: mainTextStyle.copyWith(
                                      color: notifier.getMainText,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  _buildTrendLegend(notifier),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Expanded(
                                child: _buildFinancialTrendsChart(
                                    monthlyTrends, notifier, controller),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Account Distribution
                      Expanded(
                        child: Container(
                          height: 350,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: notifier.getContainer,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: boxShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Account Distribution',
                                style: mainTextStyle.copyWith(
                                  color: notifier.getMainText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Expanded(
                                child: _buildAccountDistribution(
                                    accounts['by_type'] ?? {}, notifier),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Quick Actions and Status Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Actions
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: notifier.getContainer,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: boxShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick Actions',
                                style: mainTextStyle.copyWith(
                                  color: notifier.getMainText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildQuickActionsList(context, notifier),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Financial Health Status
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: notifier.getContainer,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: boxShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Financial Health',
                                style: mainTextStyle.copyWith(
                                  color: notifier.getMainText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildFinancialHealthStatus(accounts, payments,
                                  bills, notifier, controller),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Recent Activities Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recent Payments
                      Expanded(
                        child: Container(
                          height: 400,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: notifier.getContainer,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: boxShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.payment,
                                      color: Colors.green, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Recent Payments',
                                    style: mainTextStyle.copyWith(
                                      color: notifier.getMainText,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      // Switch to payments tab - you can implement this
                                    },
                                    child: const Text('View All'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: recentPayments.isEmpty
                                    ? _buildEmptyState(
                                        'No recent payments',
                                        'Payments will appear here once created',
                                        Icons.payment,
                                        notifier,
                                      )
                                    : ListView.builder(
                                        itemCount: recentPayments.length,
                                        itemBuilder: (context, index) {
                                          final payment = recentPayments[index];
                                          return _buildRecentPaymentItem(
                                              payment, notifier, controller);
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Recent Bills
                      Expanded(
                        child: Container(
                          height: 400,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: notifier.getContainer,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: boxShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.receipt_long,
                                      color: Colors.orange, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Recent Bills',
                                    style: mainTextStyle.copyWith(
                                      color: notifier.getMainText,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      // Switch to bills tab - you can implement this
                                    },
                                    child: const Text('View All'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: recentBills.isEmpty
                                    ? _buildEmptyState(
                                        'No recent bills',
                                        'Bills will appear here once created',
                                        Icons.receipt_long,
                                        notifier,
                                      )
                                    : ListView.builder(
                                        itemCount: recentBills.length,
                                        itemBuilder: (context, index) {
                                          final bill = recentBills[index];
                                          return _buildRecentBillItem(
                                              bill, notifier, controller);
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    ColourNotifier notifier,
    double growth,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: notifier.getContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: boxShadow,
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              if (growth != 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: growth > 0
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        growth > 0 ? Icons.trending_up : Icons.trending_down,
                        size: 12,
                        color: growth > 0 ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${growth.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: growth > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: mainTextStyle.copyWith(
              color: notifier.getMainText,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: mediumBlackTextStyle.copyWith(
              color: notifier.getMainText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: mediumGreyTextStyle.copyWith(
              color: notifier.getMaingey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendLegend(ColourNotifier notifier) {
    return Row(
      children: [
        _buildLegendItem('Revenue', Colors.green, notifier),
        const SizedBox(width: 16),
        _buildLegendItem('Expenses', Colors.red, notifier),
        const SizedBox(width: 16),
        _buildLegendItem('Bills', Colors.orange, notifier),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, ColourNotifier notifier) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: notifier.getMaingey,
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialTrendsChart(
    List<dynamic> monthlyTrends,
    ColourNotifier notifier,
    AccountingController controller,
  ) {
    if (monthlyTrends.isEmpty) {
      return _buildEmptyState(
        'No trend data available',
        'Financial trends will appear here once data is available',
        Icons.trending_up,
        notifier,
      );
    }

    // Simple visual representation since we don't have a charts library
    return Column(
      children: [
        // Chart area simulation
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: notifier.getBgColor,
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: notifier.getBorderColor.withOpacity(0.3)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 48,
                    color: notifier.getMaingey,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Financial Trends Chart',
                    style: mediumBlackTextStyle.copyWith(
                      color: notifier.getMainText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chart visualization would be displayed here',
                    style: mediumGreyTextStyle.copyWith(
                      color: notifier.getMaingey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Month labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: monthlyTrends.take(6).map((trend) {
            return Text(
              trend['month'] ?? '',
              style: TextStyle(
                fontSize: 10,
                color: notifier.getMaingey,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAccountDistribution(
      Map<String, dynamic> distribution, ColourNotifier notifier) {
    if (distribution.isEmpty) {
      return _buildEmptyState(
        'No account data',
        'Account distribution will appear here',
        Icons.pie_chart,
        notifier,
      );
    }

    final total = distribution.values
        .fold(0, (sum, value) => sum + (int.tryParse(value.toString()) ?? 0));

    return Column(
      children: [
        // Pie chart simulation
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: notifier.getBgColor,
              shape: BoxShape.circle,
              border:
                  Border.all(color: notifier.getBorderColor.withOpacity(0.3)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.donut_large,
                    size: 40,
                    color: notifier.getMaingey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    total.toString(),
                    style: mainTextStyle.copyWith(
                      color: notifier.getMainText,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Total Accounts',
                    style: mediumGreyTextStyle.copyWith(
                      color: notifier.getMaingey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Distribution list
        Expanded(
          child: Column(
            children: distribution.entries.map((entry) {
              final type = entry.key;
              final count = int.tryParse(entry.value.toString()) ?? 0;
              final percentage = total > 0 ? (count / total * 100) : 0;
              final color = _getTypeColor(type);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        type.toUpperCase(),
                        style: mediumBlackTextStyle.copyWith(
                          color: notifier.getMainText,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      '$count (${percentage.toStringAsFixed(0)}%)',
                      style: mediumBlackTextStyle.copyWith(
                        color: notifier.getMainText,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsList(BuildContext context, ColourNotifier notifier) {
    final actions = [
      {
        'title': 'Create Account',
        'subtitle': 'Add new account',
        'icon': Icons.account_balance,
        'color': Colors.blue,
        'action': () {
          // Navigate to create account
        },
      },
      {
        'title': 'Generate Report',
        'subtitle': 'Financial reports',
        'icon': Icons.assessment,
        'color': Colors.green,
        'action': () {
          // Navigate to reports
        },
      },
      {
        'title': 'Create Bill',
        'subtitle': 'New patient bill',
        'icon': Icons.receipt_long,
        'color': Colors.orange,
        'action': () {
          // Navigate to create bill
        },
      },
      {
        'title': 'Add Payment',
        'subtitle': 'Record payment',
        'icon': Icons.payment,
        'color': Colors.purple,
        'action': () {
          // Navigate to add payment
        },
      },
    ];

    return Column(
      children: actions.map((action) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: action['action'] as VoidCallback,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: notifier.getBgColor,
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: notifier.getBorderColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (action['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: action['color'] as Color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          action['title'] as String,
                          style: mediumBlackTextStyle.copyWith(
                            color: notifier.getMainText,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          action['subtitle'] as String,
                          style: mediumGreyTextStyle.copyWith(
                            color: notifier.getMaingey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: notifier.getMaingey,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFinancialHealthStatus(
    Map<String, dynamic> accounts,
    Map<String, dynamic> payments,
    Map<String, dynamic> bills,
    ColourNotifier notifier,
    AccountingController controller,
  ) {
    final totalAccounts =
        int.tryParse(accounts['total']?.toString() ?? '0') ?? 0;
    final activeAccounts =
        int.tryParse(accounts['active']?.toString() ?? '0') ?? 0;
    final totalRevenue =
        double.tryParse(payments['total_amount']?.toString() ?? '0') ?? 0;
    final totalBills =
        double.tryParse(bills['total_amount']?.toString() ?? '0') ?? 0;
    final paidBills = int.tryParse(bills['paid']?.toString() ?? '0') ?? 0;
    final totalBillCount =
        int.tryParse(bills['total_count']?.toString() ?? '0') ?? 0;

    final accountHealth =
        totalAccounts > 0 ? (activeAccounts / totalAccounts) : 0;
    final collectionRate =
        totalBillCount > 0 ? (paidBills / totalBillCount) : 0;
    final revenueHealth = totalRevenue > 10000 ? 1.0 : totalRevenue / 10000;

    final overallHealth = (accountHealth + collectionRate + revenueHealth) / 3;

    final healthItems = [
      {
        'title': 'Account Status',
        'value': '${(accountHealth * 100).toStringAsFixed(0)}%',
        'status': accountHealth > 0.8
            ? 'Excellent'
            : accountHealth > 0.6
                ? 'Good'
                : 'Needs Attention',
        'color': accountHealth > 0.8
            ? Colors.green
            : accountHealth > 0.6
                ? Colors.orange
                : Colors.red,
      },
      {
        'title': 'Collection Rate',
        'value': '${(collectionRate * 100).toStringAsFixed(0)}%',
        'status': collectionRate > 0.8
            ? 'Excellent'
            : collectionRate > 0.6
                ? 'Good'
                : 'Needs Attention',
        'color': collectionRate > 0.8
            ? Colors.green
            : collectionRate > 0.6
                ? Colors.orange
                : Colors.red,
      },
      {
        'title': 'Revenue Health',
        'value': controller.formatCurrency(totalRevenue.toString()),
        'status': revenueHealth > 0.8
            ? 'Strong'
            : revenueHealth > 0.4
                ? 'Moderate'
                : 'Growing',
        'color': revenueHealth > 0.8
            ? Colors.green
            : revenueHealth > 0.4
                ? Colors.orange
                : Colors.blue,
      },
    ];

    return Column(
      children: [
        // Overall health indicator
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: overallHealth > 0.7
                ? Colors.green.withOpacity(0.1)
                : overallHealth > 0.5
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: overallHealth > 0.7
                  ? Colors.green.withOpacity(0.3)
                  : overallHealth > 0.5
                      ? Colors.orange.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                overallHealth > 0.7
                    ? Icons.check_circle
                    : overallHealth > 0.5
                        ? Icons.warning
                        : Icons.error,
                color: overallHealth > 0.7
                    ? Colors.green
                    : overallHealth > 0.5
                        ? Colors.orange
                        : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Health Score',
                      style: mediumBlackTextStyle.copyWith(
                        color: notifier.getMainText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${(overallHealth * 100).toStringAsFixed(0)}% - ${overallHealth > 0.7 ? 'Excellent' : overallHealth > 0.5 ? 'Good' : 'Needs Attention'}',
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
        ),
        const SizedBox(height: 16),
        // Individual health metrics
        ...healthItems.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item['color'] as Color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: mediumBlackTextStyle.copyWith(
                          color: notifier.getMainText,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            item['value'] as String,
                            style: mediumBlackTextStyle.copyWith(
                              color: notifier.getMainText,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (item['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item['status'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: item['color'] as Color,
                              ),
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
        }).toList(),
      ],
    );
  }

  Widget _buildEmptyState(
      String title, String subtitle, IconData icon, ColourNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: notifier.getMaingey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: notifier.getMaingey,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: mediumBlackTextStyle.copyWith(
              color: notifier.getMainText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: mediumGreyTextStyle.copyWith(
              color: notifier.getMaingey,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPaymentItem(
    Map<String, dynamic> payment,
    ColourNotifier notifier,
    AccountingController controller,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifier.getBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifier.getBorderColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.arrow_upward,
              color: Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment['pay_to'] ?? 'Unknown Payee',
                  style: mediumBlackTextStyle.copyWith(
                    color: notifier.getMainText,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  payment['description'] ?? '',
                  style: mediumGreyTextStyle.copyWith(
                    color: notifier.getMaingey,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 10,
                      color: notifier.getMaingey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      payment['payment_date_human'] ?? '',
                      style: mediumGreyTextStyle.copyWith(
                        color: notifier.getMaingey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                controller.formatCurrency(payment['amount'] ?? '0'),
                style: mediumBlackTextStyle.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              if (payment['account'] != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getTypeColor(payment['account']['type'] ?? '')
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    payment['account']['name'] ?? '',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: _getTypeColor(payment['account']['type'] ?? ''),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBillItem(
    Map<String, dynamic> bill,
    ColourNotifier notifier,
    AccountingController controller,
  ) {
    final status = bill['status'] ?? '';
    final statusColor = _getBillStatusColor(status);
    final isPaid = bill['is_paid'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifier.getBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifier.getBorderColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isPaid ? Icons.check_circle : Icons.receipt_long,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill['reference'] ?? 'Unknown Bill',
                  style: mediumBlackTextStyle.copyWith(
                    color: notifier.getMainText,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bill['patient']?['full_name'] ?? 'Unknown Patient',
                  style: mediumGreyTextStyle.copyWith(
                    color: notifier.getMaingey,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 10,
                      color: notifier.getMaingey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      bill['bill_date_formatted'] ?? '',
                      style: mediumGreyTextStyle.copyWith(
                        color: notifier.getMaingey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                controller.formatCurrency(bill['amount'] ?? '0'),
                style: mediumBlackTextStyle.copyWith(
                  color: notifier.getMainText,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods
  double _calculateAccountsGrowth(Map<String, dynamic> accounts) {
    // This would calculate growth from previous period
    // For now, return a static value or calculate based on available data
    return 5.2; // Example growth percentage
  }

  double _calculatePaymentsGrowth(Map<String, dynamic> payments) {
    final growth = payments['growth']?['amount_change'];
    return double.tryParse(growth?.toString() ?? '0') ?? 0.0;
  }

  double _calculateBillsGrowth(Map<String, dynamic> bills) {
    // Calculate bills growth
    return 2.1; // Example growth percentage
  }

  String _calculateCollectionRate(Map<String, dynamic> bills) {
    final paid = int.tryParse(bills['paid']?.toString() ?? '0') ?? 0;
    final total = int.tryParse(bills['total_count']?.toString() ?? '0') ?? 0;

    if (total == 0) return '0%';

    final rate = (paid / total * 100);
    return '${rate.toStringAsFixed(1)}%';
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

  Color _getBillStatusColor(String status) {
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
}
