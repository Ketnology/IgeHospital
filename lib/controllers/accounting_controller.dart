import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ige_hospital/models/account_model.dart';
import 'package:ige_hospital/models/bill_model.dart';
import 'package:ige_hospital/provider/accounting_service.dart';

class AccountingController extends GetxController {
  final AccountingService _accountingService = Get.put(AccountingService());

  // ========== LOADING STATES ==========
  var isLoading = false.obs;
  var isAccountsLoading = false.obs;
  var isPaymentsLoading = false.obs;
  var isBillsLoading = false.obs;
  var isDashboardLoading = false.obs;

  // ========== DATA OBSERVABLES ==========
  var accounts = <Account>[].obs;
  var filteredAccounts = <Account>[].obs;
  var payments = <Payment>[].obs;
  var filteredPayments = <Payment>[].obs;
  var bills = <Bill>[].obs;
  var filteredBills = <Bill>[].obs;
  var dashboardData = <String, dynamic>{}.obs;
  var financialOverview = <String, dynamic>{}.obs;

  // ========== PAGINATION ==========
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxInt perPage = 15.obs;

  // ========== FILTER VARIABLES ==========
  var searchQuery = ''.obs;
  var selectedAccountType = 'All Types'.obs;
  var selectedAccountStatus = 'All Statuses'.obs;
  var selectedBillStatus = 'All Statuses'.obs;
  var selectedPaymentMode = 'All Modes'.obs;
  var sortBy = 'created_at'.obs;
  var sortDirection = 'desc'.obs;

  // Filter date ranges
  var dateFrom = ''.obs;
  var dateTo = ''.obs;
  var amountMin = 0.0.obs;
  var amountMax = 0.0.obs;

  // ========== DROPDOWN OPTIONS ==========
  final accountTypes = ['All Types', 'revenue', 'expense', 'asset'].obs;
  final accountStatuses = ['All Statuses', 'active', 'inactive'].obs;
  final billStatuses = ['All Statuses', 'paid', 'unpaid', 'pending'].obs;
  final paymentModes = ['All Modes', 'cash', 'card', 'online'].obs;

  // ========== FORM CONTROLLERS ==========
  final accountNameController = TextEditingController();
  final accountDescriptionController = TextEditingController();
  final paymentPayToController = TextEditingController();
  final paymentAmountController = TextEditingController();
  final paymentDescriptionController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadAccountingData();

