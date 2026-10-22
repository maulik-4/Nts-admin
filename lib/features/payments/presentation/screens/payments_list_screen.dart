import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/capability_gate.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/searchable_picker_modal.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../auth/domain/models/role_capabilities.dart';
import '../../../cases/data/models/case_model.dart';
import '../../../cases/presentation/providers/cases_notifier.dart';
import '../../../clients/data/models/client_model.dart';
import '../../../clients/presentation/providers/clients_notifier.dart';
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
    final statusFilter = ref.watch(paymentStatusFilterProvider);
    final methodFilter = ref.watch(paymentMethodFilterProvider);
    final selectedCaseId = ref.watch(paymentCaseFilterProvider);
    final selectedClientId = ref.watch(paymentClientFilterProvider);
    final casesAsync = ref.watch(casesNotifierProvider);
    final clientsAsync = ref.watch(clientsNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasActiveFilter = selectedCaseId != null ||
        selectedClientId != null ||
        statusFilter != null ||
        methodFilter != null ||
        _searchController.text.trim().isNotEmpty;

    // Compute metrics on current filtered view (or all)
    double totalPaid = 0.0;
    double totalPending = 0.0;
    paymentsAsync.whenData((list) {
      for (final p in list) {
        final amt = double.tryParse(p.amount) ?? 0.0;
        if (p.isPaid) {
          totalPaid += amt;
        } else {
          totalPending += amt;
        }
      }
    });

    final totalCount = paymentsAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Payments & Billing',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFDBEAFE),
                ),
              ),
              child: Text(
                '$totalCount',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ],
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
          onPressed: () async {
            final caseId = ref.read(paymentCaseFilterProvider);
            final clientId = ref.read(paymentClientFilterProvider);
            final queryParams = <String, String>{};
            if (caseId != null) queryParams['caseId'] = caseId.toString();
            if (clientId != null) queryParams['clientId'] = clientId.toString();
            final uri = Uri(
              path: '/app/more/payments/create',
              queryParameters: queryParams.isEmpty ? null : queryParams,
            );
            await context.push(uri.toString());
            if (context.mounted) {
              ref.read(paymentsNotifierProvider.notifier).loadPayments();
            }
          },
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
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
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
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
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
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(paymentSearchQueryProvider.notifier).state =
                              '';
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
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
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

          // Filter Row: All Payments, Filter by Case, Filter by Client, Status, Method
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterPill(
                  context: context,
                  label: 'All Payments',
                  isSelected: !hasActiveFilter,
                  onTap: () {
                    _searchController.clear();
                    ref.read(paymentSearchQueryProvider.notifier).state = '';
                    ref.read(paymentStatusFilterProvider.notifier).state = null;
                    ref.read(paymentMethodFilterProvider.notifier).state = null;
                    ref.read(paymentCaseFilterProvider.notifier).state = null;
                    ref.read(paymentClientFilterProvider.notifier).state = null;
                    setState(() {});
                  },
                ),
                const SizedBox(width: 8),
                _buildCaseFilterButton(
                  context: context,
                  cases: casesAsync.valueOrNull ?? [],
                  selectedCaseId: selectedCaseId,
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildClientFilterButton(
                  context: context,
                  clients: clientsAsync.valueOrNull ?? [],
                  selectedClientId: selectedClientId,
                  isDark: isDark,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 1,
                  height: 22,
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFCBD5E1),
                ),
                _buildFilterPill(
                  context: context,
                  label: 'Paid',
                  isSelected: statusFilter == PaymentStatus.paid,
                  onTap: () =>
                      ref.read(paymentStatusFilterProvider.notifier).state =
                          statusFilter == PaymentStatus.paid
                              ? null
                              : PaymentStatus.paid,
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  context: context,
                  label: 'Pending',
                  isSelected: statusFilter == PaymentStatus.pending,
                  onTap: () =>
                      ref.read(paymentStatusFilterProvider.notifier).state =
                          statusFilter == PaymentStatus.pending
                              ? null
                              : PaymentStatus.pending,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 1,
                  height: 22,
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFCBD5E1),
                ),
                ...PaymentMethod.values.map((m) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterPill(
                      context: context,
                      label: m.displayName,
                      isSelected: methodFilter == m,
                      onTap: () =>
                          ref.read(paymentMethodFilterProvider.notifier).state =
                              methodFilter == m ? null : m,
                    ),
                  );
                }),
              ],
            ),
          ),

          // Active filter banner with quick create
          if (selectedCaseId != null || selectedClientId != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFDBEAFE),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.filter_alt_rounded,
                      size: 16,
                      color: Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedCaseId != null && selectedClientId != null
                            ? 'Filtered by Case & Client'
                            : selectedCaseId != null
                                ? 'Filtered by Case #${casesAsync.valueOrNull?.where((c) => c.id == selectedCaseId).firstOrNull?.caseNumber ?? selectedCaseId}'
                                : 'Filtered by Client ${clientsAsync.valueOrNull?.where((cl) => cl.id == selectedClientId).firstOrNull?.name ?? selectedClientId}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF93C5FD)
                              : const Color(0xFF1D4ED8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        final queryParams = <String, String>{};
                        if (selectedCaseId != null) {
                          queryParams['caseId'] = selectedCaseId.toString();
                        }
                        if (selectedClientId != null) {
                          queryParams['clientId'] =
                              selectedClientId.toString();
                        }
                        final uri = Uri(
                          path: '/app/more/payments/create',
                          queryParameters: queryParams,
                        );
                        context.push(uri.toString());
                      },
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Text(
                          '+ Record Here',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 6),

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

  Widget _buildCaseFilterButton({
    required BuildContext context,
    required List<Case> cases,
    required int? selectedCaseId,
    required bool isDark,
  }) {
    final selectedCase = selectedCaseId == null
        ? null
        : cases.where((c) => c.id == selectedCaseId).firstOrNull;
    final hasSelection = selectedCase != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final items = [
            const SearchablePickerItem<int?>(
              value: null,
              label: 'All Cases',
              subtitle: 'Show payments across all cases',
              icon: Icons.clear_all_rounded,
              iconColor: Color(0xFF64748B),
            ),
            ...cases.map((c) {
              final subtitle = c.courtName.isNotEmpty
                  ? '${c.title} • ${c.courtName}'
                  : c.title;
              return SearchablePickerItem<int?>(
                value: c.id,
                label: c.caseNumber,
                subtitle: subtitle,
                icon: Icons.folder_rounded,
                iconColor: const Color(0xFF2563EB),
              );
            }),
          ];

          final pickedId = await showSearchablePicker<int?>(
            context: context,
            title: 'Filter by Case',
            searchHint: 'Search case number, title, or court...',
            selectedValue: selectedCaseId,
            items: items,
          );

          ref.read(paymentCaseFilterProvider.notifier).state = pickedId;
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: hasSelection
                ? (isDark
                    ? const Color(0xFF1E3A8A).withAlpha(89)
                    : const Color(0xFFEFF6FF))
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasSelection
                  ? (isDark
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF2563EB))
                  : (isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0)),
              width: 1,
            ),
            boxShadow: hasSelection
                ? [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withAlpha(38),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasSelection ? Icons.balance_rounded : Icons.tune_rounded,
                size: 15,
                color: hasSelection
                    ? const Color(0xFF2563EB)
                    : (isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B)),
              ),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  hasSelection ? selectedCase.caseNumber : 'Filter by Case',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight:
                        hasSelection ? FontWeight.w700 : FontWeight.w500,
                    color: hasSelection
                        ? (isDark
                            ? const Color(0xFF60A5FA)
                            : const Color(0xFF1D4ED8))
                        : (isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF475569)),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              if (hasSelection)
                GestureDetector(
                  onTap: () {
                    ref.read(paymentCaseFilterProvider.notifier).state = null;
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFDBEAFE),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 12,
                      color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                    ),
                  ),
                )
              else
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClientFilterButton({
    required BuildContext context,
    required List<Client> clients,
    required int? selectedClientId,
    required bool isDark,
  }) {
    final selectedClient = selectedClientId == null
        ? null
        : clients.where((cl) => cl.id == selectedClientId).firstOrNull;
    final hasSelection = selectedClient != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final items = [
            const SearchablePickerItem<int?>(
              value: null,
              label: 'All Clients',
              subtitle: 'Show payments across all clients',
              icon: Icons.clear_all_rounded,
              iconColor: Color(0xFF64748B),
            ),
            ...clients.map((cl) {
              final contact = cl.phone.isNotEmpty
                  ? cl.phone
                  : ((cl.email != null && cl.email!.isNotEmpty)
                      ? cl.email!
                      : 'Client #${cl.id}');
              return SearchablePickerItem<int?>(
                value: cl.id,
                label: cl.name,
                subtitle: contact,
                icon: Icons.person_rounded,
                iconColor: const Color(0xFF2563EB),
              );
            }),
          ];

          final pickedId = await showSearchablePicker<int?>(
            context: context,
            title: 'Filter by Client',
            searchHint: 'Search client name, phone, or email...',
            selectedValue: selectedClientId,
            items: items,
          );

          ref.read(paymentClientFilterProvider.notifier).state = pickedId;
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: hasSelection
                ? (isDark
                    ? const Color(0xFF1E3A8A).withAlpha(89)
                    : const Color(0xFFEFF6FF))
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasSelection
                  ? (isDark
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF2563EB))
                  : (isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0)),
              width: 1,
            ),
            boxShadow: hasSelection
                ? [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withAlpha(38),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasSelection
                    ? Icons.person_rounded
                    : Icons.person_outline_rounded,
                size: 15,
                color: hasSelection
                    ? const Color(0xFF2563EB)
                    : (isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B)),
              ),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  hasSelection ? selectedClient.name : 'Filter by Client',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight:
                        hasSelection ? FontWeight.w700 : FontWeight.w500,
                    color: hasSelection
                        ? (isDark
                            ? const Color(0xFF60A5FA)
                            : const Color(0xFF1D4ED8))
                        : (isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF475569)),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              if (hasSelection)
                GestureDetector(
                  onTap: () {
                    ref.read(paymentClientFilterProvider.notifier).state = null;
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFDBEAFE),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 12,
                      color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                    ),
                  ),
                )
              else
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
