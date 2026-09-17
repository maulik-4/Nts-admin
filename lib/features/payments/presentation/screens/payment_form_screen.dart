import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_button.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment record created successfully.'),
            backgroundColor: LexColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to record payment: $e'),
            backgroundColor: LexColors.error,
          ),
        );
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
      appBar: AppBar(title: const Text('Record Fee Payment')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LexCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Details',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? LexColors.textPrimaryDark
                                : LexColors.slatePrimary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Amount Field
                        LexTextField(
                          label: 'Amount (₹) *',
                          controller: _amountController,
                          hintText: 'e.g., 15000.00',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Payment amount is required';
                            }
                            final parsed = double.tryParse(val.trim());
                            if (parsed == null || parsed <= 0) {
                              return 'Enter a valid positive amount';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Payment Method Dropdown
                        DropdownButtonFormField<PaymentMethod>(
                          initialValue: _selectedMethod,
                          decoration: InputDecoration(
                            labelText: 'Payment Method *',
                            filled: true,
                            fillColor: isDark
                                ? LexColors.surfaceDark
                                : LexColors.surfaceLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: PaymentMethod.values.map((m) {
                            return DropdownMenuItem<PaymentMethod>(
                              value: m,
                              child: Text(m.displayName),
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
                        DropdownButtonFormField<PaymentStatus>(
                          initialValue: _selectedStatus,
                          decoration: InputDecoration(
                            labelText: 'Payment Status *',
                            filled: true,
                            fillColor: isDark
                                ? LexColors.surfaceDark
                                : LexColors.surfaceLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: PaymentStatus.values.map((s) {
                            return DropdownMenuItem<PaymentStatus>(
                              value: s,
                              child: Text(s.displayName),
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
                        clientsAsync.when(
                          data: (clients) {
                            return DropdownButtonFormField<int?>(
                              initialValue: _selectedClientId,
                              decoration: InputDecoration(
                                labelText: 'Client (Optional)',
                                hintText: 'Select client',
                                filled: true,
                                fillColor: isDark
                                    ? LexColors.surfaceDark
                                    : LexColors.surfaceLight,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('None (General Payment)'),
                                ),
                                ...clients.map((cl) {
                                  return DropdownMenuItem<int?>(
                                    value: cl.id,
                                    child: Text(
                                      cl.name,
                                      overflow: TextOverflow.ellipsis,
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
                        casesAsync.when(
                          data: (cases) {
                            return DropdownButtonFormField<int?>(
                              initialValue: _selectedCaseId,
                              decoration: InputDecoration(
                                labelText: 'Associated Case (Optional)',
                                hintText: 'Select case',
                                filled: true,
                                fillColor: isDark
                                    ? LexColors.surfaceDark
                                    : LexColors.surfaceLight,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('None (General Fee)'),
                                ),
                                ...cases.map((c) {
                                  return DropdownMenuItem<int?>(
                                    value: c.id,
                                    child: Text(
                                      '${c.title} (${c.caseNumber})',
                                      overflow: TextOverflow.ellipsis,
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
                  LexButton(
                    label: 'Record Payment',
                    icon: Icons.check_circle_outline,
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _handleSubmit,
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
