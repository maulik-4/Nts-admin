import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/capability_gate.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/lex_text_field.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../auth/domain/models/role_capabilities.dart';
import '../../data/models/payment_model.dart';
import '../providers/payments_notifier.dart';
import '../widgets/payment_card.dart';

class PaymentsListScreen extends ConsumerStatefulWidget {
  const PaymentsListScreen({super.key});

  @override
  ConsumerState<PaymentsListScreen> createState() => _PaymentsListScreenState();
}

class _PaymentsListScreenState extends ConsumerState<PaymentsListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(filteredPaymentsProvider);
    final allPaymentsAsync = ref.watch(paymentsNotifierProvider);
    final statusFilter = ref.watch(paymentStatusFilterProvider);
    final methodFilter = ref.watch(paymentMethodFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Compute metrics
    double totalPaid = 0.0;
    double totalPending = 0.0;
    allPaymentsAsync.whenData((list) {
      for (final p in list) {
        final amt = double.tryParse(p.amount) ?? 0.0;
        if (p.isPaid) {
          totalPaid += amt;
        } else {
          totalPending += amt;
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments & Billing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () {
              ref.read(paymentsNotifierProvider.notifier).loadPayments();
            },
          ),
        ],
      ),
      floatingActionButton: CapabilityGate(
        capability: UserCapability.createPayments,
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/app/more/payments/create'),
          backgroundColor: isDark
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.primary,
          foregroundColor: isDark ? Colors.black : Colors.white,
          icon: const Icon(Icons.add),
          label: const Text(
            'Record Payment',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      body: Column(
        children: [
          // Financial Summary Cards
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                Expanded(
                  child: LexCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 15,
                              color: LexColors.success,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'TOTAL PAID',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: LexColors.success,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '₹${totalPaid.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? LexColors.textPrimaryDark
                                : LexColors.slatePrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LexCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.hourglass_empty_rounded,
                              size: 15,
                              color: LexColors.warning,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'TOTAL PENDING',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: LexColors.warning,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '₹${totalPending.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? LexColors.textPrimaryDark
                                : LexColors.slatePrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: LexTextField(
              controller: _searchController,
              hintText: 'Search by client, case, method, or amount...',
              prefixIcon: Icons.search,
              suffix: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(paymentSearchQueryProvider.notifier).state =
                            '';
                        setState(() {});
                      },
                    )
                  : null,
              onChanged: (val) {
                ref.read(paymentSearchQueryProvider.notifier).state = val;
                setState(() {});
              },
            ),
          ),

          // Status & Method Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'All Status',
                  isSelected: statusFilter == null,
                  onSelected: () =>
                      ref.read(paymentStatusFilterProvider.notifier).state =
                          null,
                ),
                const SizedBox(width: 8),
                ...PaymentStatus.values.map((s) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      label: s.displayName,
                      isSelected: statusFilter == s,
                      onSelected: () =>
                          ref.read(paymentStatusFilterProvider.notifier).state =
                              statusFilter == s ? null : s,
                    ),
                  );
                }),
                const SizedBox(width: 8),
                Container(
                  width: 1,
                  height: 24,
                  color: isDark ? LexColors.borderDark : LexColors.borderLight,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'All Methods',
                  isSelected: methodFilter == null,
                  onSelected: () =>
                      ref.read(paymentMethodFilterProvider.notifier).state =
                          null,
                ),
                const SizedBox(width: 8),
                ...PaymentMethod.values.map((m) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      label: m.displayName,
                      isSelected: methodFilter == m,
                      onSelected: () =>
                          ref.read(paymentMethodFilterProvider.notifier).state =
                              methodFilter == m ? null : m,
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Payment Cards List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(paymentsNotifierProvider.notifier).loadPayments(),
              child: paymentsAsync.when(
                data: (payments) {
                  if (payments.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 60),
                        EmptyStateWidget(
                          title: 'No Payments Recorded',
                          message: 'Record your first fee payment or clear active filters.',
                          icon: Icons.payments_outlined,
                        ),
                      ],
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isTablet = constraints.maxWidth >= 600;

                      if (isTablet) {
                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 2.3,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: payments.length,
                          itemBuilder: (context, index) {
                            final p = payments[index];
                            return PaymentCard(
                              payment: p,
                              onTap: () =>
                                  context.push('/app/more/payments/${p.id}'),
                            );
                          },
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: payments.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final p = payments[index];
                          return PaymentCard(
                            payment: p,
                            onTap: () =>
                                context.push('/app/more/payments/${p.id}'),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: 5,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      const SkeletonLoader(height: 100),
                ),
                error: (err, stack) => Center(
                  child: ErrorStateWidget(
                    message: 'Unable to load payments: $err',
                    onRetry: () => ref
                        .read(paymentsNotifierProvider.notifier)
                        .loadPayments(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected
              ? (isDark ? LexColors.slatePrimary : Colors.white)
              : (isDark
                    ? LexColors.textSecondaryDark
                    : LexColors.textSecondaryLight),
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: isDark
          ? Theme.of(context).colorScheme.secondary
          : Theme.of(context).colorScheme.primary,
      backgroundColor: isDark ? LexColors.surfaceDark : const Color(0xFFF1F5F9),
      side: BorderSide(
        color: isSelected
            ? Colors.transparent
            : (isDark ? LexColors.borderDark : LexColors.borderLight),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      showCheckmark: false,
    );
  }
}
