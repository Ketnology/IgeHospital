import 'package:flutter/material.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';

/// Recent transactions list component
/// Follows Single Responsibility Principle - only responsible for displaying recent transactions
class RecentTransactionsList extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final ColourNotifier notifier;

  const RecentTransactionsList({
    super.key,
    required this.transactions,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: notifier.getContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: boxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: notifier.getIconColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Recent Transactions',
                      style: mainTextStyle.copyWith(
                        color: notifier.getMainText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full transactions list
                  },
                  child: Text(
                    'View All',
                    style: mediumBlackTextStyle.copyWith(
                      color: notifier.getIconColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Transactions list
          if (transactions.isEmpty)
            _buildEmptyState()
          else
            _buildTransactionsList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: notifier.getMaingey,
            ),
            const SizedBox(height: 16),
            Text(
              'No recent transactions',
              style: mediumBlackTextStyle.copyWith(
                color: notifier.getMainText,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Transactions will appear here once created',
              style: mediumGreyTextStyle.copyWith(
                color: notifier.getMaingey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Column(
      children: [
        // Table header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: notifier.getBgColor,
            border: Border(
              top: BorderSide(color: notifier.getBorderColor),
              bottom: BorderSide(color: notifier.getBorderColor),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Description',
                  style: mediumBlackTextStyle.copyWith(
                    color: notifier.getMainText,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Type',
                  style: mediumBlackTextStyle.copyWith(
                    color: notifier.getMainText,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Amount',
                  style: mediumBlackTextStyle.copyWith(
                    color: notifier.getMainText,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 60), // For date column
            ],
          ),
        ),

        // Transaction items
        ...transactions
            .take(5)
            .map((transaction) => _buildTransactionItem(transaction)),

        // Show more button if there are more transactions
        if (transactions.length > 5)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: TextButton(
                onPressed: () {
                  // Navigate to full transactions list
                },
                child: Text(
                  'Show ${transactions.length - 5} more transactions',
                  style: mediumBlackTextStyle.copyWith(
                    color: notifier.getIconColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final String description =
        transaction['description'] ?? 'Unknown Transaction';
    final String type = transaction['type'] ?? 'payment';
    final dynamic amount = transaction['amount'] ?? 0;
    final String date = transaction['date'] ?? transaction['created_at'] ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: notifier.getBorderColor.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          // Transaction icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getTransactionTypeColor(type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTransactionTypeIcon(type),
              color: _getTransactionTypeColor(type),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),

          // Description
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: mediumBlackTextStyle.copyWith(
                    color: notifier.getMainText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (date.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(date),
                    style: mediumGreyTextStyle.copyWith(
                      color: notifier.getMaingey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Type
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getTransactionTypeColor(type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                type.toUpperCase(),
                style: mediumBlackTextStyle.copyWith(
                  color: _getTransactionTypeColor(type),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Amount
          Expanded(
            child: Text(
              _formatCurrency(amount),
              style: mediumBlackTextStyle.copyWith(
                color: _getAmountColor(type),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTransactionTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'payment':
        return Colors.blue;
      case 'bill':
        return Colors.green;
      case 'expense':
        return Colors.red;
      case 'revenue':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getTransactionTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'payment':
        return Icons.payment;
      case 'bill':
        return Icons.receipt;
      case 'expense':
        return Icons.trending_down;
      case 'revenue':
        return Icons.trending_up;
      default:
        return Icons.account_balance;
    }
  }

  Color _getAmountColor(String type) {
    switch (type.toLowerCase()) {
      case 'expense':
        return Colors.red;
      case 'revenue':
      case 'bill':
        return Colors.green;
      default:
        return notifier.getMainText;
    }
  }

  String _formatCurrency(dynamic amount) {
    try {
      final double value = double.parse(amount.toString());
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
