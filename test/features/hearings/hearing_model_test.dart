import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/hearings/data/models/hearing_model.dart';

void main() {
  group('Hearing Model Tests', () {
    test('parses Hearing from JSON successfully', () {
      final json = {
        'id': 2,
        'start': '2026-09-25T10:30:00',
        'end': '2026-09-25T11:30:00',
        'title': 'Bail Application Hearing',
        'date': '2026-09-25',
        'start_time': '10:30:00',
        'end_time': '11:30:00',
        'court_name': 'Court Room 3, HP High Court',
        'judge_name': 'Justice A. K. Sharma',
        'notes': 'Bring verified affidavits.',
        'case': 4,
        'created_by': 10,
      };

      final h = Hearing.fromJson(json);

      expect(h.id, 2);
      expect(h.title, 'Bail Application Hearing');
      expect(h.date, '2026-09-25');
      expect(h.startTime, '10:30:00');
      expect(h.courtName, 'Court Room 3, HP High Court');
      expect(h.judgeName, 'Justice A. K. Sharma');
      expect(h.caseId, 4);
      expect(h.parsedDate, isNotNull);
      expect(h.parsedDate!.year, 2026);
    });

    test('CreateHearingRequest formats json correctly', () {
      const req = CreateHearingRequest(
        title: 'Evidence Hearing',
        date: '2026-10-05',
        startTime: '11:00:00',
        endTime: '12:00:00',
        courtName: 'Court 1',
        judgeName: 'Judge Kapoor',
        notes: 'Summon witness',
        caseId: 4,
      );

      final json = req.toJson();

      expect(json['title'], 'Evidence Hearing');
      expect(json['date'], '2026-10-05');
      expect(json['start_time'], '11:00:00');
      expect(json['end_time'], '12:00:00');
      expect(json['court_name'], 'Court 1');
      expect(json['judge_name'], 'Judge Kapoor');
      expect(json['notes'], 'Summon witness');
      expect(json['case'], 4);
    });

    test('UpdateHearingRequest omits null fields', () {
      const req = UpdateHearingRequest(notes: 'Adjourned to next week');

      final json = req.toJson();

      expect(json['notes'], 'Adjourned to next week');
      expect(json.containsKey('title'), isFalse);
      expect(json.containsKey('date'), isFalse);
    });
  });
}
