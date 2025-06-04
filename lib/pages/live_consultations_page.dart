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

  Widget _buildPageTopBar(BuildContext context, ColourNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Toggle Filters Button
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
              Obx(() => Text(
                controller.pageInfo,
                style: TextStyle(
                  color: notifier.getMaingey,
                  fontSize: 14,
                ),
              )),
            ],
          ),

          // Action buttons
          Row(
            children: [
              // Refresh button
              IconButton(
                onPressed: () {
                  controller.loadConsultations();
                  controller.loadUpcomingConsultations();
                  controller.loadTodaysConsultations();
                },
                icon: Icon(Icons.refresh, color: notifier.getIconColor),
                tooltip: 'Refresh',
              ),
              const SizedBox(width: 8),
              // Create Consultation Button
              ElevatedButton(
                onPressed: () {
                  _showCreateConsultationDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appMainColor,
                  fixedSize: const Size.fromHeight(40),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      "assets/plus-circle.svg",
                      color: Colors.white,
                      width: 18,
                      height: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Create New",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w200,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
            child: CircularProgressIndicator(color: notifier.getIconColor),
          );
        }

        if (controller.filteredConsultations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.video_call_outlined, size: 64, color: notifier.getMaingey),
                const SizedBox(height: 16),
                Text(
                  'No consultations found',
                  style: TextStyle(
                    fontSize: 18,
                    color: notifier.getMainText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your filters or create a new consultation',
                  style: TextStyle(
                    color: notifier.getMaingey,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showCreateConsultationDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appMainColor,
                  ),
                  child: const Text(
                    'Create Consultation',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Consultations list
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive grid
                  if (constraints.maxWidth > 1200) {
                    return _buildGridView(3, notifier);
                  } else if (constraints.maxWidth > 800) {
                    return _buildGridView(2, notifier);
                  } else {
                    return _buildListView(notifier);
                  }
                },
              ),
            ),

            // Pagination
            _buildPagination(notifier),
          ],
        );
      }),
    );
  }

  Widget _buildGridView(int crossAxisCount, ColourNotifier notifier) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.9,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: controller.filteredConsultations.length,
      itemBuilder: (context, index) {
        final consultation = controller.filteredConsultations[index];
        return ConsultationCard(
          consultation: consultation,
          onTap: () => _showConsultationDetail(context, consultation),
          onEdit: () => _showEditConsultationDialog(context, consultation),
          onDelete: () => _showDeleteConfirmation(context, consultation, notifier),
          onJoin: () => _handleJoinConsultation(consultation.id),
          onStart: () => _handleStartConsultation(consultation.id),
          onEnd: () => _handleEndConsultation(consultation.id),
        );
      },
    );
  }

  Widget _buildListView(ColourNotifier notifier) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: controller.filteredConsultations.length,
      itemBuilder: (context, index) {
        final consultation = controller.filteredConsultations[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ConsultationCard(
            consultation: consultation,
            onTap: () => _showConsultationDetail(context, consultation),
            onEdit: () => _showEditConsultationDialog(context, consultation),
            onDelete: () => _showDeleteConfirmation(context, consultation, notifier),
            onJoin: () => _handleJoinConsultation(consultation.id),
            onStart: () => _handleStartConsultation(consultation.id),
            onEnd: () => _handleEndConsultation(consultation.id),
          ),
        );
      },
    );
  }

  Widget _buildPagination(ColourNotifier notifier) {
    return Obx(() {
      if (controller.lastPage.value <= 1) return const SizedBox();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notifier.getContainer,
          border: Border(top: BorderSide(color: notifier.getBorderColor)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous button
            ElevatedButton.icon(
              onPressed: controller.hasPreviousPage
                  ? () => controller.previousPage()
                  : null,
              icon: const Icon(Icons.chevron_left),
              label: const Text('Previous'),
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.hasPreviousPage
                    ? notifier.getIconColor
                    : notifier.getMaingey,
                foregroundColor: Colors.white,
              ),
            ),

            // Page info
            Text(
              'Page ${controller.currentPage.value} of ${controller.lastPage.value}',
              style: TextStyle(
                color: notifier.getMainText,
                fontWeight: FontWeight.w500,
              ),
            ),

            // Next button
            ElevatedButton.icon(
              onPressed: controller.hasNextPage
                  ? () => controller.nextPage()
                  : null,
              icon: const Icon(Icons.chevron_right),
              label: const Text('Next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.hasNextPage
                    ? notifier.getIconColor
                    : notifier.getMaingey,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    });
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
        title: Text(
          'Delete Consultation',
          style: TextStyle(color: notifier.getMainText),
        ),
        content: Text(
          'Are you sure you want to delete "${consultation.consultationTitle}"?',
          style: TextStyle(color: notifier.getMainText),
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