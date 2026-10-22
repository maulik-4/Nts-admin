import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../dashboard/presentation/providers/dashboard_notifier.dart';
import '../../data/models/client_model.dart';
import '../providers/clients_notifier.dart';
import 'client_detail_screen.dart';

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

  static const List<String> _commonCities = [
    'New Delhi',
    'Delhi NCR',
    'Mumbai',
    'Bengaluru',
    'Kolkata',
    'Chennai',
    'Hyderabad',
    'Ahmedabad',
    'Pune',
    'Chandigarh',
    'Jaipur',
    'Lucknow',
    'Surat',
    'Indore',
    'Patna',
    'Bhopal',
    'Nagpur',
    'Kochi',
    'Guwahati',
    'Dehradun',
  ];

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
        ref.invalidate(clientDetailProvider(widget.clientId!));
        ref.invalidate(dashboardNotifierProvider);
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
        ref.invalidate(dashboardNotifierProvider);
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
    final cardBg = isDark ? const Color(0xFF131D33) : Colors.white;
    final cardBorder =
        isDark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final dividerColor =
        isDark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF070E1A) : const Color(0xFFF1F5F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Top Header with 1.1.png matching 1.png
            Stack(
              children: [
                // Background image 1.1.png
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
                // Gradient overlay on left side
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
                // Header Content
                SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AppBar row with Back Button & Title
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
                            Text(
                              isEdit ? 'Edit Client' : 'Add New Client',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Badge + Add New Client title + Subtitle
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0B1B34)
                                    .withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B)
                                      .withValues(alpha: 0.6),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_add_alt_1_outlined,
                                size: 24,
                                color: Color(0xFFFBBF24),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.4,
                                      ),
                                      children: [
                                        TextSpan(
                                            text: isEdit
                                                ? 'Update '
                                                : 'Add New '),
                                        const TextSpan(
                                          text: 'Client',
                                          style: TextStyle(
                                              color: Color(0xFFFBBF24)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Create a new client profile and\nmanage their legal matters efficiently.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.35,
                                      color:
                                          Colors.white.withValues(alpha: 0.85),
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
                ),
              ],
            ),

            // 2. Main Surface Form Card matching 1.png
            Transform.translate(
              offset: const Offset(0, -12),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Section 1: Client Information
                      _buildSectionHeader(
                        icon: Icons.person_outline_rounded,
                        title: 'Client Information',
                        subtitle: 'Enter the primary details of the client',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 18),

                      // Client Name / Business Name *
                      _buildFieldLabel('Client Name / Business Name',
                          isRequired: true, isDark: isDark),
                      _buildTextField(
                        controller: _nameController,
                        hintText: 'e.g. Acme Legal Corp or Rajesh Sharma',
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (val) =>
                            Validators.required(val, 'Client name'),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),

                      // Phone Number *
                      _buildFieldLabel('Phone Number',
                          isRequired: true, isDark: isDark),
                      _buildTextField(
                        controller: _phoneController,
                        hintText: '+91 98765 43210',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: Validators.phone,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),

                      // Email Address (Optional)
                      _buildFieldLabel('Email Address (Optional)',
                          isRequired: false, isDark: isDark),
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'client@example.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val != null && val.trim().isNotEmpty) {
                            return Validators.email(val);
                          }
                          return null;
                        },
                        isDark: isDark,
                      ),

                      // Divider
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        child: Divider(
                            color: dividerColor, height: 1, thickness: 1),
                      ),

                      // Section 2: Address & Jurisdiction
                      _buildSectionHeader(
                        icon: Icons.location_on_outlined,
                        title: 'Address & Jurisdiction',
                        subtitle: 'Add location and office address details',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 18),

                      // City / Jurisdiction (Optional)
                      _buildFieldLabel('City / Jurisdiction (Optional)',
                          isRequired: false, isDark: isDark),
                      _buildCitySelectorField(isDark: isDark),
                      const SizedBox(height: 16),

                      // Office / Postal Address *
                      _buildFieldLabel('Office / Postal Address',
                          isRequired: true, isDark: isDark),
                      _buildAddressField(isDark: isDark),

                      if (isEdit) ...[
                        const SizedBox(height: 18),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Active Client Status',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            'Active clients are visible in case assignment pickers.',
                            style:
                                TextStyle(fontSize: 12, color: textSecondary),
                          ),
                          value: _isActive,
                          onChanged: (val) => setState(() => _isActive = val),
                        ),
                      ],

                      const SizedBox(height: 28),

                      // Submit Button matching 1.png
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFD97706),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFB45309),
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color:
                      isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label,
      {bool isRequired = false, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
          ),
          children: [
            TextSpan(text: label),
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 13.5,
          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        ),
        prefixIcon: Icon(
          prefixIcon,
          size: 20,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
        filled: true,
        fillColor: isDark
            ? const Color(0xFF0F172A).withValues(alpha: 0.6)
            : const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF2563EB),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildCitySelectorField({required bool isDark}) {
    return InkWell(
      onTap: () => _showCityPicker(context, isDark: isDark),
      borderRadius: BorderRadius.circular(12),
      child: IgnorePointer(
        child: TextFormField(
          controller: _cityController,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: 'e.g. New Delhi',
            hintStyle: TextStyle(
              fontSize: 13.5,
              color:
                  isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
            prefixIcon: Icon(
              Icons.apartment_rounded,
              size: 20,
              color:
                  isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
            suffixIcon: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 24,
              color:
                  isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF0F172A).withValues(alpha: 0.6)
                : const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color:
                    isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color:
                    isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF2563EB),
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressField({required bool isDark}) {
    return Stack(
      children: [
        TextFormField(
          controller: _addressController,
          maxLines: 3,
          keyboardType: TextInputType.multiline,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          validator: (val) => Validators.required(val, 'Address'),
          decoration: InputDecoration(
            hintText: 'Street address, office suite, area, landmark, pincode...',
            hintStyle: TextStyle(
              fontSize: 13,
              color:
                  isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 34),
              child: Icon(
                Icons.home_outlined,
                size: 20,
                color:
                    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF0F172A).withValues(alpha: 0.6)
                : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.fromLTRB(14, 14, 24, 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color:
                    isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color:
                    isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF2563EB),
                width: 1.5,
              ),
            ),
          ),
        ),
        // Resize handle indicator at bottom right matching 1.png
        Positioned(
          bottom: 8,
          right: 8,
          child: CustomPaint(
            size: const Size(10, 10),
            painter: _ResizeGripPainter(
              color:
                  isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF091629),
            Color(0xFF132B4F),
            Color(0xFF0D203D),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF091629).withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _submit,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _isLoading
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Row(
                    children: [
                      const SizedBox(width: 20), // balance right arrow
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person_add_alt_1_rounded,
                              color: Colors.white,
                              size: 19,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isEdit ? 'Save Client Changes' : 'Create Client',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15.5,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 19,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _showCityPicker(BuildContext context, {required bool isDark}) {
    final searchController = TextEditingController();
    List<String> filteredCities = List.from(_commonCities);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF131D33) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.65,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (ctx, scrollController) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    18,
                    12,
                    18,
                    MediaQuery.of(ctx).viewInsets.bottom + 18,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Select City / Jurisdiction',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: searchController,
                        autofocus: false,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search city or enter custom...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            final q = val.toLowerCase().trim();
                            filteredCities = _commonCities
                                .where((c) => c.toLowerCase().contains(q))
                                .toList();
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      if (searchController.text.trim().isNotEmpty &&
                          !_commonCities.contains(searchController.text.trim()))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () {
                              _cityController.text =
                                  searchController.text.trim();
                              Navigator.pop(ctx);
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E2D4A)
                                    : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF38BDF8)
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.add_location_alt_outlined,
                                      size: 18, color: Color(0xFF2563EB)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Use "${searchController.text.trim()}"',
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2563EB),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          itemCount: filteredCities.length,
                          separatorBuilder: (context, index) => Divider(
                            color: isDark
                                ? const Color(0xFF1E2D4A)
                                : const Color(0xFFF1F5F9),
                            height: 1,
                          ),
                          itemBuilder: (ctx, idx) {
                            final city = filteredCities[idx];
                            final isSelected =
                                _cityController.text.trim().toLowerCase() ==
                                    city.toLowerCase();
                            return ListTile(
                              dense: true,
                              title: Text(
                                city,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? const Color(0xFF2563EB)
                                      : (isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A)),
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check,
                                      color: Color(0xFF2563EB), size: 18)
                                  : null,
                              onTap: () {
                                _cityController.text = city;
                                Navigator.pop(ctx);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ResizeGripPainter extends CustomPainter {
  final Color color;
  const _ResizeGripPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width - 3, size.height),
      Offset(size.width, size.height - 3),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - 7, size.height),
      Offset(size.width, size.height - 7),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ResizeGripPainter oldDelegate) =>
      oldDelegate.color != color;
}