    // Setup filter listeners
    ever(searchQuery, (_) => applyFilters());
    ever(selectedAccountType, (_) => applyFilters());
    ever(selectedAccountStatus, (_) => applyFilters());
    ever(selectedBillStatus, (_) => applyFilters());
    ever(selectedPaymentMode, (_) => applyFilters());
  }

  @override
  void onClose() {
    accountNameController.dispose();
    accountDescriptionController.dispose();
    paymentPayToController.dispose();
    paymentAmountController.dispose();
    paymentDescriptionController.dispose();
    super.onClose();
  }

  // ========== LOAD DATA METHODS ==========

  Future<void> loadAccountingData() async {
    await Future.wait([
      loadAccounts(),
      loadPayments(),
      loadBills(),
      loadDashboard(),
    ]);
  }

  Future<void> loadAccounts() async {
    isAccountsLoading.value = true;
    try {
      final accountsList = await _accountingService.getAccounts(
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        type: selectedAccountType.value != 'All Types'
            ? selectedAccountType.value
            : null,
        status: selectedAccountStatus.value != 'All Statuses'
            ? selectedAccountStatus.value
            : null,
        sortBy: sortBy.value,
        sortDirection: sortDirection.value,
        perPage: perPage.value,
      );

      accounts.value = accountsList;
      applyFilters();
    } catch (e) {
      Get.log("Error loading accounts: $e");
    } finally {
      isAccountsLoading.value = false;
    }
  }

  Future<void> loadPayments() async {
    isPaymentsLoading.value = true;
    try {
      final paymentsList = await _accountingService.getPayments(
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        dateFrom: dateFrom.value.isNotEmpty ? dateFrom.value : null,
        dateTo: dateTo.value.isNotEmpty ? dateTo.value : null,
        amountMin: amountMin.value > 0 ? amountMin.value : null,
        amountMax: amountMax.value > 0 ? amountMax.value : null,
        sortBy: sortBy.value,
        sortDirection: sortDirection.value,
        perPage: perPage.value,
      );

      payments.value = paymentsList;
      applyFilters();
    } catch (e) {
      Get.log("Error loading payments: $e");
    } finally {
      isPaymentsLoading.value = false;
    }
  }

  Future<void> loadBills() async {
    isBillsLoading.value = true;
    try {
      final result = await _accountingService.getBillsWithPagination(
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        status: selectedBillStatus.value != 'All Statuses'
            ? selectedBillStatus.value
            : null,
        paymentMode: selectedPaymentMode.value != 'All Modes'
            ? selectedPaymentMode.value
            : null,
        dateFrom: dateFrom.value.isNotEmpty ? dateFrom.value : null,
        dateTo: dateTo.value.isNotEmpty ? dateTo.value : null,
        amountMin: amountMin.value > 0 ? amountMin.value : null,
        amountMax: amountMax.value > 0 ? amountMax.value : null,
        sortBy: sortBy.value,
        sortDirection: sortDirection.value,
        page: currentPage.value,
        perPage: perPage.value,
      );

      bills.value = result['bills'];
      totalItems.value = result['total'];
      totalPages.value = result['last_page'];
      applyFilters();
    } catch (e) {
      Get.log("Error loading bills: $e");
    } finally {
      isBillsLoading.value = false;
    }
  }

  Future<void> loadDashboard() async {
    isDashboardLoading.value = true;
    try {
      final dashboard = await _accountingService.getAccountingDashboard();
      dashboardData.value = dashboard;

      final overview = await _accountingService.getFinancialOverview();
      financialOverview.value = overview;
    } catch (e) {
      Get.log("Error loading dashboard: $e");
    } finally {
      isDashboardLoading.value = false;
    }
  }

  // ========== FILTER METHODS ==========

  void applyFilters() {
    // Filter accounts
    filteredAccounts.value = accounts.where((account) {
      bool matchesSearch = true;
      if (searchQuery.value.isNotEmpty) {
        matchesSearch = account.name
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ||
            account.description
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase());
      }

      bool matchesType = selectedAccountType.value == 'All Types' ||
          account.type == selectedAccountType.value;

      bool matchesStatus = selectedAccountStatus.value == 'All Statuses' ||
          account.status == selectedAccountStatus.value;

      return matchesSearch && matchesType && matchesStatus;
    }).toList();

    // Filter payments
    filteredPayments.value = payments.where((payment) {
      bool matchesSearch = true;
      if (searchQuery.value.isNotEmpty) {
        matchesSearch = payment.payTo
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ||
            payment.description
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase());
      }

      return matchesSearch;
    }).toList();

    // Filter bills
    filteredBills.value = bills.where((bill) {
      bool matchesSearch = true;
      if (searchQuery.value.isNotEmpty) {
        matchesSearch = bill.reference
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ||
            (bill.patient?.fullName
                    .toLowerCase()
                    .contains(searchQuery.value.toLowerCase()) ??
                false);
      }

      bool matchesStatus = selectedBillStatus.value == 'All Statuses' ||
          bill.status == selectedBillStatus.value;

      bool matchesPaymentMode = selectedPaymentMode.value == 'All Modes' ||
          bill.paymentMode == selectedPaymentMode.value;

      return matchesSearch && matchesStatus && matchesPaymentMode;
    }).toList();
  }

  void resetFilters() {
    searchQuery.value = '';
    selectedAccountType.value = 'All Types';
    selectedAccountStatus.value = 'All Statuses';
    selectedBillStatus.value = 'All Statuses';
    selectedPaymentMode.value = 'All Modes';
    dateFrom.value = '';
    dateTo.value = '';
    amountMin.value = 0.0;
    amountMax.value = 0.0;
    currentPage.value = 1;

    loadAccountingData();
  }

  void changePage(int page) {
    currentPage.value = page;
    loadBills();
  }

  void changePerPage(int newPerPage) {
    perPage.value = newPerPage;
    currentPage.value = 1;
    loadAccountingData();
  }

  // ========== CRUD OPERATIONS ==========

  // Account Operations
  Future<void> createAccount() async {
    if (accountNameController.text.isEmpty) {
      Get.snackbar('Error', 'Account name is required');
      return;
    }

    isLoading.value = true;
    try {
      final accountData = {
        'name': accountNameController.text,
        'type': selectedAccountType.value,
        'description': accountDescriptionController.text,
        'status': 'active',
      };

      await _accountingService.createAccount(accountData);
      clearAccountForm();
      loadAccounts();
      Get.back(); // Close dialog
    } catch (e) {
      Get.snackbar('Error', 'Failed to create account: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateAccount(String id) async {
    if (accountNameController.text.isEmpty) {
      Get.snackbar('Error', 'Account name is required');
      return;
    }

    isLoading.value = true;
    try {
      final accountData = {
        'name': accountNameController.text,
        'type': selectedAccountType.value,
        'description': accountDescriptionController.text,
        'status': selectedAccountStatus.value,
      };

      await _accountingService.updateAccount(id, accountData);
      clearAccountForm();
      loadAccounts();
      Get.back(); // Close dialog
    } catch (e) {
      Get.snackbar('Error', 'Failed to update account: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAccount(String id) async {
    try {
      await _accountingService.deleteAccount(id);
      loadAccounts();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete account: $e');
    }
  }

  Future<void> toggleAccountStatus(String id) async {
    try {
      await _accountingService.toggleAccountStatus(id);
      loadAccounts();
    } catch (e) {
      Get.snackbar('Error', 'Failed to toggle account status: $e');
    }
  }

  // Payment Operations
  Future<void> createPayment(String accountId) async {
    if (paymentPayToController.text.isEmpty ||
        paymentAmountController.text.isEmpty) {
      Get.snackbar('Error', 'Pay to and amount are required');
      return;
    }

    isLoading.value = true;
    try {
      final paymentData = {
        'payment_date': DateTime.now().toIso8601String().split('T')[0],
        'account_id': accountId,
        'pay_to': paymentPayToController.text,
        'amount': double.parse(paymentAmountController.text),
        'description': paymentDescriptionController.text,
      };

      await _accountingService.createPayment(paymentData);
      clearPaymentForm();
      loadPayments();
      Get.back(); // Close dialog
    } catch (e) {
      Get.snackbar('Error', 'Failed to create payment: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Bill Operations
  Future<void> createBill(String patientId, List<BillItem> items) async {
    isLoading.value = true;
    try {
      final double totalAmount =
          items.fold(0.0, (sum, item) => sum + item.unitTotal);

      final billData = {
        'patient_id': patientId,
        'bill_date': DateTime.now().toIso8601String().split('T')[0],
        'amount': totalAmount,
        'patient_admission_id': 'ADM-${DateTime.now().millisecondsSinceEpoch}',
        'status': 'pending',
        'payment_mode': 'cash',
        'items': items.map((item) => item.toJson()).toList(),
      };

      await _accountingService.createBill(billData);
      loadBills();
      Get.back(); // Close dialog
    } catch (e) {
      Get.snackbar('Error', 'Failed to create bill: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateBillStatus(String id, String status) async {
    try {
      await _accountingService.updateBillStatus(id, status);
      loadBills();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update bill status: $e');
    }
  }

  Future<void> deleteBill(String id) async {
    try {
      await _accountingService.deleteBill(id);
      loadBills();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete bill: $e');
    }
  }

  // ========== FORM HELPERS ==========

  void clearAccountForm() {
    accountNameController.clear();
    accountDescriptionController.clear();
    selectedAccountType.value = 'revenue';
    selectedAccountStatus.value = 'active';
  }

  void clearPaymentForm() {
    paymentPayToController.clear();
    paymentAmountController.clear();
    paymentDescriptionController.clear();
  }

  void fillAccountForm(Account account) {
    accountNameController.text = account.name;
    accountDescriptionController.text = account.description;
    selectedAccountType.value = account.type;
    selectedAccountStatus.value = account.status;
  }

  // ========== UTILITY METHODS ==========

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'paid':
        return Colors.green;
      case 'inactive':
      case 'unpaid':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String getStatusText(String status) {
    return status
        .toLowerCase()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String formatCurrency(String amount) {
    try {
      final double value = double.parse(amount);
      return '₦${value.toStringAsFixed(2)}';
    } catch (e) {
      return '₦0.00';
    }
  }
}
