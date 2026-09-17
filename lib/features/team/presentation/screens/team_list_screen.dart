import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/capability_gate.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/lex_text_field.dart';
import '../../../auth/domain/models/role_capabilities.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/models/team_member.dart';
import '../providers/team_notifier.dart';

class TeamListScreen extends ConsumerStatefulWidget {
  final String? initialFilter;

  const TeamListScreen({super.key, this.initialFilter});

  @override
  ConsumerState<TeamListScreen> createState() => _TeamListScreenState();
}

class _TeamListScreenState extends ConsumerState<TeamListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialFilter == 'lawyer' ||
        widget.initialFilter == 'advocates') {
      Future.microtask(
        () =>
            ref.read(teamFilterProvider.notifier).state = TeamFilter.advocates,
      );
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showAddMemberModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AddMemberModalSheet(),
    );
  }

  void _showMemberDetailsDialog(BuildContext context, TeamMember member) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: member.badgeColor.withValues(alpha: 0.15),
              child: Text(
                member.username.isNotEmpty
                    ? member.username[0].toUpperCase()
                    : 'U',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: member.badgeColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.username,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    member.displayRole,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: member.badgeColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Email', member.email, isDark),
            const Divider(height: 16),
            _buildDetailRow(
              'Firm Organization',
              member.firm.isNotEmpty ? member.firm : 'Current Firm',
              isDark,
            ),
            const Divider(height: 16),
            _buildDetailRow('Role Authority', member.displayRole, isDark),
            if (member.joined != null) ...[
              const Divider(height: 16),
              _buildDetailRow(
                'Member Since',
                DateFormat.yMMMMd().format(member.joined!),
                isDark,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? LexColors.textSecondaryDark
                  : LexColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? LexColors.textPrimaryDark
                  : LexColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredMembersAsync = ref.watch(filteredTeamMembersProvider);
    final activeFilter = ref.watch(teamFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          activeFilter == TeamFilter.advocates
              ? 'Firm Advocates'
              : 'Firm Team & Advocates',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Team',
            onPressed: () =>
                ref.read(teamNotifierProvider.notifier).loadTeamMembers(),
          ),
        ],
      ),
      floatingActionButton: CapabilityGate(
        capability: UserCapability.manageTeam,
        child: FloatingActionButton.extended(
          onPressed: () => _showAddMemberModal(context),
          icon: const Icon(Icons.person_add_outlined),
          label: const Text('Add Member'),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? LexColors.surfaceDark : LexColors.canvasLight,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? LexColors.borderDark : LexColors.borderLight,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchCtrl,
                  onChanged: (val) {
                    ref.read(teamSearchQueryProvider.notifier).state = val;
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, or role...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              ref.read(teamSearchQueryProvider.notifier).state =
                                  '';
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Filter Tabs
                Row(
                  children: [
                    _buildFilterChip('All', TeamFilter.all, activeFilter),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Advocates',
                      TeamFilter.advocates,
                      activeFilter,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip('Staff', TeamFilter.staff, activeFilter),
                  ],
                ),
              ],
            ),
          ),

          // Member List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(teamNotifierProvider.notifier).loadTeamMembers(),
              child: filteredMembersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: LexColors.error,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Error loading team: $err',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref
                              .read(teamNotifierProvider.notifier)
                              .loadTeamMembers(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (members) {
                  if (members.isEmpty) {
                    return ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.group_outlined,
                                    size: 64,
                                    color: isDark
                                        ? LexColors.textSecondaryDark
                                        : LexColors.textSecondaryLight,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    activeFilter == TeamFilter.advocates
                                        ? 'No advocates found in your firm'
                                        : 'No team members found in your firm',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Add lawyers and staff to collaborate in your firm workspace.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isDark
                                          ? LexColors.textSecondaryDark
                                          : LexColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: members.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (ctx, idx) =>
                        _buildMemberCard(context, members[idx]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    TeamFilter filter,
    TeamFilter activeFilter,
  ) {
    final isSelected = filter == activeFilter;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        ref.read(teamFilterProvider.notifier).state = filter;
      },
      selectedColor: isDark
          ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2)
          : Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? (isDark ? LexColors.accentGold : Colors.white)
            : (isDark
                  ? LexColors.textSecondaryDark
                  : LexColors.textSecondaryLight),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, TeamMember member) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initial = member.username.isNotEmpty
        ? member.username[0].toUpperCase()
        : 'U';

    return LexCard(
      padding: const EdgeInsets.all(16),
      onTap: () => _showMemberDetailsDialog(context, member),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: member.badgeColor.withValues(alpha: 0.15),
            child: Text(
              initial,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: member.badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: member.badgeColor.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        member.displayRole,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: member.badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 14,
                      color: isDark
                          ? LexColors.textSecondaryDark
                          : LexColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        member.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? LexColors.textSecondaryDark
                              : LexColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
                if (member.joined != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Joined: ${DateFormat.yMMMd().format(member.joined!)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? LexColors.textMutedDark
                          : LexColors.textMutedLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            size: 20,
            color: isDark ? LexColors.textMutedDark : LexColors.textMutedLight,
          ),
        ],
      ),
    );
  }
}

