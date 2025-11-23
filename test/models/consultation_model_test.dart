import 'package:flutter_test/flutter_test.dart';
import 'package:ige_hospital/models/consultation_model.dart';

void main() {
  group('LiveConsultation', () {
    group('fromJson', () {
      test('should parse valid JSON correctly', () {
        final json = {
          'id': '1',
          'consultation_title': 'Follow-up Consultation',
          'consultation_date': '2024-01-20T10:00:00.000Z',
          'consultation_duration_minutes': 30,
          'host_video': true,
          'participant_video': true,
          'type': 'video',
          'type_number': '1',
          'created_by': 'doctor',
          'description': 'Regular follow-up',
          'meeting_id': 'meet123',
          'time_zone': 'UTC',
          'password': 'pass123',
          'status': 'scheduled',
          'meta': {'key': 'value'},
          'created_at': '2024-01-15T00:00:00.000Z',
          'updated_at': '2024-01-15T00:00:00.000Z',
          'consultation_date_formatted': 'Jan 20, 2024',
          'consultation_time_formatted': '10:00 AM',
          'date_human': 'in 5 days',
          'time_until_consultation': '5 days',
          'end_time': '2024-01-20T10:30:00.000Z',
          'duration_formatted': '30 minutes',
          'status_info': {
            'status': 'scheduled',
            'label': 'Scheduled',
            'color': 'blue',
            'is_active': false,
            'is_upcoming': true,
            'is_past': false
          },
          'can_join': true,
          'can_start': true,
          'can_end': false,
          'can_edit': true,
          'can_delete': true,
          'doctor': {
            'id': 'd1',
            'name': 'Dr. Smith',
            'email': 'smith@hospital.com',
            'phone': '1234567890',
            'specialist': 'Cardiology',
            'department': 'Heart Care'
          },
          'patient': {
            'id': 'p1',
            'name': 'John Doe',
            'email': 'john@example.com',
            'phone': '9876543210',
            'patient_unique_id': 'PAT001'
          }
        };

        final consultation = LiveConsultation.fromJson(json);

        expect(consultation.id, equals('1'));
        expect(consultation.consultationTitle, equals('Follow-up Consultation'));
        expect(consultation.consultationDate.year, equals(2024));
        expect(consultation.consultationDurationMinutes, equals(30));
        expect(consultation.hostVideo, isTrue);
        expect(consultation.participantVideo, isTrue);
        expect(consultation.type, equals('video'));
        expect(consultation.description, equals('Regular follow-up'));
        expect(consultation.meetingId, equals('meet123'));
        expect(consultation.password, equals('pass123'));
        expect(consultation.status, equals('scheduled'));
        expect(consultation.statusInfo.isUpcoming, isTrue);
        expect(consultation.permissions.canJoin, isTrue);
        expect(consultation.permissions.canStart, isTrue);
        expect(consultation.doctor.name, equals('Dr. Smith'));
        expect(consultation.patient.name, equals('John Doe'));
      });

      test('should handle meta as string', () {
        final json = {
          'id': '1',
          'consultation_title': 'Test',
          'consultation_date': '2024-01-20T10:00:00.000Z',
          'consultation_duration_minutes': 30,
          'host_video': false,
          'participant_video': false,
          'type': 'video',
          'type_number': '1',
          'created_by': 'doctor',
          'meeting_id': 'meet123',
          'time_zone': 'UTC',
          'password': '',
          'status': 'scheduled',
          'meta': '{}',
          'created_at': '2024-01-15T00:00:00.000Z',
          'updated_at': '2024-01-15T00:00:00.000Z',
          'consultation_date_formatted': '',
          'consultation_time_formatted': '',
          'date_human': '',
          'end_time': '2024-01-20T10:30:00.000Z',
          'duration_formatted': '',
          'status_info': {},
          'doctor': {},
          'patient': {}
        };

        final consultation = LiveConsultation.fromJson(json);

        expect(consultation.meta, isEmpty);
      });
    });

    group('toJson', () {
      test('should convert model to JSON correctly', () {
        final consultation = LiveConsultation(
          id: '1',
          consultationTitle: 'Test Consultation',
          consultationDate: DateTime(2024, 1, 20, 10, 0),
          consultationDurationMinutes: 30,
          hostVideo: true,
          participantVideo: true,
          type: 'video',
          typeNumber: '1',
          createdBy: 'doctor',
          description: 'Test description',
          meetingId: 'meet123',
          timeZone: 'UTC',
          password: 'pass123',
          status: 'scheduled',
          meta: {'key': 'value'},
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
          consultationDateFormatted: '',
          consultationTimeFormatted: '',
          dateHuman: '',
          statusInfo: ConsultationStatusInfo(
            status: 'scheduled',
            label: 'Scheduled',
            color: 'blue',
            isActive: false,
            isUpcoming: true,
            isPast: false,
          ),
          permissions: ConsultationPermissions(
            canJoin: true,
            canStart: true,
            canEnd: false,
            canEdit: true,
            canDelete: true,
          ),
          doctor: ConsultationDoctor(
            id: 'd1',
            name: 'Dr. Smith',
            email: 'smith@example.com',
            phone: '1234567890',
            specialist: 'Cardiology',
            department: 'Heart Care',
          ),
          patient: ConsultationPatient(
            id: 'p1',
            name: 'John Doe',
            email: 'john@example.com',
            phone: '9876543210',
            patientUniqueId: 'PAT001',
          ),
          durationFormatted: '30 minutes',
          endTime: DateTime(2024, 1, 20, 10, 30),
        );

        final json = consultation.toJson();

        expect(json['id'], equals('1'));
        expect(json['consultation_title'], equals('Test Consultation'));
        expect(json['consultation_duration_minutes'], equals(30));
        expect(json['host_video'], isTrue);
        expect(json['type'], equals('video'));
        expect(json['description'], equals('Test description'));
      });
    });
  });

  group('ConsultationStatusInfo', () {
    test('fromJson should parse correctly', () {
      final json = {
        'status': 'ongoing',
        'label': 'In Progress',
        'color': 'green',
        'is_active': true,
        'is_upcoming': false,
        'is_past': false
      };

      final statusInfo = ConsultationStatusInfo.fromJson(json);

      expect(statusInfo.status, equals('ongoing'));
      expect(statusInfo.label, equals('In Progress'));
      expect(statusInfo.color, equals('green'));
      expect(statusInfo.isActive, isTrue);
      expect(statusInfo.isUpcoming, isFalse);
      expect(statusInfo.isPast, isFalse);
    });

    test('fromJson should handle missing fields', () {
      final json = <String, dynamic>{};

      final statusInfo = ConsultationStatusInfo.fromJson(json);

      expect(statusInfo.status, equals(''));
      expect(statusInfo.label, equals(''));
      expect(statusInfo.isActive, isFalse);
    });
  });

  group('ConsultationPermissions', () {
    test('fromJson should parse correctly', () {
      final json = {
        'can_join': true,
        'can_start': true,
        'can_end': true,
        'can_edit': false,
        'can_delete': false
      };

      final permissions = ConsultationPermissions.fromJson(json);

      expect(permissions.canJoin, isTrue);
      expect(permissions.canStart, isTrue);
      expect(permissions.canEnd, isTrue);
      expect(permissions.canEdit, isFalse);
      expect(permissions.canDelete, isFalse);
    });

    test('fromJson should default to false for missing fields', () {
      final json = <String, dynamic>{};

      final permissions = ConsultationPermissions.fromJson(json);

      expect(permissions.canJoin, isFalse);
      expect(permissions.canStart, isFalse);
      expect(permissions.canEnd, isFalse);
      expect(permissions.canEdit, isFalse);
      expect(permissions.canDelete, isFalse);
    });
  });

  group('ConsultationDoctor', () {
    test('fromJson should parse correctly', () {
      final json = {
        'id': 'd1',
        'name': 'Dr. Jane Smith',
        'email': 'jane@hospital.com',
        'phone': '1234567890',
        'specialist': 'Cardiology',
        'department': 'Cardiac Care',
        'avatar': 'https://example.com/avatar.jpg'
      };

      final doctor = ConsultationDoctor.fromJson(json);

      expect(doctor.id, equals('d1'));
      expect(doctor.name, equals('Dr. Jane Smith'));
      expect(doctor.email, equals('jane@hospital.com'));
      expect(doctor.phone, equals('1234567890'));
      expect(doctor.specialist, equals('Cardiology'));
      expect(doctor.department, equals('Cardiac Care'));
      expect(doctor.avatar, equals('https://example.com/avatar.jpg'));
    });

    test('fromJson should handle missing fields', () {
      final json = <String, dynamic>{};

      final doctor = ConsultationDoctor.fromJson(json);

      expect(doctor.id, equals(''));
      expect(doctor.name, equals(''));
      expect(doctor.avatar, isNull);
    });
  });

  group('ConsultationPatient', () {
    test('fromJson should parse correctly', () {
      final json = {
        'id': 'p1',
        'name': 'John Doe',
        'email': 'john@example.com',
        'phone': '9876543210',
        'patient_unique_id': 'PAT001',
        'avatar': 'https://example.com/patient.jpg'
      };

      final patient = ConsultationPatient.fromJson(json);

      expect(patient.id, equals('p1'));
      expect(patient.name, equals('John Doe'));
      expect(patient.email, equals('john@example.com'));
      expect(patient.phone, equals('9876543210'));
      expect(patient.patientUniqueId, equals('PAT001'));
      expect(patient.avatar, equals('https://example.com/patient.jpg'));
    });

    test('fromJson should handle missing fields', () {
      final json = <String, dynamic>{};

      final patient = ConsultationPatient.fromJson(json);

      expect(patient.id, equals(''));
      expect(patient.patientUniqueId, equals(''));
      expect(patient.avatar, isNull);
    });
  });

  group('ConsultationStatistics', () {
    test('fromJson should parse correctly', () {
      final json = {
        'total_consultations': 100,
        'completed_consultations': 80,
        'cancelled_consultations': 10,
        'ongoing_consultations': 5,
        'scheduled_consultations': 5,
        'completion_rate': 80.0,
        'consultations_with_recordings': 50,
        'recording_rate': 62.5,
        'average_duration_minutes': 25.5,
        'daily_statistics': [
          {
            'date': '2024-01-15',
            'scheduled': 5,
            'completed': 4,
            'cancelled': 1,
            'ongoing': 0,
            'total': 5
          }
        ]
      };

      final stats = ConsultationStatistics.fromJson(json);

      expect(stats.totalConsultations, equals(100));
      expect(stats.completedConsultations, equals(80));
      expect(stats.cancelledConsultations, equals(10));
      expect(stats.ongoingConsultations, equals(5));
      expect(stats.scheduledConsultations, equals(5));
      expect(stats.completionRate, equals(80.0));
      expect(stats.consultationsWithRecordings, equals(50));
      expect(stats.recordingRate, equals(62.5));
      expect(stats.averageDurationMinutes, equals(25.5));
      expect(stats.dailyStatistics.length, equals(1));
      expect(stats.dailyStatistics.first.date, equals('2024-01-15'));
    });

    test('fromJson should handle missing fields', () {
      final json = <String, dynamic>{};

      final stats = ConsultationStatistics.fromJson(json);

      expect(stats.totalConsultations, equals(0));
      expect(stats.completedConsultations, equals(0));
      expect(stats.completionRate, equals(0.0));
      expect(stats.averageDurationMinutes, isNull);
      expect(stats.dailyStatistics, isEmpty);
    });
  });

  group('DailyStatistic', () {
    test('fromJson should parse correctly', () {
      final json = {
        'date': '2024-01-15',
        'scheduled': '5',
        'completed': '4',
        'cancelled': '1',
        'ongoing': '0',
        'total': 5
      };

      final stat = DailyStatistic.fromJson(json);

      expect(stat.date, equals('2024-01-15'));
      expect(stat.scheduled, equals(5));
      expect(stat.completed, equals(4));
      expect(stat.cancelled, equals(1));
      expect(stat.ongoing, equals(0));
      expect(stat.total, equals(5));
    });

    test('fromJson should handle string numbers', () {
      final json = {
        'date': '2024-01-15',
        'scheduled': '10',
        'completed': '8',
        'cancelled': '2',
        'ongoing': '0',
        'total': 10
      };

      final stat = DailyStatistic.fromJson(json);

      expect(stat.scheduled, equals(10));
      expect(stat.completed, equals(8));
    });
  });

  group('ConsultationJoinInfo', () {
    test('fromJson should parse correctly', () {
      final json = {
        'can_join_now': true,
        'join_window_start': '2024-01-20T09:45:00.000Z',
        'join_window_end': '2024-01-20T10:30:00.000Z',
        'meeting_instructions': {
          'before_meeting': ['Test camera', 'Check internet'],
          'joining_meeting': ['Click join button'],
          'during_meeting': ['Stay muted when not speaking'],
          'troubleshooting': ['Refresh page if issues']
        },
        'technical_requirements': {
          'browsers': ['Chrome', 'Firefox'],
          'bandwidth': {'minimum': '1 Mbps', 'recommended': '5 Mbps'},
          'devices': ['Desktop', 'Mobile'],
          'permissions': ['Camera', 'Microphone'],
          'zoom_specific': ['Install Zoom app']
        }
      };

      final joinInfo = ConsultationJoinInfo.fromJson(json);

      expect(joinInfo.canJoinNow, isTrue);
      expect(joinInfo.meetingInstructions.beforeMeeting.length, equals(2));
      expect(joinInfo.technicalRequirements.browsers.length, equals(2));
    });
  });

  group('ConsultationMeetingInstructions', () {
    test('fromJson should parse correctly', () {
      final json = {
        'before_meeting': ['Test camera', 'Check internet'],
        'joining_meeting': ['Click join button'],
        'during_meeting': ['Stay muted'],
        'troubleshooting': ['Refresh page']
      };

      final instructions = ConsultationMeetingInstructions.fromJson(json);

      expect(instructions.beforeMeeting.length, equals(2));
      expect(instructions.joiningMeeting.length, equals(1));
      expect(instructions.duringMeeting.length, equals(1));
      expect(instructions.troubleshooting.length, equals(1));
    });

    test('fromJson should handle missing fields', () {
      final json = <String, dynamic>{};

      final instructions = ConsultationMeetingInstructions.fromJson(json);

      expect(instructions.beforeMeeting, isEmpty);
      expect(instructions.joiningMeeting, isEmpty);
    });
  });

  group('ConsultationTechnicalRequirements', () {
    test('fromJson should parse correctly', () {
      final json = {
        'browsers': ['Chrome', 'Firefox', 'Safari'],
        'bandwidth': {'minimum': '1 Mbps', 'recommended': '5 Mbps'},
        'devices': ['Desktop', 'Laptop', 'Mobile'],
        'permissions': ['Camera', 'Microphone'],
        'zoom_specific': ['Install Zoom client']
      };

      final requirements = ConsultationTechnicalRequirements.fromJson(json);

      expect(requirements.browsers.length, equals(3));
      expect(requirements.bandwidth['minimum'], equals('1 Mbps'));
      expect(requirements.devices.length, equals(3));
      expect(requirements.permissions.length, equals(2));
      expect(requirements.zoomSpecific.length, equals(1));
    });

    test('fromJson should handle missing fields', () {
      final json = <String, dynamic>{};

      final requirements = ConsultationTechnicalRequirements.fromJson(json);

      expect(requirements.browsers, isEmpty);
      expect(requirements.bandwidth, isEmpty);
    });
  });
}
