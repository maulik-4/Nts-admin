import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_button.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../data/models/payment_gateway_model.dart';
import '../../data/repositories/subscriptions_repository.dart';
import '../providers/admin_gateway_notifier.dart';

class AdminGatewayTab extends ConsumerStatefulWidget {
  const AdminGatewayTab({super.key});

  @override
  ConsumerState<AdminGatewayTab> createState() => _AdminGatewayTabState();
}

class _AdminGatewayTabState extends ConsumerState<AdminGatewayTab> {
  final _formKey = GlobalKey<FormState>();
  final _keyIdController = TextEditingController();
  final _keySecretController = TextEditingController();
  final _webhookSecretController = TextEditingController();

  bool _isTestMode = true;
  bool _isActive = true;
  bool _isSaving = false;
  bool _obscureSecret = true;
  String? _errorMessage;

  @override
  void dispose() {
    _keyIdController.dispose();
    _keySecretController.dispose();
    _webhookSecretController.dispose();
    super.dispose();
  }

  void _populate(PlatformPaymentGateway? gateway) {
    if (gateway != null) {
      if (_keyIdController.text.isEmpty) _keyIdController.text = gateway.keyId;
      if (_keySecretController.text.isEmpty) {
        _keySecretController.text = gateway.keySecret;
      }
      if (_webhookSecretController.text.isEmpty) {
        _webhookSecretController.text = gateway.webhookSecret;
      }
      _isTestMode = gateway.isTestMode;
      _isActive = gateway.isActive;
    }
  }

  Future<void> _saveGateway() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(subscriptionsRepositoryProvider);
      await repo.savePaymentGateway(
        PlatformPaymentGateway(
          keyId: _keyIdController.text.trim(),
          keySecret: _keySecretController.text.trim(),
          webhookSecret: _webhookSecretController.text.trim(),
          isTestMode: _isTestMode,
          isActive: _isActive,
        ),
      );

      if (!mounted) return;
      ref.invalidate(adminPaymentGatewayProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Razorpay platform credentials updated successfully'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Failed to save gateway configuration.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gatewayAsync = ref.watch(adminPaymentGatewayProvider);

    return gatewayAsync.when(
      data: (gateway) {
        _populate(gateway);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LexCard(
                    borderRadius: 18,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB).withAlpha(25),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_rounded,
                                color: Color(0xFF2563EB),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Razorpay Payment Gateway',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Platform-wide billing credentials',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Configure the central Razorpay API keys used to process law firm subscription purchases and billing transactions.',
                          style: TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: LexColors.errorLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: LexColors.error,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  LexCard(
                    borderRadius: 18,
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Key ID
                        TextFormField(
                          controller: _keyIdController,
                          decoration: const InputDecoration(
                            labelText: 'Razorpay Key ID',
                            hintText: 'rzp_test_...',
                            prefixIcon: Icon(Icons.vpn_key_outlined),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Key ID is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Key Secret
                        TextFormField(
                          controller: _keySecretController,
                          obscureText: _obscureSecret,
                          decoration: InputDecoration(
                            labelText: 'Razorpay Key Secret',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureSecret
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(
                                () => _obscureSecret = !_obscureSecret,
                              ),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Key Secret is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Webhook Secret
                        TextFormField(
                          controller: _webhookSecretController,
                          decoration: const InputDecoration(
                            labelText: 'Webhook Secret (Optional)',
                            prefixIcon: Icon(Icons.webhook_rounded),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Test Mode Switch
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Test Mode (Sandbox)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: const Text(
                            'Enable for mock testing with Razorpay test keys.',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: _isTestMode,
                          activeThumbColor: const Color(0xFFF59E0B),
                          onChanged: (val) => setState(() => _isTestMode = val),
                        ),

                        // Active Switch
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Gateway Enabled',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: const Text(
                            'Allow law firms to check out and purchase subscriptions.',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: _isActive,
                          activeThumbColor: const Color(0xFF10B981),
                          onChanged: (val) => setState(() => _isActive = val),
                        ),
                        const SizedBox(height: 24),

                        LexButton(
                          label: _isSaving
                              ? 'Saving Settings...'
                              : 'Save Gateway Settings',
                          icon: Icons.save_rounded,
                          onPressed: _isSaving ? null : _saveGateway,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}
