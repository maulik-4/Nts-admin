import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../providers/clients_notifier.dart';
import '../widgets/client_card.dart';

class ClientsListScreen extends ConsumerWidget {
  const ClientsListScreen({super.key});

  Widget _buildFilterPill({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(filteredClientsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeFilter = ref.watch(clientActiveFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clients',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
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
        backgroundColor: const Color(0xFF0F1F38),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.person_add_rounded, size: 20),
        label: const Text(
          'Add Client',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: TextField(
              onChanged: (val) =>
                  ref.read(clientSearchQueryProvider.notifier).state = val,
              decoration: InputDecoration(
                hintText: 'Search by name, phone, city...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
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

          // Filter Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterPill(
                  context: context,
                  label: 'All Clients',
                  isSelected: activeFilter == null,
                  onTap: () =>
                      ref.read(clientActiveFilterProvider.notifier).state = null,
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  context: context,
                  label: 'Active',
                  isSelected: activeFilter == true,
                  onTap: () =>
                      ref.read(clientActiveFilterProvider.notifier).state = true,
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  context: context,
                  label: 'Inactive',
                  isSelected: activeFilter == false,
                  onTap: () =>
                      ref.read(clientActiveFilterProvider.notifier).state = false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Content Area
          Expanded(
            child: clientsAsync.when(
              data: (clients) {
                if (clients.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.people_outline,
                    title: 'No Clients Found',
                    message:
                        'No client profiles match your search criteria or active filter.',
                    actionLabel: 'Add New Client',
                    onAction: () => context.push('/app/clients/create'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(clientsNotifierProvider.notifier).loadClients(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
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
                itemCount: 5,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    const SkeletonLoader(height: 90, borderRadius: 16),
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
