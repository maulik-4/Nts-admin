import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../cases/presentation/providers/cases_notifier.dart';
import '../../../dashboard/presentation/providers/dashboard_notifier.dart';
import '../../../team/presentation/providers/team_notifier.dart';
import '../../data/models/task_model.dart';
import '../providers/tasks_notifier.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  final int? taskId;
  final int? initialCaseId;

  const TaskFormScreen({super.key, this.taskId, this.initialCaseId});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  int? _selectedCaseId;
  int? _selectedAssigneeId;
  TaskPriority _selectedPriority = TaskPriority.medium;
  TaskStatus _selectedStatus = TaskStatus.pending;
  DateTime? _selectedDueDate;

  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _selectedCaseId = widget.initialCaseId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized && widget.taskId != null) {
      _loadExistingTask();
      _isInitialized = true;
    }
  }

  Future<void> _loadExistingTask() async {
    final task = await ref.read(taskDetailProvider(widget.taskId!).future);
    if (!mounted) return;
    setState(() {
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _selectedCaseId = task.caseId;
      _selectedAssigneeId = task.assignedTo?.id;
      _selectedPriority = task.priority;
      _selectedStatus = task.status;
      if (task.dueDate != null) {
        _selectedDueDate = DateTime.tryParse(task.dueDate!);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final dueDateStr = _selectedDueDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDueDate!)
        : null;

    try {
      if (widget.taskId != null) {
        final request = UpdateTaskRequest(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          caseId: _selectedCaseId,
          assignedToId: _selectedAssigneeId,
          priority: _selectedPriority,
          status: _selectedStatus,
          dueDate: dueDateStr,
        );
        await ref
            .read(tasksNotifierProvider.notifier)
            .updateTask(widget.taskId!, request);
        ref.invalidate(taskDetailProvider(widget.taskId!));
      } else {
        final request = CreateTaskRequest(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          caseId: _selectedCaseId,
          assignedToId: _selectedAssigneeId,
          priority: _selectedPriority,
          status: _selectedStatus,
          dueDate: dueDateStr,
        );
        await ref.read(tasksNotifierProvider.notifier).createTask(request);
      }

      ref.invalidate(dashboardNotifierProvider);

      if (mounted) {
        AppAlerts.showSuccess(
          context,
          widget.taskId != null
              ? 'Task updated successfully.'
              : 'Task created successfully.',
        );
        context.pop();
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (e is ApiException) {
        errorMessage = e.message;
      }
      if (mounted) {
        AppAlerts.showError(context, 'Failed to save task: $errorMessage');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
      case TaskPriority.high:
        return const Color(0xFFEF4444);
      case TaskPriority.medium:
        return const Color(0xFFF59E0B);
      case TaskPriority.low:
        return const Color(0xFF64748B);
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return const Color(0xFF10B981);
      case TaskStatus.inProgress:
        return const Color(0xFF3B82F6);
      case TaskStatus.pending:
        return const Color(0xFFF59E0B);
      case TaskStatus.cancelled:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.taskId != null;
    final casesAsync = ref.watch(casesNotifierProvider);
    final teamAsync = ref.watch(filteredTeamMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Task' : 'New Task',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LexCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFDBEAFE),
                            ),
                          ),
                          child: Text(
                            isEditing ? 'UPDATE TASK' : 'NEW TASK SPECIFICATION',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Task Information',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Title Field
                        Text(
                          'Task Title *',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'e.g., File reply to show cause notice',
                            prefixIcon: const Icon(Icons.edit_note_rounded, size: 20),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Task title is required';
                            }
                            if (val.trim().length > 255) {
                              return 'Title must be 255 characters or less';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Description Field
                        Text(
                          'Description (Optional)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Add instructions, requirements, or courtroom notes...',
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(bottom: 40),
                              child: Icon(Icons.notes_rounded, size: 20),
                            ),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Associated Case Dropdown
                        Text(
                          'Associated Case (Optional)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        casesAsync.when(
                          data: (cases) {
                            return DropdownButtonFormField<int?>(
                              isExpanded: true,
                              initialValue: _selectedCaseId,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.folder_open_rounded, size: 19),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('None (General Practice Task)', overflow: TextOverflow.ellipsis),
                                ),
                                ...cases.map((c) {
                                  return DropdownMenuItem<int?>(
                                    value: c.id,
                                    child: Text(
                                      '${c.caseNumber} - ${c.title}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (val) {
                                setState(() => _selectedCaseId = val);
                              },
                            );
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (err, stack) => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 16),

                        // Assignee Dropdown
                        Text(
                          'Assignee (Optional)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        teamAsync.when(
                          data: (members) {
                            return DropdownButtonFormField<int?>(
                              isExpanded: true,
                              initialValue: _selectedAssigneeId,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person_outline_rounded, size: 19),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('Unassigned (General Firm Task)', overflow: TextOverflow.ellipsis),
                                ),
                                ...members.map((m) {
                                  return DropdownMenuItem<int?>(
                                    value: m.id,
                                    child: Text(
                                      '${m.username} (${m.displayRole})',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (val) {
                                setState(() => _selectedAssigneeId = val);
                              },
                            );
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (err, stack) => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 16),

                        // Priority & Status Section (Responsive)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isVeryNarrow = constraints.maxWidth < 300;

                            final priorityWidget = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Priority',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<TaskPriority>(
                                  isExpanded: true,
                                  initialValue: _selectedPriority,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  ),
                                  items: TaskPriority.values.map((p) {
                                    final pColor = _getPriorityColor(p);
                                    return DropdownMenuItem<TaskPriority>(
                                      value: p,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(shape: BoxShape.circle, color: pColor),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              p.displayName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedPriority = val);
                                  },
                                ),
                              ],
                            );

                            final statusWidget = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<TaskStatus>(
                                  isExpanded: true,
                                  initialValue: _selectedStatus,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  ),
                                  items: TaskStatus.values.map((s) {
                                    final sColor = _getStatusColor(s);
                                    return DropdownMenuItem<TaskStatus>(
                                      value: s,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(shape: BoxShape.circle, color: sColor),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              s.displayName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedStatus = val);
                                  },
                                ),
                              ],
                            );

                            if (isVeryNarrow) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  priorityWidget,
                                  const SizedBox(height: 16),
                                  statusWidget,
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(child: priorityWidget),
                                const SizedBox(width: 12),
                                Expanded(child: statusWidget),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Due Date Picker Field
                        Text(
                          'Due Date',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickDueDate,
                          borderRadius: BorderRadius.circular(12),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              hintText: 'Select task deadline',
                              prefixIcon: const Icon(Icons.calendar_month_outlined, size: 19),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              _selectedDueDate != null
                                  ? DateFormat('MMMM d, yyyy').format(_selectedDueDate!)
                                  : 'No due date set',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: _selectedDueDate != null ? FontWeight.w600 : FontWeight.w400,
                                color: _selectedDueDate != null
                                    ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F1F38),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isEditing ? 'Save Changes' : 'Create Task',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                                letterSpacing: 0.2,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
