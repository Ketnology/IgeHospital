import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/accounting_controller.dart';
import 'package:ige_hospital/widgets/accounting/accounts_tab.dart';
import 'package:ige_hospital/widgets/accounting/payments_tab.dart';
import 'package:ige_hospital/widgets/accounting/bills_tab.dart';
import 'package:ige_hospital/widgets/accounting/dashboard_tab.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
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
        return Scaffold(
          backgroundColor: notifier!.getBgColor,
          body: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  color: notifier.getContainer,
                  boxShadow: boxShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   'Hospital Accounting',
                    //   style: mainTextStyle.copyWith(
                    //     color: notifier.getMainText,
                    //     fontSize: 28,
                    //   ),
                    // ),
                    // const SizedBox(height: 8),
                    // Text(
                    //   'Manage accounts, payments, bills, and financial reports',
                    //   style: mediumGreyTextStyle.copyWith(
                    //     color: notifier.getMaingey,
                    //   ),
                    // ),
                    // const SizedBox(height: 20),

                    // Tab Bar
                    Container(
                      decoration: BoxDecoration(
                        color: notifier.getBgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: notifier.getBorderColor),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.dashboard),
                            text: 'Dashboard',
                          ),
                          Tab(
                            icon: Icon(Icons.account_balance),
                            text: 'Accounts',
                          ),
                          Tab(
                            icon: Icon(Icons.payment),
                            text: 'Payments',
                          ),
                          // Tab(
                          //   icon: Icon(Icons.receipt_long),
                          //   text: 'Bills',
                          // ),
                        ],
                        indicatorColor: appMainColor,
                        labelColor: appMainColor,
                        unselectedLabelColor: notifier.getMainText,
                        dividerColor: Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Content
              Expanded(
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
            ],
          ),
        );
      },
    );
  }
}
