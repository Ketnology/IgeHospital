import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/models/appointment_model.dart';
import 'package:ige_hospital/provider/appointment_service.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/provider/permission_service.dart';
import 'package:ige_hospital/widgets/common_title.dart';
import 'package:ige_hospital/widgets/appointment_components/appointment_filters.dart';
import 'package:ige_hospital/widgets/appointment_components/create_appointment_dialog.dart';
import 'package:ige_hospital/widgets/appointment_components/edit_appointment_dialog.dart';
import 'package:ige_hospital/widgets/appointment_components/appointment_detail_dialog.dart';
import 'package:ige_hospital/widgets/appointment_components/appointment_card.dart';
import 'package:ige_hospital/widgets/permission_wrapper.dart';
import 'package:ige_hospital/widgets/permission_button.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final AppointmentsService appointmentsService = Get.put(AppointmentsService());
  final PermissionService permissionService = Get.find<PermissionService>();
  final TextEditingController searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    // Set listener for appointments changes
    ever(appointmentsService.appointments, (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateAppointmentDialog(
        notifier: Provider.of<ColourNotifier>(context, listen: false),
        appointmentsService: appointmentsService,
      ),
    );
  }

  void _showEditDialog(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => EditAppointmentDialog(
        appointment: appointment,
        notifier: Provider.of<ColourNotifier>(context, listen: false),
        appointmentsService: appointmentsService,
      ),
    );
  }

  void _showAppointmentDetail(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => AppointmentDetailDialog(
        appointment: appointment,
        notifier: Provider.of<ColourNotifier>(context, listen: false),
      ),
    ).then((result) {
      if (result == 'edit' && permissionService.hasPermission('edit_appointments')) {
        _showEditDialog(appointment);
      }
    });
  }

  void _showDeleteConfirmation(AppointmentModel appointment, ColourNotifier notifier) {
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
              'Delete Appointment',
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
              'Are you sure you want to delete this appointment?',
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
                    'Dr. ${appointment.doctorName}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: notifier.getMainText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Patient: ${appointment.patientName}',
                    style: TextStyle(
                      color: notifier.getMaingey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${appointment.appointmentDate} at ${appointment.appointmentTime}',
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
              appointmentsService.deleteAppointment(appointment.id);
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

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);

    return Scaffold(
      backgroundColor: notifier.getBgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommonTitle(title: 'Appointments', path: "Hospital Operations"),
            _buildPageTopBar(notifier),
            if (_showFilters)
              AppointmentFilters(
                notifier: notifier,
                appointmentsService: appointmentsService,
              ),
            _buildAppointmentsList(notifier),
          ],
        ),
      ),
      floatingActionButton: PermissionWrapper(
        permission: 'create_appointments',
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

  Widget _buildPageTopBar(ColourNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // Stats and Quick Actions
          Row(
            children: [
              // Total appointments count
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: notifier.getIconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: notifier.getIconColor.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: notifier.getIconColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${appointmentsService.totalAppointments.value} Appointments',
                      style: TextStyle(
                        color: notifier.getIconColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(width: 12),

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
                onPressed: () => appointmentsService.fetchAppointments(),
                icon: Icon(Icons.refresh, color: notifier.getIconColor),
                tooltip: 'Refresh',
              ),
            ],
          ),

          const Spacer(),

          // Create Appointment Button
          PermissionButton(
            permission: 'create_appointments',
            onPressed: _showCreateDialog,
            child: ElevatedButton.icon(
              onPressed: null,
              icon: SvgPicture.asset(
                "assets/plus-circle.svg",
                color: Colors.white,
                width: 16,
                height: 16,
              ),
              label: const Text(
                "New Appointment",
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
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(ColourNotifier notifier) {
    return Expanded(
      child: Obx(() {
        if (appointmentsService.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: notifier.getIconColor),
                const SizedBox(height: 16),
                Text(
                  'Loading appointments...',
                  style: TextStyle(
                    color: notifier.getMaingey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        if (appointmentsService.hasError.value) {
          return _buildErrorState(notifier);
        }

        if (appointmentsService.appointments.isEmpty) {
          return _buildEmptyState(notifier);
        }

        return Column(
          children: [
            // Quick stats row if appointments exist
            if (appointmentsService.appointments.isNotEmpty)
              _buildQuickStats(notifier),

            const SizedBox(height: 16),

            Expanded(
              child: _buildAppointmentGrid(appointmentsService.appointments),
            ),

            // Pagination footer
            _buildPagination(notifier),
          ],
        );
      }),
    );
  }

  Widget _buildQuickStats(ColourNotifier notifier) {
    return Obx(() {
      // Calculate stats from current appointments
      final completedCount = appointmentsService.appointments.where((a) => a.isCompleted).length;
      final pendingCount = appointmentsService.appointments.where((a) => !a.isCompleted).length;
      final todayCount = appointmentsService.appointments.where((a) {
        try {
          final appointmentDate = DateTime.parse(a.appointmentDate);
          final today = DateTime.now();
          return appointmentDate.year == today.year &&
              appointmentDate.month == today.month &&
              appointmentDate.day == today.day;
        } catch (e) {
          return false;
        }
      }).length;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notifier.getContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: notifier.getBorderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Today',
                todayCount.toString(),
                Icons.today,
                Colors.blue,
                notifier,
              ),
            ),
            Container(
              width: 1,
              height: 30,
              color: notifier.getBorderColor,
            ),
            Expanded(
              child: _buildStatItem(
                'Completed',
                completedCount.toString(),
                Icons.check_circle_outline,
                Colors.green,
                notifier,
              ),
            ),
            Container(
              width: 1,
              height: 30,
              color: notifier.getBorderColor,
            ),
            Expanded(
              child: _buildStatItem(
                'Pending',
                pendingCount.toString(),
                Icons.schedule,
                Colors.orange,
                notifier,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(
      String label,
      String value,
      IconData icon,
      Color color,
      ColourNotifier notifier,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: notifier.getMainText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: notifier.getMaingey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentGrid(List<AppointmentModel> appointments) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid based on screen width
        int crossAxisCount;
        double childAspectRatio;

        if (constraints.maxWidth > 1400) {
          crossAxisCount = 4;
          childAspectRatio = 1.1;
        } else if (constraints.maxWidth > 1000) {
          crossAxisCount = 3;
          childAspectRatio = 1.0;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
          childAspectRatio = 0.9;
        } else {
          crossAxisCount = 1;
          childAspectRatio = 1.2;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            return _buildAppointmentCardWithPermissions(appointment);
          },
        );
      },
    );
  }

  Widget _buildAppointmentCardWithPermissions(AppointmentModel appointment) {
    final notifier = Provider.of<ColourNotifier>(context, listen: false);

    return AppointmentCard(
      appointment: appointment,
      onView: () => _showAppointmentDetail(appointment),
      onEdit: permissionService.hasPermission('edit_appointments')
          ? () => _showEditDialog(appointment)
          : null,
      onDelete: permissionService.hasPermission('delete_appointments')
          ? () => _showDeleteConfirmation(appointment, notifier)
          : null,
    );
  }

  Widget _buildPagination(ColourNotifier notifier) {
    return Obx(() {
      final totalPages = (appointmentsService.totalAppointments.value / 10).ceil();
      if (totalPages <= 1) return const SizedBox();

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: notifier.getContainer,
          border: Border(top: BorderSide(color: notifier.getBorderColor)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Showing ${appointmentsService.appointments.length} of ${appointmentsService.totalAppointments.value} appointments',
              style: TextStyle(
                color: notifier.getMaingey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildErrorState(ColourNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load appointments',
            style: TextStyle(
              color: notifier.getMainText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            appointmentsService.errorMessage.value.isNotEmpty
                ? appointmentsService.errorMessage.value
                : 'Please try again later',
            style: TextStyle(
              color: notifier.getMaingey,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => appointmentsService.fetchAppointments(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: notifier.getIconColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColourNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 60,
            color: notifier.getMaingey,
          ),
          const SizedBox(height: 16),
          Text(
            'No appointments found',
            style: TextStyle(
              color: notifier.getMainText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new appointment or adjust your filters',
            style: TextStyle(
              color: notifier.getMaingey,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => appointmentsService.resetFilters(),
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
              PermissionButton(
                permission: 'create_appointments',
                onPressed: _showCreateDialog,
                child: ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Create Appointment',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appMainColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}