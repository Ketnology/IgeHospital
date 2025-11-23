import 'package:flutter_test/flutter_test.dart';
import 'package:ige_hospital/models/bill_model.dart';

void main() {
  group('Bill', () {
    group('fromJson', () {
      test('should parse valid JSON correctly', () {
        final json = {
          'id': 'bill1',
          'reference': 'BILL-2024-001',
          'bill_date': '2024-01-15',
          'amount': '1500.00',
          'patient_admission_id': 'adm1',
          'status': 'paid',
          'payment_mode': 'credit_card',
          'created_at': '2024-01-15 10:00:00',
          'updated_at': '2024-01-15 12:00:00',
          'patient': {
            'id': 'p1',
            'patient_unique_id': 'PAT001',
            'full_name': 'John Doe',
            'email': 'john@example.com',
            'phone': '1234567890'
          },
          'bill_items': [
            {
              'id': 'item1',
              'item_name': 'Consultation',
              'qty': 1,
              'price': '500.00',
              'amount': '500.00',
              'created_at': '',
              'updated_at': '',
              'price_formatted': '\$500.00',
              'amount_formatted': '\$500.00',
              'price_currency': 'USD',
              'amount_currency': 'USD',
              'unit_total': 500.0
            },
            {
              'id': 'item2',
              'item_name': 'Lab Tests',
              'qty': 2,
              'price': '250.00',
              'amount': '500.00',
              'created_at': '',
              'updated_at': '',
              'price_formatted': '\$250.00',
              'amount_formatted': '\$500.00',
              'price_currency': 'USD',
              'amount_currency': 'USD',
              'unit_total': 500.0
            }
          ],
          'bill_date_formatted': 'Jan 15, 2024',
          'amount_formatted': '\$1,500.00',
          'amount_currency': 'USD',
          'status_display': 'Paid',
          'is_paid': true,
          'is_pending': false,
          'is_overdue': false
        };

        final bill = Bill.fromJson(json);

        expect(bill.id, equals('bill1'));
        expect(bill.reference, equals('BILL-2024-001'));
        expect(bill.billDate, equals('2024-01-15'));
        expect(bill.amount, equals('1500.00'));
        expect(bill.patientAdmissionId, equals('adm1'));
        expect(bill.status, equals('paid'));
        expect(bill.paymentMode, equals('credit_card'));
        expect(bill.patient, isNotNull);
        expect(bill.patient!.fullName, equals('John Doe'));
        expect(bill.billItems.length, equals(2));
        expect(bill.billItems[0].itemName, equals('Consultation'));
        expect(bill.billItems[1].itemName, equals('Lab Tests'));
        expect(bill.billDateFormatted, equals('Jan 15, 2024'));
        expect(bill.amountFormatted, equals('\$1,500.00'));
        expect(bill.statusDisplay, equals('Paid'));
        expect(bill.isPaid, isTrue);
        expect(bill.isPending, isFalse);
        expect(bill.isOverdue, isFalse);
      });

      test('should handle pending bill', () {
        final json = {
          'id': 'bill1',
          'status': 'pending',
          'is_paid': false,
          'is_pending': true,
          'is_overdue': false
        };

        final bill = Bill.fromJson(json);

        expect(bill.isPaid, isFalse);
        expect(bill.isPending, isTrue);
        expect(bill.isOverdue, isFalse);
      });

      test('should handle overdue bill', () {
        final json = {
          'id': 'bill1',
          'status': 'overdue',
          'is_paid': false,
          'is_pending': false,
          'is_overdue': true
        };

        final bill = Bill.fromJson(json);

        expect(bill.isPaid, isFalse);
        expect(bill.isPending, isFalse);
        expect(bill.isOverdue, isTrue);
      });

      test('should handle null patient', () {
        final json = {
          'id': 'bill1',
          'patient': null,
          'bill_items': null
        };

        final bill = Bill.fromJson(json);

        expect(bill.patient, isNull);
        expect(bill.billItems, isEmpty);
      });

      test('should handle missing fields', () {
        final json = <String, dynamic>{};

        final bill = Bill.fromJson(json);

        expect(bill.id, equals(''));
        expect(bill.reference, equals(''));
        expect(bill.billDate, equals(''));
        expect(bill.amount, equals(''));
        expect(bill.status, equals(''));
        expect(bill.isPaid, isFalse);
        expect(bill.isPending, isFalse);
        expect(bill.isOverdue, isFalse);
      });
    });

    group('toJson', () {
      test('should convert model to JSON correctly', () {
        final patient = Patient(
          id: 'p1',
          patientUniqueId: 'PAT001',
          fullName: 'John Doe',
          email: 'john@example.com',
          phone: '1234567890',
        );

        final billItems = [
          BillItem(
            id: 'item1',
            itemName: 'Consultation',
            qty: 1,
            price: '500.00',
            amount: '500.00',
            createdAt: '',
            updatedAt: '',
            priceFormatted: '',
            amountFormatted: '',
            priceCurrency: '',
            amountCurrency: '',
            unitTotal: 500.0,
          )
        ];

        final bill = Bill(
          id: 'bill1',
          reference: 'BILL-001',
          billDate: '2024-01-15',
          amount: '500.00',
          patientAdmissionId: '',
          status: 'pending',
          paymentMode: 'cash',
          createdAt: '',
          updatedAt: '',
          patient: patient,
          billItems: billItems,
          billDateFormatted: '',
          amountFormatted: '',
          amountCurrency: '',
          statusDisplay: '',
          isPaid: false,
          isPending: true,
          isOverdue: false,
        );

        final json = bill.toJson();

        expect(json['patient_id'], equals('p1'));
        expect(json['bill_date'], equals('2024-01-15'));
        expect(json['amount'], equals(500.0));
        expect(json['status'], equals('pending'));
        expect(json['payment_mode'], equals('cash'));
        expect(json['items'], isA<List>());
        expect(json['items'].length, equals(1));
      });

      test('should handle invalid amount string', () {
        final bill = Bill(
          id: 'bill1',
          reference: 'BILL-001',
          billDate: '2024-01-15',
          amount: 'invalid',
          patientAdmissionId: '',
          status: 'pending',
          paymentMode: 'cash',
          createdAt: '',
          updatedAt: '',
          billDateFormatted: '',
          amountFormatted: '',
          amountCurrency: '',
          statusDisplay: '',
          isPaid: false,
          isPending: true,
          isOverdue: false,
        );

        final json = bill.toJson();

        expect(json['amount'], equals(0.0));
      });
    });
  });

  group('BillItem', () {
    group('fromJson', () {
      test('should parse valid JSON correctly', () {
        final json = {
          'id': 'item1',
          'item_name': 'X-Ray',
          'qty': 2,
          'price': '150.00',
          'amount': '300.00',
          'created_at': '2024-01-15 10:00:00',
          'updated_at': '2024-01-15 10:00:00',
          'price_formatted': '\$150.00',
          'amount_formatted': '\$300.00',
          'price_currency': 'USD',
          'amount_currency': 'USD',
          'unit_total': 300.0
        };

        final item = BillItem.fromJson(json);

        expect(item.id, equals('item1'));
        expect(item.itemName, equals('X-Ray'));
        expect(item.qty, equals(2));
        expect(item.price, equals('150.00'));
        expect(item.amount, equals('300.00'));
        expect(item.priceFormatted, equals('\$150.00'));
        expect(item.amountFormatted, equals('\$300.00'));
        expect(item.priceCurrency, equals('USD'));
        expect(item.unitTotal, equals(300.0));
      });

      test('should handle missing fields', () {
        final json = <String, dynamic>{};

        final item = BillItem.fromJson(json);

        expect(item.id, equals(''));
        expect(item.itemName, equals(''));
        expect(item.qty, equals(0));
        expect(item.price, equals(''));
        expect(item.amount, equals(''));
        expect(item.unitTotal, equals(0.0));
      });
    });

    group('toJson', () {
      test('should convert model to JSON correctly', () {
        final item = BillItem(
          id: 'item1',
          itemName: 'Blood Test',
          qty: 3,
          price: '75.00',
          amount: '225.00',
          createdAt: '',
          updatedAt: '',
          priceFormatted: '',
          amountFormatted: '',
          priceCurrency: '',
          amountCurrency: '',
          unitTotal: 225.0,
        );

        final json = item.toJson();

        expect(json['item_name'], equals('Blood Test'));
        expect(json['qty'], equals(3));
        expect(json['price'], equals(75.0));
      });

      test('should handle invalid price string', () {
        final item = BillItem(
          id: 'item1',
          itemName: 'Test',
          qty: 1,
          price: 'invalid',
          amount: '',
          createdAt: '',
          updatedAt: '',
          priceFormatted: '',
          amountFormatted: '',
          priceCurrency: '',
          amountCurrency: '',
          unitTotal: 0.0,
        );

        final json = item.toJson();

        expect(json['price'], equals(0.0));
      });
    });
  });

  group('Patient (Bill)', () {
    test('fromJson should parse correctly', () {
      final json = {
        'id': 'p1',
        'patient_unique_id': 'PAT001',
        'full_name': 'Jane Doe',
        'email': 'jane@example.com',
        'phone': '9876543210'
      };

      final patient = Patient.fromJson(json);

      expect(patient.id, equals('p1'));
      expect(patient.patientUniqueId, equals('PAT001'));
      expect(patient.fullName, equals('Jane Doe'));
      expect(patient.email, equals('jane@example.com'));
      expect(patient.phone, equals('9876543210'));
    });

    test('fromJson should handle missing fields', () {
      final json = <String, dynamic>{};

      final patient = Patient.fromJson(json);

      expect(patient.id, equals(''));
      expect(patient.patientUniqueId, equals(''));
      expect(patient.fullName, equals(''));
      expect(patient.email, equals(''));
      expect(patient.phone, equals(''));
    });
  });
}
