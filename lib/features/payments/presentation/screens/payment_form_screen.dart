import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_alerts.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/lex_text_field.dart';
import '../../../cases/presentation/providers/cases_notifier.dart';
import '../../../clients/presentation/providers/clients_notifier.dart';
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
      appBar: AppBar(
        title: const Text(
          'Record Fee Payment',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
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
                            return DropdownButtonFormField<int?>(
                              isExpanded: true,
                              initialValue: _selectedClientId,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.person_outline_rounded,
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
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text(
                                    'None (General Practice Receipt)',
                                  ),
                                ),
                                ...clients.map((cl) {
                                  return DropdownMenuItem<int?>(
                                    value: cl.id,
                                    child: Text(
                                      cl.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (val) {
                                setState(() => _selectedClientId = val);
                              },
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
                            return DropdownButtonFormField<int?>(
                              isExpanded: true,
                              initialValue: _selectedCaseId,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.folder_open_rounded,
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
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('None (General Legal Fee)'),
                                ),
                                ...cases.map((c) {
                                  return DropdownMenuItem<int?>(
                                    value: c.id,
                                    child: Text(
                                      '${c.caseNumber} - ${c.title}',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (val) {
                                setState(() => _selectedCaseId = val);
                              },
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
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F1F38),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Record Payment Receipt',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                                letterSpacing: 0.2,
                              ),
                            ),
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
}
