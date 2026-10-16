import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/role_badge.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../auth/domain/models/role_capabilities.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get('/api/profile/me/');
      if (res.data is Map<String, dynamic>) {
        setState(() {
          _profileData = res.data as Map<String, dynamic>;
          _firstNameCtrl.text = _profileData?['first_name']?.toString() ?? '';
          _lastNameCtrl.text = _profileData?['last_name']?.toString() ?? '';
          _phoneCtrl.text = _profileData?['phone']?.toString() ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(context, 'Error loading profile: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.patch(
        '/api/profile/me/',
        data: {
          'first_name': _firstNameCtrl.text.trim(),
          'last_name': _lastNameCtrl.text.trim(),
          if (_phoneCtrl.text.trim().isNotEmpty)
            'phone': _phoneCtrl.text.trim(),
        },
      );
      if (mounted) {
        AppAlerts.showSuccess(context, 'Profile updated successfully!');
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(context, 'Failed to update profile: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hintText,
    bool readOnly = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
            prefixIcon: Icon(
              icon,
              size: 18,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final userRole = ref.watch(currentUserRoleProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final initials = user?.username.isNotEmpty == true
        ? user!.username.substring(0, 1).toUpperCase()
        : 'U';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _loadProfile,
          ),
        ],
      ),
      body: _isLoading
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: const [
                  SkeletonLoader(height: 140, borderRadius: 18),
                  SizedBox(height: 16),
                  SkeletonLoader(height: 220, borderRadius: 18),
                  SizedBox(height: 16),
                  SkeletonLoader(height: 160, borderRadius: 18),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Header Card with Camera Badge
                  LexCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 86,
                              height: 86,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF0F1F38),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFE2E8F0),
                                  width: 3,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user?.username ?? 'Legal User',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 10),
                        RoleBadge(
                          role: userRole,
                          fontSize: 12,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Personal Information Card
                  LexCard(
                    borderRadius: 18,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 19,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'First Name',
                          controller: _firstNameCtrl,
                          icon: Icons.badge_outlined,
                          hintText: 'Enter first name',
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          label: 'Last Name',
                          controller: _lastNameCtrl,
                          icon: Icons.badge_outlined,
                          hintText: 'Enter last name',
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          label: 'Primary Phone',
                          controller: _phoneCtrl,
                          icon: Icons.phone_outlined,
                          hintText: 'Enter phone number',
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F1F38),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Save Profile Changes',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Law Firm Affiliation Card
                  if (_profileData?['firm'] is Map) ...[
                    LexCard(
                      borderRadius: 18,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.business_outlined,
                                size: 19,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Law Firm Affiliation',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildDetailRow(
                            'Firm Name',
                            _profileData!['firm']['name']?.toString() ?? 'LexTech Legal',
                          ),
                          const Divider(height: 18),
                          _buildDetailRow(
                            'Address',
                            _profileData!['firm']['address']?.toString() ?? 'Headquarters',
                          ),
                          const Divider(height: 18),
                          _buildDetailRow(
                            'Firm Phone',
                            _profileData!['firm']['phone']?.toString() ?? 'Direct line',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Account & Security Card
                  LexCard(
                    borderRadius: 18,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.security_outlined,
                              size: 19,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Account & Security',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildDetailRow('Account ID', '#${user?.id ?? 1}'),
                        const Divider(height: 18),
                        _buildDetailRow('Role Authority', userRole.displayTitle),
                        const Divider(height: 18),
                        _buildDetailRow('Status', 'Active Verified Account'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
