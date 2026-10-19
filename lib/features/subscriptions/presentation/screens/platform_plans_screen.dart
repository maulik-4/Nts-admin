import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/models/subscription_models.dart';
import '../providers/subscriptions_notifier.dart';
import '../widgets/admin_gateway_tab.dart';
import '../widgets/admin_transactions_tab.dart';

class PlatformPlansScreen extends ConsumerStatefulWidget {
  const PlatformPlansScreen({super.key});

  @override
  ConsumerState<PlatformPlansScreen> createState() =>
      _PlatformPlansScreenState();
}

class _PlatformPlansScreenState extends ConsumerState<PlatformPlansScreen> {
  static const Color _superAdminGold = Color(0xFFC9A84C);

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(platformPlansNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Plans & Gateway Control'),
          bottom: const TabBar(
            indicatorColor: _superAdminGold,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.layers_outlined, size: 20), text: 'Plans'),
              Tab(
                icon: Icon(Icons.payment_outlined, size: 20),
                text: 'Payment Gateway',
              ),
              Tab(
                icon: Icon(Icons.receipt_long_outlined, size: 20),
                text: 'Transactions',
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh Plans',
              onPressed: () =>
                  ref.read(platformPlansNotifierProvider.notifier).loadPlans(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showPlanFormDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('New Plan'),
          backgroundColor: _superAdminGold,
          foregroundColor: Colors.black,
        ),
        body: TabBarView(
          children: [
            // Tab 0: Plans List
            plansAsync.when(
              data: (plans) {
                if (plans.isEmpty) {
                  return const EmptyStateWidget(
                    title: 'No Subscription Plans',
                    message: 'No plans have been configured on the platform.',
                    icon: Icons.card_membership_outlined,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(platformPlansNotifierProvider.notifier)
                      .loadPlans(),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: 88,
                    ),
                    itemCount: plans.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (ctx, idx) =>
                        _buildPlanCard(context, plans[idx], isDark),
                  ),
                );
              },
              loading: () => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: List.generate(
                    3,
                    (_) => const Padding(
                      padding: EdgeInsets.only(bottom: 14),
                      child: SkeletonLoader(height: 140),
                    ),
                  ),
                ),
              ),
              error: (err, _) => ErrorStateWidget(
                message: 'Unable to Load Plans: $err',
                onRetry: () => ref
                    .read(platformPlansNotifierProvider.notifier)
                    .loadPlans(),
              ),
            ),

            // Tab 1: Razorpay Gateway Settings
            const AdminGatewayTab(),

