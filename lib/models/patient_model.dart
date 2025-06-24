class PatientModel {
  final String id;
  final String patientUniqueId;
  final String customField;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic> user;
  final Map<String, dynamic>? address;
  final Map<String, dynamic>? template;
  final Map<String, dynamic> stats;
  final List<dynamic> appointments;
  final List<dynamic> documents;
  final List<dynamic> vitalSigns;
  final Map<String, dynamic>? vitalSignsSummary;

  PatientModel({
    required this.id,
    required this.patientUniqueId,
    required this.customField,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    this.address,
    this.template,
    required this.stats,
    required this.appointments,
    required this.documents,
    required this.vitalSigns,
    this.vitalSignsSummary,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    // Handle the case where stats could be a list or a map
    Map<String, dynamic> statsMap;
    if (json['stats'] is Map) {
      statsMap = Map<String, dynamic>.from(json['stats']);
    } else if (json['stats'] is List && (json['stats'] as List).isEmpty) {
      // If stats is an empty list, provide default values
      statsMap = {
        'appointments_count': '0',
        'documents_count': '0',
        'vital_signs_count': 0,
      };
    } else {
      // Default fallback
      statsMap = {
        'appointments_count': '0',
        'documents_count': '0',
        'vital_signs_count': 0,
      };
    }

    // Handle appointments - ensure it's a list
    List<dynamic> appointmentsList;
    if (json['appointments'] is List) {
      appointmentsList = json['appointments'];
    } else {
      appointmentsList = [];
    }

    // Handle documents - ensure it's a list
    List<dynamic> documentsList;
    if (json['documents'] is List) {
      documentsList = json['documents'];
    } else {
      documentsList = [];
    }

    // Handle vital signs - ensure it's a list
    List<dynamic> vitalSignsList;
    if (json['vital_signs'] is List) {
      vitalSignsList = json['vital_signs'];
    } else {
      vitalSignsList = [];
    }

    // Handle vital signs summary
    Map<String, dynamic>? vitalSignsSummary;
    if (json['vital_signs_summary'] is Map) {
      vitalSignsSummary = Map<String, dynamic>.from(json['vital_signs_summary']);
    }

    return PatientModel(
      id: json['id'] ?? '',
      patientUniqueId: json['patient_unique_id'] ?? '',
      customField: json['custom_field'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      user: json['user'] is Map ? Map<String, dynamic>.from(json['user']) : {},
      address: json['address'] is Map
          ? Map<String, dynamic>.from(json['address'])
          : null,
      template: json['template'] is Map
          ? Map<String, dynamic>.from(json['template'])
          : null,
      stats: statsMap,
      appointments: appointmentsList,
      documents: documentsList,
      vitalSigns: vitalSignsList,
      vitalSignsSummary: vitalSignsSummary,
    );
  }

  // Helper method to convert this model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_unique_id': patientUniqueId,
      'custom_field': customField,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user': user,
      'address': address,
      'template': template,
      'stats': stats,
      'appointments': appointments,
      'documents': documents,
      'vital_signs': vitalSigns,
      'vital_signs_summary': vitalSignsSummary,
    };
  }

  // Helper methods for vital signs
  bool get hasVitalSigns => vitalSigns.isNotEmpty;

  String get lastVitalSignsDate {
    if (vitalSignsSummary != null && vitalSignsSummary!['last_recorded'] != null) {
      return vitalSignsSummary!['last_recorded'];
    }
    return 'No records';
  }

  String get latestBloodPressure {
    if (vitalSignsSummary != null && vitalSignsSummary!['blood_pressure'] != null) {
      return vitalSignsSummary!['blood_pressure'];
    }
    return 'N/A';
  }

  String get latestHeartRate {
    if (vitalSignsSummary != null && vitalSignsSummary!['heart_rate'] != null) {
      return vitalSignsSummary!['heart_rate'];
    }
    return 'N/A';
  }

  String get latestTemperature {
    if (vitalSignsSummary != null && vitalSignsSummary!['temperature'] != null) {
      return vitalSignsSummary!['temperature'];
    }
    return 'N/A';
  }

  int get vitalSignsCount {
    if (vitalSignsSummary != null && vitalSignsSummary!['total_records'] != null) {
      return vitalSignsSummary!['total_records'] as int;
    }
    return vitalSigns.length;
  }
}