import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/accounting_controller.dart';
import 'package:ige_hospital/widgets/accounting/accounts_tab.dart';
import 'package:ige_hospital/widgets/accounting/payments_tab.dart';
import 'package:ige_hospital/widgets/accounting/bills_tab.dart';
import 'package:ige_hospital/widgets/accounting/dashboard_tab.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/widgets/common_title.dart';
import 'package:provider/provider.dart';

class AccountingPage extends StatefulWidget {
  const AccountingPage({super.key});

  @override
  State<AccountingPage> createState() => _AccountingPageState();
}

class _AccountingPageState extends State<AccountingPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final AccountingController controller = Get.put(AccountingController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ColourNotifier>(
      builder: (context, notifier, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 768;
        final isTablet = screenWidth >= 768 && screenWidth < 1024;

        return Scaffold(
          backgroundColor: notifier!.getBgColor,
          body: Column(
            children: [
              // Header Section with Common Title
              const CommonTitle(
                title: 'Accounting',
                path: "Financial Management",
              ),

              // Tab Section - Responsive layout
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : padding,
                  vertical: 8,
                ),
                padding: EdgeInsets.all(isMobile ? 8 : 12),
                decoration: BoxDecoration(
                  color: notifier.getContainer,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: boxShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Page Title and Description - responsive
                    if (!isMobile) ...[
                      Text(
                        'Financial Management System',
                        style: mainTextStyle.copyWith(
                          color: notifier.getMainText,
                          fontSize: isTablet ? 22 : 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage accounts, payments, bills, and financial reports',
                        style: mediumGreyTextStyle.copyWith(
                          color: notifier.getMaingey,
                          fontSize: isTablet ? 13 : 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Tab Bar - Responsive design
                    _buildResponsiveTabBar(notifier, isMobile, isTablet),
                  ],
                ),
              ),

              // Tab Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 0,
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      DashboardTab(),
                      AccountsTab(),
                      PaymentsTab(),
                      BillsTab(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResponsiveTabBar(
      ColourNotifier notifier, bool isMobile, bool isTablet) {
    if (isMobile) {
      // Mobile: Scrollable tabs with icons only or compact text
      return Container(
        decoration: BoxDecoration(
          color: notifier.getBgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: notifier.getBorderColor),
        ),
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            _buildMobileTab(Icons.dashboard, 'Dashboard'),
            _buildMobileTab(Icons.account_balance, 'Accounts'),
            _buildMobileTab(Icons.payment, 'Payments'),
            _buildMobileTab(Icons.receipt_long, 'Bills'),
          ],
          indicatorColor: appMainColor,
          labelColor: appMainColor,
          unselectedLabelColor: notifier.getMainText,
          dividerColor: Colors.transparent,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      );
    } else {
      // Desktop/Tablet: Full tabs with icons and text
      return Container(
        decoration: BoxDecoration(
          color: notifier.getBgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: notifier.getBorderColor),
        ),
        child: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(Icons.dashboard, size: isTablet ? 20 : 24),
              text: 'Dashboard',
            ),
            Tab(
              icon: Icon(Icons.account_balance, size: isTablet ? 20 : 24),
              text: 'Accounts',
            ),
            Tab(
              icon: Icon(Icons.payment, size: isTablet ? 20 : 24),
              text: 'Payments',
            ),
            Tab(
              icon: Icon(Icons.receipt_long, size: isTablet ? 20 : 24),
              text: 'Bills',
            ),
          ],
          indicatorColor: appMainColor,
          labelColor: appMainColor,
          unselectedLabelColor: notifier.getMainText,
          dividerColor: Colors.transparent,
          labelStyle: TextStyle(
            fontSize: isTablet ? 13 : 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: isTablet ? 12 : 13,
          ),
        ),
      );
    }
  }

  Widget _buildMobileTab(IconData icon, String text) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}