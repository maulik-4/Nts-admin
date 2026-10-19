import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/app_alerts.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../cases/presentation/providers/cases_notifier.dart';
import '../../../clients/presentation/providers/clients_notifier.dart';
import '../../../communications/presentation/widgets/whatsapp_composer_modal.dart';
import '../../data/repositories/hearings_repository.dart';
import '../providers/hearings_notifier.dart';

final hearingDetailProvider = FutureProvider.family<dynamic, int>((
  ref,
  id,
) async {
  final list = ref.watch(hearingsNotifierProvider).valueOrNull;
  if (list != null) {
    final found = list.where((h) => h.id == id);
    if (found.isNotEmpty) return found.first;
  }
  final repo = ref.watch(hearingsRepositoryProvider);
  return repo.getHearing(id);
});

class HearingDetailScreen extends ConsumerWidget {
  final int hearingId;

  const HearingDetailScreen({super.key, required this.hearingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hearingAsync = ref.watch(hearingDetailProvider(hearingId));
    final casesAsync = ref.watch(casesNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hearing Details',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.chat_bubble_rounded,
              color: Color(0xFF25D366),
            ),
            tooltip: 'Send WhatsApp Reminder',
            onPressed: () {
              final hearing = hearingAsync.valueOrNull;
              if (hearing == null) return;
              final associatedCase = casesAsync.valueOrNull
                  ?.where((c) => c.id == hearing.caseId)
                  .firstOrNull;
              final clients =
                  ref.read(clientsNotifierProvider).valueOrNull ?? [];
              final client = clients
                  .where((c) => c.id == associatedCase?.client)
                  .firstOrNull;

              WhatsAppComposerModal.show(
                context,
                clientId: associatedCase?.client ?? 0,
                recipientName: client?.name ?? 'Client',
                recipientNumber: client?.phone ?? '',
                caseId: associatedCase?.id,
                caseTitle: associatedCase?.title,
                defaultTemplate: 'hearing_reminder',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Hearing',
            onPressed: () => context.push('/app/hearings/$hearingId/edit'),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFEF4444),
            ),
            tooltip: 'Delete Hearing',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: hearingAsync.when(
        data: (hearing) {
          final associatedCase = casesAsync.valueOrNull
              ?.where((c) => c.id == hearing.caseId)
              .firstOrNull;

          String weekdayFormatted = 'UPCOMING HEARING';
          String dateFormatted = hearing.date;
          if (hearing.parsedDate != null) {
            weekdayFormatted = DateFormat('EEEE, MMMM d, yyyy')
                .format(hearing.parsedDate!)
                .toUpperCase();
            dateFormatted = DateFormat('MMMM d, yyyy')
                .format(hearing.parsedDate!);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
                LexCard(
                  borderRadius: 20,
                  leftAccentColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFDBEAFE),
                              ),
                            ),
                            child: const Icon(
                              Icons.gavel_rounded,
                              size: 26,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  weekdayFormatted,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  hearing.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          StatusBadge(status: hearing.status, showDot: true),
                          const Spacer(),
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
                            ),
                            child: Text(
                              hearing.hearingType.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                                color: isDark
                                    ? const Color(0xFFCBD5E1)
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Session and Venue Details
                LexCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Session & Venue',
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
                        'Date',
                        dateFormatted,
                        Icons.event_outlined,
                      ),
                      const Divider(height: 18),
                      _buildInfoRow(
                        context,
                        'Time',
                        hearing.startTime != null
                            ? '${hearing.startTime}${hearing.endTime != null ? " - ${hearing.endTime}" : ""}'
                            : 'Time not specified',
                        Icons.access_time_rounded,
                      ),
                      const Divider(height: 18),
                      _buildInfoRow(
                        context,
                        'Courtroom',
                        hearing.courtName.isNotEmpty
                            ? hearing.courtName
                            : 'Court Unspecified',
                        Icons.account_balance_rounded,
                      ),
                      if (hearing.judgeName?.isNotEmpty == true) ...[
                        const Divider(height: 18),
                        _buildInfoRow(
                          context,
                          'Judge',
                          hearing.judgeName!,
                          Icons.person_pin_rounded,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Associated Case
                LexCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.folder_open_rounded,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Associated Legal Case',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (associatedCase != null)
                        InkWell(
                          onTap: () =>
                              context.push('/app/cases/${associatedCase.id}'),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        associatedCase.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${associatedCase.caseNumber} • ${associatedCase.clientName ?? "Client #${associatedCase.client}"}',
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
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 20,
                                  color: Color(0xFF94A3B8),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Text(
                          'Case #${hearing.caseId}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Notes / Instructions
                LexCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notes_rounded,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Hearing Notes & Instructions',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        hearing.notes?.isNotEmpty == true ? hearing.notes! : 'No specific preparation notes recorded for this hearing session.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: isDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF475569),
                        ),
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
              SkeletonLoader(height: 120, borderRadius: 18),
              SizedBox(height: 16),
              SkeletonLoader(height: 180, borderRadius: 18),
              SizedBox(height: 16),
              SkeletonLoader(height: 120, borderRadius: 18),
            ],
          ),
        ),
        error: (err, _) => ErrorStateWidget(
          message: 'Unable to load hearing details: $err',
          onRetry: () => ref.refresh(hearingDetailProvider(hearingId)),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Scheduled Hearing?'),
        content: const Text(
          'Are you sure you want to remove this scheduled hearing from the agenda?',
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
        await ref
            .read(hearingsNotifierProvider.notifier)
            .deleteHearing(hearingId);
        if (context.mounted) {
          AppAlerts.showSuccess(context, 'Hearing removed from agenda.');
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          AppAlerts.showError(context, 'Failed to delete hearing: $e');
        }
      }
    }
  }
}
