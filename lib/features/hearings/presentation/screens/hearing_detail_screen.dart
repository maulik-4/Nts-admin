import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../cases/presentation/providers/cases_notifier.dart';
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
        title: const Text('Hearing Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Hearing',
            onPressed: () => context.push('/app/hearings/$hearingId/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: LexColors.error),
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

          String dateFormatted = hearing.date;
          if (hearing.parsedDate != null) {
            dateFormatted = DateFormat('EEEE, MMMM d, yyyy')
                .format(hearing.parsedDate!);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
                LexCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? LexColors.surfaceDark
                                  : const Color(0xFFFEF3C7).withAlpha(140),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: LexColors.accentBronze.withAlpha(60),
                              ),
                            ),
                            child: const Icon(
                              Icons.gavel_outlined,
                              size: 24,
                              color: LexColors.accentBronze,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hearing.title,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? LexColors.textPrimaryDark
                                        : LexColors.slatePrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dateFormatted,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: LexColors.accentBronze,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Schedule and Venue Details
                LexCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Session & Venue',
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
                        'Time',
                        hearing.startTime != null
                            ? '${hearing.startTime}${hearing.endTime != null ? " to ${hearing.endTime}" : ""}'
                            : 'Time not specified',
                        Icons.schedule_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        'Court',
                        hearing.courtName,
                        Icons.account_balance_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        'Judge',
                        hearing.judgeName?.isNotEmpty == true
                            ? hearing.judgeName!
                            : 'Not specified',
                        Icons.person_pin_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Associated Case
                LexCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Associated Legal Case',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? LexColors.textPrimaryDark
                              : LexColors.slatePrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (associatedCase != null)
                        InkWell(
                          onTap: () =>
                              context.push('/app/cases/${associatedCase.id}'),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        associatedCase.title,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${associatedCase.caseNumber} • ${associatedCase.clientName ?? "Client"}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? LexColors.textSecondaryDark
                                              : LexColors.textSecondaryLight,
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
                        )
                      else
                        Text(
                          'Case #${hearing.caseId}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? LexColors.textSecondaryDark
                                : LexColors.textSecondaryLight,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Notes / Instructions
                LexCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hearing Notes & Instructions',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? LexColors.textPrimaryDark
                              : LexColors.slatePrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        hearing.notes?.isNotEmpty == true ? hearing.notes! : 'No specific notes recorded for this hearing session.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: isDark
                              ? LexColors.textSecondaryDark
                              : LexColors.textSecondaryLight,
                        ),
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
          color: isDark
              ? LexColors.textSecondaryDark
              : LexColors.textSecondaryLight,
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 70,
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
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Hearing?'),
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
            style: TextButton.styleFrom(foregroundColor: LexColors.error),
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hearing deleted successfully')),
          );
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete hearing: $e')),
          );
        }
      }
    }
  }
}
