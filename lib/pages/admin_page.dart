import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/admin_service.dart';
import 'package:ige_hospital/static_data.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/widgets/add_admin_dialog.dart';
import 'package:ige_hospital/widgets/admin_data_table.dart';
import 'package:ige_hospital/widgets/admin_pagination.dart';
import 'package:ige_hospital/widgets/common_title.dart';
import 'package:provider/provider.dart';
import 'package:ige_hospital/provider/colors_provider.dart';

class AdminsPage extends StatefulWidget {
  const AdminsPage({super.key});

  @override
  State<AdminsPage> createState() => _AdminsPageState();
}

class _AdminsPageState extends State<AdminsPage> {
  final AppConst controller = Get.put(AppConst());
  ColourNotifier notifier = ColourNotifier();

  // Initialize the AdminsService
  final AdminsService adminsService = Get.put(AdminsService());

  int currentPage = 0;
  final int pageSize = 10;

  final TextEditingController searchController = TextEditingController();

  // Key for AdminDataTable to force rebuild when data changes
  final tableKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Fetch admins on page load
    adminsService.fetchAdmins();

    // Set up listener for admin data changes
    ever(adminsService.admins, (_) {
      if (mounted) {
        // Update the table key to force a rebuild
        setState(() {
          tableKey.currentState?.setState(() {});
        });
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColourNotifier>(context, listen: true);

    return Scaffold(
      backgroundColor: notifier.getBgColor,
      body: SafeArea(
        child: Column(
          children: [
            const CommonTitle(
                title: 'Administrators', path: "System Management"),
            _buildPageTopBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Obx(() {
                  if (adminsService.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: notifier.getIconColor,
                      ),
                    );
                  }

                  if (adminsService.hasError.value) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            adminsService.errorMessage.value,
                            style: TextStyle(color: notifier.getMainText),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => adminsService.fetchAdmins(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: notifier.getIconColor,
                            ),
                            child: const Text(
                              "Retry",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (adminsService.admins.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.admin_panel_settings_outlined,
                            color: notifier.getIconColor,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No administrators found",
                            style: TextStyle(
                              color: notifier.getMainText,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Try adjusting your filters or add a new administrator",
                            style: TextStyle(
                              color: notifier.getMaingey,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return LayoutBuilder(
                      builder: (context, constraints) {
                        int visibleCount = 2;
                        if (constraints.maxWidth < 600) {
                          visibleCount = 2;
                        } else if (constraints.maxWidth < 800) {
                          visibleCount = 3;
                        } else {
                          visibleCount = 4;
                        }

                        // Use our new AdminDataTable component
                        return AdminDataTable(
                          key: ValueKey('admin-table-${adminsService.admins.length}'),
                          admins: adminsService.admins,
                          notifier: notifier,
                          adminsService: adminsService,
                          visibleCount: visibleCount,
                          pageSize: pageSize,
                          currentPage: currentPage,
                          onPageChanged: (page) {
                            setState(() {
                              currentPage = page;
                            });
                          },
                          onDeleteAdmin: _showDeleteConfirmation,
                          paginationBuilder: _buildPagination,
                        );
                      }
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageTopBar() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          bool isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
          bool isDesktop = constraints.maxWidth >= 1024;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: isMobile
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: isDesktop ? 3 : 2, // More space for desktop
                    child: Container(),
                  ),
                  SizedBox(width: 20),
                  if (!isMobile) const SizedBox(width: 20),
                  Expanded(
                    flex: isDesktop ? 1 : (isTablet ? 2 : 3),
                    child:

                    ElevatedButton(
                      onPressed: () {
                        _showAddAdminDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appMainColor,
                        fixedSize: const Size.fromHeight(40),
                        elevation: 0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
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
                            "Add Administrator",
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
            ],
          );
        },
      ),
    );
  }

  Widget _buildPagination(
      int totalPages, int currentPage, Function(int) onPageChanged) {
    return AdminPagination(
      notifier: notifier,
      adminsService: adminsService,
      totalPages: totalPages,
      currentPage: currentPage,
      onPageChanged: onPageChanged,
    );
  }

  void _showAddAdminDialog() {
    showDialog(
      context: context,
      builder: (context) => AddAdminDialog(
        notifier: notifier,
        adminsService: adminsService,
      ),
    ).then((_) {
      // Refresh data after dialog is closed
      adminsService.fetchAdmins();
    });
  }

  void _showDeleteConfirmation(AdminModel admin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: notifier.getContainer,
        title: Text(
          "Confirm Delete",
          style: TextStyle(color: notifier.getMainText),
        ),
        content: Text(
          "Are you sure you want to delete ${admin.fullName}?",
          style: TextStyle(color: notifier.getMainText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: notifier.getMainText),
            ),
          ),
          TextButton(
            onPressed: () {
              adminsService.deleteAdmin(admin.id);
              Navigator.pop(context);
            },
            child: Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}