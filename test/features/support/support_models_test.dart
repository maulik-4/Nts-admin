import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/support/data/models/support_ticket.dart';

void main() {
  group('SupportTicket Models Tests', () {
    test('SupportStats parses count statistics', () {
      final json = {'total': 12, 'open': 4, 'in_progress': 3, 'resolved': 5};

      final stats = SupportStats.fromJson(json);

      expect(stats.total, 12);
      expect(stats.open, 4);
      expect(stats.inProgress, 3);
      expect(stats.resolved, 5);
    });

    test('SupportTicket and TicketReply parse JSON accurately', () {
      final json = {
        'id': 42,
        'ticket_number': 'TICK-4201',
        'subject': 'Cannot download invoice',
        'description': 'Getting 404 on receipt download',
        'category': 'billing',
        'priority': 'critical',
        'status': 'open',
        'created_at': '2025-02-10T14:30:00Z',
        'replies': [
          {
            'id': 101,
            'author': {'username': 'support_agent'},
            'message': 'We are investigating this issue.',
            'is_staff_reply': true,
            'created_at': '2025-02-10T14:45:00Z',
          },
        ],
      };

      final ticket = SupportTicket.fromJson(json);

      expect(ticket.id, 42);
      expect(ticket.ticketNumber, 'TICK-4201');
      expect(ticket.subject, 'Cannot download invoice');
      expect(ticket.category, 'billing');
      expect(ticket.priority, 'critical');
      expect(ticket.status, 'open');
      expect(ticket.isResolved, isFalse);
      expect(ticket.replies.length, 1);
      expect(ticket.replies.first.authorName, 'support_agent');
      expect(ticket.replies.first.isStaffReply, isTrue);
    });

    test('isResolved returns true for resolved or closed tickets', () {
      final resolvedTicket = SupportTicket.fromJson({
        'id': 1,
        'ticket_number': 'T-01',
        'subject': 'Done',
        'status': 'resolved',
      });
      expect(resolvedTicket.isResolved, isTrue);

      final closedTicket = SupportTicket.fromJson({
        'id': 2,
        'ticket_number': 'T-02',
        'subject': 'Done',
        'status': 'closed',
      });
      expect(closedTicket.isResolved, isTrue);
    });
  });
}
