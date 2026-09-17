import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/documents/data/models/document_model.dart';

void main() {
  group('Document Model Tests', () {
    test(
      'parses Document from backend json and extracts fileName and extension',
      () {
        final json = {
          'id': 4,
          'case_title': 'State vs Sharma',
          'created_at': '2026-09-16T08:12:24.321290Z',
          'updated_at': '2026-09-16T08:12:24.321323Z',
          'is_active': true,
          'is_deleted': false,
          'file': 'http://api.hphighcourt.site:8082/case_files/documents/sample_brief.pdf',
          'firm': 15,
          'case': 4,
          'uploaded_by': 10,
        };

        final doc = Document.fromJson(json);

        expect(doc.id, 4);
        expect(doc.caseId, 4);
        expect(doc.caseTitle, 'State vs Sharma');
        expect(doc.firm, 15);
        expect(doc.uploadedBy, 10);
        expect(doc.isActive, true);
        expect(doc.isDeleted, false);
        expect(doc.fileName, 'sample_brief.pdf');
        expect(doc.fileExtension, 'pdf');
        expect(doc.isPdf, true);
        expect(doc.isImage, false);
        expect(doc.isDoc, false);
      },
    );

    test('detects image and doc extensions correctly', () {
      const docx = Document(
        id: 1,
        caseId: 2,
        firm: 15,
        file: 'https://storage.example.com/agreements/contract.docx',
      );
      expect(docx.fileName, 'contract.docx');
      expect(docx.fileExtension, 'docx');
      expect(docx.isDoc, true);
      expect(docx.isPdf, false);

      const image = Document(
        id: 2,
        caseId: 2,
        firm: 15,
        file: 'https://storage.example.com/evidence/crime_scene.jpg',
      );
      expect(image.fileName, 'crime_scene.jpg');
      expect(image.fileExtension, 'jpg');
      expect(image.isImage, true);
    });

    test('toJson serializes accurately', () {
      const doc = Document(
        id: 10,
        caseId: 4,
        caseTitle: 'State vs Sharma',
        firm: 15,
        file: 'https://example.com/file.pdf',
        uploadedBy: 1,
      );

      final json = doc.toJson();
      expect(json['id'], 10);
      expect(json['case'], 4);
      expect(json['case_title'], 'State vs Sharma');
      expect(json['firm'], 15);
      expect(json['file'], 'https://example.com/file.pdf');
    });
  });
}
