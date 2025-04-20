import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/colors_provider.dart';

class GenericPagination extends StatelessWidget {
  final ColourNotifier notifier;
  final int totalItems;
  final int perPage;
  final int currentPage;
  final void Function(int) onPageChanged;

  const GenericPagination({
    super.key,
    required this.notifier,
    required this.totalItems,
    required this.perPage,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final calculatedTotalPages = (totalItems / perPage).ceil();
    final totalPages = calculatedTotalPages > 0 ? calculatedTotalPages : 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // First page button
          IconButton(
            icon: Icon(Icons.first_page,
                color: currentPage == 0 ? Colors.grey : notifier.getMainText),
            onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
          ),

          // Previous page button
          IconButton(
            icon: Icon(Icons.chevron_left,
                color: currentPage > 0 ? notifier.getMainText : Colors.grey),
            onPressed: currentPage > 0
                ? () => onPageChanged(currentPage - 1)
                : null,
          ),

          // Page counter
          Text(
            "Page ${currentPage + 1} of $totalPages",
            style: TextStyle(fontSize: 14, color: notifier.getMainText),
          ),

          // Next page button
          IconButton(
            icon: Icon(Icons.chevron_right,
                color: currentPage < totalPages - 1
                    ? notifier.getMainText
                    : Colors.grey),
            onPressed: currentPage < totalPages - 1
                ? () => onPageChanged(currentPage + 1)
                : null,
          ),

          // Last page button
          IconButton(
            icon: Icon(Icons.last_page,
                color: currentPage < totalPages - 1
                    ? notifier.getMainText
                    : Colors.grey),
            onPressed: currentPage < totalPages - 1
                ? () => onPageChanged(totalPages - 1)
                : null,
          ),
        ],
      ),
    );
  }
}