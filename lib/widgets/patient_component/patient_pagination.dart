import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/patient_controller.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:provider/provider.dart';

class PatientPagination extends StatelessWidget {
  final PatientController controller;

  const PatientPagination({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);
    final isMobile = MediaQuery.of(context).size.width < 768;
    final isTablet = MediaQuery.of(context).size.width >= 768 &&
        MediaQuery.of(context).size.width < 1024;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Obx(() {
      final totalPages = (controller.totalPatients.value / controller.perPage.value).ceil();

      if (totalPages <= 1) return const SizedBox.shrink();

      if (isMobile) {
        return _buildMobilePagination(notifier, totalPages);
      } else if (isTablet) {
        return _buildTabletPagination(notifier, totalPages);
      } else {
        return _buildDesktopPagination(notifier, totalPages);
      }
    });
  }

  Widget _buildMobilePagination(ColourNotifier notifier, int totalPages) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Current page indicator
          Text(
            "Page ${controller.currentPage.value} of $totalPages",
            style: TextStyle(
              fontSize: 14,
              color: notifier.getMainText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous button
              _buildNavButton(
                icon: Icons.chevron_left,
                isEnabled: controller.currentPage.value > 1,
                onPressed: () => controller.previousPage(),
                notifier: notifier,
                isMobile: true,
              ),

              // Current page number
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: notifier.getIconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${controller.currentPage.value}",
                  style: TextStyle(
                    color: notifier.getIconColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              // Next button
              _buildNavButton(
                icon: Icons.chevron_right,
                isEnabled: controller.currentPage.value < totalPages,
                onPressed: () => controller.nextPage(),
                notifier: notifier,
                isMobile: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabletPagination(ColourNotifier notifier, int totalPages) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          _buildNavButton(
            icon: Icons.chevron_left,
            label: "Prev",
            isEnabled: controller.currentPage.value > 1,
            onPressed: () => controller.previousPage(),
            notifier: notifier,
          ),

          const SizedBox(width: 20),

          // Page counter
          Text(
            "Page ${controller.currentPage.value} of $totalPages",
            style: TextStyle(
              fontSize: 14,
              color: notifier.getMainText,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(width: 20),

          // Next button
          _buildNavButton(
            icon: Icons.chevron_right,
            label: "Next",
            isEnabled: controller.currentPage.value < totalPages,
            onPressed: () => controller.nextPage(),
            notifier: notifier,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopPagination(ColourNotifier notifier, int totalPages) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // First page button
          _buildPageButton(
            icon: Icons.first_page,
            isEnabled: controller.currentPage.value > 1,
            onPressed: () => controller.setPage(1),
            notifier: notifier,
          ),

          // Previous page button
          _buildPageButton(
            icon: Icons.chevron_left,
            isEnabled: controller.currentPage.value > 1,
            onPressed: () => controller.previousPage(),
            notifier: notifier,
          ),

          // Page numbers with ellipsis
          ...buildPageNumbers(notifier, totalPages),

          // Next page button
          _buildPageButton(
            icon: Icons.chevron_right,
            isEnabled: controller.currentPage.value < totalPages,
            onPressed: () => controller.nextPage(),
            notifier: notifier,
          ),

          // Last page button
          _buildPageButton(
            icon: Icons.last_page,
            isEnabled: controller.currentPage.value < totalPages,
            onPressed: () => controller.setPage(totalPages),
            notifier: notifier,
          ),
        ],
      ),
    );
  }

  List<Widget> buildPageNumbers(ColourNotifier notifier, int totalPages) {
    List<Widget> pages = [];
    int currentPage = controller.currentPage.value;

    // Always show first page
    pages.add(_buildPageButton(
      pageNumber: 1,
      isSelected: currentPage == 1,
      notifier: notifier,
    ));

    // Show ellipsis if needed
    if (currentPage > 4) {
      pages.add(_buildEllipsis(notifier));
    }

    // Show pages around current page
    int start = (currentPage - 2).clamp(2, totalPages - 1);
    int end = (currentPage + 2).clamp(2, totalPages - 1);

    for (int i = start; i <= end; i++) {
      pages.add(_buildPageButton(
        pageNumber: i,
        isSelected: currentPage == i,
        notifier: notifier,
      ));
    }

    // Show ellipsis if needed
    if (currentPage < totalPages - 3) {
      pages.add(_buildEllipsis(notifier));
    }

    // Always show last page if more than 1 page
    if (totalPages > 1) {
      pages.add(_buildPageButton(
        pageNumber: totalPages,
        isSelected: currentPage == totalPages,
        notifier: notifier,
      ));
    }

    return pages;
  }

  Widget _buildNavButton({
    required IconData icon,
    String? label,
    required bool isEnabled,
    required VoidCallback onPressed,
    required ColourNotifier notifier,
    bool isMobile = false,
  }) {
    return InkWell(
      onTap: isEnabled ? onPressed : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 8 : 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isEnabled
                ? notifier.getBorderColor
                : notifier.getBorderColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isEnabled
                  ? notifier.getMainText
                  : notifier.getMaingey,
              size: isMobile ? 20 : 18,
            ),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isEnabled
                      ? notifier.getMainText
                      : notifier.getMaingey,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPageButton({
    int? pageNumber,
    IconData? icon,
    bool isSelected = false,
    bool isEnabled = true,
    VoidCallback? onPressed,
    required ColourNotifier notifier,
  }) {
    final onTap = onPressed ?? (pageNumber != null ? () => controller.setPage(pageNumber) : null);

    return InkWell(
      onTap: isEnabled && !isSelected ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? notifier.getIconColor
              : notifier.getContainer,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? notifier.getIconColor
                : isEnabled
                ? notifier.getBorderColor
                : notifier.getBorderColor.withOpacity(0.3),
          ),
        ),
        child: icon != null
            ? Icon(
          icon,
          color: isEnabled
              ? (isSelected ? Colors.white : notifier.getMainText)
              : notifier.getMaingey,
          size: 18,
        )
            : Text(
          "$pageNumber",
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isEnabled ? notifier.getMainText : notifier.getMaingey),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis(ColourNotifier notifier) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        "...",
        style: TextStyle(
          color: notifier.getMainText,
          fontSize: 14,
        ),
      ),
    );
  }
}