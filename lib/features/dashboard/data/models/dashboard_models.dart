import '../../../cases/data/models/case_model.dart';
import '../../../hearings/data/models/hearing_model.dart';

class ClientUsage {
  final int used;
  final int? limit;
  final String? planName;
  final bool unlimited;

  const ClientUsage({
    required this.used,
    this.limit,
    this.planName,
    this.unlimited = true,
  });

  factory ClientUsage.fromJson(Map<String, dynamic> json) {
    return ClientUsage(
      used: json['used'] is int
          ? json['used'] as int
          : int.tryParse(json['used']?.toString() ?? '0') ?? 0,
      limit: json['limit'] is int
          ? json['limit'] as int
          : int.tryParse(json['limit']?.toString() ?? ''),
      planName: json['plan_name']?.toString(),
      unlimited: json['unlimited'] as bool? ?? true,
    );
  }
}

class TaskStats {
  final int total;
  final int pending;
  final int inProgress;
  final int completed;
  final int overdue;

  const TaskStats({
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.completed,
    required this.overdue,
  });

  factory TaskStats.fromJson(Map<String, dynamic> json) {
    return TaskStats(
      total: json['total'] is int
          ? json['total'] as int
          : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      pending: json['pending'] is int
          ? json['pending'] as int
          : int.tryParse(json['pending']?.toString() ?? '0') ?? 0,
      inProgress: json['in_progress'] is int
          ? json['in_progress'] as int
          : int.tryParse(json['in_progress']?.toString() ?? '0') ?? 0,
      completed: json['completed'] is int
          ? json['completed'] as int
          : int.tryParse(json['completed']?.toString() ?? '0') ?? 0,
      overdue: json['overdue'] is int
          ? json['overdue'] as int
          : int.tryParse(json['overdue']?.toString() ?? '0') ?? 0,
    );
  }
}

class SupportStats {
  final int total;
  final int open;
  final int inProgress;
  final int resolved;

  const SupportStats({
    required this.total,
    required this.open,
    required this.inProgress,
    required this.resolved,
  });

  factory SupportStats.fromJson(Map<String, dynamic> json) {
    return SupportStats(
      total: json['total'] is int
          ? json['total'] as int
          : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      open: json['open'] is int
          ? json['open'] as int
          : int.tryParse(json['open']?.toString() ?? '0') ?? 0,
      inProgress: json['in_progress'] is int
          ? json['in_progress'] as int
          : int.tryParse(json['in_progress']?.toString() ?? '0') ?? 0,
      resolved: json['resolved'] is int
          ? json['resolved'] as int
          : int.tryParse(json['resolved']?.toString() ?? '0') ?? 0,
    );
  }
}

class SubscriptionInfo {
  final int? id;
  final bool isActive;
  final bool isTrial;
  final int? plan;
  final String? billingCycle;
  final String? startDate;
  final String? endDate;
  final bool hasActivePlan;

  const SubscriptionInfo({
    this.id,
    this.isActive = false,
    this.isTrial = false,
    this.plan,
    this.billingCycle,
    this.startDate,
    this.endDate,
    this.hasActivePlan = false,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? ''),
      isActive: json['is_active'] as bool? ?? false,
      isTrial: json['is_trial'] as bool? ?? false,
      plan: json['plan'] is int
          ? json['plan'] as int
          : int.tryParse(json['plan']?.toString() ?? ''),
      billingCycle: json['billing_cycle']?.toString(),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      hasActivePlan: true,
    );
  }

  factory SubscriptionInfo.none() =>
      const SubscriptionInfo(hasActivePlan: false);
}

class DashboardData {
  final ClientUsage? clientUsage;
  final TaskStats? taskStats;
  final SupportStats? supportStats;
  final SubscriptionInfo? subscriptionInfo;
  final int totalClients;
  final int totalCases;
  final int openCases;
  final int closedCases;
  final int upcomingHearingsCount;
  final List<Case> recentCases;
  final List<Hearing> upcomingHearings;

  const DashboardData({
    this.clientUsage,
    this.taskStats,
    this.supportStats,
    this.subscriptionInfo,
    this.totalClients = 0,
    this.totalCases = 0,
    this.openCases = 0,
    this.closedCases = 0,
    this.upcomingHearingsCount = 0,
    this.recentCases = const [],
    this.upcomingHearings = const [],
  });
}
