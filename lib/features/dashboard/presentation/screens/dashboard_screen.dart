import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/role_badge.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../auth/domain/models/role_capabilities.dart';
import '../../../auth/domain/models/user_role.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../cases/presentation/providers/cases_notifier.dart';
import '../../../clients/presentation/providers/clients_notifier.dart';
import '../../../documents/presentation/providers/documents_notifier.dart';
import '../../../firms/presentation/providers/firms_notifier.dart';
import '../../../hearings/presentation/providers/hearings_notifier.dart';
import '../../../payments/presentation/providers/payments_notifier.dart';
import '../../../subscriptions/presentation/providers/subscriptions_notifier.dart';
import '../../../tasks/presentation/providers/tasks_notifier.dart';
import '../../../team/presentation/providers/team_notifier.dart';
import '../../data/models/dashboard_models.dart';
import '../providers/dashboard_notifier.dart';
import '../widgets/metric_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _refreshAll(WidgetRef ref, UserRole role) async {
    // CRITICAL: Unknown or unassigned roles must NEVER invoke privileged backend APIs
    if (role == UserRole.unknown) {
      return;
    }

    if (role.isSuperAdmin) {
      await Future.wait([
        ref.read(firmsNotifierProvider.notifier).loadFirms(),
        ref.read(platformPlansNotifierProvider.notifier).loadPlans(),
        ref.read(teamNotifierProvider.notifier).loadTeamMembers(),
      ]);
      return;
    }

    final futures = <Future>[
      ref.read(dashboardNotifierProvider.notifier).loadDashboard(),
      ref.read(clientsNotifierProvider.notifier).loadClients(),
      ref.read(hearingsNotifierProvider.notifier).loadHearings(),
      ref.read(tasksNotifierProvider.notifier).loadTasks(),
    ];

    if (!role.isStaff) {
      futures.add(ref.read(casesNotifierProvider.notifier).loadCases());
      futures.add(ref.read(documentsNotifierProvider.notifier).loadDocuments());
    }

    if (role.isFirmAdmin) {
      futures.add(ref.read(paymentsNotifierProvider.notifier).loadPayments());
    }

    await Future.wait(futures);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(currentUserRoleProvider);
    final user = ref.watch(authNotifierProvider).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todayFormatted = DateFormat('EEEE, MMMM d, yyyy')
        .format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userRole.isSuperAdmin
                  ? 'Platform Overview'
                  : (user?.firmName ?? 'NTS Legal Pro'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              todayFormatted,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? LexColors.textSecondaryDark
                    : LexColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Workspace',
            onPressed: () => _refreshAll(ref, userRole),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshAll(ref, userRole),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Role-Specific Welcome Banner
              _buildRoleBanner(context, userRole, user),
              const SizedBox(height: 18),

              // Role-Specific Dashboard View
              if (userRole.isSuperAdmin)
                _buildSuperAdminDashboard(context, ref)
              else if (userRole.isStaff)
                _buildStaffDashboard(context, ref)
              else if (userRole.isLawyer)
                _buildLawyerDashboard(context, ref)
              else if (userRole.isFirmAdmin)
                _buildFirmAdminDashboard(context, ref)
              else
                _buildSafeDashboardFallback(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBanner(
    BuildContext context,
    UserRole userRole,
    dynamic user,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    IconData icon;
    String subtitle;

    switch (userRole) {
      case UserRole.superAdmin:
        icon = Icons.admin_panel_settings;
        subtitle = 'Platform Administrator • Full Registry Control';
        break;
      case UserRole.firmAdmin:
        icon = Icons.business_center_outlined;
        subtitle = '${user?.firmName ?? "Law Firm"} • Executive Command';
        break;
      case UserRole.lawyer:
        icon = Icons.balance;
        subtitle = 'Advocate Workspace • Cases & Hearings Agenda';
        break;
      case UserRole.staff:
        icon = Icons.task_alt;
        subtitle = 'Operations & Tasks Queue • Client Services';
        break;
      case UserRole.unknown:
        icon = Icons.person;
        subtitle = 'Workspace Member';
        break;
    }

    return LexCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: isDark
                ? LexColors.surfaceDark
                : LexColors.slatePrimary,
            child: Icon(
              icon,
              color: isDark ? LexColors.accentGold : Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${user?.username ?? (userRole.isSuperAdmin ? "Super Admin" : "Advocate")}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? LexColors.textPrimaryDark
                        : LexColors.slatePrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          RoleBadge(role: userRole),
        ],
      ),
    );
  }

  // ===========================================================================
  // 1. SUPER ADMIN DASHBOARD (Platform Overview)
  // ===========================================================================
  Widget _buildSuperAdminDashboard(BuildContext context, WidgetRef ref) {
    final firmsAsync = ref.watch(firmsNotifierProvider);
    final plansAsync = ref.watch(platformPlansNotifierProvider);
    final teamAsync = ref.watch(teamNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const superAdminGold = Color(0xFFC9A84C);

    return firmsAsync.when(
      data: (firms) {
        final totalFirms = firms.length;
        final activePlans = plansAsync.valueOrNull
                ?.where((p) => p.isActive && !p.isDeleted)
                .length ??
            0;
        final totalTeam = teamAsync.valueOrNull?.length ?? 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Quick Navigation Actions
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickActionButton(
                    context,
                    icon: Icons.business_outlined,
                    label: 'Manage Firms',
                    onTap: () => context.push('/app/firms'),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickActionButton(
                    context,
                    icon: Icons.card_membership_outlined,
                    label: 'Manage Plans',
                    onTap: () => context.push('/app/plans'),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickActionButton(
                    context,
                    icon: Icons.people_outline,
                    label: 'Platform Team',
                    onTap: () => context.push('/app/platform-team'),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickActionButton(
                    context,
                    icon: Icons.support_agent_outlined,
                    label: 'Support Tickets',
                    onTap: () => context.push('/app/more/support'),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickActionButton(
                    context,
                    icon: Icons.credit_card_outlined,
                    label: 'Subscriptions',
                    onTap: () => context.push('/app/more/subscriptions'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Platform Overview Statistics Chart (Section 8)
            _buildPlatformChart(
              context,
              totalFirms: totalFirms,
              activePlans: activePlans,
              platformTeam: totalTeam,
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // Platform Metrics (Total / Tenant Firms, Active Firms, Blocked / Inactive, Active Plans, Team)
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Tenant Firms',
                    value: '$totalFirms',
                    subtitle: 'Registered law firms',
                    icon: Icons.apartment_outlined,
                    iconColor: superAdminGold,
                    iconBgColor: superAdminGold.withAlpha(40),
                    onTap: () => context.push('/app/firms'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    title: 'Active Firms',
                    value:
                        '${firms.where((f) => f.isActive && !f.isBlocked).length}',
                    subtitle: 'Unblocked & active',
                    icon: Icons.verified_outlined,
                    iconColor: LexColors.success,
                    iconBgColor: LexColors.successLight,
                    onTap: () => context.push('/app/firms'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Blocked / Inactive',
                    value: '${firms.where((f) => f.isBlocked).length}',
                    subtitle: 'Access restricted',
                    icon: Icons.block_outlined,
                    iconColor: LexColors.error,
                    iconBgColor: LexColors.errorLight,
                    onTap: () => context.push('/app/firms'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    title: 'Active Plans',
                    value: '$activePlans',
                    subtitle: 'Configured tiers',
                    icon: Icons.card_membership_outlined,
                    iconColor: const Color(0xFF3B82F6),
                    iconBgColor: const Color(0xFF3B82F6).withAlpha(40),
                    onTap: () => context.push('/app/plans'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Platform Team',
                    value: '$totalTeam',
                    subtitle: 'Global users & team',
                    icon: Icons.badge_outlined,
                    iconColor: LexColors.slatePrimary,
                    iconBgColor: LexColors.accentLight.withAlpha(80),
                    onTap: () => context.push('/app/platform-team'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    title: 'Platform Status',
                    value: '100%',
                    subtitle: 'Cloud API operational',
                    icon: Icons.dns_outlined,
                    iconColor: const Color(0xFF3B82F6),
                    iconBgColor: const Color(0xFFEFF6FF),
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Tenant Firms Section
            LexCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tenant Law Firms Registry',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? LexColors.textPrimaryDark
                              : LexColors.slatePrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/app/firms'),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (firms.isEmpty)
                    const EmptyStateWidget(
                      icon: Icons.business_outlined,
                      title: 'No Tenant Firms',
                      message: 'No tenant firms found on the platform.',
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: firms.take(5).length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 14),
                      itemBuilder: (context, index) {
                        final firm = firms[index];
                        return InkWell(
                          onTap: () => context.push('/app/firms'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: isDark
                                      ? LexColors.surfaceDark
                                      : LexColors.canvasLight,
                                  child: Text(
                                    firm.name.isNotEmpty
                                        ? firm.name[0].toUpperCase()
                                        : 'F',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? LexColors.accentGold
                                          : LexColors.slatePrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        firm.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${firm.email} • ${firm.city ?? "India"}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark
                                              ? LexColors.textSecondaryDark
                                              : LexColors.textSecondaryLight,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadge(
                                  status: firm.isBlocked
                                      ? 'Blocked'
                                      : (firm.isActive ? 'Active' : 'Inactive'),
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
          ],
        );
      },
      loading: () => _buildSkeletonMetrics(),
      error: (err, _) => ErrorStateWidget(
        message: 'Could not load platform firms: $err',
        onRetry: () => ref.read(firmsNotifierProvider.notifier).loadFirms(),
      ),
    );
  }

  Widget _buildPlatformChart(
    BuildContext context, {
    required int totalFirms,
    required int activePlans,
    required int platformTeam,
    required bool isDark,
  }) {
    const goldColor = Color(0xFFC9A84C);
    final maxVal = [totalFirms, activePlans, platformTeam, 1]
        .reduce((a, b) => a > b ? a : b);

    return LexCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, color: goldColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Platform Overview Statistics',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? LexColors.textPrimaryDark
                      : LexColors.slatePrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildChartRow(
            'Total Firms',
            totalFirms,
            totalFirms / maxVal,
            goldColor,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildChartRow(
            'Active Plans',
            activePlans,
            activePlans / maxVal,
            const Color(0xFF3B82F6),
            isDark,
          ),
          const SizedBox(height: 12),
          _buildChartRow(
            'Platform Team',
            platformTeam,
            platformTeam / maxVal,
            LexColors.success,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildChartRow(
    String label,
    int count,
    double ratio,
    Color color,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? LexColors.textPrimaryDark
                    : LexColors.slatePrimary,
              ),
            ),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.05, 1.0),
            minHeight: 10,
            backgroundColor: isDark
                ? LexColors.surfaceDark
                : const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 2. FIRM ADMIN DASHBOARD (Executive Overview)
  // ===========================================================================
  Widget _buildFirmAdminDashboard(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardNotifierProvider);
    final paymentsAsync = ref.watch(paymentsNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return dashboardAsync.when(
      data: (data) {
        // Compute payments collection summary
        double totalCollections = 0.0;
        int paymentsCount = 0;
        paymentsAsync.whenData((payments) {
          paymentsCount = payments.length;
          for (final p in payments) {
            if (p.isPaid) {
              totalCollections += double.tryParse(p.amount) ?? 0.0;
            }
          }
        });

        final formattedCollections = NumberFormat.currency(
          symbol: '₹',
          decimalDigits: 0,
        ).format(totalCollections);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Firm Admin Quick Actions (Full Suite including Payment and Task)
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: Icons.add_circle_outline,
                    label: 'New Case',
                    onTap: () => context.push('/app/cases/create'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: Icons.person_add_outlined,
                    label: 'New Client',
                    onTap: () => context.push('/app/clients/create'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: Icons.event_available_outlined,
                    label: 'Hearing',
                    onTap: () => context.push('/app/hearings/create'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: Icons.payments_outlined,
                    label: 'Payment',
                    onTap: () => context.push('/app/more/payments/create'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: Icons.task_alt_outlined,
                    label: 'New Task',
                    onTap: () => context.push('/app/tasks/create'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Metrics Row 1: Clients & Cases
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Active Clients',
                    value: '${data.totalClients}',
                    subtitle: data.clientUsage?.unlimited == true
                        ? 'Unlimited quota'
                        : '${data.clientUsage?.used ?? data.totalClients} registered',
                    icon: Icons.people_outline,
                    iconColor: LexColors.accentWarm,
                    iconBgColor: LexColors.accentLight.withAlpha(120),
                    onTap: () => context.push('/app/clients'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    title: 'Total Cases',
                    value: '${data.totalCases}',
                    subtitle:
                        '${data.openCases} open • ${data.closedCases} closed',
                    icon: Icons.folder_outlined,
                    iconColor: LexColors.success,
                    iconBgColor: LexColors.successLight,
                    onTap: () => context.push('/app/cases'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Metrics Row 2: Hearings & Collections
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Hearings',
                    value: '${data.upcomingHearingsCount}',
                    subtitle: 'Courtroom calendar',
                    icon: Icons.gavel_outlined,
                    iconColor: LexColors.accentBronze,
                    iconBgColor: LexColors.accentLight.withAlpha(120),
                    onTap: () => context.push('/app/hearings'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    title: 'Firm Collections',
                    value: formattedCollections,
                    subtitle: '$paymentsCount billing receipts',
                    icon: Icons.payments_outlined,
                    iconColor: const Color(0xFF10B981),
                    iconBgColor: const Color(0xFFECFDF5),
                    onTap: () => context.push('/app/more/payments'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Upcoming Hearings Agenda Section
            _buildUpcomingHearingsCard(context, data, isDark),
            const SizedBox(height: 16),

            // Recent Cases Section
            _buildRecentCasesCard(context, data, isDark),
          ],
        );
      },
      loading: () => _buildSkeletonMetrics(),
      error: (err, _) => ErrorStateWidget(
        message: 'Could not load firm dashboard: $err',
        onRetry: () =>
            ref.read(dashboardNotifierProvider.notifier).loadDashboard(),
      ),
    );
  }

  // ===========================================================================
  // 3. LAWYER DASHBOARD (Case & Courtroom Workspace)
  // ===========================================================================
  Widget _buildLawyerDashboard(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardNotifierProvider);
    final docsAsync = ref.watch(documentsNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final documentsCount = docsAsync.maybeWhen(
      data: (docs) => docs.length,
      orElse: () => 0,
    );

    return dashboardAsync.when(
      data: (data) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Lawyer Quick Actions (Cases, Clients, Hearings, Tasks — No Payments)
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: Icons.add_circle_outline,
                    label: 'New Case',
                    onTap: () => context.push('/app/cases/create'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: Icons.person_add_outlined,
                    label: 'New Client',
                    onTap: () => context.push('/app/clients/create'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: Icons.event_available_outlined,
                    label: 'Hearing',
                    onTap: () => context.push('/app/hearings/create'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: Icons.task_alt_outlined,
                    label: 'New Task',
                    onTap: () => context.push('/app/tasks/create'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Lawyer Metrics: Active Cases, Upcoming Hearings, Pending Tasks, Documents
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Active Cases',
                    value: '${data.openCases}',
                    subtitle: '${data.totalCases} total portfolio',
                    icon: Icons.folder_outlined,
                    iconColor: LexColors.success,
                    iconBgColor: LexColors.successLight,
                    onTap: () => context.push('/app/cases'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    title: 'Court Hearings',
                    value: '${data.upcomingHearingsCount}',
                    subtitle: 'Scheduled appearances',
                    icon: Icons.gavel_outlined,
                    iconColor: LexColors.accentBronze,
                    iconBgColor: LexColors.accentLight.withAlpha(120),
                    onTap: () => context.push('/app/hearings'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Assigned Tasks',
                    value: '${data.taskStats?.pending ?? 0}',
                    subtitle: '${data.taskStats?.completed ?? 0} finished',
                    icon: Icons.check_circle_outline,
                    iconColor: const Color(0xFF3B82F6),
                    iconBgColor: const Color(0xFFEFF6FF),
                    onTap: () => context.push('/app/tasks'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    title: 'Documents',
                    value: '$documentsCount',
                    subtitle: 'Petitions & files',
                    icon: Icons.folder_shared_outlined,
                    iconColor: LexColors.accentWarm,
                    iconBgColor: LexColors.accentLight.withAlpha(120),
                    onTap: () => context.push('/app/more/documents'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Upcoming Hearings Agenda Section (Prominent for advocate)
            _buildUpcomingHearingsCard(context, data, isDark),
            const SizedBox(height: 16),

            // Recent Cases Section
            _buildRecentCasesCard(context, data, isDark),
          ],
        );
      },
      loading: () => _buildSkeletonMetrics(),
      error: (err, _) => ErrorStateWidget(
        message: 'Could not load advocate dashboard: $err',
        onRetry: () =>
            ref.read(dashboardNotifierProvider.notifier).loadDashboard(),
      ),
    );
  }

  // ===========================================================================
  // 4. STAFF DASHBOARD (Operational Support & Tasks Queue)
  // ===========================================================================
  Widget _buildStaffDashboard(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksNotifierProvider);
    final hearingsAsync = ref.watch(hearingsNotifierProvider);
    final clientsAsync = ref.watch(clientsNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return tasksAsync.when(
      data: (tasks) {
        final pendingTasks = tasks.where((t) => !t.isCompleted).toList();
        final completedTasks = tasks.where((t) => t.isCompleted).toList();
        final upcomingHearings = hearingsAsync.valueOrNull ?? [];
        final clientsCount = clientsAsync.valueOrNull?.length ?? 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Staff Quick Actions: Create Task & Create Client (Staff does NOT create cases or payments)
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: Icons.task_alt_outlined,
                    label: 'Create Task',
                    onTap: () => context.push('/app/tasks/create'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: Icons.person_add_outlined,
                    label: 'Register Client',
                    onTap: () => context.push('/app/clients/create'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: Icons.event_available_outlined,
                    label: 'Court Schedule',
                    onTap: () => context.push('/app/hearings'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Staff Operational Metrics: Pending Tasks, Completed Tasks, Hearings, Clients
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Pending Tasks',
                    value: '${pendingTasks.length}',
                    subtitle: 'Require action',
                    icon: Icons.assignment_late_outlined,
                    iconColor: LexColors.warning,
                    iconBgColor: LexColors.warningLight,
                    onTap: () => context.push('/app/tasks'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    title: 'Completed',
                    value: '${completedTasks.length}',
                    subtitle: 'Successfully closed',
                    icon: Icons.check_circle_outline,
                    iconColor: LexColors.success,
                    iconBgColor: LexColors.successLight,
                    onTap: () => context.push('/app/tasks'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Court Hearings',
                    value: '${upcomingHearings.length}',
                    subtitle: 'Lawyer appearances',
                    icon: Icons.gavel_outlined,
                    iconColor: LexColors.accentBronze,
                    iconBgColor: LexColors.accentLight.withAlpha(120),
                    onTap: () => context.push('/app/hearings'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    title: 'Clients',
                    value: '$clientsCount',
                    subtitle: 'Active roster',
                    icon: Icons.people_outline,
                    iconColor: LexColors.accentWarm,
                    iconBgColor: LexColors.accentLight.withAlpha(120),
                    onTap: () => context.push('/app/clients'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tasks Action Queue (Direct interactive completion for Staff)
            LexCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Operational Tasks Queue',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? LexColors.textPrimaryDark
                              : LexColors.slatePrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/app/tasks'),
                        child: const Text('All Tasks'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (pendingTasks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.task_alt,
                              size: 36,
                              color: LexColors.success,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'All tasks completed! Great work.',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pendingTasks.take(6).length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 14),
                      itemBuilder: (context, index) {
                        final task = pendingTasks[index];
                        return InkWell(
                          onTap: () => context.push('/app/tasks/${task.id}'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: task.isCompleted,
                                  onChanged: (val) {
                                    if (val == true) {
                                      ref
                                          .read(tasksNotifierProvider.notifier)
                                          .completeTask(task.id);
                                    }
                                  },
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (task.dueDate != null)
                                        Text(
                                          'Due: ${task.dueDate} • Priority: ${task.priority.displayName}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark
                                                ? LexColors.textSecondaryDark
                                                : LexColors.textSecondaryLight,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                StatusBadge(status: task.priority.name),
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

            // Court Hearings Schedule (Coordination for staff)
            LexCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Advocate Court Schedule',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? LexColors.textPrimaryDark
                              : LexColors.slatePrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/app/hearings'),
                        child: const Text('View Calendar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (upcomingHearings.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No upcoming court hearings currently scheduled.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? LexColors.textSecondaryDark
                              : LexColors.textSecondaryLight,
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: upcomingHearings.take(4).length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 14),
                      itemBuilder: (context, index) {
                        final h = upcomingHearings[index];
                        final dateStr = h.date;
                        return InkWell(
                          onTap: () => context.push('/app/hearings/${h.id}'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? LexColors.surfaceDark
                                        : const Color(0xFFFEF3C7)
                                              .withAlpha(120),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    dateStr,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: LexColors.accentBronze,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        h.courtName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${h.title} • ${h.judgeName ?? "Advocate Appearance"}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
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
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => _buildSkeletonMetrics(),
      error: (err, _) => ErrorStateWidget(
        message: 'Could not load staff operations: $err',
        onRetry: () => ref.read(tasksNotifierProvider.notifier).loadTasks(),
      ),
    );
  }

  // ===========================================================================
  // SHARED REUSABLE CARDS & SKELETONS
  // ===========================================================================
  Widget _buildUpcomingHearingsCard(
    BuildContext context,
    DashboardData data,
    bool isDark,
  ) {
    return LexCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Hearings',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? LexColors.textPrimaryDark
                      : LexColors.slatePrimary,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/app/hearings'),
                child: const Text('View Agenda'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (data.upcomingHearings.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No hearings scheduled in the immediate future.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? LexColors.textSecondaryDark
                      : LexColors.textSecondaryLight,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.upcomingHearings.length,
              separatorBuilder: (context, index) => const Divider(height: 14),
              itemBuilder: (context, index) {
                final h = data.upcomingHearings[index];
                return InkWell(
                  onTap: () => context.push('/app/hearings/${h.id}'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? LexColors.surfaceDark
                                : const Color(0xFFFEF3C7).withAlpha(120),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            h.date,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: LexColors.accentBronze,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                h.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                h.courtName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
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
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRecentCasesCard(
    BuildContext context,
    DashboardData data,
    bool isDark,
  ) {
    return LexCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Cases',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? LexColors.textPrimaryDark
                      : LexColors.slatePrimary,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/app/cases'),
                child: const Text('All Cases'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (data.recentCases.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No cases added to this workspace yet.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? LexColors.textSecondaryDark
                      : LexColors.textSecondaryLight,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.recentCases.length,
              separatorBuilder: (context, index) => const Divider(height: 14),
              itemBuilder: (context, index) {
                final c = data.recentCases[index];
                return InkWell(
                  onTap: () => context.push('/app/cases/${c.id}'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${c.caseNumber} • ${c.clientName ?? "Client"}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? LexColors.textSecondaryDark
                                      : LexColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(status: c.status),
                        const SizedBox(width: 4),
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
    );
  }

  Widget _buildSkeletonMetrics() {
    return Column(
      children: const [
        Row(
          children: [
            Expanded(child: SkeletonLoader(height: 105)),
            SizedBox(width: 12),
            Expanded(child: SkeletonLoader(height: 105)),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: SkeletonLoader(height: 105)),
            SizedBox(width: 12),
            Expanded(child: SkeletonLoader(height: 105)),
          ],
        ),
        SizedBox(height: 20),
        SkeletonLoader(height: 160),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? LexColors.surfaceDark : LexColors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? LexColors.borderDark : LexColors.borderLight,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark ? LexColors.accentGold : LexColors.slatePrimary,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? LexColors.textPrimaryDark
                    : LexColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 5. SAFE DASHBOARD FALLBACK (Unknown / Unassigned Role)
  // ===========================================================================
  Widget _buildSafeDashboardFallback(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LexCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 56,
            color: isDark
                ? LexColors.textSecondaryDark
                : LexColors.textSecondaryLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Account Under Review',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? LexColors.textPrimaryDark
                  : LexColors.slatePrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your account role is currently unassigned or pending verification. Privileged workspace operations and APIs are disabled for security. Please contact your firm administrator or support.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark
                  ? LexColors.textSecondaryDark
                  : LexColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => context.push('/app/more/profile'),
                icon: const Icon(Icons.person_outline, size: 18),
                label: const Text('View Profile'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(authNotifierProvider.notifier).logout(),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Log Out'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

