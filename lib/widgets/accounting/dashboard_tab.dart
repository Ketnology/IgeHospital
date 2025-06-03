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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Consumer<ColourNotifier>(
      builder: (context, notifier, child) {
        return RefreshIndicator(
          onRefresh: () async {
            await controller.loadDashboard();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(isMobile ? 8 : padding),
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

              try {
                final dashboardData = controller.dashboardData as Map<String, dynamic>;
                final accounts = (dashboardData['accounts'] as Map<String, dynamic>?) ?? {};
                final payments = (dashboardData['payments'] as Map<String, dynamic>?) ?? {};
                final bills = (dashboardData['bills'] as Map<String, dynamic>?) ?? {};
                final recentPayments = (dashboardData['recent_payments'] as List<dynamic>?) ?? [];
                final recentBills = (dashboardData['recent_bills'] as List<dynamic>?) ?? [];
                final monthlyTrends = (dashboardData['monthly_trends'] as List<dynamic>?) ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dashboard Header - Responsive
                    _buildDashboardHeader(notifier, isMobile, isTablet),

                    SizedBox(height: isMobile ? 16 : 24),

                    // Key Metrics Cards - Responsive Grid
                    _buildMetricsGrid(accounts, payments, bills, controller, notifier, isMobile, isTablet),

                    SizedBox(height: isMobile ? 16 : 24),

                    // Charts and Analytics - Responsive Layout
                    _buildChartsAndAnalytics(monthlyTrends, accounts, notifier, isMobile, isTablet, controller),

                    SizedBox(height: isMobile ? 16 : 24),

                    // Quick Actions and Health - Responsive Layout
                    _buildQuickActionsAndHealth(accounts, payments, bills, notifier, isMobile, isTablet, controller),

                    SizedBox(height: isMobile ? 16 : 24),

                    // Recent Activities - Responsive Layout
                    _buildRecentActivities(recentPayments, recentBills, notifier, isMobile, isTablet, controller),

                    SizedBox(height: isMobile ? 8 : 16),
                  ],
                );
              } catch (e) {
                return Center(
                  child: Text(
                    'Error loading dashboard data',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }
            }),
          ),
        );
      },
    );
  }

  Widget _buildDashboardHeader(ColourNotifier notifier, bool isMobile, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            appMainColor.withOpacity(0.1),
            appMainColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appMainColor.withOpacity(0.2)),
      ),
      child: isMobile
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Financial Dashboard',
                  style: mainTextStyle.copyWith(
                    color: notifier.getMainText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Get.find<AccountingController>().loadDashboard(),
                icon: Icon(Icons.refresh, color: notifier.getIconColor),
                tooltip: 'Refresh Dashboard',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Monitor your hospital\'s financial performance and key metrics',
            style: mediumGreyTextStyle.copyWith(
              color: notifier.getMaingey,
              fontSize: 13,
            ),
          ),
        ],
      )
          : Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Financial Dashboard',
                  style: mainTextStyle.copyWith(
                    color: notifier.getMainText,
                    fontSize: isTablet ? 22 : 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Monitor your hospital\'s financial performance and key metrics',
                  style: mediumGreyTextStyle.copyWith(
                    color: notifier.getMaingey,
                    fontSize: isTablet ? 13 : 14,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => Get.find<AccountingController>().loadDashboard(),
                icon: Icon(Icons.refresh, color: notifier.getIconColor),
                tooltip: 'Refresh Dashboard',
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: appMainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.dashboard,
                  color: appMainColor,
                  size: isTablet ? 28 : 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(
      Map<String, dynamic> accounts,
      Map<String, dynamic> payments,
      Map<String, dynamic> bills,
      AccountingController controller,
      ColourNotifier notifier,
      bool isMobile,
      bool isTablet,
      ) {
    final metrics = [
      {
        'title': 'Total Revenue',
        'value': controller.formatCurrency(payments['total_amount']?.toString() ?? '0'),
        'subtitle': '${payments['total_count']?.toString() ?? '0'} payments',
        'icon': Icons.trending_up,
        'color': Colors.green,
        'growth': _calculatePaymentsGrowth(payments),
      },
      {
        'title': 'Outstanding Bills',
        'value': controller.formatCurrency(bills['total_amount']?.toString() ?? '0'),
        'subtitle': '${bills['total_count']?.toString() ?? '0'} bills',
        'icon': Icons.receipt_long,
        'color': Colors.orange,
        'growth': _calculateBillsGrowth(bills),
      },
    ];

    if (isMobile) {
      return SizedBox(
        height: 150, // Fixed height for mobile grid
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: metrics.length,
          itemBuilder: (context, index) {
            final metric = metrics[index];
            return _buildMetricCard(
              metric['title'] as String,
              metric['value'] as String,
              metric['subtitle'] as String,
              metric['icon'] as IconData,
              metric['color'] as Color,
              notifier,
              metric['growth'] as double,
              isMobile,
            );
          },
        ),
      );
    } else {
      return Row(
        children: metrics.asMap().entries.map((entry) {
          final metric = entry.value;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: entry.key < metrics.length - 1 ? 16 : 0),
              child: _buildMetricCard(
                metric['title'] as String,
                metric['value'] as String,
                metric['subtitle'] as String,
                metric['icon'] as IconData,
                metric['color'] as Color,
                notifier,
                metric['growth'] as double,
                isMobile,
              ),
            ),
          );
        }).toList(),
      );
    }
  }

  Widget _buildMetricCard(
      String title,
      String value,
      String subtitle,
      IconData icon,
      Color color,
      ColourNotifier notifier,
      double growth,
      bool isMobile,
      ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: notifier.getContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: boxShadow,
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: isMobile ? 20 : 24),
              ),
              const Spacer(),
              if (growth != 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
                        size: isMobile ? 10 : 12,
                        color: growth > 0 ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${growth.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: isMobile ? 9 : 10,
                          fontWeight: FontWeight.w600,
                          color: growth > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Flexible(
            child: Text(
              value,
              style: mainTextStyle.copyWith(
                color: notifier.getMainText,
                fontSize: isMobile ? 18 : 28,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: mediumBlackTextStyle.copyWith(
              color: notifier.getMainText,
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: mediumGreyTextStyle.copyWith(
              color: notifier.getMaingey,
              fontSize: isMobile ? 10 : 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChartsAndAnalytics(
      List<dynamic> monthlyTrends,
      Map<String, dynamic> accounts,
      ColourNotifier notifier,
      bool isMobile,
      bool isTablet,
      AccountingController controller,
      ) {
    if (isMobile) {
      return Column(
        children: [
          // Financial Trends Chart
          _buildFinancialTrendsChart(monthlyTrends, notifier, controller, isMobile, isTablet),
          const SizedBox(height: 16),
          // Account Distribution
          _buildAccountDistribution(accounts['by_type'] ?? {}, notifier, isMobile, isTablet),
        ],
      );
    } else {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Financial Trends Chart
            Expanded(
              flex: 2,
              child: _buildFinancialTrendsChart(monthlyTrends, notifier, controller, isMobile, isTablet),
            ),
            const SizedBox(width: 16),
            // Account Distribution
            Expanded(
              child: _buildAccountDistribution(accounts['by_type'] ?? {}, notifier, isMobile, isTablet),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildFinancialTrendsChart(
      List<dynamic> monthlyTrends,
      ColourNotifier notifier,
      AccountingController controller,
      bool isMobile,
      bool isTablet,
      ) {
    return Container(
      width: double.infinity,
      height: isMobile ? 280 : (isTablet ? 320 : 350),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: notifier.getContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: boxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed header row with proper flex constraints
          if (isMobile) ...[
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: notifier.getIconColor,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Financial Trends',
                    style: mainTextStyle.copyWith(
                      color: notifier.getMainText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildTrendLegend(notifier, isMobile),
          ] else ...[
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: notifier.getIconColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Financial Trends',
                    style: mainTextStyle.copyWith(
                      color: notifier.getMainText,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildTrendLegend(notifier, isMobile),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Expanded(
            child: monthlyTrends.isEmpty
                ? _buildEmptyState(
              'No trend data available',
              'Financial trends will appear here once data is available',
              Icons.trending_up,
              notifier,
              isMobile,
            )
                : _buildChartContent(monthlyTrends, notifier, isMobile),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDistribution(
      Map<String, dynamic> distribution,
      ColourNotifier notifier,
      bool isMobile,
      bool isTablet,
      ) {
    return Container(
      width: double.infinity,
      height: isMobile ? 280 : (isTablet ? 320 : 350),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
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
              Icon(
                Icons.donut_large,
                color: notifier.getIconColor,
                size: isMobile ? 18 : 20,
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Expanded(
                child: Text(
                  'Account Distribution',
                  style: mainTextStyle.copyWith(
                    color: notifier.getMainText,
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: distribution.isEmpty
                ? _buildEmptyState(
              'No account data',
              'Account distribution will appear here',
              Icons.pie_chart,
              notifier,
              isMobile,
            )
                : _buildDistributionContent(distribution, notifier, isMobile),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContent(List<dynamic> monthlyTrends, ColourNotifier notifier, bool isMobile) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: notifier.getBgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: notifier.getBorderColor.withOpacity(0.3)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: isMobile ? 40 : 48,
                    color: notifier.getMaingey,
                  ),
                  SizedBox(height: isMobile ? 8 : 12),
                  Text(
                    'Financial Trends Chart',
                    style: mediumBlackTextStyle.copyWith(
                      color: notifier.getMainText,
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 13 : 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chart visualization would be displayed here',
                    style: mediumGreyTextStyle.copyWith(
                      color: notifier.getMaingey,
                      fontSize: isMobile ? 11 : 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (monthlyTrends.isNotEmpty)
          SizedBox(
            height: 20,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: monthlyTrends.take(isMobile ? 4 : 6).map((trend) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      trend['month'] ?? '',
                      style: TextStyle(
                        fontSize: isMobile ? 9 : 10,
                        color: notifier.getMaingey,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDistributionContent(Map<String, dynamic> distribution, ColourNotifier notifier, bool isMobile) {
    final total = distribution.values.fold(0, (sum, value) => sum + (int.tryParse(value.toString()) ?? 0));

    return Column(
      children: [
        Expanded(
          flex: isMobile ? 1 : 2,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: notifier.getBgColor,
              shape: BoxShape.circle,
              border: Border.all(color: notifier.getBorderColor.withOpacity(0.3)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.donut_large,
                    size: isMobile ? 32 : 40,
                    color: notifier.getMaingey,
                  ),
                  SizedBox(height: isMobile ? 6 : 8),
                  Text(
                    total.toString(),
                    style: mainTextStyle.copyWith(
                      color: notifier.getMainText,
                      fontSize: isMobile ? 16 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Total Accounts',
                    style: mediumGreyTextStyle.copyWith(
                      color: notifier.getMaingey,
                      fontSize: isMobile ? 9 : 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: distribution.entries.map((entry) {
              final type = entry.key;
              final count = int.tryParse(entry.value.toString()) ?? 0;
              final percentage = total > 0 ? (count / total * 100) : 0;
              final color = _getTypeColor(type);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: isMobile ? 10 : 12,
                      height: isMobile ? 10 : 12,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: isMobile ? 6 : 8),
                    Expanded(
                      child: Text(
                        type.toUpperCase(),
                        style: mediumBlackTextStyle.copyWith(
                          color: notifier.getMainText,
                          fontSize: isMobile ? 11 : 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '$count (${percentage.toStringAsFixed(0)}%)',
                      style: mediumBlackTextStyle.copyWith(
                        color: notifier.getMainText,
                        fontWeight: FontWeight.w600,
                        fontSize: isMobile ? 11 : 12,
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

  Widget _buildTrendLegend(ColourNotifier notifier, bool isMobile) {
    final legends = [
      {'label': 'Revenue', 'color': Colors.green},
      {'label': 'Expenses', 'color': Colors.red},
      {'label': 'Bills', 'color': Colors.orange},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: legends.map((legend) => Padding(
          padding: EdgeInsets.only(right: isMobile ? 8 : 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isMobile ? 10 : 12,
                height: isMobile ? 10 : 12,
                decoration: BoxDecoration(
                  color: legend['color'] as Color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: isMobile ? 4 : 6),
              Text(
                legend['label'] as String,
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  color: notifier.getMaingey,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildQuickActionsAndHealth(
      Map<String, dynamic> accounts,
      Map<String, dynamic> payments,
      Map<String, dynamic> bills,
      ColourNotifier notifier,
      bool isMobile,
      bool isTablet,
      AccountingController controller,
      ) {
    if (isMobile) {
      return Column(
        children: [
          _buildQuickActions(notifier, isMobile),
          const SizedBox(height: 16),
          _buildFinancialHealth(accounts, payments, bills, notifier, controller, isMobile),
        ],
      );
    } else {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildQuickActions(notifier, isMobile)),
            const SizedBox(width: 16),
            Expanded(child: _buildFinancialHealth(accounts, payments, bills, notifier, controller, isMobile)),
          ],
        ),
      );
    }
  }

  Widget _buildQuickActions(ColourNotifier notifier, bool isMobile) {
    final actions = [
      {
        'title': 'Create Account',
        'subtitle': 'Add new account',
        'icon': Icons.account_balance,
        'color': Colors.blue,
        'action': () {},
      },
      {
        'title': 'Create Bill',
        'subtitle': 'New patient bill',
        'icon': Icons.receipt_long,
        'color': Colors.orange,
        'action': () {},
      },
      {
        'title': 'Add Payment',
        'subtitle': 'Record payment',
        'icon': Icons.payment,
        'color': Colors.purple,
        'action': () {},
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
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
              Icon(
                Icons.flash_on,
                color: notifier.getIconColor,
                size: isMobile ? 18 : 20,
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Expanded(
                child: Text(
                  'Quick Actions',
                  style: mainTextStyle.copyWith(
                    color: notifier.getMainText,
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          ...actions.map((action) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: action['action'] as VoidCallback,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 10 : 12),
                decoration: BoxDecoration(
                  color: notifier.getBgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: notifier.getBorderColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isMobile ? 6 : 8),
                      decoration: BoxDecoration(
                        color: (action['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        action['icon'] as IconData,
                        color: action['color'] as Color,
                        size: isMobile ? 16 : 20,
                      ),
                    ),
                    SizedBox(width: isMobile ? 10 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            action['title'] as String,
                            style: mediumBlackTextStyle.copyWith(
                              color: notifier.getMainText,
                              fontWeight: FontWeight.w600,
                              fontSize: isMobile ? 13 : 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            action['subtitle'] as String,
                            style: mediumGreyTextStyle.copyWith(
                              color: notifier.getMaingey,
                              fontSize: isMobile ? 11 : 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: isMobile ? 10 : 12,
                      color: notifier.getMaingey,
                    ),
                  ],
                ),
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildFinancialHealth(
      Map<String, dynamic> accounts,
      Map<String, dynamic> payments,
      Map<String, dynamic> bills,
      ColourNotifier notifier,
      AccountingController controller,
      bool isMobile,
      ) {
    final totalAccounts = int.tryParse(accounts['total']?.toString() ?? '0') ?? 0;
    final activeAccounts = int.tryParse(accounts['active']?.toString() ?? '0') ?? 0;
    final totalRevenue = double.tryParse(payments['total_amount']?.toString() ?? '0') ?? 0;
    final paidBills = int.tryParse(bills['paid']?.toString() ?? '0') ?? 0;
    final totalBillCount = int.tryParse(bills['total_count']?.toString() ?? '0') ?? 0;

    final accountHealth = totalAccounts > 0 ? (activeAccounts / totalAccounts) : 0;
    final collectionRate = totalBillCount > 0 ? (paidBills / totalBillCount) : 0;
    final revenueHealth = totalRevenue > 10000 ? 1.0 : totalRevenue / 10000;
    final overallHealth = (accountHealth + collectionRate + revenueHealth) / 3;

    final healthItems = [
      {
        'title': 'Account Status',
        'value': '${(accountHealth * 100).toStringAsFixed(0)}%',
        'status': accountHealth > 0.8 ? 'Excellent' : accountHealth > 0.6 ? 'Good' : 'Needs Attention',
        'color': accountHealth > 0.8 ? Colors.green : accountHealth > 0.6 ? Colors.orange : Colors.red,
      },
      {
        'title': 'Collection Rate',
        'value': '${(collectionRate * 100).toStringAsFixed(0)}%',
        'status': collectionRate > 0.8 ? 'Excellent' : collectionRate > 0.6 ? 'Good' : 'Needs Attention',
        'color': collectionRate > 0.8 ? Colors.green : collectionRate > 0.6 ? Colors.orange : Colors.red,
      },
      {
        'title': 'Revenue Health',
        'value': controller.formatCurrency(totalRevenue.toString()),
        'status': revenueHealth > 0.8 ? 'Strong' : revenueHealth > 0.4 ? 'Moderate' : 'Growing',
        'color': revenueHealth > 0.8 ? Colors.green : revenueHealth > 0.4 ? Colors.orange : Colors.blue,
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
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
              Icon(
                Icons.health_and_safety,
                color: notifier.getIconColor,
                size: isMobile ? 18 : 20,
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Expanded(
                child: Text(
                  'Financial Health',
                  style: mainTextStyle.copyWith(
                    color: notifier.getMainText,
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),

          // Overall health indicator
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 12 : 16),
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
                  overallHealth > 0.7 ? Icons.check_circle : overallHealth > 0.5 ? Icons.warning : Icons.error,
                  color: overallHealth > 0.7 ? Colors.green : overallHealth > 0.5 ? Colors.orange : Colors.red,
                  size: isMobile ? 20 : 24,
                ),
                SizedBox(width: isMobile ? 10 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Health Score',
                        style: mediumBlackTextStyle.copyWith(
                          color: notifier.getMainText,
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 13 : 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${(overallHealth * 100).toStringAsFixed(0)}% - ${overallHealth > 0.7 ? 'Excellent' : overallHealth > 0.5 ? 'Good' : 'Needs Attention'}',
                        style: mediumGreyTextStyle.copyWith(
                          color: notifier.getMaingey,
                          fontSize: isMobile ? 11 : 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isMobile ? 12 : 16),

          // Individual health metrics
          ...healthItems.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: isMobile ? 35 : 40,
                  decoration: BoxDecoration(
                    color: item['color'] as Color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: isMobile ? 10 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: mediumBlackTextStyle.copyWith(
                          color: notifier.getMainText,
                          fontSize: isMobile ? 12 : 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            item['value'] as String,
                            style: mediumBlackTextStyle.copyWith(
                              color: notifier.getMainText,
                              fontSize: isMobile ? 11 : 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (item['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item['status'] as String,
                              style: TextStyle(
                                fontSize: isMobile ? 9 : 10,
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
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(
      List<dynamic> recentPayments,
      List<dynamic> recentBills,
      ColourNotifier notifier,
      bool isMobile,
      bool isTablet,
      AccountingController controller,
      ) {
    if (isMobile) {
      return Column(
        children: [
          _buildRecentPayments(recentPayments, notifier, controller, isMobile),
          const SizedBox(height: 16),
          _buildRecentBills(recentBills, notifier, controller, isMobile),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildRecentPayments(recentPayments, notifier, controller, isMobile)),
          const SizedBox(width: 16),
          Expanded(child: _buildRecentBills(recentBills, notifier, controller, isMobile)),
        ],
      );
    }
  }

  Widget _buildRecentPayments(List<dynamic> recentPayments, ColourNotifier notifier, AccountingController controller, bool isMobile) {
    return Container(
      width: double.infinity,
      height: isMobile ? 350 : 400,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
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
              Icon(Icons.payment, color: Colors.green, size: isMobile ? 18 : 20),
              SizedBox(width: isMobile ? 6 : 8),
              Expanded(
                child: Text(
                  'Recent Payments',
                  style: mainTextStyle.copyWith(
                    color: notifier.getMainText,
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: TextStyle(fontSize: isMobile ? 12 : 14),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Expanded(
            child: recentPayments.isEmpty
                ? _buildEmptyState(
              'No recent payments',
              'Payments will appear here once created',
              Icons.payment,
              notifier,
              isMobile,
            )
                : ListView.builder(
              itemCount: recentPayments.length,
              itemBuilder: (context, index) {
                final payment = recentPayments[index];
                return _buildRecentPaymentItem(payment, notifier, controller, isMobile);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBills(List<dynamic> recentBills, ColourNotifier notifier, AccountingController controller, bool isMobile) {
    return Container(
      width: double.infinity,
      height: isMobile ? 350 : 400,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
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
              Icon(Icons.receipt_long, color: Colors.orange, size: isMobile ? 18 : 20),
              SizedBox(width: isMobile ? 6 : 8),
              Expanded(
                child: Text(
                  'Recent Bills',
                  style: mainTextStyle.copyWith(
                    color: notifier.getMainText,
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: TextStyle(fontSize: isMobile ? 12 : 14),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Expanded(
            child: recentBills.isEmpty
                ? _buildEmptyState(
              'No recent bills',
              'Bills will appear here once created',
              Icons.receipt_long,
              notifier,
              isMobile,
            )
                : ListView.builder(
              itemCount: recentBills.length,
              itemBuilder: (context, index) {
                final bill = recentBills[index];
                return _buildRecentBillItem(bill, notifier, controller, isMobile);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon, ColourNotifier notifier, bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: notifier.getMaingey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: isMobile ? 28 : 32,
              color: notifier.getMaingey,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            title,
            style: mediumBlackTextStyle.copyWith(
              color: notifier.getMainText,
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 13 : 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: mediumGreyTextStyle.copyWith(
              color: notifier.getMaingey,
              fontSize: isMobile ? 11 : 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPaymentItem(Map<String, dynamic> payment, ColourNotifier notifier, AccountingController controller, bool isMobile) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: notifier.getBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifier.getBorderColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? 35 : 40,
            height: isMobile ? 35 : 40,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isMobile ? 17.5 : 20),
            ),
            child: Icon(
              Icons.arrow_upward,
              color: Colors.green,
              size: isMobile ? 16 : 20,
            ),
          ),
          SizedBox(width: isMobile ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment['pay_to'] ?? 'Unknown Payee',
                  style: mediumBlackTextStyle.copyWith(
                    color: notifier.getMainText,
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 12 : 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (payment['description'] != null && payment['description'].toString().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    payment['description'],
                    style: mediumGreyTextStyle.copyWith(
                      color: notifier.getMaingey,
                      fontSize: isMobile ? 10 : 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: isMobile ? 8 : 10,
                      color: notifier.getMaingey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        payment['payment_date_human'] ?? '',
                        style: mediumGreyTextStyle.copyWith(
                          color: notifier.getMaingey,
                          fontSize: isMobile ? 9 : 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: isMobile ? 6 : 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                controller.formatCurrency(payment['amount'] ?? '0'),
                style: mediumBlackTextStyle.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 12 : 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (payment['account'] != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getTypeColor(payment['account']['type'] ?? '').withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    payment['account']['name'] ?? '',
                    style: TextStyle(
                      fontSize: isMobile ? 8 : 9,
                      fontWeight: FontWeight.w600,
                      color: _getTypeColor(payment['account']['type'] ?? ''),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBillItem(Map<String, dynamic> bill, ColourNotifier notifier, AccountingController controller, bool isMobile) {
    final status = bill['status'] ?? '';
    final statusColor = _getBillStatusColor(status);
    final isPaid = bill['is_paid'] ?? false;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: notifier.getBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifier.getBorderColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? 35 : 40,
            height: isMobile ? 35 : 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isMobile ? 17.5 : 20),
            ),
            child: Icon(
              isPaid ? Icons.check_circle : Icons.receipt_long,
              color: statusColor,
              size: isMobile ? 16 : 20,
            ),
          ),
          SizedBox(width: isMobile ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill['reference'] ?? 'Unknown Bill',
                  style: mediumBlackTextStyle.copyWith(
                    color: notifier.getMainText,
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 12 : 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  bill['patient']?['full_name'] ?? 'Unknown Patient',
                  style: mediumGreyTextStyle.copyWith(
                    color: notifier.getMaingey,
                    fontSize: isMobile ? 10 : 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: isMobile ? 8 : 10,
                      color: notifier.getMaingey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        bill['bill_date_formatted'] ?? '',
                        style: mediumGreyTextStyle.copyWith(
                          color: notifier.getMaingey,
                          fontSize: isMobile ? 9 : 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: isMobile ? 6 : 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                controller.formatCurrency(bill['amount'] ?? '0'),
                style: mediumBlackTextStyle.copyWith(
                  color: notifier.getMainText,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 12 : 13,
                ),
                overflow: TextOverflow.ellipsis,
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
                    fontSize: isMobile ? 8 : 9,
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
    return 5.2; // Example growth percentage
  }

  double _calculatePaymentsGrowth(Map<String, dynamic> payments) {
    final growth = payments['growth']?['amount_change'];
    return double.tryParse(growth?.toString() ?? '0') ?? 0.0;
  }

  double _calculateBillsGrowth(Map<String, dynamic> bills) {
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