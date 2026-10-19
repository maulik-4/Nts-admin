import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../shared/widgets/capability_gate.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../auth/domain/models/role_capabilities.dart';
import '../../../hearings/data/models/hearing_model.dart';
import '../../../hearings/presentation/providers/hearings_notifier.dart';
import '../../data/models/case_model.dart';
import '../../data/repositories/cases_repository.dart';
import '../providers/cases_notifier.dart';

final caseDetailProvider = FutureProvider.family<dynamic, int>((ref, id) async {
  final list = ref.watch(casesNotifierProvider).valueOrNull;
  if (list != null) {
    final found = list.where((c) => c.id == id);
    if (found.isNotEmpty) return found.first;
  }
  final repo = ref.watch(casesRepositoryProvider);
  return repo.getCase(id);
});

class CaseDetailScreen extends ConsumerWidget {
  final int caseId;

  const CaseDetailScreen({super.key, required this.caseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caseAsync = ref.watch(caseDetailProvider(caseId));
    final hearingsAsync = ref.watch(hearingsNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Case Details',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        actions: [
          CapabilityGate(
            capability: UserCapability.editCases,
            child: IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Case',
              onPressed: () => context.push('/app/cases/$caseId/edit'),
            ),
          ),
          CapabilityGate(
            capability: UserCapability.deleteCases,
            child: IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFEF4444),
              ),
              tooltip: 'Delete Case',
              onPressed: () => _confirmDelete(context, ref),
            ),
          ),
        ],
      ),
      body: caseAsync.when(
        data: (caseItem) {
          final List<Hearing> caseHearings =
              (hearingsAsync.valueOrNull
                  ?.where((h) => h.caseId == caseId)
                  .toList()) ??
              caseItem.hearings;

          final createdFormatted = caseItem.createdAt != null
              ? DateFormat('MMM d, yyyy').format(caseItem.createdAt!)
              : 'Unrecorded';

          final statusColor = caseItem.isOpen
              ? const Color(0xFF10B981)
              : const Color(0xFF94A3B8);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Overview Card
                LexCard(
                  borderRadius: 20,
                  leftAccentColor: statusColor,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Text(
                              caseItem.caseNumber,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                                color: isDark
                                    ? LexColors.accentGold
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          StatusBadge(status: caseItem.status, showDot: true),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        caseItem.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Category: ${caseItem.caseType.toUpperCase()} • Filed on $createdFormatted',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Divider(
                        height: 1,
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFF1F5F9),
                      ),
                      const SizedBox(height: 14),

                      // Quick Status Toggle Action
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _toggleStatus(context, ref, caseItem),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 11,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: Icon(
                                caseItem.isOpen
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.replay_rounded,
                                size: 16,
                              ),
                              label: Text(
                                caseItem.isOpen
                                    ? 'Mark Case as Closed'
                                    : 'Reopen Case File',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Case Details & Participants Card
                LexCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Case Information',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        'Client',
                        caseItem.clientName ?? 'Client #${caseItem.client}',
                        Icons.person_outline_rounded,
                        actionLabel: 'View Client',
                        onAction: () =>
                            context.push('/app/clients/${caseItem.client}'),
                      ),
                      const Divider(height: 18),
                      _buildInfoRow(
                        context,
                        'Courtroom',
                        caseItem.courtName.isNotEmpty
                            ? caseItem.courtName
                            : 'Unspecified Court',
                        Icons.account_balance_outlined,
                      ),
                      const Divider(height: 18),
                      _buildInfoRow(
                        context,
                        'Assigned',
                        caseItem.assignedName?.isNotEmpty == true
                            ? caseItem.assignedName!
                            : 'Unassigned',
                        Icons.shield_outlined,
                      ),
                      if (caseItem.nextHearingDate != null) ...[
                        const Divider(height: 18),
                        _buildInfoRow(
                          context,
                          'Next Date',
                          caseItem.nextHearingDate!,
                          Icons.calendar_today_outlined,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Hearings Section Card
                LexCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.event_available_rounded,
                                size: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Hearings (${caseHearings.length})',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () {
                              AppAlerts.showWarning(
                                context,
                                'Hearings scheduling is currently locked. Please review your Subscription & Quotas.',
                              );
                              context.push('/app/more/subscriptions');
                            },
                            icon: const Icon(
                              Icons.lock_outline_rounded,
                              size: 16,
                            ),
                            label: const Text('Schedule (Locked)'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (caseHearings.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'No hearings scheduled for this case yet.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: caseHearings.length,
                          separatorBuilder: (_, _) => const Divider(height: 14),
                          itemBuilder: (ctx, idx) {
                            final h = caseHearings[idx];
                            return InkWell(
                              onTap: () =>
                                  context.push('/app/hearings/${h.id}'),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            h.title,
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w700,
                                              color: isDark
                                                  ? Colors.white
                                                  : const Color(0xFF0F172A),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${h.date} • ${h.courtName}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    StatusBadge(
                                      status: h.status,
                                      showDot: true,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: const [
              SkeletonLoader(height: 150, borderRadius: 18),
              SizedBox(height: 16),
              SkeletonLoader(height: 180, borderRadius: 18),
              SizedBox(height: 16),
              SkeletonLoader(height: 140, borderRadius: 18),
            ],
          ),
        ),
        error: (err, _) => ErrorStateWidget(
          message: 'Unable to load case details: $err',
          onRetry: () => ref.refresh(caseDetailProvider(caseId)),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }

  Future<void> _toggleStatus(
    BuildContext context,
    WidgetRef ref,
    Case caseItem,
  ) async {
    final newStatus = caseItem.isOpen ? 'closed' : 'open';
    try {
      await ref
          .read(casesNotifierProvider.notifier)
          .updateCase(caseId, UpdateCaseRequest(status: newStatus));
      ref.invalidate(caseDetailProvider(caseId));
      if (context.mounted) {
        AppAlerts.showSuccess(
          context,
          'Case status updated to ${newStatus.toUpperCase()}',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppAlerts.showError(context, 'Failed to update case status: $e');
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Case?'),
        content: const Text(
          'Are you sure you want to delete this case? All associated hearing records and history will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(casesNotifierProvider.notifier).deleteCase(caseId);
        if (context.mounted) {
          AppAlerts.showSuccess(context, 'Case deleted successfully.');
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          AppAlerts.showError(context, 'Failed to delete case: $e');
        }
      }
    }
  }
}
