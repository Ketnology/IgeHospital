import 'dart:convert';
import 'package:get/get.dart';
import 'package:ige_hospital/constants/api_endpoints.dart';
import 'package:ige_hospital/models/account_model.dart';
import 'package:ige_hospital/models/bill_model.dart';
import 'package:ige_hospital/utils/http_client.dart';
import 'package:ige_hospital/utils/snack_bar_utils.dart';

class AccountingService extends GetxService {
  final HttpClient _httpClient = HttpClient();

  // ========== ACCOUNTS API ==========

  Future<List<Account>> getAccounts({
    String? search,
    String? type,
    String? status,
    String sortBy = 'name',
    String sortDirection = 'asc',
    int perPage = 15,
  }) async {
    try {
      final Map<String, String> queryParams = {
        if (search != null && search.isNotEmpty) 'search': search,
        if (type != null && type.isNotEmpty) 'type': type,
        if (status != null && status.isNotEmpty) 'status': status,
        'sort_by': sortBy,
        'sort_direction': sortDirection,
        'per_page': perPage.toString(),
      };

      final Uri uri = Uri.parse('${ApiEndpoints.baseUrl}/accounting/accounts')
          .replace(queryParameters: queryParams);
      final dynamic result = await _httpClient.get(uri.toString());

      if (result is Map<String, dynamic> && result['status'] == 200) {
        final List<dynamic> accountsList = result['data']['accounts'] ?? [];
        return accountsList.map((json) => Account.fromJson(json)).toList();
      } else {
        throw Exception(result['message'] ?? 'Failed to fetch accounts');
      }
    } catch (e) {
      Get.log("Error in getAccounts: $e");
      throw Exception('Failed to fetch accounts: $e');
    }
  }

  Future<Account> getAccountDetails(String id) async {
    try {
      final dynamic result = await _httpClient
          .get('${ApiEndpoints.baseUrl}/accounting/accounts/$id');

      if (result is Map<String, dynamic> && result['status'] == 200) {
        return Account.fromJson(result['data']);
      } else {
        throw Exception(result['message'] ?? 'Failed to get account details');
      }
    } catch (e) {
      Get.log("Error in getAccountDetails: $e");
      throw Exception('Failed to get account details: $e');
    }
  }

