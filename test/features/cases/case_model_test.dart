import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/cases/data/models/case_model.dart';

void main() {
  group('Case Model Tests', () {
    test('parses Case with nested upcoming hearing and hearings list', () {
      final json = {
        'id': 4,
        'hearings': [
          {
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
          },
        ],
        'client_name': 'Test Client 1',
        'assigned_name': 'Advocate Verma',
        'upcoming_hearing': {
          'id': 2,
          'title': 'Bail Application Hearing',
          'date': '2026-09-25',
          'start_time': '10:30:00',
          'court_name': 'Court Room 3, HP High Court',
        },
        'created_at': '2026-09-16T07:29:16.198052Z',
        'updated_at': '2026-09-16T07:29:16.198139Z',
        'is_active': true,
        'is_deleted': false,
        'title': 'State vs Sharma',
        'case_number': 'CR-2026-101',
        'case_type': 'Criminal',
        'court_name': 'High Court of Himachal Pradesh',
        'status': 'open',
        'next_hearing_date': null,
        'firm': 15,
        'client': 4,
        'assigned_to': null,
      };

      final c = Case.fromJson(json);

      expect(c.id, 4);
      expect(c.title, 'State vs Sharma');
      expect(c.caseNumber, 'CR-2026-101');
      expect(c.caseType, 'Criminal');
      expect(c.courtName, 'High Court of Himachal Pradesh');
      expect(c.status, 'open');
      expect(c.isOpen, true);
      expect(c.client, 4);
      expect(c.clientName, 'Test Client 1');
      expect(c.upcomingHearing, isNotNull);
      expect(c.upcomingHearing!.title, 'Bail Application Hearing');
      expect(c.upcomingHearing!.date, '2026-09-25');
      expect(c.hearings.length, 1);
      expect(c.hearings.first.title, 'Bail Application Hearing');
    });

    test('handles string or null upcoming hearing gracefully', () {
      final json = {
        'id': 5,
        'title': 'Civil Suit',
        'case_number': 'CS-2026-01',
        'case_type': 'Civil',
        'court_name': 'District Court',
        'status': 'closed',
        'client': 2,
        'firm': 15,
        'upcoming_hearing': '2026-10-01 at Court 2',
      };

      final c = Case.fromJson(json);

      expect(c.id, 5);
      expect(c.isOpen, false);
      expect(c.upcomingHearing, isNotNull);
      expect(c.upcomingHearing!.title, '2026-10-01 at Court 2');
    });

    test('CreateCaseRequest formats json correctly', () {
      const req = CreateCaseRequest(
        title: 'Land Dispute',
        caseNumber: 'LD-99',
        caseType: 'Property',
        courtName: 'Shimla Court',
        status: 'open',
        client: 4,
        firm: 15,
        nextHearingDate: '2026-11-15',
      );

      final json = req.toJson();

      expect(json['title'], 'Land Dispute');
      expect(json['case_number'], 'LD-99');
      expect(json['case_type'], 'Property');
      expect(json['client'], 4);
      expect(json['firm'], 15);
      expect(json['next_hearing_date'], '2026-11-15');
    });
  });
}
