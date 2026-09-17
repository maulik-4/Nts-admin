import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../team/data/models/team_member.dart';
import '../../../team/presentation/providers/team_notifier.dart';

class PlatformTeamScreen extends ConsumerStatefulWidget {
  const PlatformTeamScreen({super.key});

  @override
  ConsumerState<PlatformTeamScreen> createState() => _PlatformTeamScreenState();
}

class _PlatformTeamScreenState extends ConsumerState<PlatformTeamScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedRoleFilter = 'all'; // all, super_admin, admin, lawyer, staff
  String _selectedFirmFilter = 'all'; // all, platform, firm_only
  static const Color _superAdminGold = Color(0xFFC9A84C);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamAsync = ref.watch(teamNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Users & Team'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Users',
            onPressed: () =>
                ref.read(teamNotifierProvider.notifier).loadTeamMembers(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showInvitePlatformUserDialog(context),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Invite User'),
        backgroundColor: _superAdminGold,
        foregroundColor: Colors.black,
      ),
      body: teamAsync.when(
        data: (members) {
          final filtered = members.where((m) {
            // Search text
            if (_searchQuery.isNotEmpty) {
              final q = _searchQuery.toLowerCase();
              final matchSearch = m.username.toLowerCase().contains(q) ||
                  m.email.toLowerCase().contains(q) ||
                  m.role.toLowerCase().contains(q) ||
                  m.firm.toLowerCase().contains(q);
              if (!matchSearch) return false;
            }

            // Role filter
            if (_selectedRoleFilter != 'all') {
              if (m.role.toLowerCase() != _selectedRoleFilter.toLowerCase()) {
                return false;
              }
            }

            // Firm filter
            if (_selectedFirmFilter == 'platform') {
              if (m.firm.isNotEmpty && m.firm != '0') return false;
            } else if (_selectedFirmFilter == 'firm_only') {
              if (m.firm.isEmpty || m.firm == '0') return false;
            }

            return true;
          }).toList();

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(teamNotifierProvider.notifier).loadTeamMembers(),
            child: Column(
              children: [
                // Search Field
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText:
                          'Search by username, email, role, or firm ID...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark
                          ? LexColors.surfaceDark
                          : LexColors.surfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: isDark
                              ? LexColors.borderDark
                              : LexColors.borderLight,
                        ),
                      ),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v.trim()),
                  ),
                ),

                // Role and Firm Filter Chips (Section 20)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      _buildFilterChip('All Roles', 'all', _selectedRoleFilter, (val) {
                        setState(() => _selectedRoleFilter = val);
                      }),
                      const SizedBox(width: 6),
                      _buildFilterChip('Super Admins', 'super_admin', _selectedRoleFilter, (val) {
                        setState(() => _selectedRoleFilter = val);
                      }),
                      const SizedBox(width: 6),
                      _buildFilterChip('Firm Admins', 'admin', _selectedRoleFilter, (val) {
                        setState(() => _selectedRoleFilter = val);
                      }),
                      const SizedBox(width: 6),
                      _buildFilterChip('Lawyers', 'lawyer', _selectedRoleFilter, (val) {
                        setState(() => _selectedRoleFilter = val);
                      }),
                      const SizedBox(width: 6),
                      _buildFilterChip('Staff', 'staff', _selectedRoleFilter, (val) {
                        setState(() => _selectedRoleFilter = val);
                      }),
                      const SizedBox(width: 14),
                      Container(height: 20, width: 1, color: Colors.grey.withAlpha(80)),
                      const SizedBox(width: 14),
                      _buildFilterChip('All Tenants', 'all', _selectedFirmFilter, (val) {
                        setState(() => _selectedFirmFilter = val);
                      }),
                      const SizedBox(width: 6),
                      _buildFilterChip('Platform Only', 'platform', _selectedFirmFilter, (val) {
                        setState(() => _selectedFirmFilter = val);
                      }),
                      const SizedBox(width: 6),
                      _buildFilterChip('Firm Members', 'firm_only', _selectedFirmFilter, (val) {
                        setState(() => _selectedFirmFilter = val);
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // User Count & List
                Expanded(
                  child: filtered.isEmpty
                      ? EmptyStateWidget(
                          title: 'No Platform Users Found',
                          message: _searchQuery.isNotEmpty ||
                                  _selectedRoleFilter != 'all' ||
                                  _selectedFirmFilter != 'all'
                              ? 'No users match the active filters.'
                              : 'No users registered on the platform.',
                          icon: Icons.person_off_outlined,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 88,
                          ),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (ctx, idx) =>
                              _buildUserTile(context, filtered[idx], isDark),
                        ),
                ),
              ],
            ),
          );
        },
        loading: () => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: List.generate(
              4,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SkeletonLoader(height: 90),
              ),
            ),
          ),
        ),
        error: (err, _) => ErrorStateWidget(
          message: 'Unable to Load Users: $err',
          onRetry: () =>
              ref.read(teamNotifierProvider.notifier).loadTeamMembers(),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    String currentValue,
    ValueChanged<String> onSelected,
  ) {
    final isSelected = value == currentValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      selectedColor: _superAdminGold.withAlpha(50),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? _superAdminGold : null,
      ),
      side: BorderSide(
        color: isSelected ? _superAdminGold : Colors.transparent,
      ),
    );
  }

  Widget _buildUserTile(BuildContext context, TeamMember member, bool isDark) {
    final initials = member.username.isNotEmpty
        ? member.username.substring(0, 1).toUpperCase()
        : 'U';
    final dateStr = member.joined != null
        ? DateFormat('MMM d, yyyy').format(member.joined!)
        : 'Joined Recently';

    return LexCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: member.badgeColor.withAlpha(35),
            child: Text(
              initials,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: member.badgeColor,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.username,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: isDark
                              ? LexColors.textPrimaryDark
                              : LexColors.textPrimaryLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    StatusBadge(
                      status: member.displayRole,
                      color: member.badgeColor,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  member.email,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? LexColors.textSecondaryDark
                        : LexColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.business_outlined,
                      size: 13,
                      color: isDark
                          ? LexColors.textSecondaryDark
                          : LexColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      member.firm.isNotEmpty && member.firm != '0'
                          ? 'Firm #${member.firm}'
                          : 'Platform Level',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? LexColors.textSecondaryDark
                            : LexColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: isDark
                          ? LexColors.textSecondaryDark
                          : LexColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? LexColors.textSecondaryDark
                            : LexColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PLATFORM USER INVITATION DIALOG (Prompt Section 21)
  // API: POST /api/auth/invite/platform/
  // Payload: { "email": "user@example.com", "role": "super_admin" }
  // ===========================================================================
  void _showInvitePlatformUserDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailCtrl = TextEditingController();
    String selectedRole = 'super_admin';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.mark_email_read_outlined,
                        color: _superAdminGold,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Invite Platform User',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Invitee Email *',
                      hintText: 'user@example.com',
                      prefixIcon: Icon(Icons.email_outlined, size: 20),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v?.contains('@') != true
                        ? 'Valid email required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Platform Role *',
                      prefixIcon: Icon(Icons.admin_panel_settings_outlined, size: 20),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'super_admin',
                        child: Text('Super Admin (Platform Administrator)'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) setModalState(() => selectedRole = v);
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _superAdminGold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            setModalState(() => isSubmitting = true);

                            try {
                              await ref
                                  .read(teamNotifierProvider.notifier)
                                  .invitePlatformUser(
                                    email: emailCtrl.text.trim(),
                                    role: selectedRole,
                                  );
                              if (context.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Platform invite sent'),
                                  ),
                                );
                              }
                            } catch (e) {
                              setModalState(() => isSubmitting = false);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error sending invite: $e'),
                                  ),
                                );
                              }
                            }
                          },
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'Send Platform Invite',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showDirectAddUserDialog(context);
                    },
                    child: const Text('Or create firm/platform user with credentials'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDirectAddUserDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final usernameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final firmIdCtrl = TextEditingController();
    String selectedRole = 'admin';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.person_add_alt_1,
                        color: _superAdminGold,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Direct User Provisioning',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: usernameCtrl,
                    decoration: const InputDecoration(labelText: 'Username *'),
                    validator: (v) =>
                        v?.trim().isEmpty == true ? 'Username required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email *'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v?.contains('@') != true
                        ? 'Valid email required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Initial Password *',
                    ),
                    obscureText: true,
                    validator: (v) => (v?.length ?? 0) < 6
                        ? 'Password must be >= 6 chars'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Assigned Role',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'super_admin',
                        child: Text('Super Admin'),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('Firm Admin'),
                      ),
                      DropdownMenuItem(
                        value: 'lawyer',
                        child: Text('Advocate / Lawyer'),
                      ),
                      DropdownMenuItem(
                        value: 'staff',
                        child: Text('Legal Staff'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) setModalState(() => selectedRole = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: firmIdCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Firm ID (optional)',
                      hintText: 'e.g. 15 (leave blank for platform user)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _superAdminGold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            setModalState(() => isSubmitting = true);

                            final firmId = int.tryParse(firmIdCtrl.text.trim());

                            try {
                              await ref
                                  .read(teamNotifierProvider.notifier)
                                  .addUser(
                                    username: usernameCtrl.text.trim(),
                                    email: emailCtrl.text.trim(),
                                    password: passCtrl.text.trim(),
                                    role: selectedRole,
                                    firmId: firmId,
                                  );
                              if (context.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('User created successfully'),
                                  ),
                                );
                              }
                            } catch (e) {
                              setModalState(() => isSubmitting = false);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error adding user: $e'),
                                  ),
                                );
                              }
                            }
                          },
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'Provision User',
                            style: TextStyle(fontWeight: FontWeight.bold),
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
