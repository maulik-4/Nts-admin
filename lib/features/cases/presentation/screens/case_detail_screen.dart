import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/capability_gate.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/lex_card.dart';
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
        title: const Text('Case Details'),
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
              icon: const Icon(Icons.delete_outline, color: LexColors.error),
              tooltip: 'Delete Case',
              onPressed: () => _confirmDelete(context, ref),
            ),
          ),
        ],
      ),
      body: caseAsync.when(
        data: (caseItem) {
          // Gather hearings from either the case object or hearingsProvider
          final List<Hearing> caseHearings =
              (hearingsAsync.valueOrNull
                  ?.where((h) => h.caseId == caseId)
                  .toList()) ??
              caseItem.hearings;

          final createdFormatted = caseItem.createdAt != null
              ? DateFormat('MMM d, yyyy').format(caseItem.createdAt!)
              : 'Unknown';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Overview Card
                LexCard(
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
                                  ? LexColors.surfaceDark
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isDark
                                    ? LexColors.borderDark
                                    : LexColors.borderLight,
                              ),
                            ),
                            child: Text(
                              caseItem.caseNumber,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? LexColors.accentGold
                                    : LexColors.slatePrimary,
                              ),
                            ),
                          ),
                          StatusBadge(status: caseItem.status),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        caseItem.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? LexColors.textPrimaryDark
                              : LexColors.slatePrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Type: ${caseItem.caseType} • Filed on $createdFormatted',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? LexColors.textSecondaryDark
                              : LexColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 14),

                      // Quick Status Toggle Action
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _toggleStatus(context, ref, caseItem),
                              icon: Icon(
                                caseItem.isOpen
                                    ? Icons.check_circle_outline
                                    : Icons.replay_outlined,
                                size: 16,
                              ),
                              label: Text(
                                caseItem.isOpen
                                    ? 'Mark as Closed'
                                    : 'Reopen Case',
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Case Information',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? LexColors.textPrimaryDark
                              : LexColors.slatePrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        'Client',
                        caseItem.clientName ?? 'Client #${caseItem.client}',
                        Icons.person_outline,
                        actionLabel: 'View',
                        onAction: () =>
                            context.push('/app/clients/${caseItem.client}'),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        'Court',
                        caseItem.courtName,
                        Icons.account_balance_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        'Assigned',
                        caseItem.assignedName?.isNotEmpty == true
                            ? caseItem.assignedName!
                            : 'Unassigned',
                        Icons.shield_outlined,
                      ),
                      if (caseItem.nextHearingDate != null) ...[
                        const SizedBox(height: 12),
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

                // Hearings Section
                LexCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hearings (${caseHearings.length})',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? LexColors.textPrimaryDark
                                  : LexColors.slatePrimary,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => context.push(
                              '/app/hearings/create?caseId=$caseId',
                            ),
                            icon: const Icon(Icons.add_alarm, size: 16),
                            label: const Text('Schedule'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (caseHearings.isEmpty)
                        Text(
                          'No hearings scheduled for this case yet.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? LexColors.textSecondaryDark
                                : LexColors.textSecondaryLight,
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: caseHearings.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 16),
                          itemBuilder: (context, index) {
                            final h = caseHearings[index];
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
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? LexColors.surfaceDark
                                            : LexColors.canvasLight,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.gavel_outlined,
                                        size: 18,
                                        color: LexColors.accentBronze,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            h.title,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${h.date}${h.startTime != null ? " • ${h.startTime}" : ""}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? LexColors.textSecondaryDark
                                                  : LexColors
                                                        .textSecondaryLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      size: 18,
                                      color: LexColors.textSecondaryLight,
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
                const SizedBox(height: 16),

                // Case Operations & Actions Card
                LexCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Operations & Case Files',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? LexColors.textPrimaryDark
                              : LexColors.slatePrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => context.push(
                                '/app/tasks/create?caseId=${caseItem.id}',
                              ),
                              icon: const Icon(Icons.add_task, size: 16),
                              label: const Text(
                                'Add Task',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => context.push(
                                '/app/more/documents/upload?caseId=${caseItem.id}',
                              ),
                              icon: const Icon(Icons.upload_file, size: 16),
                              label: const Text(
                                'Upload Doc',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => context.push(
                                '/app/more/payments/create?caseId=${caseItem.id}${caseItem.clientId != null ? "&clientId=${caseItem.clientId}" : ""}',
                              ),
                              icon: const Icon(
                                Icons.payments_outlined,
                                size: 16,
                              ),
                              label: const Text('Record Fee'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark
              ? LexColors.textSecondaryDark
              : LexColors.textSecondaryLight,
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 75,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? LexColors.textSecondaryDark
                  : LexColors.textSecondaryLight,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? LexColors.textPrimaryDark
                  : LexColors.textPrimaryLight,
            ),
          ),
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(width: 8),
          InkWell(
            onTap: onAction,
            child: Text(
              actionLabel,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: LexColors.accentBronze,
              ),
            ),
          ),
        ],
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Case status changed to ${newStatus.toUpperCase()}'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update case status: $e')),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Case?'),
        content: const Text(
          'Are you sure you want to delete this case? All associated hearing records and history may be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: TextButton.styleFrom(foregroundColor: LexColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(casesNotifierProvider.notifier).deleteCase(caseId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Case deleted successfully')),
          );
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to delete case: $e')));
        }
      }
    }
  }
}
