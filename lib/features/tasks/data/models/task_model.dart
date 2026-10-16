import 'package:flutter/material.dart';

enum TaskPriority {
  low,
  medium,
  high,
  urgent;

  String get value => name;

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return const Color(0xFF10B981);
      case TaskPriority.medium:
        return const Color(0xFF3B82F6);
      case TaskPriority.high:
        return const Color(0xFFF59E0B);
      case TaskPriority.urgent:
        return const Color(0xFFEF4444);
    }
  }

  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  static TaskPriority fromString(String? val) {
    if (val == null) return TaskPriority.medium;
    return TaskPriority.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => TaskPriority.medium,
    );
  }
}

enum TaskStatus {
  pending,
  inProgress,
  completed,
  cancelled;

  String get value {
    switch (this) {
      case TaskStatus.pending:
        return 'pending';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.completed:
        return 'completed';
      case TaskStatus.cancelled:
        return 'cancelled';
    }
  }

  String get displayName {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }

  static TaskStatus fromString(String? val) {
    if (val == null) return TaskStatus.pending;
    final normalized = val.toLowerCase().replaceAll(' ', '_');
    switch (normalized) {
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      case 'cancelled':
      case 'canceled':
        return TaskStatus.cancelled;
      case 'pending':
      default:
        return TaskStatus.pending;
    }
  }
}

class TaskAuthor {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;

  const TaskAuthor({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
  });

  String get fullName {
    final first = firstName?.trim() ?? '';
    final last = lastName?.trim() ?? '';
    final combined = '$first $last'.trim();
    return combined.isNotEmpty ? combined : username;
  }

  factory TaskAuthor.fromJson(Map<String, dynamic> json) {
    return TaskAuthor(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
  };
}

class TaskComment {
  final int id;
  final TaskAuthor? author;
  final String text;
  final DateTime? createdAt;

  const TaskComment({
    required this.id,
    this.author,
    required this.text,
    this.createdAt,
  });

  factory TaskComment.fromJson(Map<String, dynamic> json) {
    return TaskComment(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      author: json['author'] is Map<String, dynamic>
          ? TaskAuthor.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      text: json['text']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author?.toJson(),
    'text': text,
    'created_at': createdAt?.toIso8601String(),
  };
}

class Task {
  final int id;
  final String title;
  final String? description;
  final int? caseId;
  final String? caseTitle;
  final TaskAuthor? assignedTo;
  final TaskAuthor? createdBy;
  final TaskPriority priority;
  final TaskStatus status;
  final String? dueDate;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<TaskComment> comments;

  const Task({
    required this.id,
    required this.title,
    this.description,
    this.caseId,
    this.caseTitle,
    this.assignedTo,
    this.createdBy,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.dueDate,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
    this.comments = const [],
  });

  bool get isCompleted => status == TaskStatus.completed;

  String? get assignedToName => assignedTo?.fullName;

  bool get isOverdue {
    if (isCompleted || dueDate == null) return false;
    final due = DateTime.tryParse(dueDate!);
    if (due == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(due.year, due.month, due.day);
    return dueDay.isBefore(today);
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    final rawComments = json['comments'];
    final List<TaskComment> parsedComments = [];
    if (rawComments is List) {
      for (final item in rawComments) {
        if (item is Map<String, dynamic>) {
          parsedComments.add(TaskComment.fromJson(item));
        }
      }
    }

    return Task(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      caseId: json['case'] is int
          ? json['case'] as int
          : int.tryParse(json['case']?.toString() ?? ''),
      caseTitle: json['case_title']?.toString(),
      assignedTo: json['assigned_to'] is Map<String, dynamic>
          ? TaskAuthor.fromJson(json['assigned_to'] as Map<String, dynamic>)
          : null,
      createdBy: json['created_by'] is Map<String, dynamic>
          ? TaskAuthor.fromJson(json['created_by'] as Map<String, dynamic>)
          : null,
      priority: TaskPriority.fromString(json['priority']?.toString()),
      status: TaskStatus.fromString(json['status']?.toString()),
      dueDate: json['due_date']?.toString(),
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      comments: parsedComments,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'case': caseId,
    'case_title': caseTitle,
    'assigned_to': assignedTo?.toJson(),
    'created_by': createdBy?.toJson(),
    'priority': priority.value,
    'status': status.value,
    'due_date': dueDate,
    'completed_at': completedAt?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'comments': comments.map((c) => c.toJson()).toList(),
  };

  Task copyWith({
    int? id,
    String? title,
    String? description,
    int? caseId,
    String? caseTitle,
    TaskAuthor? assignedTo,
    TaskAuthor? createdBy,
    TaskPriority? priority,
    TaskStatus? status,
    String? dueDate,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TaskComment>? comments,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      caseId: caseId ?? this.caseId,
      caseTitle: caseTitle ?? this.caseTitle,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      comments: comments ?? this.comments,
    );
  }
}

class CreateTaskRequest {
  final String title;
  final String? description;
  final int? caseId;
  final int? assignedToId;
  final TaskPriority priority;
  final TaskStatus status;
  final String? dueDate;

  const CreateTaskRequest({
    required this.title,
    this.description,
    this.caseId,
    this.assignedToId,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.dueDate,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'priority': priority.value,
      'status': status.value,
    };
    if (description != null && description!.trim().isNotEmpty) {
      map['description'] = description!.trim();
    }
    if (caseId != null) {
      map['case'] = caseId;
    }
    if (assignedToId != null) {
      map['assigned_to_id'] = assignedToId;
    }
    if (dueDate != null && dueDate!.trim().isNotEmpty) {
      map['due_date'] = dueDate!.trim();
    }
    return map;
  }
}

class UpdateTaskRequest {
  final String? title;
  final String? description;
  final int? caseId;
  final int? assignedToId;
  final TaskPriority? priority;
  final TaskStatus? status;
  final String? dueDate;

  const UpdateTaskRequest({
    this.title,
    this.description,
    this.caseId,
    this.assignedToId,
    this.priority,
    this.status,
    this.dueDate,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;
    if (description != null) map['description'] = description;
    if (caseId != null) map['case'] = caseId;
    if (assignedToId != null) map['assigned_to_id'] = assignedToId;
    if (priority != null) map['priority'] = priority!.value;
    if (status != null) map['status'] = status!.value;
    if (dueDate != null) map['due_date'] = dueDate;
    return map;
  }
}
