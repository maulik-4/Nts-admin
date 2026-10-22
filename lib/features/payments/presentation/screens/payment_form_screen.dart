import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_alerts.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/lex_text_field.dart';
import '../../../../shared/widgets/searchable_picker_modal.dart';
import '../../../cases/presentation/providers/cases_notifier.dart';
import '../../../cases/presentation/screens/case_detail_screen.dart';
import '../../../clients/presentation/providers/clients_notifier.dart';
import '../../../dashboard/presentation/providers/dashboard_notifier.dart';
import '../../data/models/payment_model.dart';
import '../providers/payments_notifier.dart';

class PaymentFormScreen extends ConsumerStatefulWidget {
  final int? initialCaseId;
  final int? initialClientId;

  const PaymentFormScreen({
    super.key,
    this.initialCaseId,
    this.initialClientId,
  });

  @override
  ConsumerState<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends ConsumerState<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _amountController;

  int? _selectedCaseId;
  int? _selectedClientId;
  PaymentStatus _selectedStatus = PaymentStatus.paid;
  PaymentMethod _selectedMethod = PaymentMethod.upi;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _selectedCaseId = widget.initialCaseId;
    _selectedClientId = widget.initialClientId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amountFormatted = double.parse(_amountController.text.trim())
          .toStringAsFixed(2);

      final request = CreatePaymentRequest(
        amount: amountFormatted,
        status: _selectedStatus,
        paymentMethod: _selectedMethod,
        caseId: _selectedCaseId,
        clientId: _selectedClientId,
      );

      await ref.read(paymentsNotifierProvider.notifier).createPayment(request);
      ref.invalidate(dashboardNotifierProvider);
      if (_selectedCaseId != null) {
        ref.invalidate(caseDetailProvider(_selectedCaseId!));
      }