            // Tab 2: Subscription Transactions Audit
            const AdminTransactionsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    SubscriptionPlan plan,
    bool isDark,
  ) {
    final createdStr = plan.createdAt != null
        ? DateFormat('MMM d, yyyy').format(plan.createdAt!)
        : null;

    return LexCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _superAdminGold.withAlpha(40),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _superAdminGold.withAlpha(90)),
                  ),
                  child: Text(
                    plan.name.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _superAdminGold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                status: plan.isActive ? 'Active' : 'Inactive',
                color: plan.isActive ? LexColors.success : LexColors.warning,
              ),
              if (plan.isDeleted) ...[
                const SizedBox(width: 6),
                const StatusBadge(status: 'Deleted', color: LexColors.error),
              ],
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (val) {
                  if (val == 'edit') {
                    _showPlanFormDialog(context, plan: plan);
                  } else if (val == 'delete') {
                    _confirmDeletePlan(context, plan);
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Edit Plan'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: LexColors.error,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Delete Plan',
                          style: TextStyle(color: LexColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                '₹${plan.monthlyPrice.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? LexColors.textPrimaryDark
                      : LexColors.textPrimaryLight,
                ),
              ),
              Text(
                '/ month',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? LexColors.textSecondaryDark
                      : LexColors.textSecondaryLight,
                ),
              ),
              Text(
                '(₹${plan.yearlyPrice.toStringAsFixed(0)} / year)',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? LexColors.textSecondaryDark
                      : LexColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          if (plan.description != null && plan.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              plan.description!,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? LexColors.textSecondaryDark
                    : LexColors.textSecondaryLight,
              ),
            ),
          ],
          const Divider(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildFeatureChip(
                Icons.people_outline,
                '${plan.maxClients} Clients Max',
                isDark,
              ),
              _buildFeatureChip(
                Icons.badge_outlined,
                '${plan.maxTeamMembers} Team Members',
                isDark,
              ),
              _buildFeatureChip(
                Icons.cloud_outlined,
                '${plan.storageLimitGb} GB Storage',
                isDark,
              ),
              if (plan.messageLimit != null)
                _buildFeatureChip(
                  Icons.chat_bubble_outline,
                  '${plan.messageLimit} Messages',
                  isDark,
                ),
              if (createdStr != null)
                _buildFeatureChip(
                  Icons.calendar_today_outlined,
                  'Created $createdStr',
                  isDark,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark
              ? LexColors.textSecondaryDark
              : LexColors.textSecondaryLight,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? LexColors.textSecondaryDark
                : LexColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  void _showPlanFormDialog(BuildContext context, {SubscriptionPlan? plan}) {
    final isEditing = plan != null;
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: plan?.name ?? '');
    final monthlyCtrl = TextEditingController(
      text: plan != null ? plan.monthlyPrice.toStringAsFixed(0) : '',
    );
    final yearlyCtrl = TextEditingController(
      text: plan != null ? plan.yearlyPrice.toStringAsFixed(0) : '',
    );
    final clientsCtrl = TextEditingController(
      text: plan != null ? plan.maxClients.toString() : '50',
    );
    final membersCtrl = TextEditingController(
      text: plan != null ? plan.maxTeamMembers.toString() : '5',
    );
    final storageCtrl = TextEditingController(
      text: plan != null ? plan.storageLimitGb.toString() : '10',
    );
    final descCtrl = TextEditingController(text: plan?.description ?? '');
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        isEditing ? Icons.edit_note : Icons.add_circle_outline,
                        color: _superAdminGold,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isEditing
                              ? 'Edit Subscription Tier'
                              : 'Create Subscription Tier',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Plan Name *'),
                    validator: (v) =>
                        v?.trim().isEmpty == true ? 'Name required' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: monthlyCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Monthly Price (₹) *',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) => double.tryParse(v ?? '') == null
                              ? 'Valid price required'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: yearlyCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Yearly Price (₹) *',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) => double.tryParse(v ?? '') == null
                              ? 'Valid price required'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: clientsCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Max Clients *',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) => int.tryParse(v ?? '') == null
                              ? 'Number required'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: membersCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Max Team Members *',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) => int.tryParse(v ?? '') == null
                              ? 'Number required'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: storageCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Storage Limit (GB) *',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => int.tryParse(v ?? '') == null
                        ? 'Number required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Plan Description (optional)',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _superAdminGold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            setModalState(() => isSubmitting = true);

                            final payload = <String, dynamic>{
                              'name': nameCtrl.text.trim(),
                              'monthly_price': double.parse(
                                monthlyCtrl.text.trim(),
                              ),
                              'yearly_price': double.parse(
                                yearlyCtrl.text.trim(),
                              ),
                              'max_clients': int.parse(clientsCtrl.text.trim()),
                              'max_team_members': int.parse(
                                membersCtrl.text.trim(),
                              ),
                              'storage_limit_gb': int.parse(
                                storageCtrl.text.trim(),
                              ),
                              'description': descCtrl.text.trim(),
                            };

                            try {
                              if (isEditing) {
                                await ref
                                    .read(
                                      platformPlansNotifierProvider.notifier,
                                    )
                                    .updatePlan(plan.id, payload);
                              } else {
                                await ref
                                    .read(
                                      platformPlansNotifierProvider.notifier,
                                    )
                                    .createPlan(payload);
                              }
                              if (context.mounted) {
                                Navigator.pop(ctx);
                                AppAlerts.showSuccess(
                                  context,
                                  isEditing
                                      ? 'Plan updated successfully'
                                      : 'Plan created successfully',
                                );
                              }
                            } catch (e) {
                              setModalState(() => isSubmitting = false);
                              if (context.mounted) {
                                AppAlerts.showError(
                                  context,
                                  'Error saving plan: $e',
                                );
                              }
                            }
                          },
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            isEditing ? 'Save Plan Changes' : 'Create Plan',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeletePlan(BuildContext context, SubscriptionPlan plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: LexColors.error),
            SizedBox(width: 8),
            Text('Delete Subscription Plan?'),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete the plan "${plan.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: LexColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(platformPlansNotifierProvider.notifier)
                    .deletePlan(plan.id);
                if (context.mounted) {
                  AppAlerts.showSuccess(context, 'Plan "${plan.name}" deleted');
                }
              } catch (e) {
                if (context.mounted) {
                  AppAlerts.showError(context, 'Delete failed: $e');
                }
              }
            },
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }
}
