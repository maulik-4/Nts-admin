import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/capability_gate.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../auth/domain/models/role_capabilities.dart';
import '../providers/cases_notifier.dart';
import '../widgets/case_card.dart';

class CasesListScreen extends ConsumerWidget {
  const CasesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final casesAsync = ref.watch(filteredCasesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusFilter = ref.watch(caseStatusFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cases'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(casesNotifierProvider.notifier).loadCases(),
          ),
        ],
      ),
      floatingActionButton: CapabilityGate(
        capability: UserCapability.createCases,
        child: FloatingActionButton.extended(
          heroTag: 'fab_add_case',
          onPressed: () => context.push('/app/cases/create'),
          backgroundColor: isDark
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.primary,
          foregroundColor: isDark ? Colors.black : Colors.white,
          icon: const Icon(Icons.add_circle_outline, size: 20),
          label: const Text(
            'New Case',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (val) =>
                  ref.read(caseSearchQueryProvider.notifier).state = val,
              decoration: InputDecoration(
                hintText: 'Search by case number, title, court...',
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

          // Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All Cases'),
                  selected: statusFilter == null,
                  onSelected: (_) =>
                      ref.read(caseStatusFilterProvider.notifier).state = null,
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Open'),
                  selected: statusFilter == 'open',
                  onSelected: (_) =>
                      ref.read(caseStatusFilterProvider.notifier).state =
                          'open',
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Closed'),
                  selected: statusFilter == 'closed',
                  onSelected: (_) =>
                      ref.read(caseStatusFilterProvider.notifier).state =
                          'closed',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Content Area
          Expanded(
            child: casesAsync.when(
              data: (cases) {
                if (cases.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.folder_open_outlined,
                    title: 'No Cases Found',
                    message: 'No legal cases match your search query or filter criteria.',
                    actionLabel: 'Create New Case',
                    onAction: () => context.push('/app/cases/create'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(casesNotifierProvider.notifier).loadCases(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                    itemCount: cases.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final caseItem = cases[index];
                      return CaseCard(
                        caseItem: caseItem,
                        onTap: () => context.push('/app/cases/${caseItem.id}'),
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
                    const SkeletonLoader(height: 120, borderRadius: 12),
              ),
              error: (err, _) => ErrorStateWidget(
                message: err.toString(),
                onRetry: () =>
                    ref.read(casesNotifierProvider.notifier).loadCases(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
