class LiveConsultation {
  final String id;
  final String consultationTitle;
  final DateTime consultationDate;
  final int consultationDurationMinutes;
  final bool hostVideo;
  final bool participantVideo;
  final String type;
  final String typeNumber;
  final String createdBy;
  final String? description;
  final String meetingId;
  final String timeZone;
  final String password;
  final String status;
  final Map<String, dynamic> meta;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String consultationDateFormatted;
  final String consultationTimeFormatted;
  final String dateHuman;
  final String? timeUntilConsultation;
  final ConsultationStatusInfo statusInfo;
  final ConsultationPermissions permissions;
  final ConsultationDoctor doctor;
  final ConsultationPatient patient;
  final ConsultationJoinInfo? joinInfo;
  final String durationFormatted;
  final DateTime endTime;

  LiveConsultation({
    required this.id,
    required this.consultationTitle,
    required this.consultationDate,
    required this.consultationDurationMinutes,
    required this.hostVideo,
    required this.participantVideo,
    required this.type,
    required this.typeNumber,
    required this.createdBy,
    this.description,
    required this.meetingId,
    required this.timeZone,
    required this.password,
    required this.status,
    required this.meta,
    required this.createdAt,
    required this.updatedAt,
    required this.consultationDateFormatted,
    required this.consultationTimeFormatted,
    required this.dateHuman,
    this.timeUntilConsultation,
    required this.statusInfo,
    required this.permissions,
    required this.doctor,
    required this.patient,
    this.joinInfo,
    required this.durationFormatted,
    required this.endTime,
  });

