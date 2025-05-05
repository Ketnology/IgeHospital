import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/nurse_controller.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/static_data.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/widgets/common_title.dart';
import 'package:ige_hospital/widgets/nurse_components/add_nurse_dialog.dart';
import 'package:ige_hospital/widgets/nurse_components/edit_nurse_dialog.dart';
import 'package:ige_hospital/widgets/nurse_components/nurse_card.dart';
import 'package:ige_hospital/widgets/nurse_components/nurse_detail_dialog.dart';
import 'package:ige_hospital/widgets/nurse_components/nurse_filters.dart';
import 'package:provider/provider.dart';

class NursesPage extends StatefulWidget {
  const NursesPage({super.key});

  @override
  State<NursesPage> createState() => _NursesPageState();
}

class _NursesPageState extends State<NursesPage> {
  late NurseController _nurseController;
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    // Initialize and find or create the NurseController
    _initNurseController();
  }

  void _initNurseController() {
    try {
      _nurseController = Get.find<NurseController>();
    } catch (e) {
      // If not found, create a new one
      _nurseController = Get.put(NurseController());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Scaffold(
      backgroundColor: notifier.getBgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommonTitle(title: 'Nurses', path: "Hospital Staff"),
            _buildPageTopBar(context, notifier),
            if (_showFilters)
              NurseFilters(
                searchController: _searchController,
                nurseController: _nurseController,
                initiallyExpanded: true,
              ),
            _buildNursesList(notifier),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: notifier.getIconColor,
        onPressed: () {
          setState(() {
            _showFilters = !_showFilters;
          });
        },
        child: Icon(
          _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
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

          // Add Nurse Button
          ElevatedButton(
            onPressed: () {
              _showAddNurseDialog(context);
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
                  "Add Nurse",
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
    );
  }

  Widget _buildNursesList(ColourNotifier notifier) {
    return Expanded(
      child: Obx(() {
        if (_nurseController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: notifier.getIconColor),
          );
        }

        if (_nurseController.filteredNurses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: notifier.getMaingey),
                const SizedBox(height: 16),
                Text(
                  'No nurses found',
                  style: TextStyle(
                    fontSize: 18,
                    color: notifier.getMainText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your filters or add a new nurse',
                  style: TextStyle(
                    color: notifier.getMaingey,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 380,
            childAspectRatio: 0.85,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: _nurseController.filteredNurses.length,
          itemBuilder: (context, index) {
            final nurse = _nurseController.filteredNurses[index];
            return NurseCard(
              nurse: nurse,
              onView: () => _showNurseDetail(context, nurse),
              onEdit: () => _showEditNurseDialog(context, nurse),
              onDelete: () => _showDeleteConfirmation(context, nurse, notifier),
            );
          },
        );
      }),
    );
  }

  void _showNurseDetail(BuildContext context, Nurse nurse) {
    showDialog(
      context: context,
      builder: (context) => NurseDetailDialog(nurse: nurse),
    ).then((result) {
      if (result == 'edit') {
        _showEditNurseDialog(context, nurse);
      }
    });
  }

  void _showAddNurseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddNurseDialog(nurseController: _nurseController),
    ).then((_) {
      // Refresh data after dialog is closed
      _nurseController.loadNurses();
    });
  }

  void _showEditNurseDialog(BuildContext context, Nurse nurse) {
    showDialog(
      context: context,
      builder: (context) => EditNurseDialog(
        nurse: nurse,
        nurseController: _nurseController,
      ),
    ).then((_) {
      if (mounted) {
        _nurseController.loadNurses();
        // Trigger UI update
        setState(() {});
      }
    });
  }

  void _showDeleteConfirmation(BuildContext context, Nurse nurse, ColourNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: notifier.getContainer,
        title: Text(
          'Delete Nurse',
          style: TextStyle(color: notifier.getMainText),
        ),
        content: Text(
          'Are you sure you want to delete ${nurse.fullName}?',
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
              _nurseController.deleteNurse(nurse.id);
              Navigator.pop(context);
              Get.snackbar(
                'Success',
                'Nurse deleted successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
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
}