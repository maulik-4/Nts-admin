import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_alerts.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../cases/presentation/providers/cases_notifier.dart';
import '../providers/hearings_notifier.dart';
import '../widgets/hearing_card.dart';

class HearingsListScreen extends ConsumerWidget {
  const HearingsListScreen({super.key});

  Widget _buildFilterPill({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? primaryColor : const Color(0xFF0F1F38))
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isDark ? primaryColor : const Color(0xFF0F1F38))
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F1F38).withAlpha(35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hearingsAsync = ref.watch(filteredHearingsProvider);
    final casesAsync = ref.watch(casesNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeFilter = ref.watch(hearingTimeFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hearings Agenda',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
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
        onPressed: () {
          AppAlerts.showWarning(
            context,
            'Hearings management is currently locked. Please review your Subscription & Quotas.',
          );
          context.push('/app/more/subscriptions');
        },
        backgroundColor: const Color(0xFF0F1F38),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.lock_outline_rounded, size: 20),
        label: const Text(
          'Schedule Hearing (Locked)',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
      ),
      body: Column(
        children: [
          // Blocked Service Paywall Notification
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withAlpha(isDark ? 30 : 20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF59E0B).withAlpha(120),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lock_clock_rounded,
                  color: Color(0xFFD97706),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Hearings Service is locked. Review Subscription & Quotas to unlock courtroom scheduling.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFFDE68A)
                          : const Color(0xFF92400E),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/app/more/subscriptions'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Upgrade',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: Color(0xFFD97706),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: TextField(
              onChanged: (val) =>
                  ref.read(hearingSearchQueryProvider.notifier).state = val,
              decoration: InputDecoration(
                hintText: 'Search hearings by title, court, judge...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5,
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
                _buildFilterPill(
                  context: context,
                  label: 'Upcoming Hearings',
                  isSelected: timeFilter == 'upcoming',
                  onTap: () =>
                      ref.read(hearingTimeFilterProvider.notifier).state =
                          'upcoming',
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  context: context,
                  label: 'Past Hearings',
                  isSelected: timeFilter == 'past',
                  onTap: () =>
                      ref.read(hearingTimeFilterProvider.notifier).state =
                          'past',
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  context: context,
                  label: 'All Hearings',
                  isSelected: timeFilter == 'all',
                  onTap: () =>
                      ref.read(hearingTimeFilterProvider.notifier).state =
                          'all',
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

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
                    actionLabel: 'View Subscription & Quotas',
                    onAction: () {
                      AppAlerts.showWarning(
                        context,
                        'Hearings management is currently locked. Please review your Subscription & Quotas.',
                      );
                      context.push('/app/more/subscriptions');
                    },
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
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
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
                    const SkeletonLoader(height: 120, borderRadius: 16),
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
