import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/lex_button.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/models/task_model.dart';
import '../providers/tasks_notifier.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final int taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final _commentController = TextEditingController();
  bool _isPostingComment = false;
  bool _isTogglingStatus = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleToggleStatus(Task task) async {
    setState(() => _isTogglingStatus = true);
    try {
      if (task.isCompleted) {
        await ref.read(tasksNotifierProvider.notifier).reopenTask(task.id);
      } else {
        await ref.read(tasksNotifierProvider.notifier).completeTask(task.id);
      }
      ref.invalidate(taskDetailProvider(widget.taskId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update task status: $e'),
            backgroundColor: LexColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isTogglingStatus = false);
    }
  }

  Future<void> _handlePostComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isPostingComment = true);
    try {
      await ref
          .read(tasksNotifierProvider.notifier)
          .addComment(widget.taskId, text);
      _commentController.clear();
      ref.invalidate(taskDetailProvider(widget.taskId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added successfully.'),
            backgroundColor: LexColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add comment: $e'),
            backgroundColor: LexColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPostingComment = false);
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text(
          'Are you sure you want to delete this task? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: LexColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await ref.read(tasksNotifierProvider.notifier).deleteTask(widget.taskId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted successfully.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete task: $e'),
            backgroundColor: LexColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskDetailProvider(widget.taskId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Task',
            onPressed: () async {
              await context.push('/app/more/tasks/${widget.taskId}/edit');
              ref.invalidate(taskDetailProvider(widget.taskId));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: LexColors.error),
            tooltip: 'Delete Task',
            onPressed: _handleDelete,
          ),
        ],
      ),
      body: taskAsync.when(
        data: (task) {
          final dateFormat = DateFormat('MMM d, yyyy, h:mm a');

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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isDark
                                    ? LexColors.textPrimaryDark
                                    : LexColors.slatePrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge(status: task.status.displayName),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        context,
                        'Priority',
                        task.priority.displayName,
                        Icons.flag_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        context,
                        'Due Date',
                        task.dueDate ?? 'No deadline set',
                        Icons.event_outlined,
                        isWarning: task.isOverdue,
                      ),
                      if (task.caseTitle != null &&
                          task.caseTitle!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          context,
                          'Associated Case',
                          task.caseTitle!,
                          Icons.folder_outlined,
                        ),
                      ],
                      if (task.assignedTo != null) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          context,
                          'Assigned To',
                          task.assignedTo!.fullName,
                          Icons.person_outline,
                        ),
                      ],
                      if (task.createdBy != null) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          context,
                          'Created By',
                          task.createdBy!.fullName,
                          Icons.create_outlined,
                        ),
                      ],
                      if (task.completedAt != null) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          context,
                          'Completed At',
                          dateFormat.format(task.completedAt!.toLocal()),
                          Icons.check_circle_outline,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Description Card
                if (task.description != null &&
                    task.description!.trim().isNotEmpty) ...[
                  LexCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? LexColors.textPrimaryDark
                                : LexColors.slatePrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          task.description!,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: isDark
                                ? LexColors.textSecondaryDark
                                : LexColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Quick Status Toggle Button
                LexButton(
                  label: task.isCompleted
                      ? 'Reopen Task'
                      : 'Mark Task Completed',
                  icon: task.isCompleted
                      ? Icons.restart_alt_rounded
                      : Icons.check_circle_outline,
                  variant: task.isCompleted
                      ? LexButtonVariant.outline
                      : LexButtonVariant.primary,
                  isLoading: _isTogglingStatus,
                  onPressed: () => _handleToggleStatus(task),
                ),
                const SizedBox(height: 24),

                // Comments Section
                Text(
                  'Task Comments (${task.comments.length})',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? LexColors.textPrimaryDark
                        : LexColors.slatePrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Add comment input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Add an update or comment...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? LexColors.textSecondaryDark
                                : LexColors.textSecondaryLight,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? LexColors.surfaceDark
                              : LexColors.surfaceLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark
                                  ? LexColors.borderDark
                                  : LexColors.borderLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _isPostingComment ? null : _handlePostComment,
                      icon: _isPostingComment
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark
                            ? LexColors.accentGold
                            : LexColors.slatePrimary,
                        foregroundColor: isDark
                            ? LexColors.slatePrimary
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // List of comments
                if (task.comments.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'No comments yet. Post an update above.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? LexColors.textSecondaryDark
                              : LexColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  )
                else
                  ...task.comments.reversed.map((c) {
                    final cDate = c.createdAt != null
                        ? dateFormat.format(c.createdAt!.toLocal())
                        : '';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: LexCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  c.author?.fullName ?? 'Colleague',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  cDate,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? LexColors.textSecondaryDark
                                        : LexColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              c.text,
                              style: const TextStyle(fontSize: 13, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SkeletonLoader(height: 200),
              SizedBox(height: 16),
              SkeletonLoader(height: 120),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: ErrorStateWidget(
            message: 'Unable to load task details: $err',
            onRetry: () => ref.invalidate(taskDetailProvider(widget.taskId)),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isWarning = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isWarning
              ? LexColors.error
              : (isDark
                    ? LexColors.textSecondaryDark
                    : LexColors.textSecondaryLight),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark
                ? LexColors.textSecondaryDark
                : LexColors.textSecondaryLight,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isWarning
                ? LexColors.error
                : (isDark
                      ? LexColors.textPrimaryDark
                      : LexColors.textPrimaryLight),
          ),
        ),
      ],
    );
  }
}
