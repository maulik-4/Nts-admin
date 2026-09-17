import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/models/tenant_firm.dart';
import '../providers/firms_notifier.dart';

class FirmsListScreen extends ConsumerStatefulWidget {
  const FirmsListScreen({super.key});

  @override
  ConsumerState<FirmsListScreen> createState() => _FirmsListScreenState();
}

class _FirmsListScreenState extends ConsumerState<FirmsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  static const Color _superAdminGold = Color(0xFFC9A84C);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firmsAsync = ref.watch(firmsNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant Law Firms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Firms',
            onPressed: () =>
                ref.read(firmsNotifierProvider.notifier).loadFirms(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateFirmDialog(context),
        icon: const Icon(Icons.add_business),
        label: const Text('New Firm'),
        backgroundColor: _superAdminGold,
        foregroundColor: Colors.black,
      ),
      body: firmsAsync.when(
        data: (firms) {
          final filtered = firms.where((f) {
            if (_searchQuery.isEmpty) return true;
            final q = _searchQuery.toLowerCase();
            return f.name.toLowerCase().contains(q) ||
                f.email.toLowerCase().contains(q) ||
                (f.phone?.toLowerCase().contains(q) ?? false) ||
                (f.city?.toLowerCase().contains(q) ?? false) ||
                (f.state?.toLowerCase().contains(q) ?? false) ||
                (f.panNumber?.toLowerCase().contains(q) ?? false) ||
                (f.gstNumber?.toLowerCase().contains(q) ?? false);
          }).toList();

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(firmsNotifierProvider.notifier).loadFirms(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, email, phone, city, state, PAN, GST...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
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
                    onChanged: (val) =>
                        setState(() => _searchQuery = val.trim()),
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? EmptyStateWidget(
                          title: 'No Tenant Firms Found',
                          message: _searchQuery.isNotEmpty
                              ? 'No firms match "$_searchQuery".'
                              : 'No law firms are registered on the platform.',
                          icon: Icons.domain_disabled_outlined,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 8,
                            bottom: 88,
                          ),
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final firm = filtered[index];
                            return _buildFirmTile(context, firm, isDark);
                          },
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
                child: SkeletonLoader(height: 140),
              ),
            ),
          ),
        ),
        error: (err, _) => ErrorStateWidget(
          message: 'Unable to Load Firms: $err',
          onRetry: () => ref.read(firmsNotifierProvider.notifier).loadFirms(),
        ),
      ),
    );
  }

  Widget _buildFirmTile(BuildContext context, TenantFirm firm, bool isDark) {
    return InkWell(
      onTap: () => _showFirmDetailsDialog(context, firm),
      borderRadius: BorderRadius.circular(14),
      child: LexCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar, Name, Email, Status Badges, Menu
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _superAdminGold.withAlpha(40),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _superAdminGold.withAlpha(90),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      firm.name.isNotEmpty
                          ? firm.name.substring(0, 1).toUpperCase()
                          : 'F',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _superAdminGold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firm.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? LexColors.textPrimaryDark
                              : LexColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        firm.email,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? LexColors.textSecondaryDark
                              : LexColors.textSecondaryLight,
                        ),
                      ),
                      if (firm.phone != null && firm.phone!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          firm.phone!,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? LexColors.textSecondaryDark
                                : LexColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Wrap(
                  spacing: 6,
                  children: [
                    StatusBadge(
                      status: firm.isActive ? 'Active' : 'Inactive',
                      color: firm.isActive
                          ? LexColors.success
                          : LexColors.warning,
                    ),
                    if (firm.isBlocked)
                      const StatusBadge(
                        status: 'Blocked',
                        color: LexColors.error,
                      ),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (val) {
                    if (val == 'details') {
                      _showFirmDetailsDialog(context, firm);
                    } else if (val == 'edit') {
                      _showEditFirmDialog(context, firm);
                    } else if (val == 'active') {
                      _confirmToggleActive(context, firm);
                    } else if (val == 'block') {
                      _confirmToggleBlock(context, firm);
                    } else if (val == 'delete') {
                      _confirmDeleteFirm(context, firm);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'details',
                      child: Row(
                        children: [
                          Icon(Icons.analytics_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Details & Stats'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Edit Firm'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'active',
                      child: Row(
                        children: [
                          Icon(
                            firm.isActive
                                ? Icons.pause_circle_outline
                                : Icons.play_circle_outline,
                            size: 18,
                            color: firm.isActive
                                ? LexColors.warning
                                : LexColors.success,
                          ),
                          const SizedBox(width: 8),
                          Text(firm.isActive ? 'Deactivate' : 'Activate'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'block',
                      child: Row(
                        children: [
                          Icon(
                            firm.isBlocked
                                ? Icons.check_circle_outline
                                : Icons.block_outlined,
                            size: 18,
                            color: firm.isBlocked
                                ? LexColors.success
                                : LexColors.error,
                          ),
                          const SizedBox(width: 8),
                          Text(firm.isBlocked ? 'Unblock' : 'Block'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: LexColors.error,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Delete Firm',
                            style: TextStyle(color: LexColors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Location, PAN, GST Meta
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                if (firm.city != null && firm.city!.isNotEmpty)
                  _buildMetaTag(
                    Icons.location_on_outlined,
                    '${firm.city}${firm.state != null ? ", ${firm.state}" : ""}',
                    isDark,
                  ),
                if (firm.panNumber != null && firm.panNumber!.isNotEmpty)
                  _buildMetaTag(
                    Icons.credit_card_outlined,
                    'PAN: ${firm.panNumber}',
                    isDark,
                  ),
                if (firm.gstNumber != null && firm.gstNumber!.isNotEmpty)
                  _buildMetaTag(
                    Icons.receipt_long_outlined,
                    'GST: ${firm.gstNumber}',
                    isDark,
                  ),
                _buildMetaTag(Icons.tag, 'Firm #${firm.id}', isDark),
              ],
            ),
            const Divider(height: 20),

            // Action Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => _showFirmDetailsDialog(context, firm),
                  icon: const Icon(Icons.analytics_outlined, size: 16),
                  label: const Text('View Statistics'),
                  style: TextButton.styleFrom(
                    foregroundColor: _superAdminGold,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                Row(
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      onPressed: () => _confirmToggleActive(context, firm),
                      child: Text(
                        firm.isActive ? 'Deactivate' : 'Activate',
                        style: TextStyle(
                          fontSize: 12,
                          color: firm.isActive
                              ? LexColors.warning
                              : LexColors.success,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      onPressed: () => _confirmToggleBlock(context, firm),
                      child: Text(
                        firm.isBlocked ? 'Unblock' : 'Block',
                        style: TextStyle(
                          fontSize: 12,
                          color: firm.isBlocked
                              ? LexColors.success
                              : LexColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaTag(IconData icon, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: isDark
              ? LexColors.textSecondaryDark
              : LexColors.textSecondaryLight,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? LexColors.textSecondaryDark
                : LexColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // TOGGLE ACTIVE CONFIRMATION DIALOG (Prompt Section 14)
  // ===========================================================================
  void _confirmToggleActive(BuildContext context, TenantFirm firm) {
    final willDeactivate = firm.isActive;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(willDeactivate ? 'Deactivate Firm?' : 'Activate Firm?'),
        content: Text(
          willDeactivate
              ? 'Are you sure you want to deactivate "${firm.name}"? This will change the firm\'s active status.'
              : 'Are you sure you want to activate "${firm.name}"? Advocates will regain active tenant capabilities.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: willDeactivate
                  ? LexColors.warning
                  : LexColors.success,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final newStatus = await ref
                    .read(firmsNotifierProvider.notifier)
                    .toggleActive(firm.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        newStatus
                            ? 'Firm "${firm.name}" is now Active'
                            : 'Firm "${firm.name}" is now Deactivated',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update status: $e')),
                  );
                }
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TOGGLE BLOCK CONFIRMATION DIALOG (Prompt Section 15)
  // ===========================================================================
  void _confirmToggleBlock(BuildContext context, TenantFirm firm) {
    final willBlock = !firm.isBlocked;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(willBlock ? 'Block Firm?' : 'Unblock Firm?'),
        content: Text(
          willBlock
              ? 'Are you sure you want to block "${firm.name}"? Access will be restricted platform-wide.'
              : 'Are you sure you want to unblock "${firm.name}"? Normal access will be restored.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: willBlock ? LexColors.error : LexColors.success,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final newStatus = await ref
                    .read(firmsNotifierProvider.notifier)
                    .toggleBlock(firm.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        newStatus
                            ? 'Firm "${firm.name}" is now Blocked'
                            : 'Firm "${firm.name}" is now Allowed (Unblocked)',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update block status: $e'),
                    ),
                  );
                }
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // FIRM DETAILS & LIVE STATISTICS (Prompt Section 18 & 19)
  // ===========================================================================
  void _showFirmDetailsDialog(BuildContext context, TenantFirm firm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => FutureBuilder<Map<String, dynamic>>(
        future: ref.read(firmsNotifierProvider.notifier).getFirmStats(firm.id),
        builder: (ctx, snapshot) {
          final stats = snapshot.data ?? {};
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _superAdminGold.withAlpha(40),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.apartment,
                          color: _superAdminGold,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              firm.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Firm ID: #${firm.id} • ${firm.email}',
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
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Statistics Section
                  const Text(
                    'Platform Statistics',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  if (isLoading)
                    const Row(
                      children: [
                        Expanded(child: SkeletonLoader(height: 64)),
                        SizedBox(width: 8),
                        Expanded(child: SkeletonLoader(height: 64)),
                        SizedBox(width: 8),
                        Expanded(child: SkeletonLoader(height: 64)),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatBadge(
                            'Clients',
                            '${stats['clients'] ?? stats['total_clients'] ?? 0}',
                            Icons.people_outline,
                            const Color(0xFF3B82F6),
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatBadge(
                            'Cases',
                            '${stats['cases'] ?? stats['total_cases'] ?? 0}',
                            Icons.folder_outlined,
                            _superAdminGold,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatBadge(
                            'Users',
                            '${stats['users'] ?? stats['total_users'] ?? 0}',
                            Icons.badge_outlined,
                            LexColors.success,
                            isDark,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 18),

                  // Firm Details Summary
                  const Text(
                    'Firm Information',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  LexCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          'Phone',
                          firm.phone ?? 'Not provided',
                          isDark,
                        ),
                        const Divider(height: 14),
                        _buildDetailRow(
                          'Address',
                          firm.address ?? 'Not provided',
                          isDark,
                        ),
                        const Divider(height: 14),
                        _buildDetailRow(
                          'City / State',
                          '${firm.city ?? "N/A"}, ${firm.state ?? "N/A"} (${firm.pincode ?? "N/A"})',
                          isDark,
                        ),
                        const Divider(height: 14),
                        _buildDetailRow(
                          'PAN Number',
                          firm.panNumber ?? 'Not provided',
                          isDark,
                        ),
                        const Divider(height: 14),
                        _buildDetailRow(
                          'GST Number',
                          firm.gstNumber ?? 'Not provided',
                          isDark,
                        ),
                        const Divider(height: 14),
                        _buildDetailRow(
                          'Status',
                          firm.isBlocked
                              ? 'Blocked'
                              : (firm.isActive ? 'Active' : 'Inactive'),
                          isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Change Admin Action (Prompt Section 19)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? LexColors.surfaceDark
                          : LexColors.canvasLight,
                      foregroundColor: isDark
                          ? LexColors.accentGold
                          : LexColors.slatePrimary,
                      side: BorderSide(
                        color: isDark
                            ? LexColors.borderDark
                            : LexColors.borderLight,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showChangeAdminDialog(context, firm);
                    },
                    icon: const Icon(Icons.swap_horiz, size: 18),
                    label: const Text('Transfer Firm Administrator Role'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatBadge(
    String label,
    String count,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
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
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? LexColors.textSecondaryDark
                : LexColors.textSecondaryLight,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // CHANGE FIRM ADMIN DIALOG (Prompt Section 19)
  // ===========================================================================
  void _showChangeAdminDialog(BuildContext context, TenantFirm firm) {
    final userIdCtrl = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.admin_panel_settings, color: _superAdminGold),
              SizedBox(width: 8),
              Text('Change Firm Admin'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transfer the "admin" role for "${firm.name}" to another user within the firm.',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: userIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'Target User ID *',
                  hintText: 'e.g. 25',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _superAdminGold,
                foregroundColor: Colors.black,
              ),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final userId = int.tryParse(userIdCtrl.text.trim());
                      if (userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a valid User ID'),
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isSubmitting = true);
                      try {
                        await ref
                            .read(firmsNotifierProvider.notifier)
                            .changeAdmin(firm.id, userId);
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Firm Admin changed successfully'),
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isSubmitting = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to change admin: $e'),
                            ),
                          );
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Transfer Admin'),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // CREATE FIRM DIALOG (Prompt Section 11 & 12)
  // ===========================================================================
  void _showCreateFirmDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final stateCtrl = TextEditingController();
    final pincodeCtrl = TextEditingController();
    final panCtrl = TextEditingController();
    final gstCtrl = TextEditingController();
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();
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
                      const Icon(Icons.business, color: _superAdminGold),
                      const SizedBox(width: 8),
                      const Text(
                        'Create Law Firm',
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
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Firm Name *'),
                    validator: (v) =>
                        v?.trim().isEmpty == true ? 'Firm name required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Firm Email *',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v?.contains('@') != true
                        ? 'Valid email required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(labelText: 'Phone *'),
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v?.trim().length ?? 0) < 7
                        ? 'Valid phone number required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Office Address *',
                    ),
                    validator: (v) =>
                        v?.trim().isEmpty == true ? 'Address required' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: cityCtrl,
                          decoration: const InputDecoration(
                            labelText: 'City *',
                          ),
                          validator: (v) => v?.trim().isEmpty == true
                              ? 'City required'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: stateCtrl,
                          decoration: const InputDecoration(
                            labelText: 'State *',
                          ),
                          validator: (v) => v?.trim().isEmpty == true
                              ? 'State required'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: pincodeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Pincode',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: panCtrl,
                          decoration: const InputDecoration(
                            labelText: 'PAN Number (10 chars)',
                          ),
                          textCapitalization: TextCapitalization.characters,
                          validator: (v) {
                            if (v != null &&
                                v.trim().isNotEmpty &&
                                v.trim().length != 10) {
                              return 'PAN must be 10 characters';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: gstCtrl,
                    decoration: const InputDecoration(
                      labelText: 'GST Number (15 chars when provided)',
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (v) {
                      if (v != null &&
                          v.trim().isNotEmpty &&
                          v.trim().length != 15) {
                        return 'GST must be 15 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Initial Administrator Credentials',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: userCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Admin Username *',
                    ),
                    validator: (v) =>
                        v?.trim().isEmpty == true ? 'Username required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Admin Password *',
                    ),
                    obscureText: true,
                    validator: (v) => (v?.length ?? 0) < 6
                        ? 'Password must be >= 6 chars'
                        : null,
                  ),
                  const SizedBox(height: 20),
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
                                  .read(firmsNotifierProvider.notifier)
                                  .createFirm({
                                    'firm_name': nameCtrl.text.trim(),
                                    'email': emailCtrl.text.trim(),
                                    'phone': phoneCtrl.text.trim(),
                                    'address': addressCtrl.text.trim(),
                                    'city': cityCtrl.text.trim(),
                                    'state': stateCtrl.text.trim(),
                                    'pincode': pincodeCtrl.text.trim(),
                                    'pan_number': panCtrl.text.trim(),
                                    'gst_number': gstCtrl.text.trim(),
                                    'username': userCtrl.text.trim(),
                                    'password': passCtrl.text.trim(),
                                  });
                              if (context.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Law Firm created successfully',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              setModalState(() => isSubmitting = false);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error creating firm: $e'),
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
                            'Create Firm',
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

  // ===========================================================================
  // EDIT FIRM DIALOG (Prompt Section 16)
  // ===========================================================================
  void _showEditFirmDialog(BuildContext context, TenantFirm firm) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: firm.name);
    final emailCtrl = TextEditingController(text: firm.email);
    final phoneCtrl = TextEditingController(text: firm.phone);
    final addressCtrl = TextEditingController(text: firm.address);
    final cityCtrl = TextEditingController(text: firm.city ?? '');
    final stateCtrl = TextEditingController(text: firm.state ?? '');
    final pincodeCtrl = TextEditingController(text: firm.pincode ?? '');
    final panCtrl = TextEditingController(text: firm.panNumber ?? '');
    final gstCtrl = TextEditingController(text: firm.gstNumber ?? '');
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Edit ${firm.name}'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Firm Name *'),
                    validator: (v) =>
                        v?.trim().isEmpty == true ? 'Name required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email *'),
                    validator: (v) => v?.contains('@') != true
                        ? 'Valid email required'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: cityCtrl,
                    decoration: const InputDecoration(labelText: 'City'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: stateCtrl,
                    decoration: const InputDecoration(labelText: 'State'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: pincodeCtrl,
                    decoration: const InputDecoration(labelText: 'Pincode'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: panCtrl,
                    decoration: const InputDecoration(labelText: 'PAN Number'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: gstCtrl,
                    decoration: const InputDecoration(labelText: 'GST Number'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _superAdminGold,
                foregroundColor: Colors.black,
              ),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isSubmitting = true);
                      try {
                        await ref
                            .read(firmsNotifierProvider.notifier)
                            .updateFirm(firm.id, {
                              'name': nameCtrl.text.trim(),
                              'email': emailCtrl.text.trim(),
                              'phone': phoneCtrl.text.trim(),
                              'address': addressCtrl.text.trim(),
                              'city': cityCtrl.text.trim(),
                              'state': stateCtrl.text.trim(),
                              'pincode': pincodeCtrl.text.trim(),
                              'pan_number': panCtrl.text.trim(),
                              'gst_number': gstCtrl.text.trim(),
                            });
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Firm updated successfully'),
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isSubmitting = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Update failed: $e')),
                          );
                        }
                      }
                    },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // DELETE FIRM CONFIRMATION DIALOG (Prompt Section 17)
  // ===========================================================================
  void _confirmDeleteFirm(BuildContext context, TenantFirm firm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: LexColors.error),
            SizedBox(width: 8),
            Text('Delete Law Firm?'),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently remove "${firm.name}" (ID #${firm.id})? This action permanently removes the firm and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: LexColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(firmsNotifierProvider.notifier)
                    .deleteFirm(firm.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Firm "${firm.name}" deleted')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
                }
              }
            },
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }
}
