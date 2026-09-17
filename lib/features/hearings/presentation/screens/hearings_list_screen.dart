import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../cases/presentation/providers/cases_notifier.dart';
import '../providers/hearings_notifier.dart';
import '../widgets/hearing_card.dart';

class HearingsListScreen extends ConsumerWidget {
  const HearingsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hearingsAsync = ref.watch(filteredHearingsProvider);
    final casesAsync = ref.watch(casesNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeFilter = ref.watch(hearingTimeFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hearings Agenda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(hearingsNotifierProvider.notifier).loadHearings(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_schedule_hearing',
        onPressed: () => context.push('/app/hearings/create'),
        backgroundColor: isDark
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.primary,
        foregroundColor: isDark ? Colors.black : Colors.white,
        icon: const Icon(Icons.event_available_outlined, size: 20),
        label: const Text(
          'Schedule Hearing',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (val) =>
                  ref.read(hearingSearchQueryProvider.notifier).state = val,
              decoration: InputDecoration(
                hintText: 'Search hearings by title, court, judge...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: isDark
                    ? LexColors.surfaceDark
                    : LexColors.canvasLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark
                        ? LexColors.borderDark
                        : LexColors.borderLight,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark
                        ? LexColors.borderDark
                        : LexColors.borderLight,
                  ),
                ),
              ),
            ),
          ),

          // Time Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Upcoming Hearings'),
                  selected: timeFilter == 'upcoming',
                  onSelected: (_) =>
                      ref.read(hearingTimeFilterProvider.notifier).state =
                          'upcoming',
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Past Hearings'),
                  selected: timeFilter == 'past',
                  onSelected: (_) =>
                      ref.read(hearingTimeFilterProvider.notifier).state =
                          'past',
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('All Hearings'),
                  selected: timeFilter == 'all',
                  onSelected: (_) =>
                      ref.read(hearingTimeFilterProvider.notifier).state =
                          'all',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Content Area
          Expanded(
            child: hearingsAsync.when(
              data: (hearings) {
                if (hearings.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.event_busy_outlined,
                    title: 'No Hearings Found',
                    message:
                        'No scheduled courtroom hearings match your criteria.',
                    actionLabel: 'Schedule Hearing',
                    onAction: () => context.push('/app/hearings/create'),
                  );
                }

                // Map case titles for quick lookup
                final Map<int, String> caseTitleMap = {};
                final cases = casesAsync.valueOrNull ?? [];
                for (final c in cases) {
                  caseTitleMap[c.id] = '${c.caseNumber} - ${c.title}';
                }

                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(hearingsNotifierProvider.notifier)
                      .loadHearings(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                    itemCount: hearings.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final hearing = hearings[index];
                      return HearingCard(
                        hearing: hearing,
                        caseTitle: caseTitleMap[hearing.caseId],
                        onTap: () =>
                            context.push('/app/hearings/${hearing.id}'),
                      );
                    },
                  ),
                );
              },
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    const SkeletonLoader(height: 100, borderRadius: 12),
              ),
              error: (err, _) => ErrorStateWidget(
                message: err.toString(),
                onRetry: () =>
                    ref.read(hearingsNotifierProvider.notifier).loadHearings(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
