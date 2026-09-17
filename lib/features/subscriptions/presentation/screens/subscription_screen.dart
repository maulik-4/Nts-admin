import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../auth/domain/models/role_capabilities.dart';
import '../../data/models/subscription_models.dart';
import '../providers/subscriptions_notifier.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  void _confirmPlanActivation(
    BuildContext context,
    WidgetRef ref,
    SubscriptionPlan plan,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Activate ${plan.name}'),
        content: Text(
          'Do you want to switch your firm to ${plan.name} at ₹${plan.monthlyPrice.toStringAsFixed(0)}/mo '
          '(₹${plan.yearlyPrice.toStringAsFixed(0)}/yr)?\n\n'
          'Includes up to ${plan.maxClients} clients, ${plan.maxTeamMembers} team members, and ${plan.storageLimitGb}GB storage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref
                    .read(subscriptionNotifierProvider.notifier)
                    .activatePlan(plan.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Plan ${plan.name} activated successfully!',
                      ),
                      backgroundColor: LexColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to activate plan: $e'),
                      backgroundColor: LexColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Confirm & Activate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subStateAsync = ref.watch(subscriptionNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription & Quotas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Status',
            onPressed: () => ref
                .read(subscriptionNotifierProvider.notifier)
                .loadSubscriptionData(),
          ),
        ],
      ),
      body: subStateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: LexColors.error,
                ),
                const SizedBox(height: 12),
                Text(
                  'Error loading subscription: $err',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref
                      .read(subscriptionNotifierProvider.notifier)
                      .loadSubscriptionData(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (data) {
          final activeSub = data.activeSubscription;
          final usage = data.clientUsage;
          final plans = data.availablePlans;
          final userRole = ref.watch(currentUserRoleProvider);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (userRole.isSuperAdmin) ...[
                  LexCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.admin_panel_settings,
                          color: Color(0xFFC9A84C),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Platform Subscriptions Console',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Platform-level subscription tiers and firm quota management.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC9A84C),
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () => context.push('/app/plans'),
                          child: const Text('Manage Plans'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (!userRole.isSuperAdmin) ...[
                  // Active Plan Card
                  _buildActivePlanCard(context, activeSub, isDark),
                  const SizedBox(height: 24),

                  // Real-time Quota & Usage Card
                  _buildQuotaCard(context, usage, isDark),
                  const SizedBox(height: 28),
                ],

                // Available Plans Section
                Row(
                  children: [
                    Text(
                      'Available Subscription Plans',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? LexColors.textPrimaryDark
                            : LexColors.slatePrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (plans.isEmpty)
                  const Text('No additional plans available.')
                else
                  ...plans.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildPlanCard(context, ref, p, activeSub, isDark),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivePlanCard(
    BuildContext context,
    FirmSubscription? sub,
    bool isDark,
  ) {
    final hasActive = sub != null && sub.isActive && !sub.isExpired;
    final planTitle =
        sub?.planName ?? (hasActive ? 'Standard Plan' : 'Trial / Free Tier');

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [LexColors.slatePrimary, const Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: hasActive
                      ? Colors.green.withValues(alpha: 0.25)
                      : Colors.orange.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: hasActive ? Colors.greenAccent : Colors.orangeAccent,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasActive
                          ? Icons.check_circle
                          : Icons.warning_amber_rounded,
                      size: 14,
                      color: hasActive
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hasActive ? 'ACTIVE SUBSCRIPTION' : 'FREE / TRIAL',
                      style: TextStyle(
                        color: hasActive
                            ? Colors.greenAccent
                            : Colors.orangeAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (sub?.billingCycle != null)
                Text(
                  sub!.billingCycle.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            planTitle,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sub?.endDate != null
                ? 'Valid until: ${DateFormat.yMMMd().format(sub!.endDate!)}'
                : 'Full legal practice workspace active',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotaCard(
    BuildContext context,
    ClientUsage? usage,
    bool isDark,
  ) {
    final used = usage?.used ?? 0;
    final limit = usage?.limit;
    final isUnlimited = usage?.unlimited ?? false;
    final pct = usage?.usagePercentage ?? 0.0;

    return LexCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 20,
                color: isDark ? LexColors.accentGold : LexColors.accentBronze,
              ),
              const SizedBox(width: 8),
              const Text(
                'Firm Quota & Usage',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Clients Quota',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                isUnlimited
                    ? '$used Clients (Unlimited)'
                    : '$used of ${limit ?? 0} Clients',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: isUnlimited ? 0.05 : pct,
              minHeight: 8,
              backgroundColor: isDark ? Colors.white12 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(
                pct > 0.85 ? LexColors.error : LexColors.accentGold,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status: ${isUnlimited ? 'Unlimited Firm Access' : '${((1.0 - pct) * 100).toInt()}% Quota Remaining'}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? LexColors.textSecondaryDark
                      : LexColors.textSecondaryLight,
                ),
              ),
              const Text(
                'Includes Document Cloud',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    WidgetRef ref,
    SubscriptionPlan plan,
    FirmSubscription? activeSub,
    bool isDark,
  ) {
    final isCurrent = activeSub?.planId == plan.id;

    return LexCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  plan.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'CURRENT PLAN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹${plan.monthlyPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                '/month',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(width: 12),
              Text(
                '(₹${plan.yearlyPrice.toStringAsFixed(0)}/year)',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _buildFeatureItem(
                Icons.people_outline,
                '${plan.maxClients} Clients',
              ),
              _buildFeatureItem(
                Icons.group_outlined,
                '${plan.maxTeamMembers} Team Members',
              ),
              _buildFeatureItem(
                Icons.cloud_outlined,
                '${plan.storageLimitGb} GB Storage',
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCurrent
                  ? null
                  : () => _confirmPlanActivation(context, ref, plan),
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrent
                    ? Colors.grey
                    : LexColors.slatePrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                isCurrent ? 'Current Active Plan' : 'Select & Upgrade',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
