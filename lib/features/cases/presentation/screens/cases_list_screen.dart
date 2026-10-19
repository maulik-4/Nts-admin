import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_alerts.dart';
import '../../../../shared/widgets/capability_gate.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../auth/domain/models/role_capabilities.dart';
import '../providers/cases_notifier.dart';
import '../widgets/case_card.dart';

class CasesListScreen extends ConsumerWidget {
  const CasesListScreen({super.key});

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
    final casesAsync = ref.watch(filteredCasesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusFilter = ref.watch(caseStatusFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cases',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
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
          onPressed: () {
            AppAlerts.showWarning(
              context,
              'New Case creation is currently locked. Please review your Subscription & Quotas.',
            );
            context.push('/app/more/subscriptions');
          },
          backgroundColor: const Color(0xFF0F1F38),
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.lock_outline_rounded, size: 20),
          label: const Text(
            'New Case (Locked)',
            style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: TextField(
              onChanged: (val) =>
                  ref.read(caseSearchQueryProvider.notifier).state = val,
              decoration: InputDecoration(
                hintText: 'Search cases by name, client, number...',
                hintStyle: TextStyle(
                  fontSize: 13.5,
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

          // Status Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterPill(
                  context: context,
                  label: 'All Cases',
                  isSelected: statusFilter == null,
                  onTap: () =>
                      ref.read(caseStatusFilterProvider.notifier).state = null,
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  context: context,
                  label: 'Open',
                  isSelected: statusFilter == 'open',
                  onTap: () =>
                      ref.read(caseStatusFilterProvider.notifier).state =
                          'open',
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  context: context,
                  label: 'Closed',
                  isSelected: statusFilter == 'closed',
                  onTap: () =>
                      ref.read(caseStatusFilterProvider.notifier).state =
                          'closed',
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Content Area
          Expanded(
            child: casesAsync.when(
              data: (cases) {
                if (cases.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.folder_open_outlined,
                    title: 'No Cases Found',
                    message: 'No legal cases match your search query or filter criteria.',
                    actionLabel: 'View Subscription & Quotas',
                    onAction: () {
                      AppAlerts.showWarning(
                        context,
                        'New Case creation is currently locked. Please review your Subscription & Quotas.',
                      );
                      context.push('/app/more/subscriptions');
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(casesNotifierProvider.notifier).loadCases(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
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
                    const SkeletonLoader(height: 130, borderRadius: 16),
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