  Future<void> createAccount(Map<String, dynamic> accountData) async {
    try {
      final dynamic result = await _httpClient.post(
        '${ApiEndpoints.baseUrl}/accounting/accounts',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(accountData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 201 || result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Account created successfully');
        } else {
          throw Exception(result['message'] ?? 'Failed to create account');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in createAccount: $e");
      throw Exception('Failed to create account: $e');
    }
  }

  Future<void> updateAccount(
      String id, Map<String, dynamic> accountData) async {
    try {
      final dynamic result = await _httpClient.put(
        '${ApiEndpoints.baseUrl}/accounting/accounts/$id',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(accountData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Account updated successfully');
        } else {
          throw Exception(result['message'] ?? 'Failed to update account');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in updateAccount: $e");
      throw Exception('Failed to update account: $e');
    }
  }

  Future<void> deleteAccount(String id) async {
    try {
      final dynamic result = await _httpClient
          .delete('${ApiEndpoints.baseUrl}/accounting/accounts/$id');

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Account deleted successfully');
        } else {
          throw Exception(result['message'] ?? 'Failed to delete account');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in deleteAccount: $e");
      throw Exception('Failed to delete account: $e');
    }
  }

  Future<void> toggleAccountStatus(String id) async {
    try {
      final dynamic result = await _httpClient.patch(
          '${ApiEndpoints.baseUrl}/accounting/accounts/$id/toggle-status');

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar(
              result['message'] ?? 'Account status updated');
        } else {
          throw Exception(
              result['message'] ?? 'Failed to toggle account status');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in toggleAccountStatus: $e");
      throw Exception('Failed to toggle account status: $e');
    }
  }

  // ========== PAYMENTS API ==========

  Future<List<Payment>> getPayments({
    String? search,
    String? accountId,
    double? amountMin,
    double? amountMax,
    String? dateFrom,
    String? dateTo,
    String sortBy = 'payment_date',
    String sortDirection = 'desc',
    int perPage = 15,
  }) async {
    try {
      final Map<String, String> queryParams = {
        if (search != null && search.isNotEmpty) 'search': search,
        if (accountId != null && accountId.isNotEmpty) 'account_id': accountId,
        if (amountMin != null) 'amount_min': amountMin.toString(),
        if (amountMax != null) 'amount_max': amountMax.toString(),
        if (dateFrom != null && dateFrom.isNotEmpty) 'date_from': dateFrom,
        if (dateTo != null && dateTo.isNotEmpty) 'date_to': dateTo,
        'sort_by': sortBy,
        'sort_direction': sortDirection,
        'per_page': perPage.toString(),
      };

      final Uri uri = Uri.parse('${ApiEndpoints.baseUrl}/accounting/payments')
          .replace(queryParameters: queryParams);
      final dynamic result = await _httpClient.get(uri.toString());

      if (result is Map<String, dynamic> && result['status'] == 200) {
        final List<dynamic> paymentsList = result['data']['payments'] ?? [];
        return paymentsList.map((json) => Payment.fromJson(json)).toList();
      } else {
        throw Exception(result['message'] ?? 'Failed to fetch payments');
      }
    } catch (e) {
      Get.log("Error in getPayments: $e");
      throw Exception('Failed to fetch payments: $e');
    }
  }

  Future<void> createPayment(Map<String, dynamic> paymentData) async {
    try {
      final dynamic result = await _httpClient.post(
        '${ApiEndpoints.baseUrl}/accounting/payments',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(paymentData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 201 || result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Payment created successfully');
        } else {
          throw Exception(result['message'] ?? 'Failed to create payment');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in createPayment: $e");
      throw Exception('Failed to create payment: $e');
    }
  }

  // ========== BILLS API ==========

  Future<Map<String, dynamic>> getBillsWithPagination({
    String? search,
    String? patientId,
    String? status,
    String? paymentMode,
    double? amountMin,
    double? amountMax,
    String? dateFrom,
    String? dateTo,
    String sortBy = 'bill_date',
    String sortDirection = 'desc',
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final Map<String, String> queryParams = {
        if (search != null && search.isNotEmpty) 'search': search,
        if (patientId != null && patientId.isNotEmpty) 'patient_id': patientId,
        if (status != null && status.isNotEmpty) 'status': status,
        if (paymentMode != null && paymentMode.isNotEmpty)
          'payment_mode': paymentMode,
        if (amountMin != null) 'amount_min': amountMin.toString(),
        if (amountMax != null) 'amount_max': amountMax.toString(),
        if (dateFrom != null && dateFrom.isNotEmpty) 'date_from': dateFrom,
        if (dateTo != null && dateTo.isNotEmpty) 'date_to': dateTo,
        'sort_by': sortBy,
        'sort_direction': sortDirection,
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final Uri uri = Uri.parse('${ApiEndpoints.baseUrl}/accounting/bills')
          .replace(queryParameters: queryParams);
      final dynamic result = await _httpClient.get(uri.toString());

      if (result is Map<String, dynamic> && result['status'] == 200) {
        final List<dynamic> billsList = result['data']['bills'] ?? [];
        final List<Bill> bills =
            billsList.map((json) => Bill.fromJson(json)).toList();

        return {
          'bills': bills,
          'total': result['data']['total'] ?? 0,
          'current_page': result['data']['current_page'] ?? 1,
          'last_page': result['data']['last_page'] ?? 1,
          'per_page': result['data']['per_page'] ?? perPage,
          'summary': result['data']['summary'] ?? {},
        };
      } else {
        throw Exception(result['message'] ?? 'Failed to fetch bills');
      }
    } catch (e) {
      Get.log("Error in getBillsWithPagination: $e");
      throw Exception('Failed to fetch bills: $e');
    }
  }

  Future<Bill> getBillDetails(String id) async {
    try {
      final dynamic result =
          await _httpClient.get('${ApiEndpoints.baseUrl}/accounting/bills/$id');

      if (result is Map<String, dynamic> && result['status'] == 200) {
        return Bill.fromJson(result['data']);
      } else {
        throw Exception(result['message'] ?? 'Failed to get bill details');
      }
    } catch (e) {
      Get.log("Error in getBillDetails: $e");
      throw Exception('Failed to get bill details: $e');
    }
  }

  Future<void> createBill(Map<String, dynamic> billData) async {
    try {
      final dynamic result = await _httpClient.post(
        '${ApiEndpoints.baseUrl}/accounting/bills',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(billData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 201 || result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Bill created successfully');
        } else {
          throw Exception(result['message'] ?? 'Failed to create bill');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in createBill: $e");
      throw Exception('Failed to create bill: $e');
    }
  }

  Future<void> updateBill(String id, Map<String, dynamic> billData) async {
    try {
      final dynamic result = await _httpClient.put(
        '${ApiEndpoints.baseUrl}/accounting/bills/$id',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(billData),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Bill updated successfully');
        } else {
          throw Exception(result['message'] ?? 'Failed to update bill');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in updateBill: $e");
      throw Exception('Failed to update bill: $e');
    }
  }

  Future<void> deleteBill(String id) async {
    try {
      final dynamic result = await _httpClient
          .delete('${ApiEndpoints.baseUrl}/accounting/bills/$id');

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar('Bill deleted successfully');
        } else {
          throw Exception(result['message'] ?? 'Failed to delete bill');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in deleteBill: $e");
      throw Exception('Failed to delete bill: $e');
    }
  }

  Future<void> updateBillStatus(String id, String status) async {
    try {
      final dynamic result = await _httpClient.patch(
        '${ApiEndpoints.baseUrl}/accounting/bills/$id/status',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );

      if (result is Map<String, dynamic>) {
        if (result['status'] == 200) {
          SnackBarUtils.showSuccessSnackBar(
              result['message'] ?? 'Bill status updated');
        } else {
          throw Exception(result['message'] ?? 'Failed to update bill status');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Get.log("Error in updateBillStatus: $e");
      throw Exception('Failed to update bill status: $e');
    }
  }

  // ========== DASHBOARD API ==========

  Future<Map<String, dynamic>> getAccountingDashboard() async {
    try {
      final dynamic result =
          await _httpClient.get('${ApiEndpoints.baseUrl}/accounting/dashboard');

      if (result is Map<String, dynamic> && result['status'] == 200) {
        return result['data'];
      } else {
        throw Exception(
            result['message'] ?? 'Failed to fetch accounting dashboard');
      }
    } catch (e) {
      Get.log("Error in getAccountingDashboard: $e");
      throw Exception('Failed to fetch accounting dashboard: $e');
    }
  }

  Future<Map<String, dynamic>> getFinancialOverview() async {
    try {
      final dynamic result = await _httpClient.get(
          '${ApiEndpoints.baseUrl}/accounting/dashboard/financial-overview');

      if (result is Map<String, dynamic> && result['status'] == 200) {
        return result['data'];
      } else {
        throw Exception(
            result['message'] ?? 'Failed to fetch financial overview');
      }
    } catch (e) {
      Get.log("Error in getFinancialOverview: $e");
      throw Exception('Failed to fetch financial overview: $e');
    }
  }
}
