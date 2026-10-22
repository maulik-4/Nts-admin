import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../shared/widgets/capability_gate.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/searchable_picker_modal.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../auth/domain/models/role_capabilities.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../clients/data/models/client_model.dart';
import '../../../clients/presentation/providers/clients_notifier.dart';
import '../../../dashboard/presentation/providers/dashboard_notifier.dart';
import '../../../firms/presentation/providers/firms_notifier.dart';
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
    Future.microtask(() {
      ref.read(teamSearchQueryProvider.notifier).state = '';
    });
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

  void _showAddMemberModal(
    BuildContext context, {
    String initialRole = 'lawyer',
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddMemberModalSheet(initialRole: initialRole),
    );
  }

  void _showMemberDetailsDialog(BuildContext context, TeamMember member) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar & Role
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0F1F38),
                  border: Border.all(color: member.badgeColor, width: 2.5),
                ),
                child: Center(
                  child: Text(
                    member.username.isNotEmpty
                        ? member.username[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                member.username,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: member.badgeColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: member.badgeColor.withAlpha(70)),
                ),
                child: Text(
                  member.displayRole.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: member.badgeColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Divider(
                height: 1,
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
              const SizedBox(height: 16),

              // Details List
              _buildDetailRow(
                'Email Address',
                member.email,
                isDark,
                trailing: IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  color: const Color(0xFF2563EB),
                  tooltip: 'Copy Email',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: member.email));
                    AppAlerts.showSuccess(context, 'Email copied to clipboard');
                  },
                ),
              ),
              if (member.phone != null && member.phone!.isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildDetailRow(
                  'Phone Number',
                  member.phone!,
                  isDark,
                  trailing: IconButton(
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                    color: const Color(0xFF059669),
                    tooltip: 'Call Now',
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _callLawyer(context, member.phone, member.username);
                    },
                  ),
                ),
              ],
              const SizedBox(height: 10),
              _buildDetailRow(
                'Firm Organization',
                member.firm.isNotEmpty ? member.firm : 'Current Firm',
                isDark,
              ),
              const SizedBox(height: 10),
              _buildDetailRow('Role Authority', member.displayRole, isDark),
              if (member.joined != null) ...[
                const SizedBox(height: 10),
                _buildDetailRow(
                  'Member Since',
                  DateFormat.yMMMMd().format(member.joined!),
                  isDark,
                ),
              ],
              const SizedBox(height: 22),

              // Direct Call Advocate / Lawyer button
              if (member.isLawyer ||
                  member.role.toLowerCase() == 'lawyer' ||
                  member.role.toLowerCase() == 'admin') ...[
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _callLawyer(context, member.phone, member.username);
                    },
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                    label: Text(
                      'Call Advocate (${member.username})',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F1F38),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _callLawyer(
    BuildContext context,
    String? phone,
    String lawyerName,
  ) async {
    final validPhone = phone?.trim();
    if (validPhone != null && validPhone.isNotEmpty) {
      final cleanPhone = validPhone.replaceAll(RegExp(r'[^0-9+]'), '');
      final uri = Uri.parse('tel:$cleanPhone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return;
      }
    }

    if (!context.mounted) return;
    final phoneCtrl = TextEditingController(text: validPhone ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF059669)),
            const SizedBox(width: 8),
            Expanded(child: Text('Call $lawyerName')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Initiate telephone consultation with advocate $lawyerName:',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '+91 98765 43210',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.call, size: 16),
            label: const Text('Call Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final number = phoneCtrl.text.replaceAll(RegExp(r'[^0-9+]'), '');
              if (number.isNotEmpty) {
                Navigator.of(ctx).pop();
                final uri = Uri.parse('tel:$number');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  if (context.mounted) {
                    AppAlerts.showError(
                      context,
                      'Unable to place call on this device.',
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _callNumber(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showClientDetailsDialog(BuildContext context, Client client) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF7C3AED).withAlpha(25),
                  border: Border.all(
                    color: const Color(0xFF7C3AED),
                    width: 2.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    client.name.isNotEmpty ? client.name[0].toUpperCase() : 'C',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                client.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF7C3AED).withAlpha(70),
                  ),
                ),
                child: const Text(
                  'FIRM CLIENT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: Color(0xFF7C3AED),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Divider(
                height: 1,
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
              const SizedBox(height: 16),
              if (client.phone.isNotEmpty) ...[
                _buildDetailRow(
                  'Phone Number',
                  client.phone,
                  isDark,
                  trailing: IconButton(
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                    color: const Color(0xFF059669),
                    tooltip: 'Call Client',
                    onPressed: () => _callNumber(client.phone),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (client.email != null && client.email!.isNotEmpty) ...[
                _buildDetailRow(
                  'Email Address',
                  client.email!,
                  isDark,
                  trailing: IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    color: const Color(0xFF2563EB),
                    tooltip: 'Copy Email',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: client.email!));
                      AppAlerts.showSuccess(
                        context,
                        'Email copied to clipboard',
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
              _buildDetailRow(
                'Account Status',
                client.isActive ? 'Active Client' : 'Inactive',
                isDark,
              ),
              if ((client.city != null && client.city!.isNotEmpty) ||
                  client.address.isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildDetailRow(
                  'Location',
                  client.city != null && client.city!.isNotEmpty
                      ? client.city!
                      : client.address,
                  isDark,
                ),
              ],
              const SizedBox(height: 22),
              if (client.phone.isNotEmpty) ...[
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _callNumber(client.phone);
                    },
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                    label: Text('Call Client (${client.name})'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F1F38),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    bool isDark, {
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }

  Widget _buildFilterPill({
    required BuildContext context,
    required String label,
    int? count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? primaryColor : const Color(0xFF0F1F38))
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isDark ? primaryColor : const Color(0xFF0F1F38))
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F1F38).withAlpha(35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF475569)),
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withAlpha(50)
                      : (isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF475569)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoleFilterButton({
    required BuildContext context,
    required TeamFilter activeFilter,
    required int advocatesCount,
    required int staffCount,
    required int adminCount,
    required int clientsCount,
    required bool isDark,
  }) {
    final hasSelection = activeFilter != TeamFilter.all;
    String roleLabel = 'Filter by Role';
    if (activeFilter == TeamFilter.advocates) roleLabel = 'Role: Advocates';
    if (activeFilter == TeamFilter.staff) roleLabel = 'Role: Staff';
    if (activeFilter == TeamFilter.admin) roleLabel = 'Role: Admins';
    if (activeFilter == TeamFilter.clients) roleLabel = 'Role: Clients';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final items = [
            const SearchablePickerItem<TeamFilter>(
              value: TeamFilter.all,
              label: 'All Roles',
              subtitle: 'Show all advocates, staff, admins, and clients',
              icon: Icons.clear_all_rounded,
              iconColor: Color(0xFF64748B),
            ),
            SearchablePickerItem<TeamFilter>(
              value: TeamFilter.advocates,
              label: 'Advocates / Lawyers',
              subtitle:
                  '$advocatesCount members with practicing advocate credentials',
              icon: Icons.gavel_rounded,
              iconColor: const Color(0xFF1E40AF),
            ),
            SearchablePickerItem<TeamFilter>(
              value: TeamFilter.staff,
              label: 'Legal Staff',
              subtitle: '$staffCount paralegals and administrative personnel',
              icon: Icons.badge_outlined,
              iconColor: const Color(0xFF475569),
            ),
            SearchablePickerItem<TeamFilter>(
              value: TeamFilter.admin,
              label: 'Firm Admins',
              subtitle: '$adminCount firm management administrators',
              icon: Icons.shield_outlined,
              iconColor: const Color(0xFF0F1F38),
            ),
            SearchablePickerItem<TeamFilter>(
              value: TeamFilter.clients,
              label: 'Clients',
              subtitle: '$clientsCount registered client profiles',
              icon: Icons.person_outline_rounded,
              iconColor: const Color(0xFF7C3AED),
            ),
          ];

          final picked = await showSearchablePicker<TeamFilter>(
            context: context,
            title: 'Filter by Role',
            searchHint: 'Search role (Advocate, Staff, Admin, Client)...',
            selectedValue: activeFilter,
            items: items,
          );

          if (picked != null) {
            ref.read(teamFilterProvider.notifier).state = picked;
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: hasSelection
                ? (isDark
                    ? const Color(0xFF1E3A8A).withAlpha(89)
                    : const Color(0xFFEFF6FF))
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasSelection
                  ? (isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB))
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasSelection ? Icons.badge_rounded : Icons.tune_rounded,
                size: 15,
                color: hasSelection
                    ? const Color(0xFF2563EB)
                    : (isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B)),
              ),
              const SizedBox(width: 6),
              Text(
                roleLabel,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight:
                      hasSelection ? FontWeight.w700 : FontWeight.w500,
                  color: hasSelection
                      ? (isDark
                          ? const Color(0xFF60A5FA)
                          : const Color(0xFF1D4ED8))
                      : (isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF475569)),
                ),
              ),
              const SizedBox(width: 4),
              if (hasSelection)
                GestureDetector(
                  onTap: () {
                    ref.read(teamFilterProvider.notifier).state =
                        TeamFilter.all;
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFDBEAFE),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 12,
                      color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                    ),
                  ),
                )
              else
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFirmFilterButton({
    required BuildContext context,
    required List<dynamic> firms,
    required int? selectedFirmId,
    required bool isDark,
  }) {
    dynamic selectedFirm;
    if (selectedFirmId != null) {
      for (final f in firms) {
        if (f.id == selectedFirmId) {
          selectedFirm = f;
          break;
        }
      }
    }
    final hasSelection = selectedFirm != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final items = [
            const SearchablePickerItem<int?>(
              value: null,
              label: 'All Firms',
              subtitle: 'Show team members across all firms',
              icon: Icons.clear_all_rounded,
              iconColor: Color(0xFF64748B),
            ),
            ...firms.map((f) => SearchablePickerItem<int?>(
                  value: f.id as int,
                  label: f.name as String,
                  subtitle: (f.domain as String).isNotEmpty
                      ? (f.domain as String)
                      : 'Firm #${f.id}',
                  icon: Icons.business_rounded,
                  iconColor: const Color(0xFF2563EB),
                )),
          ];

          final picked = await showSearchablePicker<int?>(
            context: context,
            title: 'Filter by Firm',
            searchHint: 'Search firm name or domain...',
            selectedValue: selectedFirmId,
            items: items,
          );

          ref.read(teamFirmFilterProvider.notifier).state = picked;
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: hasSelection
                ? (isDark
                    ? const Color(0xFF1E3A8A).withAlpha(89)
                    : const Color(0xFFEFF6FF))
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasSelection
                  ? (isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB))
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasSelection ? Icons.business_rounded : Icons.domain_rounded,
                size: 15,
                color: hasSelection
                    ? const Color(0xFF2563EB)
                    : (isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B)),
              ),
              const SizedBox(width: 6),
              Text(
                hasSelection ? selectedFirm.name as String : 'Filter by Firm',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight:
                      hasSelection ? FontWeight.w700 : FontWeight.w500,
                  color: hasSelection
                      ? (isDark
                          ? const Color(0xFF60A5FA)
                          : const Color(0xFF1D4ED8))
                      : (isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF475569)),
                ),
              ),
              const SizedBox(width: 4),
              if (hasSelection)
                GestureDetector(
                  onTap: () {
                    ref.read(teamFirmFilterProvider.notifier).state = null;
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFDBEAFE),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 12,
                      color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                    ),
                  ),
                )
              else
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredMembersAsync = ref.watch(filteredTeamMembersProvider);
    final allMembers = ref.watch(teamNotifierProvider).value ?? [];
    final clientsAsync = ref.watch(teamClientsProvider);
    final allClients = ref.watch(clientsNotifierProvider).value ?? [];
    final activeFilter = ref.watch(teamFilterProvider);
    final currentUser = ref.watch(authNotifierProvider).user;
    final selectedFirmId = ref.watch(teamFirmFilterProvider);
    final firmsAsync = ref.watch(firmsNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final adminCount = allMembers.where((m) => m.isFirmAdmin).length;
    final advocatesCount =
        allMembers.where((m) => m.role.toLowerCase() == 'lawyer').length;
    final staffCount =
        allMembers.where((m) => m.role.toLowerCase() == 'staff').length;
    final clientsCount = allClients.length;
    final totalCount = allMembers.length + clientsCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Firm Team',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Team & Clients',
            onPressed: () {
              ref.read(teamNotifierProvider.notifier).loadTeamMembers();
              ref.read(clientsNotifierProvider.notifier).loadClients();
            },
          ),
        ],
      ),
      floatingActionButton: CapabilityGate(
        capability: UserCapability.manageTeam,
        child: FloatingActionButton.extended(
          heroTag: 'fab_add_member',
          onPressed: () async {
            if (activeFilter == TeamFilter.clients) {
              await context.push('/app/clients/create');
              if (context.mounted) {
                ref.read(clientsNotifierProvider.notifier).loadClients();
              }
            } else if (activeFilter == TeamFilter.staff) {
              _showAddMemberModal(context, initialRole: 'staff');
            } else if (activeFilter == TeamFilter.admin) {
              _showAddMemberModal(context, initialRole: 'admin');
            } else {
              _showAddMemberModal(context, initialRole: 'lawyer');
            }
          },
          backgroundColor: const Color(0xFF0F1F38),
          foregroundColor: Colors.white,
          elevation: 4,
          icon: Icon(
            activeFilter == TeamFilter.clients
                ? Icons.person_add_alt_1_rounded
                : Icons.person_add_rounded,
            size: 20,
          ),
          label: Text(
            activeFilter == TeamFilter.clients
                ? 'Add Client'
                : activeFilter == TeamFilter.staff
                    ? 'Add Staff'
                    : 'Add Member',
            style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) {
                ref.read(teamSearchQueryProvider.notifier).state = val;
              },
              decoration: InputDecoration(
                hintText: 'Search members, advocates, or clients...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref.read(teamSearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Filter Row: All, Filter by Role, Filter by Firm, Quick Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterPill(
                  context: context,
                  label: 'All',
                  count: totalCount,
                  isSelected:
                      activeFilter == TeamFilter.all && selectedFirmId == null,
                  onTap: () {
                    ref.read(teamFilterProvider.notifier).state =
                        TeamFilter.all;
                    ref.read(teamFirmFilterProvider.notifier).state = null;
                  },
                ),
                const SizedBox(width: 8),
                _buildRoleFilterButton(
                  context: context,
                  activeFilter: activeFilter,
                  advocatesCount: advocatesCount,
                  staffCount: staffCount,
                  adminCount: adminCount,
                  clientsCount: clientsCount,
                  isDark: isDark,
                ),
                if (currentUser?.isSuperAdmin == true) ...[
                  const SizedBox(width: 8),
                  _buildFirmFilterButton(
                    context: context,
                    firms: firmsAsync.valueOrNull ?? [],
                    selectedFirmId: selectedFirmId,
                    isDark: isDark,
                  ),
                ],
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 1,
                  height: 22,
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFCBD5E1),
                ),
                _buildFilterPill(
                  context: context,
                  label: 'Advocates',
                  count: advocatesCount,
                  isSelected: activeFilter == TeamFilter.advocates,
                  onTap: () => ref.read(teamFilterProvider.notifier).state =
                      TeamFilter.advocates,
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  context: context,
                  label: 'Staff',
                  count: staffCount,
                  isSelected: activeFilter == TeamFilter.staff,
                  onTap: () => ref.read(teamFilterProvider.notifier).state =
                      TeamFilter.staff,
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  context: context,
                  label: 'Admins',
                  count: adminCount,
                  isSelected: activeFilter == TeamFilter.admin,
                  onTap: () => ref.read(teamFilterProvider.notifier).state =
                      TeamFilter.admin,
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  context: context,
                  label: 'Clients',
                  count: clientsCount,
                  isSelected: activeFilter == TeamFilter.clients,
                  onTap: () => ref.read(teamFilterProvider.notifier).state =
                      TeamFilter.clients,
                ),
              ],
            ),
          ),

          // Active filter banner with quick create
          if (activeFilter != TeamFilter.all || selectedFirmId != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFDBEAFE),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.filter_alt_rounded,
                      size: 16,
                      color: Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        activeFilter == TeamFilter.advocates
                            ? 'Showing $advocatesCount Advocates'
                            : activeFilter == TeamFilter.staff
                                ? 'Showing $staffCount Legal Staff'
                                : activeFilter == TeamFilter.admin
                                    ? 'Showing $adminCount Firm Admins'
                                    : activeFilter == TeamFilter.clients
                                        ? 'Showing $clientsCount Clients'
                                        : 'Filtered by Firm',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF93C5FD)
                              : const Color(0xFF1D4ED8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () async {
                        if (activeFilter == TeamFilter.clients) {
                          await context.push('/app/clients/create');
                          if (context.mounted) {
                            ref.read(clientsNotifierProvider.notifier).loadClients();
                          }
                        } else if (activeFilter == TeamFilter.staff) {
                          _showAddMemberModal(context, initialRole: 'staff');
                        } else if (activeFilter == TeamFilter.admin) {
                          _showAddMemberModal(context, initialRole: 'admin');
                        } else {
                          _showAddMemberModal(context, initialRole: 'lawyer');
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Text(
                          activeFilter == TeamFilter.clients
                              ? '+ Add Client'
                              : activeFilter == TeamFilter.staff
                                  ? '+ Add Staff'
                                  : '+ Add Member',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),

          // Member & Client List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  ref.read(teamNotifierProvider.notifier).loadTeamMembers(),
                  ref.read(clientsNotifierProvider.notifier).loadClients(),
                ]);
              },
              child: _buildListContent(
                context,
                activeFilter: activeFilter,
                filteredMembersAsync: filteredMembersAsync,
                clientsAsync: clientsAsync,
                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent(
    BuildContext context, {
    required TeamFilter activeFilter,
    required AsyncValue<List<TeamMember>> filteredMembersAsync,
    required AsyncValue<List<Client>> clientsAsync,
    required bool isDark,
  }) {
    if (activeFilter == TeamFilter.clients) {
      return clientsAsync.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, _) =>
              const SkeletonLoader(height: 80, borderRadius: 16),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: LexColors.error,
                ),
                const SizedBox(height: 12),
                Text(
                  'Error loading clients: $err',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(clientsNotifierProvider.notifier).loadClients(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (clients) {
          if (clients.isEmpty) {
            return _buildEmptyState(
              context,
              icon: Icons.person_search_outlined,
              title: 'No clients found',
              description: 'No registered clients match your current filters.',
              isDark: isDark,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
            itemCount: clients.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (ctx, idx) => _buildClientCard(context, clients[idx]),
          );
        },
      );
    }

    if (activeFilter == TeamFilter.advocates ||
        activeFilter == TeamFilter.staff ||
        activeFilter == TeamFilter.admin) {
      return filteredMembersAsync.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, _) =>
              const SkeletonLoader(height: 80, borderRadius: 16),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: LexColors.error,
                ),
                const SizedBox(height: 12),
                Text('Error loading team: $err', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(teamNotifierProvider.notifier).loadTeamMembers(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (members) {
          if (members.isEmpty) {
            return _buildEmptyState(
              context,
              icon: Icons.group_outlined,
              title: activeFilter == TeamFilter.advocates
                  ? 'No advocates found in your firm'
                  : activeFilter == TeamFilter.admin
                      ? 'No firm admins found in your firm'
                      : 'No staff members found in your firm',
              description: 'Add advocates and staff to collaborate in your firm workspace.',
              isDark: isDark,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
            itemCount: members.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (ctx, idx) => _buildMemberCard(context, members[idx]),
          );
        },
      );
    }

    // activeFilter == TeamFilter.all
    if (filteredMembersAsync.isLoading && clientsAsync.isLoading) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) =>
            const SkeletonLoader(height: 80, borderRadius: 16),
      );
    }

    final members = filteredMembersAsync.value ?? [];
    final clients = clientsAsync.value ?? [];

    if (members.isEmpty && clients.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.group_work_outlined,
        title: 'No team members or clients found',
        description:
            'Invite advocates, staff, and onboard clients for your firm.',
        isDark: isDark,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
      children: [
        if (members.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
            child: Row(
              children: [
                Text(
                  'TEAM MEMBERS (${members.length})',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          ...members.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildMemberCard(context, m),
            ),
          ),
        ],
        if (clients.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(
              left: 4,
              bottom: 8,
              top: members.isNotEmpty ? 12 : 4,
            ),
            child: Row(
              children: [
                Text(
                  'FIRM CLIENTS (${clients.length})',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          ...clients.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildClientCard(context, c),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
  }) {
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
                    icon,
                    size: 56,
                    color: isDark
                        ? LexColors.textSecondaryDark
                        : LexColors.textSecondaryLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
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

  Widget _buildClientCard(BuildContext context, Client client) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const clientColor = Color(0xFF7C3AED);
    final initial = client.name.isNotEmpty ? client.name[0].toUpperCase() : 'C';

    return LexCard(
      borderRadius: 16,
      leftAccentColor: clientColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: () => _showClientDetailsDialog(context, client),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? clientColor.withAlpha(35)
                  : clientColor.withAlpha(20),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: clientColor,
                ),
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
                        client.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
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
                        color: clientColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: clientColor.withAlpha(50),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'Client',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: clientColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (client.phone.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 13,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          client.phone,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (client.email != null &&
                    client.email!.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 13,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          client.email!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (client.city != null && client.city!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    client.city!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (client.phone.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.phone_in_talk_rounded, size: 20),
              color: const Color(0xFF059669),
              tooltip: 'Call ${client.name}',
              onPressed: () => _callNumber(client.phone),
            ),
          ],
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, TeamMember member) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initial = member.username.isNotEmpty
        ? member.username[0].toUpperCase()
        : 'U';

    return LexCard(
      borderRadius: 16,
      leftAccentColor: member.badgeColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: () => _showMemberDetailsDialog(context, member),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? member.badgeColor.withAlpha(35)
                  : member.badgeColor.withAlpha(20),
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: member.badgeColor,
                ),
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
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
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
                        color: member.badgeColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: member.badgeColor.withAlpha(50),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        member.displayRole,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
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
                      size: 13,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        member.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                if (member.joined != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Joined: ${DateFormat.yMMMd().format(member.joined!)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (member.isLawyer ||
              member.role.toLowerCase() == 'lawyer' ||
              member.role.toLowerCase() == 'admin' ||
              (member.phone != null && member.phone!.isNotEmpty)) ...[
            IconButton(
              icon: const Icon(Icons.phone_in_talk_rounded, size: 20),
              color: const Color(0xFF059669),
              tooltip: 'Call ${member.username}',
              onPressed: () =>
                  _callLawyer(context, member.phone, member.username),
            ),
          ],
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
        ],
      ),
    );
  }
}

class _AddMemberModalSheet extends ConsumerStatefulWidget {
  final String initialRole;

  const _AddMemberModalSheet({this.initialRole = 'lawyer'});

  @override
  ConsumerState<_AddMemberModalSheet> createState() =>
      _AddMemberModalSheetState();
}

class _AddMemberModalSheetState extends ConsumerState<_AddMemberModalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  late String _selectedRole;
  int _mode = 0; // 0: Add Directly, 1: Send Invite
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

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
        ref.invalidate(dashboardNotifierProvider);
        if (mounted) {
          Navigator.of(context).pop();
          AppAlerts.showSuccess(context, 'Member added to firm successfully.');
        }
      } else {
        await ref
            .read(teamNotifierProvider.notifier)
            .inviteMember(email: _emailCtrl.text.trim(), role: _selectedRole);
        ref.invalidate(dashboardNotifierProvider);
        if (mounted) {
          Navigator.of(context).pop();
          AppAlerts.showSuccess(context, 'Invitation email sent successfully.');
        }
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(context, 'Failed to add team member: $e');
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
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
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
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF475569)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _mode == 0 ? 'Add Team Member' : 'Invite Team Member',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 14),

              // Segmented mode selector
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    label: Text(
                      'Add Directly',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text(
                      'Send Invite',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (set) => setState(() => _mode = set.first),
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              if (_mode == 0) ...[
                Text(
                  'Username *',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _usernameCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. advocate_smith',
                    prefixIcon: const Icon(
                      Icons.person_outline_rounded,
                      size: 19,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) =>
                      v?.trim().isEmpty == true ? 'Username required' : null,
                ),
                const SizedBox(height: 14),
              ],

              Text(
                'Email Address *',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'colleague@example.com',
                  prefixIcon: const Icon(Icons.email_outlined, size: 19),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) {
                  if (v?.trim().isEmpty == true) return 'Email required';
                  if (!v!.contains('@')) return 'Enter a valid email address';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              if (_mode == 0) ...[
                Text(
                  'Temporary Password *',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Min. 8 characters',
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      size: 19,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) => v == null || v.length < 6
                      ? 'Password must be >= 6 chars'
                      : null,
                ),
                const SizedBox(height: 14),
              ],

              // Role selection dropdown
              Text(
                'Assigned Role',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.badge_outlined, size: 19),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
              const SizedBox(height: 14),

              // Information banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFDBEAFE),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _mode == 0
                            ? 'Member will be added immediately with these credentials.'
                            : 'An email invitation link will be dispatched to the colleague.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF1E3A8A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        backgroundColor: const Color(0xFF0F1F38),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                              _mode == 0 ? 'Create Member' : 'Send Invite',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
