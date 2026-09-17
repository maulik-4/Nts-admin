import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../cases/presentation/providers/cases_notifier.dart';
import '../../data/repositories/clients_repository.dart';
import '../providers/clients_notifier.dart';

final clientDetailProvider = FutureProvider.family<dynamic, int>((
  ref,
  id,
) async {
  // First check if available in list
  final list = ref.watch(clientsNotifierProvider).valueOrNull;
  if (list != null) {
    final found = list.where((c) => c.id == id);
    if (found.isNotEmpty) return found.first;
  }
  // Otherwise fetch from repository
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Client',
            onPressed: () => context.push('/app/clients/$clientId/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: LexColors.error),
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

          final dateFormatted = client.createdAt != null
              ? DateFormat('MMM d, yyyy').format(client.createdAt!)
              : 'Unknown';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
                LexCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: isDark
                                ? LexColors.surfaceDark
                                : const Color(0xFFEEF2F6),
                            child: Text(
                              client.name.isNotEmpty
                                  ? client.name.substring(0, 1).toUpperCase()
                                  : 'C',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? LexColors.accentGold
                                    : LexColors.slatePrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  client.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? LexColors.textPrimaryDark
                                        : LexColors.slatePrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    StatusBadge(
                                      status: client.isActive
                                          ? 'Active'
                                          : 'Inactive',
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Added $dateFormatted',
                                      style: TextStyle(
                                        fontSize: 12,
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
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Contact Details Card
                LexCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact Information',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? LexColors.textPrimaryDark
                              : LexColors.slatePrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        'Phone',
                        client.phone,
                        Icons.phone_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        'Email',
                        client.email?.isNotEmpty == true
                            ? client.email!
                            : 'Not provided',
                        Icons.email_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        'City',
                        client.city?.isNotEmpty == true
                            ? client.city!
                            : 'Not specified',
                        Icons.location_city_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        'Address',
                        client.address.isNotEmpty
                            ? client.address
                            : 'Not provided',
                        Icons.map_outlined,
                      ),
                      if (client.idProof != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          context,
                          'ID Proof URL',
                          client.idProof!,
                          Icons.badge_outlined,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Associated Cases Card
                LexCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Associated Cases (${associatedCases.length})',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? LexColors.textPrimaryDark
                                  : LexColors.slatePrimary,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => context.push('/app/cases/create'),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Case'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (associatedCases.isEmpty)
                        Text(
                          'No cases currently associated with this client.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? LexColors.textSecondaryDark
                                : LexColors.textSecondaryLight,
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: associatedCases.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 16),
                          itemBuilder: (context, index) {
                            final c = associatedCases[index];
                            return InkWell(
                              onTap: () => context.push('/app/cases/${c.id}'),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            c.title,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            c.caseNumber,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? LexColors.textSecondaryDark
                                                  : LexColors
                                                        .textSecondaryLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    StatusBadge(status: c.status),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.chevron_right,
                                      size: 18,
                                      color: LexColors.textSecondaryLight,
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorStateWidget(
          message: 'Unable to load client details: $err',
          onRetry: () => ref.refresh(clientDetailProvider(clientId)),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark
              ? LexColors.textSecondaryDark
              : LexColors.textSecondaryLight,
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? LexColors.textSecondaryDark
                  : LexColors.textSecondaryLight,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? LexColors.textPrimaryDark
                  : LexColors.textPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Client?'),
        content: const Text(
          'Are you sure you want to delete this client? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: TextButton.styleFrom(foregroundColor: LexColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(clientsNotifierProvider.notifier).deleteClient(clientId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Client deleted successfully')),
          );
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete client: $e')),
          );
        }
      }
    }
  }
}
