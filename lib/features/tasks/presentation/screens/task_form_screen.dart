import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_button.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/lex_text_field.dart';
import '../../../cases/presentation/providers/cases_notifier.dart';
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
        // Edit Task
        final request = UpdateTaskRequest(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          caseId: _selectedCaseId,
          priority: _selectedPriority,
          status: _selectedStatus,
          dueDate: dueDateStr,
        );
        await ref
            .read(tasksNotifierProvider.notifier)
            .updateTask(widget.taskId!, request);
        ref.invalidate(taskDetailProvider(widget.taskId!));
      } else {
        // Create Task
        final request = CreateTaskRequest(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          caseId: _selectedCaseId,
          priority: _selectedPriority,
          status: _selectedStatus,
          dueDate: dueDateStr,
        );
        await ref.read(tasksNotifierProvider.notifier).createTask(request);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.taskId != null
                  ? 'Task updated successfully.'
                  : 'Task created successfully.',
            ),
            backgroundColor: LexColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save task: $e'),
            backgroundColor: LexColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.taskId != null;
    final casesAsync = ref.watch(casesNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Task' : 'New Task')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LexCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Task Information',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? LexColors.textPrimaryDark
                                : LexColors.slatePrimary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        LexTextField(
                          label: 'Task Title *',
                          controller: _titleController,
                          hintText: 'e.g., File reply to notice',
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

                        // Description
                        LexTextField(
                          label: 'Description (Optional)',
                          controller: _descriptionController,
                          hintText: 'Add any specific instructions or requirements...',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),

                        // Associated Case Dropdown
                        casesAsync.when(
                          data: (cases) {
                            return DropdownButtonFormField<int?>(
                              initialValue: _selectedCaseId,
                              decoration: InputDecoration(
                                labelText: 'Associated Case (Optional)',
                                filled: true,
                                fillColor: isDark
                                    ? LexColors.surfaceDark
                                    : LexColors.surfaceLight,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('None (General Task)'),
                                ),
                                ...cases.map((c) {
                                  return DropdownMenuItem<int?>(
                                    value: c.id,
                                    child: Text(
                                      '${c.title} (${c.caseNumber})',
                                      overflow: TextOverflow.ellipsis,
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

                        // Priority Dropdown
                        DropdownButtonFormField<TaskPriority>(
                          initialValue: _selectedPriority,
                          decoration: InputDecoration(
                            labelText: 'Priority',
                            filled: true,
                            fillColor: isDark
                                ? LexColors.surfaceDark
                                : LexColors.surfaceLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: TaskPriority.values.map((p) {
                            return DropdownMenuItem<TaskPriority>(
                              value: p,
                              child: Text(p.displayName),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedPriority = val);
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Status Dropdown
                        DropdownButtonFormField<TaskStatus>(
                          initialValue: _selectedStatus,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            filled: true,
                            fillColor: isDark
                                ? LexColors.surfaceDark
                                : LexColors.surfaceLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: TaskStatus.values.map((s) {
                            return DropdownMenuItem<TaskStatus>(
                              value: s,
                              child: Text(s.displayName),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedStatus = val);
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Due Date Picker Field
                        InkWell(
                          onTap: _pickDueDate,
                          borderRadius: BorderRadius.circular(8),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Due Date',
                              hintText: 'Select task deadline',
                              suffixIcon: const Icon(
                                Icons.calendar_today,
                                size: 18,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? LexColors.surfaceDark
                                  : LexColors.surfaceLight,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              _selectedDueDate != null
                                  ? DateFormat('MMMM d, yyyy')
                                        .format(_selectedDueDate!)
                                  : 'No due date selected',
                              style: TextStyle(
                                color: _selectedDueDate != null
                                    ? (isDark
                                          ? LexColors.textPrimaryDark
                                          : LexColors.textPrimaryLight)
                                    : (isDark
                                          ? LexColors.textSecondaryDark
                                          : LexColors.textSecondaryLight),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  LexButton(
                    label: isEditing ? 'Save Changes' : 'Create Task',
                    icon: isEditing ? Icons.check : Icons.add_task,
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _handleSubmit,
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
