import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/lex_text_field.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
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

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(filteredTasksProvider);
    final statusFilter = ref.watch(taskStatusFilterProvider);
    final priorityFilter = ref.watch(taskPriorityFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/app/more/tasks/create'),
        backgroundColor: isDark
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.primary,
        foregroundColor: isDark ? Colors.black : Colors.white,
        icon: const Icon(Icons.add_task),
        label: const Text(
          'New Task',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: LexTextField(
              controller: _searchController,
              hintText: 'Search tasks by title, case, or assignee...',
              prefixIcon: Icons.search,
              suffix: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(taskSearchQueryProvider.notifier).state = '';
                        setState(() {});
                      },
                    )
                  : null,
              onChanged: (val) {
                ref.read(taskSearchQueryProvider.notifier).state = val;
                setState(() {});
              },
            ),
          ),

          // Horizontal Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                // Status Filter Chips
                _buildFilterChip(
                  label: 'All Status',
                  isSelected: statusFilter == null,
                  onSelected: () =>
                      ref.read(taskStatusFilterProvider.notifier).state = null,
                ),
                const SizedBox(width: 8),
                ...TaskStatus.values.map((s) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      label: s.displayName,
                      isSelected: statusFilter == s,
                      onSelected: () =>
                          ref.read(taskStatusFilterProvider.notifier).state =
                              statusFilter == s ? null : s,
                    ),
                  );
                }),
                const SizedBox(width: 8),
                Container(
                  width: 1,
                  height: 24,
                  color: isDark ? LexColors.borderDark : LexColors.borderLight,
                ),
                const SizedBox(width: 8),
                // Priority Filter Chips
                _buildFilterChip(
                  label: 'All Priority',
                  isSelected: priorityFilter == null,
                  onSelected: () =>
                      ref.read(taskPriorityFilterProvider.notifier).state =
                          null,
                ),
                const SizedBox(width: 8),
                ...TaskPriority.values.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      label: p.displayName,
                      isSelected: priorityFilter == p,
                      onSelected: () =>
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

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isTablet = constraints.maxWidth >= 600;

                      if (isTablet) {
                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 2.2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return TaskCard(
                              task: task,
                              onTap: () =>
                                  context.push('/app/more/tasks/${task.id}'),
                              onToggleComplete: (shouldComplete) async {
                                if (shouldComplete) {
                                  await ref
                                      .read(tasksNotifierProvider.notifier)
                                      .completeTask(task.id);
                                } else {
                                  await ref
                                      .read(tasksNotifierProvider.notifier)
                                      .reopenTask(task.id);
                                }
                              },
                            );
                          },
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: tasks.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return TaskCard(
                            task: task,
                            onTap: () =>
                                context.push('/app/more/tasks/${task.id}'),
                            onToggleComplete: (shouldComplete) async {
                              if (shouldComplete) {
                                await ref
                                    .read(tasksNotifierProvider.notifier)
                                    .completeTask(task.id);
                              } else {
                                await ref
                                    .read(tasksNotifierProvider.notifier)
                                    .reopenTask(task.id);
                              }
                            },
                          );
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
                      const SkeletonLoader(height: 110),
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

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected
              ? (isDark ? LexColors.slatePrimary : Colors.white)
              : (isDark
                    ? LexColors.textSecondaryDark
                    : LexColors.textSecondaryLight),
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: isDark
          ? Theme.of(context).colorScheme.secondary
          : Theme.of(context).colorScheme.primary,
      backgroundColor: isDark ? LexColors.surfaceDark : const Color(0xFFF1F5F9),
      side: BorderSide(
        color: isSelected
            ? Colors.transparent
            : (isDark ? LexColors.borderDark : LexColors.borderLight),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      showCheckmark: false,
    );
  }
}
