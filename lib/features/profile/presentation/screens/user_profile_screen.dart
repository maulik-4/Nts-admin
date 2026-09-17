import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/lex_text_field.dart';
import '../../../../shared/widgets/role_badge.dart';
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
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
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
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: LexColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: LexColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final userRole = ref.watch(currentUserRoleProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadProfile),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Header Card
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: userRole.badgeColor.withValues(
                            alpha: 0.15,
                          ),
                          child: Text(
                            user?.username.isNotEmpty == true
                                ? user!.username[0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: userRole.badgeColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          user?.username ?? 'Legal User',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? LexColors.textSecondaryDark
                                : LexColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 10),
                        RoleBadge(
                          role: userRole,
                          fontSize: 12,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          userRole.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? LexColors.textSecondaryDark
                                : LexColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Personal Info Card
                  LexCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LexTextField(
                          controller: _firstNameCtrl,
                          label: 'First Name',
                          hintText: 'Enter first name',
                          prefixIcon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 14),
                        LexTextField(
                          controller: _lastNameCtrl,
                          label: 'Last Name',
                          hintText: 'Enter last name',
                          prefixIcon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
                                : const Text('Save Profile Changes'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Firm Context Card
                  if (_profileData?['firm'] is Map) ...[
                    LexCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Law Firm Affiliation',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            'Firm Name',
                            _profileData!['firm']['name']?.toString() ??
                                'NTS Legal',
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            'Address',
                            _profileData!['firm']['address']?.toString() ??
                                'Not specified',
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            'Firm Phone',
                            _profileData!['firm']['phone']?.toString() ??
                                'Not specified',
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }
}
