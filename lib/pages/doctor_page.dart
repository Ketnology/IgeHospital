import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/controllers/add_doctor_dialog.dart';
import 'package:ige_hospital/controllers/doctor_card.dart';
import 'package:ige_hospital/controllers/doctor_controller.dart';
import 'package:ige_hospital/controllers/doctor_detail_dialog.dart';
import 'package:ige_hospital/controllers/edit_doctor_dialog.dart';

class DoctorsPage extends StatelessWidget {
  // Make sure the controller is properly registered with GetX
  // We use Get.put to ensure the controller is initialized and accessible globally
  static final DoctorController controller = Get.put(DoctorController());

  const DoctorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildFilters(context),
            _buildDoctorsList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => _showAddDoctorDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Doctors',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Manage hospital doctors',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () => _showAddDoctorDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Doctor'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => controller.searchQuery.value = value,
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, specialty...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () => controller.resetFilters(),
                icon: const Icon(Icons.refresh),
                tooltip: 'Reset filters',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedDepartment.value.isEmpty ?
                  'All Departments' : controller.selectedDepartment.value,
                  decoration: InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: controller.departments.map((department) {
                    return DropdownMenuItem(
                      value: department,
                      child: Text(department),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.selectedDepartment.value =
                      value == 'All Departments' ? '' : value;
                    }
                  },
                )),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedStatus.value.isEmpty ?
                  'All' : controller.selectedStatus.value,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: ['All', 'Active', 'Pending', 'Blocked'].map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: status == 'All' ? Colors.grey :
                              controller.getStatusColor(status),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(status),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.selectedStatus.value = value == 'All' ? '' : value;
                    }
                  },
                )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedSpecialty.value.isEmpty ?
                  'All Specialties' : controller.selectedSpecialty.value,
                  decoration: InputDecoration(
                    labelText: 'Specialty',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: controller.specialties.map((specialty) {
                    return DropdownMenuItem(
                      value: specialty,
                      child: Text(specialty),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.selectedSpecialty.value =
                      value == 'All Specialties' ? '' : value;
                    }
                  },
                )),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                  value: controller.sortDirection.value,
                  decoration: InputDecoration(
                    labelText: 'Sort By',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'desc',
                      child: Row(
                        children: const [
                          Icon(Icons.arrow_downward, size: 16),
                          SizedBox(width: 8),
                          Text('Newest First'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'asc',
                      child: Row(
                        children: const [
                          Icon(Icons.arrow_upward, size: 16),
                          SizedBox(width: 8),
                          Text('Oldest First'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.sortDirection.value = value;
                    }
                  },
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsList() {
    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.filteredDoctors.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No doctors found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your filters or add a new doctor',
                  style: TextStyle(
                    color: Colors.grey[500],
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
          itemCount: controller.filteredDoctors.length,
          itemBuilder: (context, index) {
            final doctor = controller.filteredDoctors[index];
            return DoctorCard(
              doctor: doctor,
              onView: () => _showDoctorDetail(context, doctor),
              onEdit: () => _showEditDoctorDialog(context, doctor),
              onDelete: () => _showDeleteConfirmation(context, doctor),
            );
          },
        );
      }),
    );
  }

  void _showDoctorDetail(BuildContext context, Doctor doctor) {
    showDialog(
      context: context,
      builder: (context) => DoctorDetailDialog(doctor: doctor),
    );
  }

  void _showAddDoctorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddDoctorDialog(),
    );
  }

  void _showEditDoctorDialog(BuildContext context, Doctor doctor) {
    showDialog(
      context: context,
      builder: (context) => EditDoctorDialog(doctor: doctor),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Doctor doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Doctor'),
        content: Text('Are you sure you want to delete Dr. ${doctor.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteDoctor(doctor.id);
              Navigator.pop(context);
              Get.snackbar(
                'Success',
                'Doctor deleted successfully',
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