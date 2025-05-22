class Account {
  final String id;
  final String name;
  final String type;
  final String description;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String typeDisplay;
  final String statusDisplay;
  final bool isActive;
  final double totalPaymentsAmount;
  final List<Payment> payments;

  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.typeDisplay,
    required this.statusDisplay,
    required this.isActive,
    this.totalPaymentsAmount = 0.0,
    this.payments = const [],
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      typeDisplay: json['type_display'] ?? '',
      statusDisplay: json['status_display'] ?? '',
      isActive: json['is_active'] ?? false,
      totalPaymentsAmount:
          double.tryParse(json['total_payments_amount']?.toString() ?? '0') ??
              0.0,
      payments: json['payments'] != null
          ? (json['payments'] as List).map((p) => Payment.fromJson(p)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'description': description,
      'status': status,
    };
  }
}

class Payment {
  final String id;
  final String paymentDate;
  final String payTo;
  final String amount;
  final String description;
  final String createdAt;
  final String updatedAt;
  final Account? account;
  final String paymentDateFormatted;
  final String amountFormatted;
  final String amountCurrency;
  final String createdAtHuman;
  final String paymentDateHuman;

  Payment({
    required this.id,
    required this.paymentDate,
    required this.payTo,
    required this.amount,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.account,
    required this.paymentDateFormatted,
    required this.amountFormatted,
    required this.amountCurrency,
    required this.createdAtHuman,
    required this.paymentDateHuman,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? '',
      paymentDate: json['payment_date'] ?? '',
      payTo: json['pay_to'] ?? '',
      amount: json['amount'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      account:
          json['account'] != null ? Account.fromJson(json['account']) : null,
      paymentDateFormatted: json['payment_date_formatted'] ?? '',
      amountFormatted: json['amount_formatted'] ?? '',
      amountCurrency: json['amount_currency'] ?? '',
      createdAtHuman: json['created_at_human'] ?? '',
      paymentDateHuman: json['payment_date_human'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_date': paymentDate,
      'account_id': account?.id,
      'pay_to': payTo,
      'amount': double.tryParse(amount) ?? 0.0,
      'description': description,
    };
  }
}
