import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../providers/clients_notifier.dart';
import '../widgets/client_card.dart';

class ClientsListScreen extends ConsumerWidget {
  const ClientsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(filteredClientsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeFilter = ref.watch(clientActiveFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(clientsNotifierProvider.notifier).loadClients(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_add_client',
        onPressed: () => context.push('/app/clients/create'),
        backgroundColor: isDark ? LexColors.accentGold : LexColors.slatePrimary,
        foregroundColor: isDark ? LexColors.slatePrimary : Colors.white,
        icon: const Icon(Icons.person_add_outlined, size: 20),
        label: const Text(
          'Add Client',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (val) =>
                  ref.read(clientSearchQueryProvider.notifier).state = val,
              decoration: InputDecoration(
                hintText: 'Search by name, phone, city...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: isDark
                    ? LexColors.surfaceDark
                    : LexColors.canvasLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark
                        ? LexColors.borderDark
                        : LexColors.borderLight,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark
                        ? LexColors.borderDark
                        : LexColors.borderLight,
                  ),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: activeFilter == null,
                  onSelected: (_) =>
                      ref.read(clientActiveFilterProvider.notifier).state =
                          null,
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Active'),
                  selected: activeFilter == true,
                  onSelected: (_) =>
                      ref.read(clientActiveFilterProvider.notifier).state =
                          true,
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Inactive'),
                  selected: activeFilter == false,
                  onSelected: (_) =>
                      ref.read(clientActiveFilterProvider.notifier).state =
                          false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Content Area
          Expanded(
            child: clientsAsync.when(
              data: (clients) {
                if (clients.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.people_outline,
                    title: 'No Clients Found',
                    message: 'No client profiles match your current search criteria or have been added yet.',
                    actionLabel: 'Add First Client',
                    onAction: () => context.push('/app/clients/create'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(clientsNotifierProvider.notifier).loadClients(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                    itemCount: clients.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final client = clients[index];
                      return ClientCard(
                        client: client,
                        onTap: () => context.push('/app/clients/${client.id}'),
                      );
                    },
                  ),
                );
              },
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 6,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    const SkeletonLoader(height: 100, borderRadius: 12),
              ),
              error: (err, _) => ErrorStateWidget(
                message: err.toString(),
                onRetry: () =>
                    ref.read(clientsNotifierProvider.notifier).loadClients(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
