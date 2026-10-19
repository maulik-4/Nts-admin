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

  Widget _buildOperationTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String badgeText,
    required VoidCallback onTap,
    bool isWarningBadge = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LexCard(
      onTap: onTap,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? iconColor.withAlpha(35) : iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? LexColors.textPrimaryDark
                        : const Color(0xFF0F172A),
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
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: isWarningBadge
                  ? (isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7))
                  : (isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isWarningBadge
                    ? (isDark
                          ? const Color(0xFFB45309)
                          : const Color(0xFFFDE68A))
                    : (isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0)),
              ),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isWarningBadge
                    ? const Color(0xFFD97706)
                    : (isDark
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF475569)),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
        ],
      ),
    );
  }

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

    final firmDisplayName =
        (user?.firmName != null && user!.firmName!.trim().isNotEmpty)
        ? user.firmName!
        : 'LexTech Law Practice';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              firmDisplayName,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            Text(
              userRole.isSuperAdmin
                  ? 'Platform Administration'
                  : 'Workspace & Operations',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? LexColors.textSecondaryDark
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/app/more/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ============================================
            // PROFILE CARD WITH SUMMARY STRIP
            // ============================================
            GestureDetector(
              onTap: () => context.push('/app/more/profile'),
              child: LexCard(
                borderRadius: 18,
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF0F1F38),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              user?.username.isNotEmpty == true
                                  ? user!.username.substring(0, 1).toUpperCase()
                                  : (userRole.isSuperAdmin ? 'S' : 'A'),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
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
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user?.email ?? '',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  RoleBadge(role: userRole),
                                  const SizedBox(width: 8),
                                  Text(
                                    'ID: #${user?.id ?? 1}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? const Color(0xFF64748B)
                                          : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                      ],
                    ),

                    if (!userRole.isSuperAdmin) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'FIRM',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF64748B),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  firmDisplayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 26,
                              color: const Color(0xFFCBD5E1),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ACCESS LEVEL',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF64748B),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  userRole.displayTitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 26,
                              color: const Color(0xFFCBD5E1),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'MEMBERS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF64748B),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Active Firm',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ============================================
            // SUPER ADMIN SPECIFIC OPERATIONS
            // ============================================
            if (userRole.isSuperAdmin) ...[
              Text(
                'PLATFORM ADMINISTRATION',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 10),
              _buildOperationTile(
                context,
                title: 'Tenant Law Firms',
                subtitle:
                    'Manage registered firms, status, stats & admin transfer',
                icon: Icons.business_rounded,
                iconColor: const Color(0xFF2563EB),
                iconBgColor: const Color(0xFFEFF6FF),
                badgeText: '$firmsCount registered',
                onTap: () => context.push('/app/firms'),
              ),
              const SizedBox(height: 10),
              _buildOperationTile(
                context,
                title: 'Subscription Plans',
                subtitle: 'Configure platform tiers, pricing & resource quotas',
                icon: Icons.card_membership_rounded,
                iconColor: const Color(0xFF059669),
                iconBgColor: const Color(0xFFECFDF5),
                badgeText: 'Pricing',
                onTap: () => context.push('/app/plans'),
              ),
              const SizedBox(height: 10),
              _buildOperationTile(
                context,
                title: 'Platform Team & Global Users',
                subtitle: 'Manage platform administrators & global users',
                icon: Icons.people_alt_rounded,
                iconColor: const Color(0xFF7C3AED),
                iconBgColor: const Color(0xFFF5F3FF),
                badgeText: 'Team',
                onTap: () => context.push('/app/platform-team'),
              ),
              const SizedBox(height: 10),
              _buildOperationTile(
                context,
                title: 'Support Tickets & Helpdesk',
                subtitle:
                    'Resolve tickets, reply to inquiries & platform assistance',
                icon: Icons.support_agent_rounded,
                iconColor: const Color(0xFFEA580C),
                iconBgColor: const Color(0xFFFFF7ED),
                badgeText: 'Support',
                onTap: () => context.push('/app/more/support'),
              ),
              const SizedBox(height: 10),
              _buildOperationTile(
                context,
                title: 'Platform Subscriptions',
                subtitle: 'View firm subscription records, status & quotas',
                icon: Icons.credit_card_rounded,
                iconColor: const Color(0xFF0891B2),
                iconBgColor: const Color(0xFFECFEFF),
                badgeText: 'Subscriptions',
                onTap: () => context.push('/app/more/subscriptions'),
              ),
              const SizedBox(height: 20),
            ],

            // ============================================
            // FIRM / LEGAL OPERATIONS (Firm Admin, Lawyer, Staff)
            // ============================================
            if (!userRole.isSuperAdmin) ...[
              Text(
                'OPERATIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 10),

              // Tasks Card
              if (RoleCapabilities.hasCapability(
                userRole,
                UserCapability.viewTasks,
              )) ...[
                _buildOperationTile(
                  context,
                  title: 'Tasks & Deadlines',
                  subtitle: 'Assign work items, deadlines & progress updates',
                  icon: Icons.task_alt_rounded,
                  iconColor: const Color(0xFF2563EB),
                  iconBgColor: const Color(0xFFEFF6FF),
                  badgeText: '$pendingTasksCount pending',
                  isWarningBadge: pendingTasksCount > 0,
                  onTap: () => context.push('/app/tasks'),
                ),
                const SizedBox(height: 10),
              ],

              // Documents Card
              if (RoleCapabilities.hasCapability(
                userRole,
                UserCapability.viewDocuments,
              )) ...[
                _buildOperationTile(
                  context,
                  title: 'Legal Documents',
                  subtitle: 'Case files, petitions, judgments & evidence',
                  icon: Icons.folder_shared_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  iconBgColor: const Color(0xFFF5F3FF),
                  badgeText: '$documentsCount files',
                  onTap: () => context.push('/app/more/documents'),
                ),
                const SizedBox(height: 10),
              ],

              // Payments Card
              if (RoleCapabilities.hasCapability(
                userRole,
                UserCapability.viewPayments,
              )) ...[
                _buildOperationTile(
                  context,
                  title: 'Payments & Billing',
                  subtitle: 'Client fees, receipts & invoice notifications',
                  icon: Icons.payments_rounded,
                  iconColor: const Color(0xFF059669),
                  iconBgColor: const Color(0xFFECFDF5),
                  badgeText: '$paymentsCount records',
                  onTap: () => context.push('/app/more/payments'),
                ),
                const SizedBox(height: 10),
              ],

              // Firm Messages
              _buildOperationTile(
                context,
                title: 'Firm Messages',
                subtitle: 'Direct communication with firm colleagues',
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: const Color(0xFF0891B2),
                iconBgColor: const Color(0xFFECFEFF),
                badgeText: 'Chat',
                onTap: () => context.push('/app/more/messages'),
              ),
              const SizedBox(height: 10),

              // Notifications
              _buildOperationTile(
                context,
                title: 'Notifications & Alerts',
                subtitle: 'Hearing dates, case assignments & updates',
                icon: Icons.notifications_none_rounded,
                iconColor: const Color(0xFFD97706),
                iconBgColor: const Color(0xFFFFFBEB),
                badgeText: 'Alerts',
                onTap: () => context.push('/app/more/notifications'),
              ),
              const SizedBox(height: 10),

              // Help & Support
              _buildOperationTile(
                context,
                title: 'Help & Support',
                subtitle:
                    'Submit support tickets, report issues & query status',
                icon: Icons.support_agent_rounded,
                iconColor: const Color(0xFFE11D48),
                iconBgColor: const Color(0xFFFFF1F2),
                badgeText: 'Support',
                onTap: () => context.push('/app/more/support'),
              ),
              const SizedBox(height: 20),
            ],

            // ============================================
            // FIRM ADMINISTRATION (Firm Admin only)
            // ============================================
            if (userRole.isFirmAdmin) ...[
              Text(
                'FIRM ADMINISTRATION',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 10),
              _buildOperationTile(
                context,
                title: 'Team & Advocates',
                subtitle: 'Invite and manage firm lawyers and staff',
                icon: Icons.group_outlined,
                iconColor: const Color(0xFF2563EB),
                iconBgColor: const Color(0xFFEFF6FF),
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
                iconColor: const Color(0xFF059669),
                iconBgColor: const Color(0xFFECFDF5),
                badgeText: 'Active',
                onTap: () => context.push('/app/more/subscriptions'),
              ),
              const SizedBox(height: 10),
              _buildOperationTile(
                context,
                title: 'Firm Branding & Website',
                subtitle: 'Customize public portal, tagline, colors & logo',
                icon: Icons.palette_outlined,
                iconColor: const Color(0xFFD97706),
                iconBgColor: const Color(0xFFFFFBEB),
                badgeText: 'Custom',
                onTap: () => context.push('/app/more/branding'),
              ),
              const SizedBox(height: 20),
            ],

            // ============================================
            // SIGN OUT
            // ============================================
            LexButton(
              label: 'Sign Out Workspace',
              variant: LexButtonVariant.outline,
              icon: Icons.logout_rounded,
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
}
