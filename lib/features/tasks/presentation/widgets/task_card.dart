import 'package:flutter/material.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final ValueChanged<bool>? onToggleComplete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LexCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox or Status icon
              if (onToggleComplete != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () => onToggleComplete!(!task.isCompleted),
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: task.isCompleted
                            ? LexColors.success
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: task.isCompleted
                              ? LexColors.success
                              : (isDark
                                    ? LexColors.borderDark
                                    : LexColors.borderLight),
                          width: 1.5,
                        ),
                      ),
                      child: task.isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted
                            ? (isDark
                                  ? LexColors.textSecondaryDark
                                  : LexColors.textSecondaryLight)
                            : (isDark
                                  ? LexColors.textPrimaryDark
                                  : Theme.of(context).colorScheme.primary),
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
                              ? LexColors.textSecondaryDark
                              : LexColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: task.status.displayName),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Priority Chip
              _buildPriorityBadge(task.priority),

              // Due Date
              if (task.dueDate != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_outlined,
                      size: 14,
                      color: task.isOverdue
                          ? LexColors.error
                          : (isDark
                                ? LexColors.textSecondaryDark
                                : LexColors.textSecondaryLight),
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
                            ? LexColors.error
                            : (isDark
                                  ? LexColors.textSecondaryDark
                                  : LexColors.textSecondaryLight),
                      ),
                    ),
                  ],
                ),

              // Associated Case
              if (task.caseTitle != null && task.caseTitle!.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 14,
                      color: isDark
                          ? LexColors.accentGold
                          : LexColors.slateLight,
                    ),
                    const SizedBox(width: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 140),
                      child: Text(
                        task.caseTitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? LexColors.textSecondaryDark
                              : LexColors.textSecondaryLight,
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
                      Icons.chat_bubble_outline,
                      size: 13,
                      color: isDark
                          ? LexColors.textSecondaryDark
                          : LexColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${task.comments.length}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? LexColors.textSecondaryDark
                            : LexColors.textSecondaryLight,
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

  Widget _buildPriorityBadge(TaskPriority priority) {
    Color color;
    Color bgColor;

    switch (priority) {
      case TaskPriority.urgent:
        color = LexColors.error;
        bgColor = LexColors.errorLight;
        break;
      case TaskPriority.high:
        color = const Color(0xFFE11D48);
        bgColor = const Color(0xFFFFF1F2);
        break;
      case TaskPriority.medium:
        color = LexColors.warning;
        bgColor = LexColors.accentLight;
        break;
      case TaskPriority.low:
        color = LexColors.textSecondaryLight;
        bgColor = const Color(0xFFF1F5F9);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            priority.displayName.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
