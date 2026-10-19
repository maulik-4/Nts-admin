import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/client_portal_notifier.dart';
import '../theme/client_portal_theme.dart';
import '../widgets/client_empty_state.dart';
import '../widgets/client_hearing_card.dart';
import '../widgets/client_hearing_detail_sheet.dart';
import '../widgets/client_loading_skeleton.dart';
import '../widgets/client_portal_app_bar.dart';
import '../widgets/client_search_field.dart';
import '../../data/models/client_dashboard_model.dart';

class ClientHearingsScreen extends ConsumerStatefulWidget {
  const ClientHearingsScreen({super.key});

  @override
  ConsumerState<ClientHearingsScreen> createState() =>
      _ClientHearingsScreenState();
}

class _ClientHearingsScreenState extends ConsumerState<ClientHearingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilterIndex = 0; // 0: All, 1: Upcoming, 2: Past

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<HearingItem> _filterHearings(List<HearingItem> hearings, String query) {
    var list = hearings;

    // Filter by Tab (Upcoming vs Past)
    if (_selectedFilterIndex == 1) {
      list = list.where((h) => h.isUpcoming).toList();
    } else if (_selectedFilterIndex == 2) {
      list = list.where((h) => !h.isUpcoming).toList();
    }

    // Filter by Search Query
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((h) {
        return h.title.toLowerCase().contains(q) ||
            h.caseTitle.toLowerCase().contains(q) ||
            h.caseNumber.toLowerCase().contains(q) ||
            h.courtName.toLowerCase().contains(q) ||
            h.judgeName.toLowerCase().contains(q);
      }).toList();
    }

    // Sort by date: upcoming earliest first, past newest first
    final sorted = List<HearingItem>.from(list);
    sorted.sort((a, b) {
      try {
        final da = DateTime.parse(a.date);
        final db = DateTime.parse(b.date);
        return _selectedFilterIndex == 2
            ? db.compareTo(da) // Past: newest first
            : da.compareTo(db); // Upcoming / All: earliest first
      } catch (_) {
        return 0;
      }
    });

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(clientDashboardProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= 600;

    return Scaffold(
      backgroundColor: isDark
          ? ClientPortalColors.darkPageBackground
          : ClientPortalColors.pageBackground,
      appBar: const ClientPortalAppBar(title: 'Hearings', showBrandIcon: false),
      body: dashboardAsync.when(
        data: (data) {
          final allHearings = data.hearings;
          final upcomingCount = allHearings.where((h) => h.isUpcoming).length;
          final pastCount = allHearings.where((h) => !h.isUpcoming).length;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: ClientPortalDimensions.maxContentWidth,
              ),
              child: Column(
                children: [
                  // Search & Filter Header
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
                          'Court Appearances & Sessions',
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
                              'Search hearings by case, court, or title...',
                          onChanged: (_) => setState(() {}),
                          onClear: () => setState(() {}),
                        ),
                        const SizedBox(height: 12),

                        // Segmented Filter Bar
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
                              _FilterSegment(
                                label: 'All (${allHearings.length})',
                                isSelected: _selectedFilterIndex == 0,
                                onTap: () =>
                                    setState(() => _selectedFilterIndex = 0),
                                isDark: isDark,
                              ),
                              _FilterSegment(
                                label: 'Upcoming ($upcomingCount)',
                                isSelected: _selectedFilterIndex == 1,
                                onTap: () =>
                                    setState(() => _selectedFilterIndex = 1),
                                isDark: isDark,
                              ),
                              _FilterSegment(
                                label: 'Past ($pastCount)',
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

                  // Hearings List
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final filtered = _filterHearings(
                          allHearings,
                          _searchController.text,
                        );

                        if (allHearings.isEmpty) {
                          return const ClientEmptyState(
                            icon: Icons.event_busy_rounded,
                            title: 'No Court Hearings Recorded',
                            description: 'There are no active or past court hearings linked to your client profile.',
                          );
                        }

                        if (filtered.isEmpty) {
                          return ClientEmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'No Matching Hearings',
                            description: 'No hearings match your current search criteria. Try a different query or filter.',
                            actionLabel: 'Clear Search',
                            onAction: () {
                              _searchController.clear();
                              setState(() {
                                _selectedFilterIndex = 0;
                              });
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
                            final hearing = filtered[index];
                            return ClientHearingCard(
                              hearing: hearing,
                              onTap: () => ClientHearingDetailSheet.show(
                                context,
                                hearing: hearing,
                              ),
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
                Text('Failed to load hearings: $err'),
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

class _FilterSegment extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _FilterSegment({
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
      itemBuilder: (context, index) => const ClientLoadingSkeleton(height: 140),
    );
  }
}
