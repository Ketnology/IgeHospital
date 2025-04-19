import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/provider/admin_service.dart';

class AdminPagination extends StatelessWidget {
  final ColourNotifier notifier;
  final AdminsService adminsService;
  final int totalPages;
  final int currentPage;
  final void Function(int) onPageChanged;

  const AdminPagination({
    super.key,
    required this.notifier,
    required this.adminsService,
    required this.totalPages,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
          () {
        final calculatedTotalPages = (adminsService.totalAdmins.value /
            adminsService.perPage.value)
            .ceil();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // First page button
              IconButton(
                icon: Icon(Icons.first_page,
                    color:
                    currentPage == 0 ? Colors.grey : notifier.getMainText),
                onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
              ),

              // Previous page button
              IconButton(
                icon: Icon(Icons.chevron_left,
                    color:
                    currentPage > 0 ? notifier.getMainText : Colors.grey),
                onPressed: currentPage > 0
                    ? () => onPageChanged(currentPage - 1)
                    : null,
              ),

              // Page counter
              Text(
                "Page ${currentPage + 1} of ${calculatedTotalPages > 0 ? calculatedTotalPages : 1}",
                style: TextStyle(fontSize: 14, color: notifier.getMainText),
              ),

              // Next page button
              IconButton(
                icon: Icon(Icons.chevron_right,
                    color: currentPage < calculatedTotalPages - 1
                        ? notifier.getMainText
                        : Colors.grey),
                onPressed: currentPage < calculatedTotalPages - 1
                    ? () => onPageChanged(currentPage + 1)
                    : null,
              ),

              // Last page button
              IconButton(
                icon: Icon(Icons.last_page,
                    color: currentPage < calculatedTotalPages - 1
                        ? notifier.getMainText
                        : Colors.grey),
                onPressed: currentPage < calculatedTotalPages - 1
                    ? () => onPageChanged(calculatedTotalPages - 1)
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}