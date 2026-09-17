import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/firm_theme_provider.dart';
import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../auth/domain/models/role_capabilities.dart';
import '../../data/models/subscription_models.dart';
import '../providers/subscriptions_notifier.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  void _choosePlan(BuildContext context, WidgetRef ref, SubscriptionPlan plan) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _BillingSelectionDialog(plan: plan),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subStateAsync = ref.watch(subscriptionNotifierProvider);
    final userRole = ref.watch(currentUserRoleProvider);
    final firmTheme = ref.watch(firmThemeProvider);
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
                  _buildActivePlanCard(
                    context,
                    activeSub,
                    firmTheme.primaryColor,
                    isDark,
                  ),
                  const SizedBox(height: 20),

                  // Real-time Quota & Usage Card
                  _buildQuotaCard(
                    context,
                    usage,
                    firmTheme.accentColor,
                    isDark,
                  ),
                  const SizedBox(height: 28),
                ],

                // Available Plans Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Available Subscription Plans',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? LexColors.textPrimaryDark
                            : firmTheme.primaryColor,
                      ),
                    ),
                    Text(
                      '${plans.length} tiers',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (plans.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('No subscription plans currently available.'),
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 720;
                      if (isWide) {
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: plans.map((p) {
                            final cardWidth = (constraints.maxWidth - 16) / 2;
                            return SizedBox(
                              width: cardWidth,
                              child: _buildPlanCard(
                                context,
                                ref,
                                p,
                                activeSub,
                                firmTheme.primaryColor,
                                firmTheme.accentColor,
                                isDark,
                              ),
                            );
                          }).toList(),
                        );
                      }

                      // Mobile 1-column layout
                      return Column(
                        children: plans.map((p) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _buildPlanCard(
                              context,
                              ref,
                              p,
                              activeSub,
                              firmTheme.primaryColor,
                              firmTheme.accentColor,
                              isDark,
                            ),
                          );
                        }).toList(),
                      );
                    },
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
    Color primaryColor,
    bool isDark,
  ) {
    final currentSub = sub;
    final hasActive =
        currentSub != null &&
        (currentSub.planId != null || currentSub.planName != null);
    final planTitle =
        currentSub?.planName ??
        (hasActive ? 'Active Plan' : 'No Active Subscription');

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [primaryColor, const Color(0xFF1E293B)],
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
                      hasActive ? Icons.check_circle : Icons.info_outline,
                      size: 14,
                      color: hasActive
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hasActive
                          ? 'ACTIVE SUBSCRIPTION'
                          : 'NO ACTIVE PLAN / FREE TIER',
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
            hasActive
                ? (currentSub.endDate != null
                      ? 'Valid until: ${DateFormat.yMMMd().format(currentSub.endDate!)}'
                      : 'Your firm workspace is active with full litigation access')
                : 'Select a plan below to activate your law firm workspace and unlock resource quotas.',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotaCard(
    BuildContext context,
    ClientUsage? usage,
    Color accentColor,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.pie_chart_outline, size: 20, color: accentColor),
                  const SizedBox(width: 8),
                  const Text(
                    'Workspace Quota & Resource Usage',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              if (usage?.planName != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    usage!.planName!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
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
                pct > 0.85 ? LexColors.error : accentColor,
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
                'Includes Cloud Storage',
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
    Color primaryColor,
    Color accentColor,
    bool isDark,
  ) {
    final isCurrent =
        activeSub?.planId == plan.id ||
        (activeSub?.planName != null && activeSub?.planName == plan.name);

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
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'ACTIVE PLAN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹${plan.monthlyPrice.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : primaryColor,
                ),
              ),
              const Text(
                '/mo',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(width: 12),
              Text(
                '₹${plan.yearlyPrice.toStringAsFixed(0)}/yr',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 12),
          _buildFeatureRow(
            Icons.people_alt_outlined,
            'Up to ${plan.maxClients} Active Clients',
          ),
          const SizedBox(height: 8),
          _buildFeatureRow(
            Icons.group_outlined,
            'Up to ${plan.maxTeamMembers} Team Members',
          ),
          const SizedBox(height: 8),
          _buildFeatureRow(
            Icons.cloud_outlined,
            '${plan.storageLimitGb} GB Secure Storage',
          ),
          if (plan.messageLimit != null) ...[
            const SizedBox(height: 8),
            _buildFeatureRow(
              Icons.chat_outlined,
              '${plan.messageLimit} Monthly Firm Messages',
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCurrent
                  ? null
                  : () => _choosePlan(context, ref, plan),
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrent ? Colors.grey : primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isCurrent ? 'Current Plan' : 'Choose Plan',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

/// Interactive Billing Period Dialog with loading protection and confirmation
class _BillingSelectionDialog extends ConsumerStatefulWidget {
  final SubscriptionPlan plan;

  const _BillingSelectionDialog({required this.plan});

  @override
  ConsumerState<_BillingSelectionDialog> createState() =>
      _BillingSelectionDialogState();
}

class _BillingSelectionDialogState
    extends ConsumerState<_BillingSelectionDialog> {
  String _selectedBilling = 'monthly';
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final firmTheme = ref.watch(firmThemeProvider);
    final monthlyTotalForYear = widget.plan.monthlyPrice * 12;
    final yearlySavings = monthlyTotalForYear - widget.plan.yearlyPrice;
    final hasSavings = yearlySavings > 0;

    return AlertDialog(
      title: Text('Subscribe to ${widget.plan.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select your preferred billing schedule for your firm:',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Monthly Option
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: _isSubmitting
                  ? null
                  : () => setState(() => _selectedBilling = 'monthly'),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _selectedBilling == 'monthly'
                        ? firmTheme.primaryColor
                        : Colors.grey.withValues(alpha: 0.3),
                    width: _selectedBilling == 'monthly' ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedBilling == 'monthly'
                              ? firmTheme.primaryColor
                              : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: _selectedBilling == 'monthly'
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: firmTheme.primaryColor,
                                ),
                              ),
                            )
                          : null,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Monthly Billing',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '₹${widget.plan.monthlyPrice.toStringAsFixed(0)} / month',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Yearly Option
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: _isSubmitting
                  ? null
                  : () => setState(() => _selectedBilling = 'yearly'),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _selectedBilling == 'yearly'
                        ? firmTheme.primaryColor
                        : Colors.grey.withValues(alpha: 0.3),
                    width: _selectedBilling == 'yearly' ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedBilling == 'yearly'
                              ? firmTheme.primaryColor
                              : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: _selectedBilling == 'yearly'
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: firmTheme.primaryColor,
                                ),
                              ),
                            )
                          : null,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Yearly Billing',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              if (hasSavings) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Save ₹${yearlySavings.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            '₹${widget.plan.yearlyPrice.toStringAsFixed(0)} / year',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Includes up to ${widget.plan.maxClients} clients, ${widget.plan.maxTeamMembers} advocates/staff, and ${widget.plan.storageLimitGb}GB cloud storage.',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: firmTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          onPressed: _isSubmitting
              ? null
              : () async {
                  setState(() => _isSubmitting = true);
                  try {
                    await ref
                        .read(subscriptionNotifierProvider.notifier)
                        .activatePlan(
                          widget.plan.id,
                          billing: _selectedBilling,
                        );

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Plan ${widget.plan.name} ($_selectedBilling) activated successfully!',
                          ),
                          backgroundColor: LexColors.success,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      setState(() => _isSubmitting = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to activate plan: $e'),
                          backgroundColor: LexColors.error,
                        ),
                      );
                    }
                  }
                },
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Confirm & Activate'),
        ),
      ],
    );
  }
}
