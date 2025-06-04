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
import 'package:provider/provider.dart';

class LiveConsultationsPage extends StatefulWidget {
  const LiveConsultationsPage({super.key});

  @override
  State<LiveConsultationsPage> createState() => _LiveConsultationsPageState();
}

class _LiveConsultationsPageState extends State<LiveConsultationsPage> {
  bool _showFilters = false;
  static final ConsultationController controller = Get.put(
      ConsultationController());

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Scaffold(
      backgroundColor: notifier.getBgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommonTitle(
                title: 'Live Consultations', path: "Medical Services"),
            _buildPageTopBar(context, notifier),
            if (_showFilters) const ConsultationFilters(
                initiallyExpanded: true),
            _buildStatisticsCards(notifier),
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
              Obx(() =>
                  Text(
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
                      "New Consultation",
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

  Widget _buildStatisticsCards(ColourNotifier notifier) {
    return Obx(() {
      if (controller.statistics.value == null) {
        return const SizedBox();
      }

      final stats = controller.statistics.value!;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive grid based on screen width
            int crossAxisCount = 2;
            if (constraints.maxWidth > 1200) {
              crossAxisCount = 5;
            } else if (constraints.maxWidth > 800) {
              crossAxisCount = 4;
            } else if (constraints.maxWidth > 600) {
              crossAxisCount = 3;
            }

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.8,
              children: [
                _buildStatCard(
                  'Total',
                  stats.totalConsultations.toString(),
                  Icons.video_call,
                  const Color(0xFF3B82F6),
                  notifier,
                ),
                _buildStatCard(
                  'Scheduled',
                  stats.scheduledConsultations.toString(),
                  Icons.schedule,
                  const Color(0xFF8B5CF6),
                  notifier,
                ),
                _buildStatCard(
                  'Ongoing',
                  stats.ongoingConsultations.toString(),
                  Icons.play_circle,
                  const Color(0xFF10B981),
                  notifier,
                ),
                _buildStatCard(
                  'Completed',
                  stats.completedConsultations.toString(),
                  Icons.check_circle,
                  const Color(0xFF6B7280),
                  notifier,
                ),
                _buildStatCard(
                  'Cancelled',
                  stats.cancelledConsultations.toString(),
                  Icons.cancel,
                  const Color(0xFFEF4444),
                  notifier,
                ),
              ],
            );
          },
        ),
      );
    });
  }

  Widget _buildStatCard(String label,
      String value,
      IconData icon,
      Color color,
      ColourNotifier notifier,) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifier.getContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifier.getBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: notifier.getMainText,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: notifier.getMaingey,
              fontWeight: FontWeight.w500,
            ),
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
                Icon(Icons.video_call_outlined, size: 64,
                    color: notifier.getMaingey),
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
}