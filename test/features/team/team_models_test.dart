import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/team/data/models/team_member.dart';

void main() {
  group('TeamMember Model Tests', () {
    test('parses json correctly for lawyer role', () {
      final json = {
        'id': 101,
        'username': 'adv_sharma',
        'email': 'sharma@lexfirm.com',
        'role': 'lawyer',
        'firm': '15',
        'joined': '2025-01-15T10:00:00Z',
      };

      final member = TeamMember.fromJson(json);

      expect(member.id, 101);
      expect(member.username, 'adv_sharma');
      expect(member.email, 'sharma@lexfirm.com');
      expect(member.role, 'lawyer');
      expect(member.displayRole, 'Advocate / Lawyer');
      expect(member.isLawyer, isTrue);
      expect(member.isAdmin, isFalse);
      expect(member.isStaff, isFalse);
      expect(member.firm, '15');
      expect(member.joined, DateTime.parse('2025-01-15T10:00:00Z'));
    });

    test('parses json correctly for staff role', () {
      final json = {
        'id': 102,
        'username': 'paralegal_patel',
        'email': 'patel@lexfirm.com',
        'role': 'staff',
        'firm': '15',
      };

      final member = TeamMember.fromJson(json);

      expect(member.username, 'paralegal_patel');
      expect(member.displayRole, 'Legal Staff');
      expect(member.isLawyer, isFalse);
      expect(member.isStaff, isTrue);
      expect(member.isAdmin, isFalse);
    });

    test('parses firm admin role correctly', () {
      final json = {
        'id': 103,
        'username': 'admin_verma',
        'email': 'admin@lexfirm.com',
        'role': 'admin',
        'firm': '15',
      };

      final member = TeamMember.fromJson(json);

      expect(member.displayRole, 'Firm Admin');
      expect(member.isAdmin, isTrue);
      expect(member.isLawyer, isTrue);
      expect(member.isStaff, isFalse);
    });
  });
}
