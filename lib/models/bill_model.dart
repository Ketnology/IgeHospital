class Bill {
  final String id;
  final String reference;
  final String billDate;
  final String amount;
  final String patientAdmissionId;
  final String status;
  final String paymentMode;
  final String createdAt;
  final String updatedAt;
  final Patient? patient;
  final List<BillItem> billItems;
  final String billDateFormatted;
  final String amountFormatted;
  final String amountCurrency;
  final String statusDisplay;
  final bool isPaid;
  final bool isPending;
  final bool isOverdue;

  Bill({
    required this.id,
    required this.reference,
    required this.billDate,
    required this.amount,
    required this.patientAdmissionId,
    required this.status,
    required this.paymentMode,
    required this.createdAt,
    required this.updatedAt,
    this.patient,
    this.billItems = const [],
    required this.billDateFormatted,
    required this.amountFormatted,
    required this.amountCurrency,
    required this.statusDisplay,
    required this.isPaid,
    required this.isPending,
    required this.isOverdue,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] ?? '',
      reference: json['reference'] ?? '',
      billDate: json['bill_date'] ?? '',
      amount: json['amount'] ?? '',
      patientAdmissionId: json['patient_admission_id'] ?? '',
      status: json['status'] ?? '',
      paymentMode: json['payment_mode'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      patient:
          json['patient'] != null ? Patient.fromJson(json['patient']) : null,
      billItems: json['bill_items'] != null
          ? (json['bill_items'] as List)
              .map((item) => BillItem.fromJson(item))
              .toList()
          : [],
      billDateFormatted: json['bill_date_formatted'] ?? '',
      amountFormatted: json['amount_formatted'] ?? '',
      amountCurrency: json['amount_currency'] ?? '',
      statusDisplay: json['status_display'] ?? '',
      isPaid: json['is_paid'] ?? false,
      isPending: json['is_pending'] ?? false,
      isOverdue: json['is_overdue'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patient?.id,
      'bill_date': billDate,
      'amount': double.tryParse(amount) ?? 0.0,
      'patient_admission_id': patientAdmissionId,
      'status': status,
      'payment_mode': paymentMode,
      'items': billItems.map((item) => item.toJson()).toList(),
    };
  }
}

class BillItem {
  final String id;
  final String itemName;
  final int qty;
  final String price;
  final String amount;
  final String createdAt;
  final String updatedAt;
  final String priceFormatted;
  final String amountFormatted;
  final String priceCurrency;
  final String amountCurrency;
  final double unitTotal;

  BillItem({
    required this.id,
    required this.itemName,
    required this.qty,
    required this.price,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
    required this.priceFormatted,
    required this.amountFormatted,
    required this.priceCurrency,
    required this.amountCurrency,
    required this.unitTotal,
  });

  factory BillItem.fromJson(Map<String, dynamic> json) {
    return BillItem(
      id: json['id'] ?? '',
      itemName: json['item_name'] ?? '',
      qty: json['qty'] ?? 0,
      price: json['price'] ?? '',
      amount: json['amount'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      priceFormatted: json['price_formatted'] ?? '',
      amountFormatted: json['amount_formatted'] ?? '',
      priceCurrency: json['price_currency'] ?? '',
      amountCurrency: json['amount_currency'] ?? '',
      unitTotal: (json['unit_total'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_name': itemName,
      'qty': qty,
      'price': double.tryParse(price) ?? 0.0,
    };
  }
}

class Patient {
  final String id;
  final String patientUniqueId;
  final String fullName;
  final String email;
  final String phone;

  Patient({
    required this.id,
    required this.patientUniqueId,
    required this.fullName,
    required this.email,
    required this.phone,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] ?? '',
      patientUniqueId: json['patient_unique_id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}
