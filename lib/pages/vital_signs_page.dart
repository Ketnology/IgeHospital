import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/vital_signs_controller.dart';
import 'package:ige_hospital/models/vital_signs_model.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/widgets/common_title.dart';
import 'package:ige_hospital/widgets/vital_signs_components/add_vital_signs_dialog.dart';
import 'package:ige_hospital/widgets/vital_signs_components/edit_vital_signs_dialog.dart';
import 'package:ige_hospital/widgets/vital_signs_components/vital_signs_card.dart';
import 'package:ige_hospital/widgets/permission_wrapper.dart';
import 'package:ige_hospital/widgets/permission_button.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:provider/provider.dart';

class VitalSignsPage extends StatefulWidget {
  final String patientId;
  final String patientName;

  const VitalSignsPage({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<VitalSignsPage> createState() => _VitalSignsPageState();
}

class _VitalSignsPageState extends State<VitalSignsPage> {
  late VitalSignsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(VitalSignsController());
    controller.initializeForPatient(widget.patientId, widget.patientName);
  }

  Widget _buildStatsOverview(ColourNotifier notifier) {
    return Obx(() {
      if (controller.vitalSigns.isEmpty) {
        return Container(); // Return empty container if no data
      }

      final latest = controller.vitalSigns.last;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notifier.getContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Latest Readings',
              style: TextStyle(
                color: notifier.getMainText,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('Blood Pressure', latest.bloodPressure, Icons.favorite,
                    latest.isBloodPressureNormal ? Colors.green : Colors.red, notifier),
                _buildStatItem('Heart Rate', latest.heartRate, Icons.monitor_heart,
                    latest.isHeartRateNormal ? Colors.green : Colors.red, notifier),
                _buildStatItem('Temperature', latest.temperature, Icons.thermostat,
                    latest.isTemperatureNormal ? Colors.green : Colors.red, notifier),
                _buildStatItem('Oxygen', latest.oxygenSaturation, Icons.air,
                    Colors.blue, notifier),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color, ColourNotifier notifier) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: notifier.getMainText,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: notifier.getMaingey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildVitalSignsList(ColourNotifier notifier) {
    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: notifier.getIconColor,
            ),
          );
        }

        if (controller.vitalSigns.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.monitor_heart_outlined,
                  size: 48,
                  color: notifier.getMaingey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No vital signs recorded yet',
                  style: TextStyle(
                    color: notifier.getMaingey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          itemCount: controller.vitalSigns.length,
          itemBuilder: (context, index) {
            final vitalSign = controller.vitalSigns[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: VitalSignsCard(
                vitalSign: vitalSign,
                onEdit: () => _showEditVitalSignsDialog(context, vitalSign),
                onDelete: () => controller.deleteVitalSigns(vitalSign.id),
              ),
            );
          },
        );
      }),
    );
  }

  void _showAddVitalSignsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddVitalSignsDialog(controller: controller),
    );
  }

  void _showEditVitalSignsDialog(BuildContext context, VitalSignModel vitalSign) {
    showDialog(
      context: context,
      builder: (context) => EditVitalSignsDialog(
        controller: controller,
        vitalSign: vitalSign,
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
            CommonTitle(
              title: 'Vital Signs - ${widget.patientName}',
              path: "Patient Records > Vital Signs",
            ),
            _buildPageTopBar(notifier),
            _buildStatsOverview(notifier),
            _buildVitalSignsList(notifier),
          ],
        ),
      ),
      floatingActionButton: PermissionWrapper(
        anyOf: ['edit_patients', 'create_patients'],
        child: FloatingActionButton(
          backgroundColor: notifier.getIconColor,
          onPressed: () => _showAddVitalSignsDialog(context),
          child: Icon(
            Icons.add,
            color: notifier.getBgColor,
          ),
        ),
      ),
    );
  }

  Widget _buildPageTopBar(ColourNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button and view toggles
          Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.arrow_back,
                  color: notifier.getIconColor,
                ),
                tooltip: 'Back to Patient Records',
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () => controller.loadVitalSigns(),
                icon: Icon(Icons.refresh, color: notifier.getIconColor),
                tooltip: 'Refresh',
              ),
            ],
          ),

          // Add Vital Signs Button
          PermissionButton(
            anyOf: ['edit_patients', 'create_patients'],
            onPressed: () => _showAddVitalSignsDialog(context),
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
                    "Record Vital Signs",
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
}