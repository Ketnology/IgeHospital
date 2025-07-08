import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/consultation_controller.dart';
import 'package:ige_hospital/models/consultation_model.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/widgets/common_title.dart';
import 'package:ige_hospital/widgets/consultation_card.dart';
import 'package:ige_hospital/widgets/consultation_filters.dart';
import 'package:ige_hospital/widgets/consultation_form_dialog.dart';
import 'package:ige_hospital/widgets/consultation_detail_dialog.dart';
import 'package:provider/provider.dart';

class LiveConsultationsPage extends StatefulWidget {
  const LiveConsultationsPage({super.key});

  @override
  State<LiveConsultationsPage> createState() => _LiveConsultationsPageState();
}

class _LiveConsultationsPageState extends State<LiveConsultationsPage> {
  bool _showFilters = false;
  static final ConsultationController controller = Get.put(ConsultationController());

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Scaffold(
      backgroundColor: notifier.getBgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommonTitle(title: 'Live Consultations', path: "Medical Services"),
            _buildPageTopBar(context, notifier),
            if (_showFilters) const ConsultationFilters(initiallyExpanded: true),
            _buildConsultationsList(notifier),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: notifier.getIconColor,
        onPressed: () {
          _showCreateConsultationDialog(context);
        },
        child: Icon(
          Icons.add,
          color: notifier.getBgColor,
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ColourNotifier notifier,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifier.getContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifier.getBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: notifier.getMainText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: notifier.getMaingey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageTopBar(BuildContext context, ColourNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // Quick actions
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                icon: Icon(
                  _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
                  color: notifier.getIconColor,
                ),
                tooltip: _showFilters ? 'Hide filters' : 'Show filters',
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  controller.loadConsultations();
                  controller.loadUpcomingConsultations();
                  controller.loadTodaysConsultations();
                  controller.loadStatistics();
                },
                icon: Icon(Icons.refresh, color: notifier.getIconColor),
                tooltip: 'Refresh',
              ),
            ],
          ),

          const Spacer(),

          // Page info and actions
          Row(
            children: [
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: notifier.getIconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  controller.pageInfo,
                  style: TextStyle(
                    color: notifier.getIconColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showCreateConsultationDialog(context),
                icon: SvgPicture.asset(
                  "assets/plus-circle.svg",
                  color: Colors.white,
                  width: 16,
                  height: 16,
                ),
                label: const Text(
                  "New Consultation",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: appMainColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationsList(ColourNotifier notifier) {
    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: notifier.getIconColor),
                const SizedBox(height: 16),
                Text(
                  'Loading consultations...',
                  style: TextStyle(
                    color: notifier.getMaingey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.filteredConsultations.isEmpty) {
          return _buildEmptyState(notifier);
        }

        return Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 1400) {
                    return _buildGridView(4, notifier);
                  } else if (constraints.maxWidth > 1000) {
                    return _buildGridView(3, notifier);
                  } else if (constraints.maxWidth > 700) {
                    return _buildGridView(2, notifier);
                  } else {
                    return _buildListView(notifier);
                  }
                },
              ),
            ),
            _buildPagination(notifier),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState(ColourNotifier notifier) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: notifier.getIconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.video_call_outlined,
                size: 64,
                color: notifier.getIconColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No consultations found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: notifier.getMainText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or create a new consultation',
              style: TextStyle(
                color: notifier.getMaingey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => controller.resetFilters(),
                  icon: Icon(Icons.refresh, color: notifier.getIconColor),
                  label: Text(
                    'Reset Filters',
                    style: TextStyle(color: notifier.getIconColor),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: notifier.getIconColor),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showCreateConsultationDialog(context),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Create Consultation',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appMainColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(int crossAxisCount, ColourNotifier notifier) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: crossAxisCount > 2 ? 1.2 : 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: controller.filteredConsultations.length,
      itemBuilder: (context, index) {
        final consultation = controller.filteredConsultations[index];
        return _buildConsultationCard(consultation, notifier);
      },
    );
  }

  Widget _buildListView(ColourNotifier notifier) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: controller.filteredConsultations.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final consultation = controller.filteredConsultations[index];
        return _buildConsultationCard(consultation, notifier, isListView: true);
      },
    );
  }

  Widget _buildConsultationCard(LiveConsultation consultation, ColourNotifier notifier, {bool isListView = false}) {
    return ConsultationCard(
      consultation: consultation,
      isCompact: !isListView,
      onTap: () => _showConsultationDetail(context, consultation),
      onEdit: () => _showEditConsultationDialog(context, consultation),
      onDelete: () => _showDeleteConfirmation(context, consultation, notifier),
      onJoin: () => _handleJoinConsultation(consultation.id),
      onStart: () => _handleStartConsultation(consultation.id),
      onEnd: () => _handleEndConsultation(consultation.id),
    );
  }

  Widget _buildPagination(ColourNotifier notifier) {
    return Obx(() {
      if (controller.lastPage.value <= 1) return const SizedBox();

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: notifier.getContainer,
          border: Border(top: BorderSide(color: notifier.getBorderColor)),
        ),
        child: Row(
          children: [
            // Previous button
            ElevatedButton.icon(
              onPressed: controller.hasPreviousPage
                  ? () => controller.previousPage()
                  : null,
              icon: const Icon(Icons.chevron_left, size: 18),
              label: const Text('Previous'),
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.hasPreviousPage
                    ? notifier.getIconColor
                    : notifier.getMaingey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),

            const Spacer(),

            // Page numbers
            Row(
              children: _buildPageNumbers(notifier),
            ),

            const Spacer(),

            // Next button
            ElevatedButton.icon(
              onPressed: controller.hasNextPage
                  ? () => controller.nextPage()
                  : null,
              icon: const Icon(Icons.chevron_right, size: 18),
              label: const Text('Next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.hasNextPage
                    ? notifier.getIconColor
                    : notifier.getMaingey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildPageNumbers(ColourNotifier notifier) {
    List<Widget> pageNumbers = [];
    final currentPage = controller.currentPage.value;
    final lastPage = controller.lastPage.value;

    // Show first page
    if (currentPage > 3) {
      pageNumbers.add(_buildPageButton(1, notifier));
      if (currentPage > 4) {
        pageNumbers.add(Text('...', style: TextStyle(color: notifier.getMaingey)));
      }
    }

    // Show pages around current page
    for (int i = (currentPage - 2).clamp(1, lastPage);
    i <= (currentPage + 2).clamp(1, lastPage);
    i++) {
      pageNumbers.add(_buildPageButton(i, notifier));
    }

    // Show last page
    if (currentPage < lastPage - 2) {
      if (currentPage < lastPage - 3) {
        pageNumbers.add(Text('...', style: TextStyle(color: notifier.getMaingey)));
      }
      pageNumbers.add(_buildPageButton(lastPage, notifier));
    }

    return pageNumbers.map((widget) =>
        Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: widget)
    ).toList();
  }

  Widget _buildPageButton(int page, ColourNotifier notifier) {
    final isCurrentPage = controller.currentPage.value == page;

    return InkWell(
      onTap: () => controller.changePage(page),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isCurrentPage ? notifier.getIconColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrentPage ? notifier.getIconColor : notifier.getBorderColor,
          ),
        ),
        child: Center(
          child: Text(
            page.toString(),
            style: TextStyle(
              color: isCurrentPage ? Colors.white : notifier.getMainText,
              fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateConsultationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ConsultationFormDialog(),
    );
  }

  void _showEditConsultationDialog(BuildContext context, LiveConsultation consultation) {
    showDialog(
      context: context,
      builder: (context) => ConsultationFormDialog(
        consultation: consultation,
        isEdit: true,
      ),
    );
  }

  void _showConsultationDetail(BuildContext context, LiveConsultation consultation) {
    showDialog(
      context: context,
      builder: (context) => ConsultationDetailDialog(consultation: consultation),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context,
      LiveConsultation consultation,
      ColourNotifier notifier,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: notifier.getContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 24),
            const SizedBox(width: 12),
            Text(
              'Delete Consultation',
              style: TextStyle(
                color: notifier.getMainText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this consultation?',
              style: TextStyle(color: notifier.getMainText),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: notifier.getBgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: notifier.getBorderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    consultation.consultationTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: notifier.getMainText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dr. ${consultation.doctor.name} • ${consultation.patient.name}',
                    style: TextStyle(
                      color: notifier.getMaingey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    consultation.dateHuman,
                    style: TextStyle(
                      color: notifier.getMaingey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: notifier.getMainText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteConsultation(consultation.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleJoinConsultation(String id) {
    controller.joinConsultation(id);
  }

  void _handleStartConsultation(String id) {
    controller.startConsultation(id);
  }

  void _handleEndConsultation(String id) {
    controller.endConsultation(id);
  }
}