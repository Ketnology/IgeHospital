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
      };
    } else {
      // Default fallback
      statsMap = {
        'appointments_count': '0',
        'documents_count': '0',
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
    };
  }
}
