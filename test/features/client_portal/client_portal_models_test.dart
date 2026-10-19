import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/client_portal/data/models/client_dashboard_model.dart';
import 'package:flutter_application_1/features/client_portal/data/models/client_document_model.dart';
import 'package:flutter_application_1/features/client_portal/data/models/access_link_model.dart';

void main() {
  group('Client Portal Models Tests', () {
    test('ClientPortalDashboardData parses from json correctly', () {
      final json = {
        'hearings': [
          {
            'id': 101,
            'case_id': 202,
            'case_title': 'State vs. Doe',
            'case_number': 'CR/2026/89',
            'date': '2026-11-20',
            'court_name': 'High Court Hall 3',
            'notes': 'Bring original certificates',
            'is_upcoming': true,
          },
        ],
        'cases': [
          {
            'id': 202,
            'case_number': 'CR/2026/89',
            'title': 'State vs. Doe',
            'court_name': 'High Court of HP',
            'case_type': 'Criminal Appeal',
            'status': 'in_progress',
            'lawyer_name': 'Adv. Sharma',
          },
        ],
        'assigned_lawyers': [
          {
            'id': 1,
            'name': 'Adv. Sharma',
            'email': 'sharma@lex.com',
            'phone': '+919876543210',
            'role': 'lead_counsel',
          },
        ],
      };

      final data = ClientPortalDashboardData.fromJson(json);

      expect(data.hearings.length, 1);
      expect(data.hearings.first.caseTitle, 'State vs. Doe');
      expect(data.hearings.first.courtName, 'High Court Hall 3');
      expect(data.hearings.first.isUpcoming, true);

      expect(data.cases.length, 1);
      expect(data.cases.first.caseNumber, 'CR/2026/89');
      expect(data.cases.first.courtName, 'High Court of HP');

      expect(data.assignedLawyers.length, 1);
      expect(data.assignedLawyers.first.name, 'Adv. Sharma');
      expect(data.assignedLawyers.first.phone, '+919876543210');
    });

    test('ClientDocumentItem parses properly with computed properties', () {
      final json = {
        'id': 55,
        'title': 'Signed Affidavits.pdf',
        'file_name': 'signed_affidavits.pdf',
        'file_ext': 'pdf',
        'file_size': 1048576, // 1 MB
        'mime_type': 'application/pdf',
        'created_at': '2026-10-15T12:00:00Z',
        'shared_at': '2026-10-16T08:00:00Z',
        'expires_at': '2026-12-31T23:59:59Z',
        'case_id': 202,
        'case_title': 'State vs. Doe',
        'access_policy': 'shared',
        'shared_by_name': 'Adv. Sharma',
        'firm_name': 'Apex Advocates',
      };

      final doc = ClientDocumentItem.fromJson(json);

      expect(doc.id, 55);
      expect(doc.title, 'Signed Affidavits.pdf');
      expect(doc.isPdf, true);
      expect(doc.fileExt, 'pdf');
      expect(doc.formattedFileSize, '1.0 MB');
      expect(doc.caseTitle, 'State vs. Doe');
      expect(doc.accessPolicy, 'shared');
    });

    test('DocumentAccessLink parses 300-second expiration signed URL', () {
      final json = {
        'download_url': 'https://api.hphighcourt.site/api/portal/documents/55/download/?token=sec_tok_123',
        'download_path': '/documents/55/download/',
        'token': 'sec_tok_123',
        'expires_in_seconds': 300,
      };

      final link = DocumentAccessLink.fromJson(json);

      expect(link.token, 'sec_tok_123');
      expect(link.expiresInSeconds, 300);
      expect(link.downloadUrl, contains('token=sec_tok_123'));
    });
  });
}
