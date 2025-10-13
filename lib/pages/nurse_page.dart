import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/nurse_controller.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/widgets/common_title.dart';
import 'package:ige_hospital/widgets/nurse_components/add_nurse_dialog.dart';
import 'package:ige_hospital/widgets/nurse_components/edit_nurse_dialog.dart';
import 'package:ige_hospital/widgets/nurse_components/nurse_card.dart';
import 'package:ige_hospital/widgets/nurse_components/nurse_detail_dialog.dart';
import 'package:ige_hospital/widgets/nurse_components/nurse_filters.dart';
import 'package:ige_hospital/widgets/permission_wrapper.dart';
import 'package:ige_hospital/widgets/permission_button.dart';
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
    _initNurseController();
  }

  void _initNurseController() {
    try {
      _nurseController = Get.find<NurseController>();
    } catch (e) {
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
            // Updated title
            const CommonTitle(title: 'Nurses', path: "Hospital Staff"),
            _buildPageTopBar(context, notifier),
            if (_showFilters)
              NurseFilters(
                searchController: _searchController,
                nurseController: _nurseController,
              ),
            _buildNursesList(notifier),
          ],
        ),
      ),
      floatingActionButton: PermissionWrapper(
        permission: 'create_nurses',
        child: FloatingActionButton(
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
      ),
    );
  }

  Widget _buildPageTopBar(BuildContext context, ColourNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Stats and Filters Button
          Row(
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
              const SizedBox(width: 8),

              // Refresh Button
              IconButton(
                onPressed: () => _nurseController.loadNurses(),
                icon: Icon(Icons.refresh, color: notifier.getIconColor),
                tooltip: 'Refresh',
              ),
            ],
          ),

          PermissionButton(
            permission: 'create_nurses',
            onPressed: () => _showAddNurseDialog(context),
            child: ElevatedButton(
              onPressed: null,
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
                  'No receptionists found', // Updated text
                  style: TextStyle(fontSize: 18, color: notifier.getMainText),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your filters or add a new receptionist', // Updated text
                  style: TextStyle(color: notifier.getMaingey),
                ),
                const SizedBox(height: 16),
                PermissionButton(
                  permission: 'create_nurses',
                  onPressed: () => _showAddNurseDialog(context),
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(backgroundColor: appMainColor),
                    child: const Text('Add Nurse', style: TextStyle(color: Colors.white)),
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
        setState(() {});
      }
    });
  }

  void _showDeleteConfirmation(
      BuildContext context, Nurse nurse, ColourNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: notifier.getContainer,
        title: Text(
          'Delete Receptionist', // Updated title
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
          PermissionButton(
            permission: 'delete_nurses',
            onPressed: () {
              _nurseController.deleteNurse(nurse.id);
              Navigator.pop(context);
              Get.snackbar(
                'Success',
                'Receptionist deleted successfully', // Updated message
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ),
        ],
      ),
    );
  }
}