import 'package:get/get.dart';
import 'package:flutter/material.dart';

class Doctor {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String gender;
  final String department;
  final String specialty;
  final String status;
  final String profileImage;
  final String qualification;
  final String description;
  final String bloodGroup;
  final String createdAt;
  final String updatedAt;

  Doctor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.department,
    required this.specialty,
    required this.status,
    required this.profileImage,
    required this.qualification,
    required this.description,
    required this.bloodGroup,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => "$firstName $lastName";
}

class DoctorController extends GetxController {
  var isLoading = false.obs;
  var doctors = <Doctor>[].obs;
  var filteredDoctors = <Doctor>[].obs;

  // Filter variables
  var searchQuery = ''.obs;
  var selectedDepartment = ''.obs;
  var selectedSpecialty = ''.obs;
  var selectedStatus = ''.obs;
  var sortDirection = 'desc'.obs;

  // Department list for filter dropdown
  var departments = <String>[
    'All Departments',
    'Cardiology',
    'Neurology',
    'Orthopedics',
    'Pediatrics',
    'Dermatology',
    'Ophthalmology',
    'Gynecology',
  ].obs;

  // Specialties list
  var specialties = <String>[
    'All Specialties',
    'Cardiologist',
    'Neurologist',
    'Orthopedic Surgeon',
    'Pediatrician',
    'Dermatologist',
    'Ophthalmologist',
    'Gynecologist',
  ].obs;

  @override
  void onInit() {
    super.onInit();
    loadDoctors();

    // Initialize filter listeners
    ever(searchQuery, (_) => applyFilters());
    ever(selectedDepartment, (_) => applyFilters());
    ever(selectedSpecialty, (_) => applyFilters());
    ever(selectedStatus, (_) => applyFilters());
    ever(sortDirection, (_) => applyFilters());
  }

  void loadDoctors() {
    isLoading.value = true;

    // Demo data
    doctors.value = [
      Doctor(
        id: '1',
        firstName: 'John',
        lastName: 'Smith',
        email: 'john.smith@hospital.com',
        phone: '+1 (555) 123-4567',
        gender: 'Male',
        department: 'Cardiology',
        specialty: 'Cardiologist',
        status: 'Active',
        profileImage: 'https://randomuser.me/api/portraits/men/1.jpg',
        qualification: 'MD, FACC',
        description: 'Dr. Smith is a board-certified cardiologist with over 15 years of experience in treating heart conditions. He specializes in interventional cardiology and coronary artery disease.',
        bloodGroup: 'O+',
        createdAt: '2023-01-15',
        updatedAt: '2023-10-05',
      ),
      Doctor(
        id: '2',
        firstName: 'Emma',
        lastName: 'Johnson',
        email: 'emma.johnson@hospital.com',
        phone: '+1 (555) 234-5678',
        gender: 'Female',
        department: 'Neurology',
        specialty: 'Neurologist',
        status: 'Active',
        profileImage: 'https://randomuser.me/api/portraits/women/2.jpg',
        qualification: 'MD, PhD',
        description: 'Dr. Johnson is a neurologist specializing in the diagnosis and treatment of disorders of the nervous system. She has particular expertise in headache disorders and multiple sclerosis.',
        bloodGroup: 'A+',
        createdAt: '2022-11-10',
        updatedAt: '2023-09-22',
      ),
      Doctor(
        id: '3',
        firstName: 'David',
        lastName: 'Wilson',
        email: 'david.wilson@hospital.com',
        phone: '+1 (555) 345-6789',
        gender: 'Male',
        department: 'Orthopedics',
        specialty: 'Orthopedic Surgeon',
        status: 'Active',
        profileImage: 'https://randomuser.me/api/portraits/men/3.jpg',
        qualification: 'MD, FAAOS',
        description: 'Dr. Wilson is an orthopedic surgeon who specializes in joint replacement surgery. He has performed over 2,000 joint replacements and is an expert in minimally invasive techniques.',
        bloodGroup: 'B+',
        createdAt: '2022-03-20',
        updatedAt: '2023-08-15',
      ),
      Doctor(
        id: '4',
        firstName: 'Sophia',
        lastName: 'Martinez',
        email: 'sophia.martinez@hospital.com',
        phone: '+1 (555) 456-7890',
        gender: 'Female',
        department: 'Pediatrics',
        specialty: 'Pediatrician',
        status: 'Pending',
        profileImage: 'https://randomuser.me/api/portraits/women/4.jpg',
        qualification: 'MD, FAAP',
        description: 'Dr. Martinez is a pediatrician with a focus on developmental pediatrics. She works closely with families to ensure the healthy growth and development of children from birth through adolescence.',
        bloodGroup: 'O-',
        createdAt: '2023-02-05',
        updatedAt: '2023-07-30',
      ),
      Doctor(
        id: '5',
        firstName: 'Michael',
        lastName: 'Brown',
        email: 'michael.brown@hospital.com',
        phone: '+1 (555) 567-8901',
        gender: 'Male',
        department: 'Dermatology',
        specialty: 'Dermatologist',
        status: 'Blocked',
        profileImage: 'https://randomuser.me/api/portraits/men/5.jpg',
        qualification: 'MD, FAAD',
        description: 'Dr. Brown is a dermatologist who specializes in skin cancer detection and treatment. He is also skilled in cosmetic dermatology procedures.',
        bloodGroup: 'AB+',
        createdAt: '2021-11-12',
        updatedAt: '2023-06-18',
      ),
      Doctor(
        id: '6',
        firstName: 'Olivia',
        lastName: 'Garcia',
        email: 'olivia.garcia@hospital.com',
        phone: '+1 (555) 678-9012',
        gender: 'Female',
        department: 'Ophthalmology',
        specialty: 'Ophthalmologist',
        status: 'Active',
        profileImage: 'https://randomuser.me/api/portraits/women/6.jpg',
        qualification: 'MD, FACS',
        description: 'Dr. Garcia is an ophthalmologist who specializes in cataract and refractive surgery. She is passionate about helping patients improve their vision and quality of life.',
        bloodGroup: 'A-',
        createdAt: '2022-05-18',
        updatedAt: '2023-09-03',
      ),
      Doctor(
        id: '7',
        firstName: 'William',
        lastName: 'Taylor',
        email: 'william.taylor@hospital.com',
        phone: '+1 (555) 789-0123',
        gender: 'Male',
        department: 'Gynecology',
        specialty: 'Gynecologist',
        status: 'Active',
        profileImage: 'https://randomuser.me/api/portraits/men/7.jpg',
        qualification: 'MD, FACOG',
        description: 'Dr. Taylor is a gynecologist with expertise in minimally invasive gynecologic surgery. He is committed to providing compassionate and comprehensive care to women of all ages.',
        bloodGroup: 'B-',
        createdAt: '2022-08-30',
        updatedAt: '2023-07-12',
      ),
    ];

    // Initialize filtered list with all doctors
    filteredDoctors.value = List.from(doctors);
    isLoading.value = false;
  }

