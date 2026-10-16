import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/app_alerts.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../cases/presentation/providers/cases_notifier.dart';
import '../../data/repositories/clients_repository.dart';
import '../providers/clients_notifier.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Client Details',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Client',
            onPressed: () => context.push('/app/clients/$clientId/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
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
              : 'Unrecorded';

          final accentColor = client.isActive
              ? const Color(0xFF10B981)
              : const Color(0xFF94A3B8);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
                LexCard(
                  borderRadius: 20,
                  leftAccentColor: accentColor,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFDBEAFE),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                client.name.isNotEmpty
                                    ? client.name.substring(0, 1).toUpperCase()
                                    : 'C',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  client.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Client since $dateFormatted',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(
                            status: client.isActive ? 'Active' : 'Inactive',
                            showDot: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Contact Information
                LexCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.contact_mail_outlined,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Contact Information',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        'Phone',
                        client.phone,
                        Icons.phone_outlined,
                      ),
                      if (client.email != null && client.email!.isNotEmpty) ...[
                        const Divider(height: 18),
                        _buildInfoRow(
                          context,
                          'Email',
                          client.email!,
                          Icons.email_outlined,
                        ),
                      ],
                      if (client.city != null && client.city!.isNotEmpty) ...[
                        const Divider(height: 18),
                        _buildInfoRow(
                          context,
                          'City',
                          client.city!,
                          Icons.location_city_outlined,
                        ),
                      ],
                      const Divider(height: 18),
                      _buildInfoRow(
                        context,
                        'Address',
                        client.address,
                        Icons.home_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Associated Cases Card
                LexCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.folder_shared_outlined,
                                size: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Cases (${associatedCases.length})',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () => context.push(
                              '/app/cases/create?clientId=$clientId',
                            ),
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text('Add Case'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (associatedCases.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'No cases linked to this client yet.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: associatedCases.length,
                          separatorBuilder: (_, _) => const Divider(height: 14),
                          itemBuilder: (ctx, idx) {
                            final c = associatedCases[idx];
                            return InkWell(
                              onTap: () => context.push('/app/cases/${c.id}'),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            c.title,
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w700,
                                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${c.caseNumber} • ${c.courtName}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    StatusBadge(status: c.status, showDot: true),
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
        loading: () => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: const [
              SkeletonLoader(height: 110, borderRadius: 18),
              SizedBox(height: 16),
              SkeletonLoader(height: 160, borderRadius: 18),
              SizedBox(height: 16),
              SkeletonLoader(height: 140, borderRadius: 18),
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
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
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
          'Are you sure you want to delete this client profile? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(clientsNotifierProvider.notifier).deleteClient(clientId);
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