      if (mounted) {
        AppAlerts.showSuccess(context, 'Payment record saved successfully.');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(context, 'Failed to record payment: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final casesAsync = ref.watch(casesNotifierProvider);
    final clientsAsync = ref.watch(clientsNotifierProvider);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF070E1A) : const Color(0xFFF1F5F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Header with 1.1.png matching client_form_screen
            Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/1.1.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.centerRight,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF071224), Color(0xFF1E3A8A)],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          const Color(0xFF071224).withValues(alpha: 0.95),
                          const Color(0xFF071224).withValues(alpha: 0.8),
                          const Color(0xFF0A1830).withValues(alpha: 0.35),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.45, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () => context.pop(),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Record Fee Payment',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E3A8A)
                                    .withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF3B82F6)
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.currency_rupee_rounded,
                                      size: 13, color: Color(0xFF93C5FD)),
                                  SizedBox(width: 6),
                                  Text(
                                    'BILLING & FEE REVENUE',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                      color: Color(0xFF93C5FD),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Record Fee Receipt',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Log client fee collection, retainers, and legal service billing receipts with digital confirmation.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.8),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Form Body
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        LexCard(
                          borderRadius: 20,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFDBEAFE),
                            ),
                          ),
                          child: const Text(
                            'TRANSACTION SPECIFICATION',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Payment Information',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Amount
                        LexTextField(
                          label: 'Payment Amount (INR) *',
                          controller: _amountController,
                          hintText: 'e.g. 15000.00',
                          prefixIcon: Icons.currency_rupee_rounded,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Amount is required';
                            }
                            final d = double.tryParse(val.trim());
                            if (d == null || d <= 0) {
                              return 'Enter a valid positive amount';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Method Dropdown
                        Text(
                          'Payment Method *',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<PaymentMethod>(
                          isExpanded: true,
                          initialValue: _selectedMethod,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.payment_rounded,
                              size: 19,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: PaymentMethod.values.map((m) {
                            return DropdownMenuItem<PaymentMethod>(
                              value: m,
                              child: Text(
                                m.displayName,
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedMethod = val);
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Status Dropdown
                        Text(
                          'Payment Status *',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<PaymentStatus>(
                          isExpanded: true,
                          initialValue: _selectedStatus,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.verified_outlined,
                              size: 19,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: PaymentStatus.values.map((s) {
                            final color = s == PaymentStatus.paid
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B);
                            return DropdownMenuItem<PaymentStatus>(
                              value: s,
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    s.displayName,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedStatus = val);
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Client Selector
                        Text(
                          'Associated Client (Optional)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        clientsAsync.when(
                          data: (clients) {
                            final selectedClient = _selectedClientId == null
                                ? null
                                : clients
                                    .where((cl) => cl.id == _selectedClientId)
                                    .firstOrNull;

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  final items = [
                                    const SearchablePickerItem<int>(
                                      value: -1,
                                      label: 'None (General Practice Receipt)',
                                      subtitle:
                                          'Do not associate with a specific client',
                                      icon: Icons.remove_circle_outline_rounded,
                                      iconColor: Color(0xFF64748B),
                                    ),
                                    ...clients.map((cl) {
                                      final contact = cl.phone.isNotEmpty
                                          ? cl.phone
                                          : ((cl.email != null &&
                                                  cl.email!.isNotEmpty)
                                              ? cl.email!
                                              : 'Client #${cl.id}');
                                      return SearchablePickerItem<int>(
                                        value: cl.id,
                                        label: cl.name,
                                        subtitle: contact,
                                        icon: Icons.person_rounded,
                                        iconColor: const Color(0xFF2563EB),
                                      );
                                    }),
                                  ];

                                  final pickedId =
                                      await showSearchablePicker<int>(
                                    context: context,
                                    title: 'Select Associated Client',
                                    searchHint:
                                        'Search client name, phone, or email...',
                                    selectedValue: _selectedClientId ?? -1,
                                    items: items,
                                  );

                                  if (pickedId != null) {
                                    setState(() {
                                      _selectedClientId =
                                          pickedId == -1 ? null : pickedId;
                                    });
                                  }
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 13,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.person_outline_rounded,
                                        size: 19,
                                        color: _selectedClientId != null
                                            ? const Color(0xFF2563EB)
                                            : (isDark
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF64748B)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          selectedClient != null
                                              ? selectedClient.name
                                              : 'None (General Practice Receipt)',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: selectedClient != null
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: isDark
                                                ? (selectedClient != null
                                                    ? Colors.white
                                                    : const Color(0xFF94A3B8))
                                                : (selectedClient != null
                                                    ? const Color(0xFF0F172A)
                                                    : const Color(0xFF64748B)),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (_selectedClientId != null)
                                        GestureDetector(
                                          onTap: () {
                                            setState(
                                              () => _selectedClientId = null,
                                            );
                                          },
                                          child: Icon(
                                            Icons.close_rounded,
                                            size: 18,
                                            color: isDark
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF64748B),
                                          ),
                                        )
                                      else
                                        Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: 20,
                                          color: isDark
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFF64748B),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (err, stack) => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 16),

                        // Case Selector
                        Text(
                          'Associated Case (Optional)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        casesAsync.when(
                          data: (cases) {
                            final selectedCase = _selectedCaseId == null
                                ? null
                                : cases
                                    .where((c) => c.id == _selectedCaseId)
                                    .firstOrNull;

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  final items = [
                                    const SearchablePickerItem<int>(
                                      value: -1,
                                      label: 'None (General Legal Fee)',
                                      subtitle:
                                          'Do not associate with a specific case',
                                      icon: Icons.remove_circle_outline_rounded,
                                      iconColor: Color(0xFF64748B),
                                    ),
                                    ...cases.map((c) {
                                      final subtitle = c.courtName.isNotEmpty
                                          ? '${c.title} • ${c.courtName}'
                                          : c.title;
                                      return SearchablePickerItem<int>(
                                        value: c.id,
                                        label: c.caseNumber,
                                        subtitle: subtitle,
                                        icon: Icons.folder_rounded,
                                        iconColor: const Color(0xFF2563EB),
                                      );
                                    }),
                                  ];

                                  final pickedId =
                                      await showSearchablePicker<int>(
                                    context: context,
                                    title: 'Select Associated Case',
                                    searchHint:
                                        'Search case number, title, or court...',
                                    selectedValue: _selectedCaseId ?? -1,
                                    items: items,
                                  );

                                  if (pickedId != null) {
                                    setState(() {
                                      _selectedCaseId =
                                          pickedId == -1 ? null : pickedId;
                                      if (_selectedCaseId != null) {
                                        final sc = cases
                                            .where(
                                              (c) => c.id == _selectedCaseId,
                                            )
                                            .firstOrNull;
                                        if (sc != null &&
                                            _selectedClientId == null) {
                                          _selectedClientId = sc.client;
                                        }
                                      }
                                    });
                                  }
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 13,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.folder_open_rounded,
                                        size: 19,
                                        color: _selectedCaseId != null
                                            ? const Color(0xFF2563EB)
                                            : (isDark
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF64748B)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          selectedCase != null
                                              ? '${selectedCase.caseNumber} - ${selectedCase.title}'
                                              : 'None (General Legal Fee)',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: selectedCase != null
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: isDark
                                                ? (selectedCase != null
                                                    ? Colors.white
                                                    : const Color(0xFF94A3B8))
                                                : (selectedCase != null
                                                    ? const Color(0xFF0F172A)
                                                    : const Color(0xFF64748B)),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (_selectedCaseId != null)
                                        GestureDetector(
                                          onTap: () {
                                            setState(
                                              () => _selectedCaseId = null,
                                            );
                                          },
                                          child: Icon(
                                            Icons.close_rounded,
                                            size: 18,
                                            color: isDark
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF64748B),
                                          ),
                                        )
                                      else
                                        Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: 20,
                                          color: isDark
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFF64748B),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (err, stack) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F1F38),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long_rounded, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Record Payment Receipt',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  ),
),
);
  }
}
