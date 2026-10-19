import 'package:flutter/material.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final ValueChanged<bool>? onToggleComplete;
  final VoidCallback? onMorePressed;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    this.onToggleComplete,
    this.onMorePressed,
  });

  Widget _buildPriorityBadge(BuildContext context, TaskPriority priority) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color color;
    Color bgColor;

    switch (priority) {
      case TaskPriority.urgent:
        color = const Color(0xFFEF4444);
        bgColor = isDark ? color.withAlpha(45) : const Color(0xFFFEF2F2);
        break;
      case TaskPriority.high:
        color = const Color(0xFFE11D48);
        bgColor = isDark ? color.withAlpha(45) : const Color(0xFFFFF1F2);
        break;
      case TaskPriority.medium:
        color = const Color(0xFFF59E0B);
        bgColor = isDark ? color.withAlpha(45) : const Color(0xFFFFFBEB);
        break;
      case TaskPriority.low:
        color = const Color(0xFF64748B);
        bgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag_rounded, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            priority.displayName.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getLeftAccent() {
    if (task.isCompleted) return const Color(0xFF10B981);
    switch (task.priority) {
      case TaskPriority.urgent:
      case TaskPriority.high:
        return const Color(0xFFEF4444);
      case TaskPriority.medium:
        return const Color(0xFFF59E0B);
      case TaskPriority.low:
        return const Color(0xFF3B82F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LexCard(
      onTap: onTap,
      borderRadius: 16,
      leftAccentColor: _getLeftAccent(),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox button
              if (onToggleComplete != null)
                GestureDetector(
                  onTap: () => onToggleComplete!(!task.isCompleted),
                  child: Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(top: 2, right: 12),
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? const Color(0xFF10B981)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: task.isCompleted
                            ? const Color(0xFF10B981)
                            : (isDark
                                  ? const Color(0xFF475569)
                                  : const Color(0xFFCBD5E1)),
                        width: 1.8,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),

              // Title and details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted
                            ? (isDark
                                  ? LexColors.textSecondaryDark
                                  : const Color(0xFF94A3B8))
                            : (isDark
                                  ? LexColors.textPrimaryDark
                                  : const Color(0xFF0F172A)),
                      ),
                    ),
                    if (task.description != null &&
                        task.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Status badge with dot
              StatusBadge(status: task.status.displayName, showDot: true),

              // More options
              if (onMorePressed != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  onPressed: onMorePressed,
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 10,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Priority Chip
              _buildPriorityBadge(context, task.priority),

              // Case Folder Badge
              if (task.caseTitle != null && task.caseTitle!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.folder_open_rounded,
                        size: 12,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 130),
                        child: Text(
                          task.caseTitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Due Date Pill
              if (task.dueDate != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_outlined,
                      size: 13,
                      color: task.isOverdue
                          ? const Color(0xFFEF4444)
                          : (isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task.dueDate!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: task.isOverdue
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: task.isOverdue
                            ? const Color(0xFFEF4444)
                            : (isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),

              // Assignee indicator if available
              if (task.assignedToName != null &&
                  task.assignedToName!.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_circle_outlined,
                      size: 13,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 100),
                      child: Text(
                        task.assignedToName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),

              // Comments count
              if (task.comments.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 12,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${task.comments.length}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