class _AddMemberModalSheet extends ConsumerStatefulWidget {
  const _AddMemberModalSheet();

  @override
  ConsumerState<_AddMemberModalSheet> createState() =>
      _AddMemberModalSheetState();
}

class _AddMemberModalSheetState extends ConsumerState<_AddMemberModalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _selectedRole = 'lawyer';
  int _mode = 0; // 0: Add Directly, 1: Send Invite
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      if (_mode == 0) {
        final currentFirmId = ref.read(authNotifierProvider).user?.firm;
        await ref
            .read(teamNotifierProvider.notifier)
            .addUser(
              username: _usernameCtrl.text.trim(),
              email: _emailCtrl.text.trim(),
              password: _passwordCtrl.text,
              role: _selectedRole,
              firmId: currentFirmId,
            );
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User added to firm successfully')),
          );
        }
      } else {
        await ref
            .read(teamNotifierProvider.notifier)
            .inviteMember(email: _emailCtrl.text.trim(), role: _selectedRole);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invitation sent successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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

    return Container(
      decoration: BoxDecoration(
        color: isDark ? LexColors.surfaceDark : LexColors.canvasLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _mode == 0
                    ? 'Add Team Member to Firm'
                    : 'Invite Team Member to Firm',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              // Segmented mode selector
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Add Directly')),
                  ButtonSegment(value: 1, label: Text('Send Invite')),
                ],
                selected: {_mode},
                onSelectionChanged: (set) => setState(() => _mode = set.first),
              ),
              const SizedBox(height: 20),

              if (_mode == 0) ...[
                LexTextField(
                  controller: _usernameCtrl,
                  label: 'Username *',
                  hintText: 'e.g. advocate_smith',
                  prefixIcon: Icons.person_outline,
                  validator: (v) =>
                      v?.trim().isEmpty == true ? 'Username required' : null,
                ),
                const SizedBox(height: 14),
              ],

              LexTextField(
                controller: _emailCtrl,
                label: 'Email Address *',
                hintText: 'colleague@example.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v?.trim().isEmpty == true) return 'Email required';
                  if (!v!.contains('@')) return 'Enter a valid email address';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              if (_mode == 0) ...[
                LexTextField(
                  controller: _passwordCtrl,
                  label: 'Temporary Password *',
                  hintText: 'Min. 8 characters',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (v) => v == null || v.length < 6
                      ? 'Password must be >= 6 chars'
                      : null,
                ),
                const SizedBox(height: 14),
              ],

              // Role selection dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Assigned Role',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'lawyer',
                    child: Text('Advocate / Lawyer'),
                  ),
                  DropdownMenuItem(value: 'staff', child: Text('Legal Staff')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _selectedRole = v);
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _mode == 0
                            ? 'Create Member Account'
                            : 'Send Invite Email',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