  void applyFilters() {
    filteredDoctors.value = doctors.where((doctor) {
      // Search by name, email, or specialty
      bool matchesSearch = true;
      if (searchQuery.value.isNotEmpty) {
        matchesSearch = doctor.fullName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            doctor.email.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            doctor.specialty.toLowerCase().contains(searchQuery.value.toLowerCase());
      }

      // Filter by department
      bool matchesDepartment = true;
      if (selectedDepartment.value.isNotEmpty && selectedDepartment.value != 'All Departments') {
        matchesDepartment = doctor.department == selectedDepartment.value;
      }

      // Filter by specialty
      bool matchesSpecialty = true;
      if (selectedSpecialty.value.isNotEmpty && selectedSpecialty.value != 'All Specialties') {
        matchesSpecialty = doctor.specialty == selectedSpecialty.value;
      }

      // Filter by status
      bool matchesStatus = true;
      if (selectedStatus.value.isNotEmpty && selectedStatus.value != 'All') {
        matchesStatus = doctor.status.toLowerCase() == selectedStatus.value.toLowerCase();
      }

      return matchesSearch && matchesDepartment && matchesSpecialty && matchesStatus;
    }).toList();

    // Sort the list
    if (sortDirection.value == 'asc') {
      filteredDoctors.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else {
      filteredDoctors.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  void resetFilters() {
    searchQuery.value = '';
    selectedDepartment.value = '';
    selectedSpecialty.value = '';
    selectedStatus.value = '';
    sortDirection.value = 'desc';
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'blocked':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  void addDoctor({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String gender,
    required String department,
    required String specialty,
    required String qualification,
    required String description,
    required String bloodGroup,
  }) {
    // Generate a new ID (in a real app, this would come from the backend)
    final newId = (doctors.length + 1).toString();

    // Create a new doctor object
    final newDoctor = Doctor(
      id: newId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      gender: gender,
      department: department,
      specialty: specialty,
      status: 'Active', // Default to active
      profileImage: 'https://randomuser.me/api/portraits/${gender.toLowerCase() == 'male' ? 'men' : 'women'}/${doctors.length + 1}.jpg',
      qualification: qualification,
      description: description,
      bloodGroup: bloodGroup,
      createdAt: DateTime.now().toString().split(' ')[0], // Current date
      updatedAt: DateTime.now().toString().split(' ')[0], // Current date
    );

    // Add to the list
    doctors.add(newDoctor);

    // Re-apply filters to update the filtered list
    applyFilters();
  }

  void updateDoctor({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String gender,
    required String department,
    required String specialty,
    required String status,
    required String qualification,
    required String description,
    required String bloodGroup,
  }) {
    // Find the index of the doctor to update
    final index = doctors.indexWhere((doctor) => doctor.id == id);

    if (index != -1) {
      // Create an updated doctor object (preserving the original profile image and dates)
      final originalDoctor = doctors[index];
      final updatedDoctor = Doctor(
        id: id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        gender: gender,
        department: department,
        specialty: specialty,
        status: status,
        profileImage: originalDoctor.profileImage,
        qualification: qualification,
        description: description,
        bloodGroup: bloodGroup,
        createdAt: originalDoctor.createdAt,
        updatedAt: DateTime.now().toString().split(' ')[0], // Update the updatedAt date
      );

      // Replace the old doctor with the updated one
      doctors[index] = updatedDoctor;

      // Re-apply filters to update the filtered list
      applyFilters();
    }
  }

  void deleteDoctor(String id) {
    doctors.removeWhere((doctor) => doctor.id == id);
    applyFilters(); // Re-apply filters to update filtered list
  }
}