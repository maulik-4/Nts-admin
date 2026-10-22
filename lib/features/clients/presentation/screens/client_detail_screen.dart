import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../cases/presentation/providers/cases_notifier.dart';
import '../../../communications/presentation/widgets/communication_preference_dialog.dart';
import '../../../communications/presentation/widgets/whatsapp_composer_modal.dart';
import '../../../dashboard/presentation/providers/dashboard_notifier.dart';
import '../../../documents/presentation/widgets/document_share_dialog.dart';
import '../../data/repositories/clients_repository.dart';
import '../providers/clients_notifier.dart';
import '../widgets/invite_client_dialog.dart';

final clientDetailProvider = FutureProvider.family<dynamic, int>((
  ref,
  id,
) async {
  final list = ref.watch(clientsNotifierProvider).valueOrNull;
  if (list != null) {
    final found = list.where((c) => c.id == id);
    if (found.isNotEmpty) return found.first;
  }
  final repo = ref.watch(clientsRepositoryProvider);
  return repo.getClient(id);
});

class ClientDetailScreen extends ConsumerWidget {
  final int clientId;

  const ClientDetailScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientAsync = ref.watch(clientDetailProvider(clientId));
    final casesAsync = ref.watch(casesNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF131D33) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0);
    final dividerColor =
        isDark ? const Color(0xFF1E2D4A) : const Color(0xFFF1F5F9);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final actionTileBg =
        isDark ? const Color(0xFF0C1322) : const Color(0xFFF8FAFC);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Client Details',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Client',
            onPressed: () async {
              await context.push('/app/clients/$clientId/edit');
              ref.invalidate(clientDetailProvider(clientId));
              ref.read(clientsNotifierProvider.notifier).loadClients();
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFEF4444),
            ),
            tooltip: 'Delete Client',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: clientAsync.when(
        data: (client) {
          final associatedCases =
              casesAsync.valueOrNull
                  ?.where((c) => c.client == clientId)
                  .toList() ??
              [];

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Contact Information Card matching 3.png
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Client Avatar Icon Container
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFF1E2D4A)
                              : const Color(0xFFEFF6FF),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Phone Row
                      _buildContactRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: client.phone.isNotEmpty
                            ? client.phone
                            : 'Not provided',
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                      Divider(color: dividerColor, height: 24),
                      // Email Row
                      _buildContactRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: client.email != null && client.email!.isNotEmpty
                            ? client.email!
                            : 'Not provided',
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                      Divider(color: dividerColor, height: 24),
                      // Address Row
                      _buildContactRow(
                        icon: Icons.home_outlined,
                        label: 'Address',
                        value: client.address.isNotEmpty
                            ? client.address
                            : (client.city != null && client.city!.isNotEmpty
                                ? client.city!
                                : 'Not provided'),
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 2. Client Portal & Communications Card (2x2 Grid) matching 3.png
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.link_rounded,
                            size: 20,
                            color: isDark
                                ? const Color(0xFF38BDF8)
                                : const Color(0xFF0284C7),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Client Portal & Communications',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Row 1 of 2x2 grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildPortalActionTile(
                              icon: Icons.person_add_alt_1_rounded,
                              label: 'Invite to\nPortal',
                              isDark: isDark,
                              actionTileBg: actionTileBg,
                              borderColor: borderColor,
                              textPrimary: textPrimary,
                              onTap: () {
                                InviteClientDialog.show(
                                  context,
                                  initialEmail: client.email,
                                  initialName: client.name,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPortalActionTile(
                              icon: Icons.description_outlined,
                              label: 'Shared\nDocuments',
                              isDark: isDark,
                              actionTileBg: actionTileBg,
                              borderColor: borderColor,
                              textPrimary: textPrimary,
                              onTap: () {
                                DocumentShareDialog.show(
                                  context,
                                  clientId: client.id,
                                  clientName: client.name,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Row 2 of 2x2 grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildPortalActionTile(
                              icon: Icons.chat_bubble_rounded,
                              iconColor: const Color(0xFF25D366),
                              isWhatsApp: true,
                              label: 'Send\nWhatsApp',
                              isDark: isDark,
                              actionTileBg: actionTileBg,
                              borderColor: borderColor,
                              textPrimary: textPrimary,
                              onTap: () {
                                WhatsAppComposerModal.show(
                                  context,
                                  clientId: client.id,
                                  recipientName: client.name,
                                  recipientNumber: client.phone,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPortalActionTile(
                              icon: Icons.tune_rounded,
                              label: 'Preferences',
                              isDark: isDark,
                              actionTileBg: actionTileBg,
                              borderColor: borderColor,
                              textPrimary: textPrimary,
                              onTap: () {
                                CommunicationPreferenceDialog.show(
                                  context,
                                  clientId: client.id,
                                  clientName: client.name,
                                  phoneNumber: client.phone,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 3. Associated Cases Card matching 3.png
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.folder_outlined,
                                size: 20,
                                color: isDark
                                    ? const Color(0xFF38BDF8)
                                    : const Color(0xFF0284C7),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Cases',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E2D4A)
                                      : const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${associatedCases.length}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? const Color(0xFF38BDF8)
                                        : const Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () => context.push(
                              '/app/cases/create?clientId=${client.id}',
                            ),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E2D4A)
                                    : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_circle,
                                    size: 16,
                                    color: isDark
                                        ? const Color(0xFF38BDF8)
                                        : const Color(0xFF2563EB),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Add case',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? const Color(0xFF38BDF8)
                                          : const Color(0xFF2563EB),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (associatedCases.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            'No cases linked to this client yet.',
                            style: TextStyle(
                              fontSize: 13,
                              color: textSecondary,
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: associatedCases.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (ctx, idx) {
                            final c = associatedCases[idx];
                            final isOpen = c.status.toLowerCase() != 'closed';
                            return InkWell(
                              onTap: () => context.push('/app/cases/${c.id}'),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF1E2D4A)
                                            : const Color(0xFFEFF6FF),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.description_outlined,
                                        size: 20,
                                        color: isDark
                                            ? const Color(0xFF38BDF8)
                                            : const Color(0xFF2563EB),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            c.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w700,
                                              color: textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            c.caseNumber,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w500,
                                              color: textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            '${c.caseType.isNotEmpty ? c.caseType : 'General'} • ${c.courtName}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Pill Badge matching 1.png (● OPEN)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isOpen
                                            ? (isDark
                                                ? const Color(0xFF064E3B)
                                                    .withValues(alpha: 0.6)
                                                : const Color(0xFFDCFCE7))
                                            : (isDark
                                                ? const Color(0xFF1E293B)
                                                : const Color(0xFFF1F5F9)),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isOpen
                                              ? (isDark
                                                  ? const Color(0xFF10B981)
                                                      .withValues(alpha: 0.6)
                                                  : const Color(0xFF86EFAC))
                                              : (isDark
                                                  ? const Color(0xFF475569)
                                                  : const Color(0xFFCBD5E1)),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isOpen
                                                  ? (isDark
                                                      ? const Color(0xFF34D399)
                                                      : const Color(0xFF16A34A))
                                                  : (isDark
                                                      ? const Color(0xFF94A3B8)
                                                      : const Color(
                                                          0xFF64748B)),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            c.status.toUpperCase(),
                                            style: TextStyle(
                                              color: isOpen
                                                  ? (isDark
                                                      ? const Color(0xFF34D399)
                                                      : const Color(0xFF15803D))
                                                  : (isDark
                                                      ? const Color(0xFF94A3B8)
                                                      : const Color(
                                                          0xFF475569)),
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 18,
                                      color: isDark
                                          ? const Color(0xFF64748B)
                                          : const Color(0xFF94A3B8),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SkeletonLoader(height: 180, borderRadius: 20),
              SizedBox(height: 16),
              SkeletonLoader(height: 180, borderRadius: 20),
              SizedBox(height: 16),
              SkeletonLoader(height: 140, borderRadius: 20),
            ],
          ),
        ),
        error: (err, _) => ErrorStateWidget(
          message: 'Unable to load client details: $err',
          onRetry: () => ref.refresh(clientDetailProvider(clientId)),
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: textSecondary),
        const SizedBox(width: 14),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortalActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    required Color actionTileBg,
    required Color borderColor,
    required Color textPrimary,
    Color? iconColor,
    bool isWhatsApp = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 11),
          decoration: BoxDecoration(
            color: actionTileBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isWhatsApp
                      ? const Color(0xFF25D366).withValues(alpha: 0.15)
                      : (isDark
                          ? const Color(0xFF1E2D4A)
                          : const Color(0xFFE0F2FE)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 17,
                  color: iconColor ??
                      (isDark
                          ? const Color(0xFF38BDF8)
                          : const Color(0xFF0284C7)),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                      height: 1.25,
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 15,
                color:
                    isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Client?'),
        content: const Text(
          'Are you sure you want to delete this client profile? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(clientsNotifierProvider.notifier).deleteClient(clientId);
        ref.invalidate(dashboardNotifierProvider);
        if (context.mounted) {
          AppAlerts.showSuccess(context, 'Client profile removed.');
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          AppAlerts.showError(context, 'Failed to delete client: $e');
        }
      }
    }
  }
}
