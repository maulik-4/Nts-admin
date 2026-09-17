import 'package:flutter/material.dart';

import '../../../../core/theme/lex_colors.dart';

class SupportStats {
  final int total;
  final int open;
  final int inProgress;
  final int resolved;

  const SupportStats({
    this.total = 0,
    this.open = 0,
    this.inProgress = 0,
    this.resolved = 0,
  });

  factory SupportStats.fromJson(Map<String, dynamic> json) {
    return SupportStats(
      total: json['total'] as int? ?? 0,
      open: json['open'] as int? ?? 0,
      inProgress: json['in_progress'] as int? ?? 0,
      resolved: json['resolved'] as int? ?? 0,
    );
  }
}

class TicketReply {
  final int id;
  final String authorName;
  final String message;
  final bool isStaffReply;
  final DateTime? createdAt;

  const TicketReply({
    required this.id,
    required this.authorName,
    required this.message,
    required this.isStaffReply,
    this.createdAt,
  });

  factory TicketReply.fromJson(Map<String, dynamic> json) {
    String authorStr = 'User';
    if (json['author'] is Map) {
      authorStr = json['author']['username']?.toString() ?? 'User';
    }

    return TicketReply(
      id: json['id'] as int? ?? 0,
      authorName: authorStr,
      message: json['message'] as String? ?? '',
      isStaffReply: json['is_staff_reply'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'message': message};
}

class SupportTicket {
  final int id;
  final String ticketNumber;
  final String subject;
  final String description;
  final String category;
  final String priority;
  final String status;
  final DateTime? createdAt;
  final DateTime? resolvedAt;
  final List<TicketReply> replies;

  const SupportTicket({
    required this.id,
    required this.ticketNumber,
    required this.subject,
    required this.description,
    this.category = 'technical',
    this.priority = 'normal',
    this.status = 'open',
    this.createdAt,
    this.resolvedAt,
    this.replies = const [],
  });

  bool get isResolved =>
      status.toLowerCase() == 'resolved' || status.toLowerCase() == 'closed';

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
      case 'closed':
        return LexColors.success;
      default:
        return Colors.grey;
    }
  }

  Color get priorityColor {
    switch (priority.toLowerCase()) {
      case 'critical':
        return LexColors.error;
      case 'high':
        return Colors.deepOrange;
      case 'normal':
        return LexColors.slatePrimary;
      case 'low':
      default:
        return Colors.blueGrey;
    }
  }

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    var rawReplies = json['replies'];
    List<TicketReply> replyList = [];
    if (rawReplies is List) {
      replyList = rawReplies
          .map((r) => TicketReply.fromJson(r as Map<String, dynamic>))
          .toList();
    }

    return SupportTicket(
      id: json['id'] as int? ?? 0,
      ticketNumber: json['ticket_number'] as String? ?? '',
      subject: json['subject'] as String? ?? 'Support Ticket',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'technical',
      priority: json['priority'] as String? ?? 'normal',
      status: json['status'] as String? ?? 'open',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.tryParse(json['resolved_at'].toString())
          : null,
      replies: replyList,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject': subject,
    'description': description,
    'category': category,
    'priority': priority,
  };
}
