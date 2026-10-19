import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_alerts.dart';
import '../../../../shared/widgets/capability_gate.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../auth/domain/models/role_capabilities.dart';
import '../../data/models/task_model.dart';
import '../providers/tasks_notifier.dart';
import '../widgets/task_card.dart';

class TasksListScreen extends ConsumerStatefulWidget {
  const TasksListScreen({super.key});

  @override
  ConsumerState<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends ConsumerState<TasksListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(filteredTasksProvider);
    final allTasks = ref.watch(tasksNotifierProvider).value ?? [];
    final statusFilter = ref.watch(taskStatusFilterProvider);
    final priorityFilter = ref.watch(taskPriorityFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tasks',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () {
              ref.read(tasksNotifierProvider.notifier).loadTasks();
            },
          ),
        ],
      ),
      floatingActionButton: CapabilityGate(
        capability: UserCapability.createTask,
        child: FloatingActionButton.extended(
          heroTag: 'fab_add_task',
          onPressed: () => context.push('/app/tasks/create'),
          backgroundColor: const Color(0xFF0F1F38),
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_task_rounded, size: 20),
          label: const Text(
            'New Task',
            style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
          ),
        ),
      ),
      body: Column(
        children: [

          // Search & Filter header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      ref.read(taskSearchQueryProvider.notifier).state = val;
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Search tasks by title, case, or assignee...',
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
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                        .read(taskSearchQueryProvider.notifier)
                                        .state =
                                    '';
                                setState(() {});
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1E293B)
                          : Colors.white,
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
              ],
            ),
          ),

          // Horizontal Filter Chips with counts
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterPill(
                  context: context,
                  label: 'All Status',
                  count: allTasks.length,
                  isSelected: statusFilter == null,
                  onTap: () =>
                      ref.read(taskStatusFilterProvider.notifier).state = null,
                ),
                const SizedBox(width: 8),
                ...TaskStatus.values.map((s) {
                  final count = allTasks.where((t) => t.status == s).length;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterPill(
                      context: context,
                      label: s.displayName,
                      count: count,
                      isSelected: statusFilter == s,
                      onTap: () =>
                          ref.read(taskStatusFilterProvider.notifier).state =
                              statusFilter == s ? null : s,
                    ),
                  );
                }),
                const SizedBox(width: 4),
                Container(
                  width: 1,
                  height: 22,
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFCBD5E1),
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  context: context,
                  label: 'All Priority',
                  isSelected: priorityFilter == null,
                  onTap: () =>
                      ref.read(taskPriorityFilterProvider.notifier).state =
                          null,
                ),
                const SizedBox(width: 8),
                ...TaskPriority.values.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterPill(
                      context: context,
                      label: p.displayName,
                      isSelected: priorityFilter == p,
                      onTap: () =>
                          ref.read(taskPriorityFilterProvider.notifier).state =
                              priorityFilter == p ? null : p,
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Tasks List Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(tasksNotifierProvider.notifier).loadTasks(),
              child: tasksAsync.when(
                data: (tasks) {
                  if (tasks.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 60),
                        EmptyStateWidget(
                          title: 'No Tasks Found',
                          message:
                              'Create your first task or clear active filters.',
                          icon: Icons.task_alt_outlined,
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
                    itemCount: tasks.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskCard(
                        task: task,
                        onTap: () => context.push('/app/more/tasks/${task.id}'),
                        onToggleComplete: (shouldComplete) async {
                          try {
                            if (shouldComplete) {
                              await ref
                                  .read(tasksNotifierProvider.notifier)
                                  .completeTask(task.id);
                            } else {
                              await ref
                                  .read(tasksNotifierProvider.notifier)
                                  .reopenTask(task.id);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              AppAlerts.showError(
                                context,
                                'Failed to update task status: $e',
                              );
                            }
                          }
                        },
                      );
                    },
                  );
                },
                loading: () => ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: 5,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      const SkeletonLoader(height: 110, borderRadius: 16),
                ),
                error: (err, stack) => Center(
                  child: ErrorStateWidget(
                    message: 'Unable to load tasks: $err',
                    onRetry: () =>
                        ref.read(tasksNotifierProvider.notifier).loadTasks(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
