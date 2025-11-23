import 'package:flutter_test/flutter_test.dart';
import 'package:ige_hospital/models/account_model.dart';

void main() {
  group('Account', () {
    group('fromJson', () {
      test('should parse valid JSON correctly', () {
        final json = {
          'id': 'acc1',
          'name': 'Operating Account',
          'type': 'operating',
          'description': 'Main operating account for hospital',
          'status': 'active',
          'created_at': '2024-01-01 00:00:00',
          'updated_at': '2024-01-02 00:00:00',
          'type_display': 'Operating',
          'status_display': 'Active',
          'is_active': true,
          'total_payments_amount': '15000.50',
          'payments': [
            {
              'id': 'pay1',
              'payment_date': '2024-01-15',
              'pay_to': 'Vendor XYZ',
              'amount': '500.00',
              'description': 'Medical supplies',
              'created_at': '2024-01-15 00:00:00',
              'updated_at': '2024-01-15 00:00:00',
              'payment_date_formatted': 'Jan 15, 2024',
              'amount_formatted': '\$500.00',
              'amount_currency': 'USD',
              'created_at_human': '5 days ago',
              'payment_date_human': 'Last week'
            }
          ]
        };

        final account = Account.fromJson(json);

        expect(account.id, equals('acc1'));
        expect(account.name, equals('Operating Account'));
        expect(account.type, equals('operating'));
        expect(account.description, equals('Main operating account for hospital'));
        expect(account.status, equals('active'));
        expect(account.createdAt, equals('2024-01-01 00:00:00'));
        expect(account.updatedAt, equals('2024-01-02 00:00:00'));
        expect(account.typeDisplay, equals('Operating'));
        expect(account.statusDisplay, equals('Active'));
        expect(account.isActive, isTrue);
        expect(account.totalPaymentsAmount, equals(15000.50));
        expect(account.payments.length, equals(1));
        expect(account.payments.first.id, equals('pay1'));
      });

      test('should handle numeric total_payments_amount', () {
        final json = {
          'id': 'acc1',
          'total_payments_amount': 5000.00
        };

        final account = Account.fromJson(json);

        expect(account.totalPaymentsAmount, equals(5000.00));
      });

      test('should handle null and missing fields', () {
        final json = <String, dynamic>{};

        final account = Account.fromJson(json);

        expect(account.id, equals(''));
        expect(account.name, equals(''));
        expect(account.type, equals(''));
        expect(account.description, equals(''));
        expect(account.status, equals(''));
        expect(account.isActive, isFalse);
        expect(account.totalPaymentsAmount, equals(0.0));
        expect(account.payments, isEmpty);
      });

      test('should handle null payments array', () {
        final json = {
          'id': 'acc1',
          'payments': null
        };

        final account = Account.fromJson(json);

        expect(account.payments, isEmpty);
      });

      test('should handle invalid total_payments_amount', () {
        final json = {
          'id': 'acc1',
          'total_payments_amount': 'invalid'
        };

        final account = Account.fromJson(json);

        expect(account.totalPaymentsAmount, equals(0.0));
      });
    });

    group('toJson', () {
      test('should convert model to JSON correctly', () {
        final account = Account(
          id: 'acc1',
          name: 'Savings Account',
          type: 'savings',
          description: 'Hospital savings',
          status: 'active',
          createdAt: '2024-01-01',
          updatedAt: '2024-01-02',
          typeDisplay: 'Savings',
          statusDisplay: 'Active',
          isActive: true,
          totalPaymentsAmount: 10000.0,
          payments: [],
        );

        final json = account.toJson();

        expect(json['name'], equals('Savings Account'));
        expect(json['type'], equals('savings'));
        expect(json['description'], equals('Hospital savings'));
        expect(json['status'], equals('active'));
        // Note: toJson only includes editable fields
        expect(json.containsKey('id'), isFalse);
        expect(json.containsKey('payments'), isFalse);
      });
    });
  });

  group('Payment', () {
    group('fromJson', () {
      test('should parse valid JSON correctly', () {
        final json = {
          'id': 'pay1',
          'payment_date': '2024-01-15',
          'pay_to': 'Medical Supplier Inc.',
          'amount': '2500.00',
          'description': 'Monthly medical supplies',
          'created_at': '2024-01-15 10:00:00',
          'updated_at': '2024-01-15 10:00:00',
          'account': {
            'id': 'acc1',
            'name': 'Operating Account',
            'type': 'operating',
            'description': '',
            'status': 'active',
            'created_at': '',
            'updated_at': '',
            'type_display': 'Operating',
            'status_display': 'Active',
            'is_active': true
          },
          'payment_date_formatted': 'Jan 15, 2024',
          'amount_formatted': '\$2,500.00',
          'amount_currency': 'USD',
          'created_at_human': 'Today',
          'payment_date_human': 'Today'
        };

        final payment = Payment.fromJson(json);

        expect(payment.id, equals('pay1'));
        expect(payment.paymentDate, equals('2024-01-15'));
        expect(payment.payTo, equals('Medical Supplier Inc.'));
        expect(payment.amount, equals('2500.00'));
        expect(payment.description, equals('Monthly medical supplies'));
        expect(payment.createdAt, equals('2024-01-15 10:00:00'));
        expect(payment.account, isNotNull);
        expect(payment.account!.id, equals('acc1'));
        expect(payment.paymentDateFormatted, equals('Jan 15, 2024'));
        expect(payment.amountFormatted, equals('\$2,500.00'));
        expect(payment.amountCurrency, equals('USD'));
        expect(payment.createdAtHuman, equals('Today'));
        expect(payment.paymentDateHuman, equals('Today'));
      });

      test('should handle null account', () {
        final json = {
          'id': 'pay1',
          'payment_date': '2024-01-15',
          'pay_to': 'Vendor',
          'amount': '100.00',
          'description': 'Test payment',
          'created_at': '',
          'updated_at': '',
          'account': null,
          'payment_date_formatted': '',
          'amount_formatted': '',
          'amount_currency': '',
          'created_at_human': '',
          'payment_date_human': ''
        };

        final payment = Payment.fromJson(json);

        expect(payment.account, isNull);
      });

      test('should handle missing fields', () {
        final json = <String, dynamic>{};

        final payment = Payment.fromJson(json);

        expect(payment.id, equals(''));
        expect(payment.paymentDate, equals(''));
        expect(payment.payTo, equals(''));
        expect(payment.amount, equals(''));
        expect(payment.description, equals(''));
        expect(payment.account, isNull);
        expect(payment.paymentDateFormatted, equals(''));
        expect(payment.amountFormatted, equals(''));
      });
    });

    group('toJson', () {
      test('should convert model to JSON correctly', () {
        final account = Account(
          id: 'acc1',
          name: 'Test Account',
          type: 'operating',
          description: '',
          status: 'active',
          createdAt: '',
          updatedAt: '',
          typeDisplay: '',
          statusDisplay: '',
          isActive: true,
        );

        final payment = Payment(
          id: 'pay1',
          paymentDate: '2024-01-15',
          payTo: 'Test Vendor',
          amount: '1500.00',
          description: 'Test payment description',
          createdAt: '',
          updatedAt: '',
          account: account,
          paymentDateFormatted: '',
          amountFormatted: '',
          amountCurrency: '',
          createdAtHuman: '',
          paymentDateHuman: '',
        );

        final json = payment.toJson();

        expect(json['payment_date'], equals('2024-01-15'));
        expect(json['account_id'], equals('acc1'));
        expect(json['pay_to'], equals('Test Vendor'));
        expect(json['amount'], equals(1500.0));
        expect(json['description'], equals('Test payment description'));
      });

      test('should handle null account in toJson', () {
        final payment = Payment(
          id: 'pay1',
          paymentDate: '2024-01-15',
          payTo: 'Vendor',
          amount: '100.00',
          description: 'Test',
          createdAt: '',
          updatedAt: '',
          account: null,
          paymentDateFormatted: '',
          amountFormatted: '',
          amountCurrency: '',
          createdAtHuman: '',
          paymentDateHuman: '',
        );

        final json = payment.toJson();

        expect(json['account_id'], isNull);
      });

      test('should handle invalid amount string in toJson', () {
        final payment = Payment(
          id: 'pay1',
          paymentDate: '2024-01-15',
          payTo: 'Vendor',
          amount: 'invalid',
          description: 'Test',
          createdAt: '',
          updatedAt: '',
          account: null,
          paymentDateFormatted: '',
          amountFormatted: '',
          amountCurrency: '',
          createdAtHuman: '',
          paymentDateHuman: '',
        );

        final json = payment.toJson();

        expect(json['amount'], equals(0.0));
      });
    });
  });
}
