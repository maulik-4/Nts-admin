import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/client_portal_notifier.dart';
import '../theme/client_portal_theme.dart';
import '../widgets/client_case_card.dart';
import '../widgets/client_case_detail_sheet.dart';
import '../widgets/client_empty_state.dart';
import '../widgets/client_loading_skeleton.dart';
import '../widgets/client_portal_app_bar.dart';
import '../widgets/client_search_field.dart';
import '../../data/models/client_dashboard_model.dart';

class ClientCasesScreen extends ConsumerStatefulWidget {
  const ClientCasesScreen({super.key});

  @override
  ConsumerState<ClientCasesScreen> createState() => _ClientCasesScreenState();
}

class _ClientCasesScreenState extends ConsumerState<ClientCasesScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilterIndex = 0; // 0: All, 1: Active, 2: Closed

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ClientCaseItem> _filterCases(List<ClientCaseItem> cases, String query) {
    var list = cases;

    // Filter by Status Tab
    if (_selectedFilterIndex == 1) {
      list = list.where((c) {
        final s = c.status.toLowerCase();
        return s.contains('active') ||
            s.contains('progress') ||
            s.contains('open');
      }).toList();
    } else if (_selectedFilterIndex == 2) {
      list = list.where((c) {
        final s = c.status.toLowerCase();
        return s.contains('close') ||
            s.contains('settl') ||
            s.contains('resolv');
      }).toList();
    }

    // Filter by Search Query
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((c) {
        return c.title.toLowerCase().contains(q) ||
            c.caseNumber.toLowerCase().contains(q) ||
            c.courtName.toLowerCase().contains(q) ||
            c.lawyerName.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(clientDashboardProvider);
    final documentsAsync = ref.watch(clientDocumentsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= 600;

    return Scaffold(
      backgroundColor: isDark
          ? ClientPortalColors.darkPageBackground
          : ClientPortalColors.pageBackground,
      appBar: const ClientPortalAppBar(title: 'Cases', showBrandIcon: false),
      body: dashboardAsync.when(
        data: (data) {
          final allCases = data.cases;
          final activeCount = allCases.where((c) {
            final s = c.status.toLowerCase();
            return s.contains('active') ||
                s.contains('progress') ||
                s.contains('open');
          }).length;
          final closedCount = allCases.where((c) {
            final s = c.status.toLowerCase();
            return s.contains('close') ||
                s.contains('settl') ||
                s.contains('resolv');
          }).length;

          final docs = documentsAsync.value ?? [];

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: ClientPortalDimensions.maxContentWidth,
              ),
              child: Column(
                children: [
                  // Controls Header
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      isTablet
                          ? ClientPortalDimensions.tabletPadding
                          : ClientPortalDimensions.mobilePadding,
                      16,
                      isTablet
                          ? ClientPortalDimensions.tabletPadding
                          : ClientPortalDimensions.mobilePadding,
                      12,
                    ),
                    color: isDark
                        ? ClientPortalColors.darkPageBackground
                        : ClientPortalColors.pageBackground,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Matters & Legal Records',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? ClientPortalColors.darkSecondaryText
                                : ClientPortalColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClientSearchField(
                          controller: _searchController,
                          hintText:
                              'Search cases by title, number, or court...',
                          onChanged: (_) => setState(() {}),
                          onClear: () => setState(() {}),
                        ),
                        const SizedBox(height: 12),

                        // Segmented Status Filter
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E2D4A).withValues(alpha: 0.7)
                                : const Color(0xFFE2E8F0)
                                      .withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              _StatusFilterSegment(
                                label: 'All (${allCases.length})',
                                isSelected: _selectedFilterIndex == 0,
                                onTap: () =>
                                    setState(() => _selectedFilterIndex = 0),
                                isDark: isDark,
                              ),
                              _StatusFilterSegment(
                                label: 'Active ($activeCount)',
                                isSelected: _selectedFilterIndex == 1,
                                onTap: () =>
                                    setState(() => _selectedFilterIndex = 1),
                                isDark: isDark,
                              ),
                              _StatusFilterSegment(
                                label: 'Closed ($closedCount)',
                                isSelected: _selectedFilterIndex == 2,
                                onTap: () =>
                                    setState(() => _selectedFilterIndex = 2),
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Cases List
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final filtered = _filterCases(
                          allCases,
                          _searchController.text,
                        );

                        if (allCases.isEmpty) {
                          return const ClientEmptyState(
                            icon: Icons.work_off_outlined,
                            title: 'No Legal Cases Recorded',
                            description: 'There are currently no active legal cases linked to your client portal profile.',
                          );
                        }

                        if (filtered.isEmpty) {
                          return ClientEmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'No Matching Cases',
                            description: 'No cases match your filter criteria. Try adjusting your search keywords.',
                            actionLabel: 'Reset Filters',
                            onAction: () {
                              _searchController.clear();
                              setState(() => _selectedFilterIndex = 0);
                            },
                          );
                        }

                        return ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet
                                ? ClientPortalDimensions.tabletPadding
                                : ClientPortalDimensions.mobilePadding,
                            vertical: 12,
                          ),
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final caseItem = filtered[index];
                            final nextHearing = data.hearings
                                .where(
                                  (h) =>
                                      h.caseId == caseItem.id && h.isUpcoming,
                                )
                                .firstOrNull;

                            return ClientCaseCard(
                              caseItem: caseItem,
                              nextHearing: nextHearing,
                              onTap: () {
                                final relatedHearings = data.hearings
                                    .where((h) => h.caseId == caseItem.id)
                                    .toList();
                                final counsel = data.assignedLawyers
                                    .where((l) => l.name == caseItem.lawyerName)
                                    .toList();
                                final relatedDocs = docs
                                    .where((d) => d.caseTitle == caseItem.title)
                                    .toList();

                                ClientCaseDetailSheet.show(
                                  context,
                                  caseItem: caseItem,
                                  relatedHearings: relatedHearings,
                                  assignedCounsel: counsel,
                                  relatedDocuments: relatedDocs,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const _LoadingView(),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 44,
                  color: ClientPortalColors.error,
                ),
                const SizedBox(height: 12),
                Text('Failed to load cases: $err'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(clientDashboardProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusFilterSegment extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _StatusFilterSegment({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? ClientPortalColors.primaryNavy : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.3 : 0.05,
                      ),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? (isDark ? Colors.white : ClientPortalColors.primaryNavy)
                  : (isDark
                        ? ClientPortalColors.darkSecondaryText
                        : ClientPortalColors.secondaryText),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => const ClientLoadingSkeleton(height: 150),
    );
  }
}