  factory LiveConsultation.fromJson(Map<String, dynamic> json) {
    return LiveConsultation(
      id: json['id'] ?? '',
      consultationTitle: json['consultation_title'] ?? '',
      consultationDate: DateTime.parse(json['consultation_date']),
      consultationDurationMinutes: json['consultation_duration_minutes'] ?? 0,
      hostVideo: json['host_video'] ?? false,
      participantVideo: json['participant_video'] ?? false,
      type: json['type'] ?? '',
      typeNumber: json['type_number'] ?? '',
      createdBy: json['created_by'] ?? '',
      description: json['description'],
      meetingId: json['meeting_id'] ?? '',
      timeZone: json['time_zone'] ?? '',
      password: json['password'] ?? '',
      status: json['status'] ?? '',
      meta: json['meta'] is String
          ? {} // If meta is a JSON string, we'd need to decode it, but for now just empty map
          : (json['meta'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      consultationDateFormatted: json['consultation_date_formatted'] ?? '',
      consultationTimeFormatted: json['consultation_time_formatted'] ?? '',
      dateHuman: json['date_human'] ?? '',
      timeUntilConsultation: json['time_until_consultation'],
      statusInfo: ConsultationStatusInfo.fromJson(json['status_info'] ?? {}),
      permissions: ConsultationPermissions.fromJson(json),
      doctor: ConsultationDoctor.fromJson(json['doctor'] ?? {}),
      patient: ConsultationPatient.fromJson(json['patient'] ?? {}),
      joinInfo: json['join_info'] != null
          ? ConsultationJoinInfo.fromJson(json['join_info'])
          : null,
      durationFormatted: json['duration_formatted'] ?? '',
      endTime: DateTime.parse(json['end_time']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'consultation_title': consultationTitle,
      'consultation_date': consultationDate.toIso8601String(),
      'consultation_duration_minutes': consultationDurationMinutes,
      'host_video': hostVideo,
      'participant_video': participantVideo,
      'type': type,
      'description': description,
      'time_zone': timeZone,
      'meta': meta,
    };
  }
}

class ConsultationStatusInfo {
  final String status;
  final String label;
  final String color;
  final bool isActive;
  final bool isUpcoming;
  final bool isPast;

  ConsultationStatusInfo({
    required this.status,
    required this.label,
    required this.color,
    required this.isActive,
    required this.isUpcoming,
    required this.isPast,
  });

  factory ConsultationStatusInfo.fromJson(Map<String, dynamic> json) {
    return ConsultationStatusInfo(
      status: json['status'] ?? '',
      label: json['label'] ?? '',
      color: json['color'] ?? '',
      isActive: json['is_active'] ?? false,
      isUpcoming: json['is_upcoming'] ?? false,
      isPast: json['is_past'] ?? false,
    );
  }
}

class ConsultationPermissions {
  final bool canJoin;
  final bool canStart;
  final bool canEnd;
  final bool canEdit;
  final bool canDelete;

  ConsultationPermissions({
    required this.canJoin,
    required this.canStart,
    required this.canEnd,
    required this.canEdit,
    required this.canDelete,
  });

  factory ConsultationPermissions.fromJson(Map<String, dynamic> json) {
    return ConsultationPermissions(
      canJoin: json['can_join'] ?? false,
      canStart: json['can_start'] ?? false,
      canEnd: json['can_end'] ?? false,
      canEdit: json['can_edit'] ?? false,
      canDelete: json['can_delete'] ?? false,
    );
  }
}

class ConsultationDoctor {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String specialist;
  final String department;
  final String? avatar;

  ConsultationDoctor({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialist,
    required this.department,
    this.avatar,
  });

  factory ConsultationDoctor.fromJson(Map<String, dynamic> json) {
    return ConsultationDoctor(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      specialist: json['specialist'] ?? '',
      department: json['department'] ?? '',
      avatar: json['avatar'],
    );
  }
}

class ConsultationPatient {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String patientUniqueId;
  final String? avatar;

  ConsultationPatient({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.patientUniqueId,
    this.avatar,
  });

  factory ConsultationPatient.fromJson(Map<String, dynamic> json) {
    return ConsultationPatient(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      patientUniqueId: json['patient_unique_id'] ?? '',
      avatar: json['avatar'],
    );
  }
}

class ConsultationJoinInfo {
  final bool canJoinNow;
  final DateTime joinWindowStart;
  final DateTime joinWindowEnd;
  final ConsultationMeetingInstructions meetingInstructions;
  final ConsultationTechnicalRequirements technicalRequirements;

  ConsultationJoinInfo({
    required this.canJoinNow,
    required this.joinWindowStart,
    required this.joinWindowEnd,
    required this.meetingInstructions,
    required this.technicalRequirements,
  });

  factory ConsultationJoinInfo.fromJson(Map<String, dynamic> json) {
    return ConsultationJoinInfo(
      canJoinNow: json['can_join_now'] ?? false,
      joinWindowStart: DateTime.parse(json['join_window_start']),
      joinWindowEnd: DateTime.parse(json['join_window_end']),
      meetingInstructions: ConsultationMeetingInstructions.fromJson(
          json['meeting_instructions'] ?? {}),
      technicalRequirements: ConsultationTechnicalRequirements.fromJson(
          json['technical_requirements'] ?? {}),
    );
  }
}

class ConsultationMeetingInstructions {
  final List<String> beforeMeeting;
  final List<String> joiningMeeting;
  final List<String> duringMeeting;
  final List<String> troubleshooting;

  ConsultationMeetingInstructions({
    required this.beforeMeeting,
    required this.joiningMeeting,
    required this.duringMeeting,
    required this.troubleshooting,
  });

  factory ConsultationMeetingInstructions.fromJson(Map<String, dynamic> json) {
    return ConsultationMeetingInstructions(
      beforeMeeting: List<String>.from(json['before_meeting'] ?? []),
      joiningMeeting: List<String>.from(json['joining_meeting'] ?? []),
      duringMeeting: List<String>.from(json['during_meeting'] ?? []),
      troubleshooting: List<String>.from(json['troubleshooting'] ?? []),
    );
  }
}

class ConsultationTechnicalRequirements {
  final List<String> browsers;
  final Map<String, String> bandwidth;
  final List<String> devices;
  final List<String> permissions;
  final List<String> zoomSpecific;

  ConsultationTechnicalRequirements({
    required this.browsers,
    required this.bandwidth,
    required this.devices,
    required this.permissions,
    required this.zoomSpecific,
  });

  factory ConsultationTechnicalRequirements.fromJson(
      Map<String, dynamic> json) {
    return ConsultationTechnicalRequirements(
      browsers: List<String>.from(json['browsers'] ?? []),
      bandwidth: Map<String, String>.from(json['bandwidth'] ?? {}),
      devices: List<String>.from(json['devices'] ?? []),
      permissions: List<String>.from(json['permissions'] ?? []),
      zoomSpecific: List<String>.from(json['zoom_specific'] ?? []),
    );
  }
}

class ConsultationStatistics {
  final int totalConsultations;
  final int completedConsultations;
  final int cancelledConsultations;
  final int ongoingConsultations;
  final int scheduledConsultations;
  final double completionRate;
  final int consultationsWithRecordings;
  final double recordingRate;
  final double? averageDurationMinutes;
  final List<DailyStatistic> dailyStatistics;

  ConsultationStatistics({
    required this.totalConsultations,
    required this.completedConsultations,
    required this.cancelledConsultations,
    required this.ongoingConsultations,
    required this.scheduledConsultations,
    required this.completionRate,
    required this.consultationsWithRecordings,
    required this.recordingRate,
    this.averageDurationMinutes,
    required this.dailyStatistics,
  });

  factory ConsultationStatistics.fromJson(Map<String, dynamic> json) {
    return ConsultationStatistics(
      totalConsultations: json['total_consultations'] ?? 0,
      completedConsultations: json['completed_consultations'] ?? 0,
      cancelledConsultations: json['cancelled_consultations'] ?? 0,
      ongoingConsultations: json['ongoing_consultations'] ?? 0,
      scheduledConsultations: json['scheduled_consultations'] ?? 0,
      completionRate: (json['completion_rate'] ?? 0).toDouble(),
      consultationsWithRecordings: json['consultations_with_recordings'] ?? 0,
      recordingRate: (json['recording_rate'] ?? 0).toDouble(),
      averageDurationMinutes: json['average_duration_minutes']?.toDouble(),
      dailyStatistics: (json['daily_statistics'] as List? ?? [])
          .map((stat) => DailyStatistic.fromJson(stat))
          .toList(),
    );
  }
}

class DailyStatistic {
  final String date;
  final int scheduled;
  final int completed;
  final int cancelled;
  final int ongoing;
  final int total;

  DailyStatistic({
    required this.date,
    required this.scheduled,
    required this.completed,
    required this.cancelled,
    required this.ongoing,
    required this.total,
  });

  factory DailyStatistic.fromJson(Map<String, dynamic> json) {
    return DailyStatistic(
      date: json['date'] ?? '',
      scheduled: int.tryParse(json['scheduled'].toString()) ?? 0,
      completed: int.tryParse(json['completed'].toString()) ?? 0,
      cancelled: int.tryParse(json['cancelled'].toString()) ?? 0,
      ongoing: int.tryParse(json['ongoing'].toString()) ?? 0,
      total: json['total'] ?? 0,
    );
  }
}