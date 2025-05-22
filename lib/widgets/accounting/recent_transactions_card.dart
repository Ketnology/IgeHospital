import 'package:flutter/material.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';

class RecentTransactionsCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> transactions;

  const RecentTransactionsCard({
    super.key,
    required this.title,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Container(
      height: 400,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: notifier.getContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: boxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: mainTextStyle.copyWith(
                  color: notifier.getMainText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: appMainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.history,
                  color: appMainColor,
                  size: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Transactions List
          Expanded(
            child: transactions.isEmpty
                ? _buildEmptyState(notifier)
                : ListView.separated(
                    itemCount: transactions.length,
                    separatorBuilder: (context, index) => Divider(
                      color: notifier.getBorderColor.withOpacity(0.3),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return _buildTransactionItem(transaction, notifier);
                    },
                  ),
          ),

          // View All Button
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {
                // Navigate to full transactions page
              },
              child: Text(
                'View All',
                style: mediumBlackTextStyle.copyWith(
                  color: appMainColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColourNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 48,
            color: notifier.getMaingey,
          ),
          const SizedBox(height: 12),
          Text(
            'No recent transactions',
            style: mediumGreyTextStyle.copyWith(
              color: notifier.getMaingey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
      Map<String, dynamic> transaction, ColourNotifier notifier) {
    final String name = transaction['name']?.toString() ??
        transaction['pay_to']?.toString() ??
        transaction['patient_name']?.toString() ??
        'Unknown';

    final String amount = transaction['amount']?.toString() ?? '0';
    final String date = transaction['date']?.toString() ??
        transaction['created_at']?.toString() ??
        'Unknown date';

    final String type = transaction['type']?.toString() ??
        (title.toLowerCase().contains('payment') ? 'payment' : 'bill');

    final String status = transaction['status']?.toString() ?? 'completed';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Transaction Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getTransactionColor(type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTransactionIcon(type),
              color: _getTransactionColor(type),
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // Transaction Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: mediumBlackTextStyle.copyWith(
                    color: notifier.getMainText,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: mediumGreyTextStyle.copyWith(
                          color: _getStatusColor(status),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(date),
                      style: mediumGreyTextStyle.copyWith(
                        color: notifier.getMaingey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(amount),
                style: mediumBlackTextStyle.copyWith(
                  color: notifier.getMainText,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                type.toUpperCase(),
                style: mediumGreyTextStyle.copyWith(
                  color: _getTransactionColor(type),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTransactionColor(String type) {
    switch (type.toLowerCase()) {
      case 'payment':
        return Colors.green;
      case 'bill':
        return Colors.blue;
      case 'expense':
        return Colors.red;
      default:
        return appMainColor;
    }
  }

  IconData _getTransactionIcon(String type) {
    switch (type.toLowerCase()) {
      case 'payment':
        return Icons.payment;
      case 'bill':
        return Icons.receipt_long;
      case 'expense':
        return Icons.trending_down;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'unpaid':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _formatCurrency(String amount) {
    try {
      final double value = double.parse(amount);
      return '₦${value.toStringAsFixed(2)}';
    } catch (e) {
      return '₦0.00';
    }
  }

  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }
}
