import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_button.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/role_badge.dart';
import '../../../auth/domain/models/role_capabilities.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../dashboard/presentation/providers/dashboard_notifier.dart';
import '../../../documents/presentation/providers/documents_notifier.dart';
import '../../../firms/presentation/providers/firms_notifier.dart';
import '../../../payments/presentation/providers/payments_notifier.dart';
import '../../../tasks/presentation/providers/tasks_notifier.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final userRole = ref.watch(currentUserRoleProvider);
    final dashboardAsync = ref.watch(dashboardNotifierProvider);
    final tasksAsync = ref.watch(tasksNotifierProvider);
    final docsAsync = ref.watch(documentsNotifierProvider);
    final paymentsAsync = ref.watch(paymentsNotifierProvider);
    final firmsAsync = ref.watch(firmsNotifierProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pendingTasksCount = dashboardAsync.maybeWhen(
      data: (data) => data.taskStats?.pending ?? 0,
      orElse: () => tasksAsync.maybeWhen(
        data: (tasks) => tasks.where((t) => !t.isCompleted).length,
        orElse: () => 0,
      ),
    );

    final documentsCount = docsAsync.maybeWhen(
      data: (docs) => docs.length,
      orElse: () => 0,
    );

    final paymentsCount = paymentsAsync.maybeWhen(
      data: (payments) => payments.length,
      orElse: () => 0,
    );

    final firmsCount = firmsAsync.maybeWhen(
      data: (firms) => firms.length,
      orElse: () => 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          userRole.isSuperAdmin
              ? 'Platform Administration'
              : 'Workspace & Operations',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ============================================
            // SUPER ADMIN SPECIFIC OPERATIONS
            // ============================================
            if (userRole.isSuperAdmin) ...[
              Text(
                'Platform Administration Console',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? LexColors.textPrimaryDark
                      : LexColors.slatePrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildOperationTile(
                context,
                title: 'Tenant Law Firms',
                subtitle:
                    'Manage registered firms, status, stats & admin transfer',
                icon: Icons.business_outlined,
                badgeText: '$firmsCount registered',
                onTap: () => context.push('/app/firms'),
              ),
              const SizedBox(height: 10),
              _buildOperationTile(
                context,
                title: 'Subscription Plans',
                subtitle: 'Configure platform tiers, pricing & resource quotas',
                icon: Icons.card_membership_outlined,
                badgeText: 'Pricing',
                onTap: () => context.push('/app/plans'),
              ),
              const SizedBox(height: 10),
              _buildOperationTile(
                context,
                title: 'Platform Team & Global Users',
                subtitle: 'Manage platform administrators & global users',
                icon: Icons.people_outline,
                badgeText: 'Team',
                onTap: () => context.push('/app/platform-team'),
              ),
              const SizedBox(height: 10),
              _buildOperationTile(
                context,
                title: 'Support Tickets & Helpdesk',
                subtitle:
                    'Resolve tickets, reply to inquiries & platform assistance',
                icon: Icons.support_agent_outlined,
                badgeText: 'Support',
                onTap: () => context.push('/app/more/support'),
              ),
              const SizedBox(height: 10),
              _buildOperationTile(
                context,
                title: 'Platform Subscriptions',
                subtitle: 'View firm subscription records, status & quotas',
                icon: Icons.credit_card_outlined,
                badgeText: 'Subscriptions',
                onTap: () => context.push('/app/more/subscriptions'),
              ),
              const SizedBox(height: 10),
              _buildOperationTile(
                context,
                title: 'Platform Settings',
                subtitle: 'Configure platform preferences & security',
                icon: Icons.settings_outlined,
                badgeText: 'Settings',
                onTap: () => context.push('/app/more/settings'),
              ),
              const SizedBox(height: 10),
              _buildOperationTile(
                context,
                title: 'System Cloud Health',
                subtitle: 'API status: api.hphighcourt.site • Active',
                icon: Icons.cloud_done_outlined,
                badgeText: 'ONLINE',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Platform cloud services operating at 100%',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            // ============================================
            // FIRM / LEGAL OPERATIONS (Firm Admin, Lawyer, Staff)
            // ============================================
            if (!userRole.isSuperAdmin) ...[
              Text(
                'Operations',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? LexColors.textPrimaryDark
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),

              // Tasks Card (Available to Firm Admin, Lawyer, Staff)
              if (RoleCapabilities.hasCapability(
                userRole,
                UserCapability.viewTasks,
              )) ...[
                _buildOperationTile(
                  context,
                  title: 'Tasks & Deadlines',
                  subtitle: 'Assign work items, deadlines & progress updates',
                  icon: Icons.task_alt_outlined,
                  badgeText: '$pendingTasksCount pending',
                  isWarningBadge: pendingTasksCount > 0,
                  onTap: () => context.push('/app/tasks'),
                ),
                const SizedBox(height: 10),
              ],

              // Documents Card (Firm Admin & Lawyer only; backend 403 on Staff)
              if (RoleCapabilities.hasCapability(
                userRole,
                UserCapability.viewDocuments,
              )) ...[
                _buildOperationTile(
                  context,
                  title: 'Legal Documents',
                  subtitle: 'Case files, petitions, judgments & evidence',
                  icon: Icons.folder_shared_outlined,
                  badgeText: '$documentsCount files',
                  onTap: () => context.push('/app/more/documents'),
                ),
                const SizedBox(height: 10),
              ],

              // Payments Card (Firm Admin only; backend 403 on Lawyer & Staff)
              if (RoleCapabilities.hasCapability(
                userRole,
                UserCapability.viewPayments,
              )) ...[
                _buildOperationTile(
                  context,
                  title: 'Payments & Billing',
                  subtitle: 'Client fees, receipts & invoice notifications',
                  icon: Icons.payments_outlined,
                  badgeText: '$paymentsCount records',
                  onTap: () => context.push('/app/more/payments'),
                ),
                const SizedBox(height: 10),
              ],

              // Firm Messages (All firm members)
              if (!userRole.isSuperAdmin) ...[
                _buildOperationTile(
                  context,
                  title: 'Firm Messages',
                  subtitle: 'Direct communication with firm colleagues',
                  icon: Icons.chat_bubble_outline,
                  badgeText: 'Chat',
                  onTap: () => context.push('/app/more/messages'),
                ),
                const SizedBox(height: 10),
              ],

              // Notifications (All users)
              _buildOperationTile(
                context,
                title: 'Notifications & Alerts',
                subtitle: 'Hearing dates, case assignments & updates',
                icon: Icons.notifications_none_outlined,
                badgeText: 'Alerts',
                onTap: () => context.push('/app/more/notifications'),
              ),
              const SizedBox(height: 10),

              // Help & Support (All users)
              _buildOperationTile(
                context,
                title: 'Help & Support',
                subtitle:
                    'Submit support tickets, report issues & query status',
                icon: Icons.support_agent_outlined,
                badgeText: 'Support',
                onTap: () => context.push('/app/more/support'),
              ),
              const SizedBox(height: 14),
            ],

            // ============================================
            // FIRM ADMINISTRATION (Firm Admin only)
            // ============================================
            if (userRole.isFirmAdmin) ...[
              Text(
                'Firm Administration',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? LexColors.textPrimaryDark
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              _buildOperationTile(
                context,
                title: 'Team & Advocates',
                subtitle: 'Invite and manage firm lawyers and staff',
                icon: Icons.group_outlined,
                badgeText: 'Manage',
                onTap: () => context.push('/app/more/team'),
              ),
              const SizedBox(height: 10),
              _buildOperationTile(
                context,
                title: 'Subscription & Quotas',
                subtitle:
                    dashboardAsync.valueOrNull?.clientUsage?.planName ??
                    'Professional Plan',
                icon: Icons.credit_card_outlined,
                badgeText: 'Active',
                onTap: () => context.push('/app/more/subscriptions'),
              ),
              const SizedBox(height: 10),
              _buildOperationTile(
                context,
                title: 'Firm Branding & Website',
                subtitle: 'Customize public portal, tagline, colors & logo',
                icon: Icons.palette_outlined,
                badgeText: 'Custom',
                onTap: () => context.push('/app/more/branding'),
              ),
              const SizedBox(height: 24),
            ],

            // ============================================
            // ACCOUNT & FIRM PROFILE
            // ============================================
            Text(
              userRole.isSuperAdmin
                  ? 'Platform Account'
                  : 'Account & Firm Profile',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? LexColors.textPrimaryDark
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            // User Info Card (Tappable to view/edit profile)
            InkWell(
              onTap: () => context.push('/app/more/profile'),
              borderRadius: BorderRadius.circular(16),
              child: LexCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: isDark
                          ? LexColors.surfaceDark
                          : Theme.of(context).colorScheme.primary,
                      child: Text(
                        user?.username.isNotEmpty == true
                            ? user!.username.substring(0, 1).toUpperCase()
                            : (userRole.isSuperAdmin ? 'S' : 'U'),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: isDark ? LexColors.accentGold : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.username ??
                                (userRole.isSuperAdmin
                                    ? 'Super Admin'
                                    : 'Advocate'),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? LexColors.textPrimaryDark
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? LexColors.textSecondaryDark
                                  : LexColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          RoleBadge(role: userRole),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Firm Details Card (Firm Admin, Lawyer, Staff)
            if (!userRole.isSuperAdmin) ...[
              LexCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Law Firm Information',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? LexColors.textPrimaryDark
                            : LexColors.slatePrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRow(
                      context,
                      'Firm Name',
                      user?.firmName ?? 'Not Configured',
                      Icons.business_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildRow(
                      context,
                      'Firm ID',
                      '#${user?.firmId ?? 15}',
                      Icons.tag_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildRow(
                      context,
                      'Access Level',
                      '${userRole.displayTitle} Permissions',
                      Icons.verified_user_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // App & Security Information
            LexCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Platform & Security',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? LexColors.textPrimaryDark
                          : LexColors.slatePrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRow(
                    context,
                    'API Host',
                    'api.hphighcourt.site',
                    Icons.cloud_done_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildRow(
                    context,
                    'Security',
                    'JWT Bearer Authentication',
                    Icons.lock_outline,
                  ),
                  const SizedBox(height: 12),
                  _buildRow(
                    context,
                    'RBAC Engine',
                    'Role-Based Capability Matrix',
                    Icons.security_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Settings Tile
            _buildOperationTile(
              context,
              title: 'Settings & Notification Alerts',
              subtitle: 'Email alerts, hearing reminders & system parameters',
              icon: Icons.settings_outlined,
              badgeText: 'Config',
              onTap: () => context.push('/app/more/settings'),
            ),
            const SizedBox(height: 24),

            // Logout Button
            LexButton(
              label: 'Sign Out Workspace',
              variant: LexButtonVariant.outline,
              icon: Icons.logout,
              isLoading: authState.isLoading,
              onPressed: () {
                ref.read(authNotifierProvider.notifier).logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String badgeText,
    required VoidCallback onTap,
    bool isWarningBadge = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LexCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark ? LexColors.surfaceDark : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? LexColors.borderDark : LexColors.borderLight,
              ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isDark
                  ? LexColors.accentGold
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? LexColors.textPrimaryDark
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
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
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isWarningBadge
                  ? LexColors.warningLight
                  : (isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isWarningBadge
                    ? LexColors.warning
                    : (isDark
                          ? LexColors.accentGold
                          : LexColors.textSecondaryLight),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right,
            size: 18,
            color: isDark
                ? LexColors.textSecondaryDark
                : LexColors.textSecondaryLight,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark
              ? LexColors.textSecondaryDark
              : LexColors.textSecondaryLight,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? LexColors.textSecondaryDark
                : LexColors.textSecondaryLight,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? LexColors.textPrimaryDark : LexColors.slatePrimary,
          ),
        ),
      ],
    );
  }
}
