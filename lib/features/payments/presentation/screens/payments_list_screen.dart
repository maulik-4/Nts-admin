import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/capability_gate.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/lex_card.dart';
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

  Widget _buildFilterPill({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? primaryColor : const Color(0xFF0F1F38))
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isDark ? primaryColor : const Color(0xFF0F1F38))
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F1F38).withAlpha(35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
          ),
        ),
      ),
    );
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
        title: const Text(
          'Payments & Billing',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
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
          heroTag: 'fab_add_payment',
          onPressed: () => context.push('/app/more/payments/create'),
          backgroundColor: const Color(0xFF0F1F38),
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text(
            'Record Payment',
            style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
          ),
        ),
      ),
      body: Column(
        children: [
          // Financial Summary Cards
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: [
                Expanded(
                  child: LexCard(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF10B981).withAlpha(20),
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'TOTAL PAID',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF10B981),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${totalPaid.toStringAsFixed(2)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LexCard(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFF59E0B).withAlpha(20),
                              ),
                              child: const Icon(
                                Icons.hourglass_empty_rounded,
                                size: 14,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'TOTAL PENDING',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFF59E0B),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${totalPending.toStringAsFixed(2)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
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
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                ref.read(paymentSearchQueryProvider.notifier).state = val;
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search by client, case, method, or amount...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(paymentSearchQueryProvider.notifier).state = '';
                          setState(() {});
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Filter Pills (Status & Method)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterPill(
                  context: context,
                  label: 'All Payments',
                  isSelected: statusFilter == null,
                  onTap: () =>
                      ref.read(paymentStatusFilterProvider.notifier).state = null,
                ),
                const SizedBox(width: 8),
                ...PaymentStatus.values.map((s) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterPill(
                      context: context,
                      label: s.displayName,
                      isSelected: statusFilter == s,
                      onTap: () => ref
                          .read(paymentStatusFilterProvider.notifier)
                          .state = statusFilter == s ? null : s,
                    ),
                  );
                }),
                Container(
                  width: 1,
                  height: 22,
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  context: context,
                  label: 'All Methods',
                  isSelected: methodFilter == null,
                  onTap: () =>
                      ref.read(paymentMethodFilterProvider.notifier).state = null,
                ),
                const SizedBox(width: 8),
                ...PaymentMethod.values.map((m) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterPill(
                      context: context,
                      label: m.displayName,
                      isSelected: methodFilter == m,
                      onTap: () => ref
                          .read(paymentMethodFilterProvider.notifier)
                          .state = methodFilter == m ? null : m,
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Payments List
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
                          title: 'No Payments Found',
                          message: 'Record your first payment receipt or adjust filters.',
                          icon: Icons.payments_outlined,
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
                    itemCount: payments.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final payment = payments[index];
                      return PaymentCard(
                        payment: payment,
                        onTap: () =>
                            context.push('/app/more/payments/${payment.id}'),
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
                      const SkeletonLoader(height: 90, borderRadius: 16),
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
}
