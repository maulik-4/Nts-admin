import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/lex_text_field.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/models/client_model.dart';
import '../providers/clients_notifier.dart';

class ClientFormScreen extends ConsumerStatefulWidget {
  final int? clientId;

  const ClientFormScreen({super.key, this.clientId});

  @override
  ConsumerState<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends ConsumerState<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;
  bool _initialized = false;

  bool get isEdit => widget.clientId != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized && isEdit) {
      _loadExistingClient();
      _initialized = true;
    }
  }

  void _loadExistingClient() {
    final list = ref.read(clientsNotifierProvider).valueOrNull;
    if (list != null) {
      final match = list.where((c) => c.id == widget.clientId);
      if (match.isNotEmpty) {
        final client = match.first;
        _nameController.text = client.name;
        _phoneController.text = client.phone;
        _emailController.text = client.email ?? '';
        _addressController.text = client.address;
        _cityController.text = client.city ?? '';
        _isActive = client.isActive;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authNotifierProvider).user;
      final firmId = user?.firmId ?? 15;

      if (isEdit) {
        final request = UpdateClientRequest(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
          address: _addressController.text.trim(),
          city: _cityController.text.trim().isNotEmpty
              ? _cityController.text.trim()
              : null,
          isActive: _isActive,
        );
        await ref
            .read(clientsNotifierProvider.notifier)
            .updateClient(widget.clientId!, request);
        if (mounted) {
          AppAlerts.showSuccess(context, 'Client updated successfully.');
          context.pop();
        }
      } else {
        final request = CreateClientRequest(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
          address: _addressController.text.trim(),
          city: _cityController.text.trim().isNotEmpty
              ? _cityController.text.trim()
              : null,
          firm: firmId,
        );
        await ref.read(clientsNotifierProvider.notifier).createClient(request);
        if (mounted) {
          AppAlerts.showSuccess(context, 'Client created successfully.');
          context.pop();
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        AppAlerts.showError(context, e.message);
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(context, 'An unexpected error occurred: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Client' : 'Add New Client',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
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
                        child: Text(
                          isEdit
                              ? 'UPDATE CLIENT PROFILE'
                              : 'CLIENT PROFILE SPECIFICATION',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Client Information',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Name
                      LexTextField(
                        controller: _nameController,
                        label: 'Client Name / Business Name *',
                        hintText: 'e.g. Acme Legal Corp or Rajesh Sharma',
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (val) =>
                            Validators.required(val, 'Client name'),
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      LexTextField(
                        controller: _phoneController,
                        label: 'Phone Number *',
                        hintText: 'e.g. +91 9876543210',
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        validator: Validators.phone,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      LexTextField(
                        controller: _emailController,
                        label: 'Email Address (Optional)',
                        hintText: 'client@example.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (val) {
                          if (val != null && val.trim().isNotEmpty) {
                            return Validators.email(val);
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // City
                      LexTextField(
                        controller: _cityController,
                        label: 'City / Jurisdiction (Optional)',
                        hintText: 'e.g. New Delhi',
                        prefixIcon: Icons.location_city_outlined,
                      ),
                      const SizedBox(height: 16),

                      // Address
                      LexTextField(
                        controller: _addressController,
                        label: 'Office / Postal Address *',
                        hintText:
                            'Street address, office suite, or postal address',
                        prefixIcon: Icons.home_outlined,
                        validator: (val) => Validators.required(val, 'Address'),
                      ),

                      if (isEdit) ...[
                        const SizedBox(height: 16),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Active Client Status',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: const Text(
                            'Active clients are visible in case assignment pickers.',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: _isActive,
                          onChanged: (val) => setState(() => _isActive = val),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
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
                        : Text(
                            isEdit ? 'Save Client Changes' : 'Create Client',
                            style: const TextStyle(
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
    );
  }
}
