import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/client_portal_notifier.dart';
import '../theme/client_portal_theme.dart';
import '../widgets/assigned_counsel_card.dart';
import '../widgets/client_case_detail_sheet.dart';
import '../widgets/client_hearing_detail_sheet.dart';
import '../widgets/client_loading_skeleton.dart';
import '../widgets/client_portal_app_bar.dart';
import '../widgets/upcoming_hearing_card.dart';
import '../widgets/welcome_card.dart';
import '../../data/models/client_dashboard_model.dart';
import '../../data/models/client_document_model.dart';
import '../../../support/presentation/screens/support_tickets_list_screen.dart';

class ClientDashboardScreen extends ConsumerWidget {
  const ClientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(clientDashboardProvider);
    final documentsAsync = ref.watch(clientDocumentsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= 600;

    return Scaffold(
      backgroundColor: isDark
          ? ClientPortalColors.darkPageBackground
          : ClientPortalColors.pageBackground,
      appBar: const ClientPortalAppBar(title: 'Client Portal'),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'client_help_query_fab',
        onPressed: () => showCreateTicketModal(
          context,
          ref,
          initialCategory: 'legal',
        ),
        backgroundColor: ClientPortalColors.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.help_outline_rounded, size: 20),
        label: const Text(
          'Ask Query',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: dashboardAsync.when(
        data: (data) => _DashboardBody(
          data: data,
          documents: documentsAsync.value ?? [],
          isTablet: isTablet,
          isDark: isDark,
        ),
        loading: () => const _LoadingView(),
        error: (err, stack) => _ErrorView(
          error: err.toString(),
          onRetry: () {
            ref.invalidate(clientDashboardProvider);
            ref.invalidate(clientDocumentsProvider);
          },
        ),
      ),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  final ClientPortalDashboardData data;
  final List<ClientDocumentItem> documents;
  final bool isTablet;
  final bool isDark;

  const _DashboardBody({
    required this.data,
    required this.documents,
    required this.isTablet,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCasesCount = data.cases.length;
    final upcomingHearingsCount = data.hearings
        .where((h) => h.isUpcoming)
        .length;
    final documentsCount = documents.length;

    // Assigned lawyers (limit to top 3 on dashboard with View All)
    final topCounsel = data.assignedLawyers.take(3).toList();

    return RefreshIndicator(
      color: ClientPortalColors.primaryBlue,
      onRefresh: () async {
        // Will be triggered by pull to refresh
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: ClientPortalDimensions.maxContentWidth,
          ),
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet
                  ? ClientPortalDimensions.tabletPadding
                  : ClientPortalDimensions.mobilePadding,
              vertical: 16,
            ),
            children: [
              // 1. Welcome Card
              WelcomeCard(data: data),
              const SizedBox(height: 16),

              // 2. Metrics / Overview row
              Row(
                children: [
                  Expanded(
                    child: _StatMetricCard(
                      label: 'Active Cases',
                      count: activeCasesCount.toString(),
                      icon: Icons.work_outline_rounded,
                      color: ClientPortalColors.primaryBlue,
                      onTap: () => context.go('/client/cases'),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatMetricCard(
                      label: 'Upcoming',
                      count: upcomingHearingsCount.toString(),
                      icon: Icons.calendar_today_rounded,
                      color: ClientPortalColors.warning,
                      onTap: () => context.go('/client/hearings'),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatMetricCard(
                      label: 'Documents',
                      count: documentsCount.toString(),
                      icon: Icons.folder_outlined,
                      color: ClientPortalColors.success,
                      onTap: () => context.go('/client/documents'),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Upcoming Hearing Card
              UpcomingHearingCard(
                hearing: data.nextHearing,
                onTap: data.nextHearing != null
                    ? () => ClientHearingDetailSheet.show(
                        context,
                        hearing: data.nextHearing!,
                      )
                    : null,
              ),
              const SizedBox(height: 24),

              // 4. Assigned Counsel Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 18,
                        color: isDark
                            ? ClientPortalColors.darkPrimaryText
                            : ClientPortalColors.primaryNavy,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Assigned Counsel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: isDark
                              ? ClientPortalColors.darkPrimaryText
                              : ClientPortalColors.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                  if (data.assignedLawyers.length > 3)
                    TextButton(
                      onPressed: () {
                        // Show all counsel in dialog
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('All Assigned Counsel'),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: data.assignedLawyers.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, idx) =>
                                    AssignedCounselCard(
                                      counsel: data.assignedLawyers[idx],
                                    ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Row(
                        children: [
                          Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: ClientPortalColors.primaryBlue,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: ClientPortalColors.primaryBlue,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (topCounsel.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? ClientPortalColors.darkCardBackground
                        : ClientPortalColors.cardBackground,
                    borderRadius: BorderRadius.circular(
                      ClientPortalDimensions.cardRadius,
                    ),
                    border: Border.all(
                      color: isDark
                          ? ClientPortalColors.darkBorder
                          : ClientPortalColors.border,
                    ),
                  ),
                  child: Text(
                    'No assigned counsel recorded at this time.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark
                          ? ClientPortalColors.darkSecondaryText
                          : ClientPortalColors.secondaryText,
                    ),
                  ),
                )
              else
                ...topCounsel.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AssignedCounselCard(
                      counsel: c,
                      onTap: () {
                        // Find matching case if counsel is assigned to one
                        final matchingCase = data.cases
                            .where((cs) => cs.lawyerName == c.name)
                            .firstOrNull;

                        if (matchingCase != null) {
                          ClientCaseDetailSheet.show(
                            context,
                            caseItem: matchingCase,
                            relatedHearings: data.hearings
                                .where((h) => h.caseId == matchingCase.id)
                                .toList(),
                            assignedCounsel: [c],
                            relatedDocuments: documents
                                .where((d) => d.caseTitle == matchingCase.title)
                                .toList(),
                          );
                        }
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // 5. Helpdesk & Legal Queries Card
              _ClientHelpQueryCard(
                isDark: isDark,
                onViewAll: () => context.push('/client/support'),
                onNewQuery: () => showCreateTicketModal(
                  context,
                  ref,
                  initialCategory: 'legal',
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClientHelpQueryCard extends StatelessWidget {
  final bool isDark;
  final VoidCallback onViewAll;
  final VoidCallback onNewQuery;

  const _ClientHelpQueryCard({
    required this.isDark,
    required this.onViewAll,
    required this.onNewQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? ClientPortalColors.darkCardBackground
            : ClientPortalColors.cardBackground,
        borderRadius: BorderRadius.circular(ClientPortalDimensions.cardRadius),
        border: Border.all(
          color: isDark
              ? ClientPortalColors.darkBorder
              : ClientPortalColors.border,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A)
                .withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ClientPortalColors.primaryBlue.withValues(
                      alpha: isDark ? 0.2 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    color: ClientPortalColors.primaryBlue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Helpdesk & Legal Queries',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: isDark
                              ? ClientPortalColors.darkPrimaryText
                              : ClientPortalColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Direct assistance from your firm counsel & staff',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? ClientPortalColors.darkSecondaryText
                              : ClientPortalColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Have a question about your case filings, courtroom hearing schedules, or document submissions? Submit a query directly to the legal desk.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: isDark
                    ? ClientPortalColors.darkSecondaryText
                    : ClientPortalColors.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onNewQuery,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Ask a Query'),
                    style: FilledButton.styleFrom(
                      backgroundColor: ClientPortalColors.primaryNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewAll,
                    icon: const Icon(Icons.forum_outlined, size: 16),
                    label: const Text('View Queries'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark
                          ? Colors.white
                          : ClientPortalColors.primaryNavy,
                      side: BorderSide(
                        color: isDark
                            ? ClientPortalColors.darkBorder
                            : ClientPortalColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatMetricCard extends StatelessWidget {
  final String label;
  final String count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _StatMetricCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? ClientPortalColors.darkCardBackground
            : ClientPortalColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? ClientPortalColors.darkBorder
              : ClientPortalColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A)
                .withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 17, color: color),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        count,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? ClientPortalColors.darkPrimaryText
                              : ClientPortalColors.primaryNavy,
                        ),
                      ),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? ClientPortalColors.darkSecondaryText
                              : ClientPortalColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          ClientLoadingSkeleton(height: 140),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: ClientLoadingSkeleton(height: 60)),
              SizedBox(width: 10),
              Expanded(child: ClientLoadingSkeleton(height: 60)),
              SizedBox(width: 10),
              Expanded(child: ClientLoadingSkeleton(height: 60)),
            ],
          ),
          SizedBox(height: 16),
          ClientLoadingSkeleton(height: 170),
          SizedBox(height: 16),
          ClientLoadingSkeleton(height: 80),
          SizedBox(height: 10),
          ClientLoadingSkeleton(height: 80),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: ClientPortalColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 28,
                color: ClientPortalColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to Load Dashboard',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? ClientPortalColors.darkPrimaryText
                    : ClientPortalColors.primaryText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: isDark
                    ? ClientPortalColors.darkSecondaryText
                    : ClientPortalColors.secondaryText,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                backgroundColor: ClientPortalColors.primaryNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
