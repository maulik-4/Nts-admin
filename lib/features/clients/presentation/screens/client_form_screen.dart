import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/theme/lex_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/lex_button.dart';
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
  String? _serverError;
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
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authNotifierProvider).user;
      final firmId = user?.firmId ?? 15;

      if (isEdit) {
        final request = UpdateClientRequest(
          name: _nameController.text,
          phone: _phoneController.text,
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
          address: _addressController.text,
          city: _cityController.text.trim().isNotEmpty
              ? _cityController.text.trim()
              : null,
          isActive: _isActive,
        );
        await ref
            .read(clientsNotifierProvider.notifier)
            .updateClient(widget.clientId!, request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Client updated successfully')),
          );
          context.pop();
        }
      } else {
        final request = CreateClientRequest(
          name: _nameController.text,
          phone: _phoneController.text,
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
          address: _addressController.text,
          city: _cityController.text.trim().isNotEmpty
              ? _cityController.text.trim()
              : null,
          firm: firmId,
        );
        await ref.read(clientsNotifierProvider.notifier).createClient(request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Client created successfully')),
          );
          context.pop();
        }
      }
    } on ApiException catch (e) {
      setState(() => _serverError = e.message);
    } catch (e) {
      setState(() => _serverError = 'An unexpected error occurred: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Client' : 'Add New Client')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_serverError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: LexColors.errorLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: LexColors.error.withAlpha(80)),
                    ),
                    child: Text(
                      _serverError!,
                      style: const TextStyle(
                        color: LexColors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],

                LexCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Client Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? LexColors.textPrimaryDark
                              : LexColors.slatePrimary,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Name
                      LexTextField(
                        controller: _nameController,
                        label: 'Client Name / Business Name',
                        hintText: 'e.g. Acme Corporation or Jane Doe',
                        prefixIcon: Icons.person_outline,
                        validator: (val) =>
                            Validators.required(val, 'Client name'),
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      LexTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hintText: 'e.g. 9876543210',
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
                        label: 'City (Optional)',
                        hintText: 'e.g. Shimla',
                        prefixIcon: Icons.location_city_outlined,
                      ),
                      const SizedBox(height: 16),

                      // Address
                      LexTextField(
                        controller: _addressController,
                        label: 'Full Address',
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: const Text(
                            'Mark as active or inactive client',
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
                LexButton(
                  label: isEdit ? 'Save Client Changes' : 'Create Client',
                  variant: LexButtonVariant.primary,
                  isLoading: _isLoading,
                  icon: isEdit
                      ? Icons.save_outlined
                      : Icons.check_circle_outline,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
