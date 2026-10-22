import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/searchable_picker_modal.dart';
import '../../../cases/presentation/providers/cases_notifier.dart';
import '../../../cases/presentation/screens/case_detail_screen.dart';
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
      if (_selectedCaseId != null) {
        ref.invalidate(caseDetailProvider(_selectedCaseId!));
      }

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
      backgroundColor:
          isDark ? const Color(0xFF070E1A) : const Color(0xFFF1F5F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Header with 1.1.png matching client_form_screen
            Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/1.1.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.centerRight,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF071224), Color(0xFF1E3A8A)],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          const Color(0xFF071224).withValues(alpha: 0.95),
                          const Color(0xFF071224).withValues(alpha: 0.8),
                          const Color(0xFF0A1830).withValues(alpha: 0.35),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.45, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () => context.pop(),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isEditing ? 'Edit Task' : 'New Task',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E3A8A)
                                    .withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF3B82F6)
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.assignment_outlined,
                                      size: 13, color: Color(0xFF93C5FD)),
                                  const SizedBox(width: 6),
                                  Text(
                                    isEditing
                                        ? 'TASK MODIFICATION'
                                        : 'WORKFLOW & DELIVERABLE',
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                      color: Color(0xFF93C5FD),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isEditing
                                  ? 'Update Task Details'
                                  : 'Create Legal Task',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Assign deadlines, priority levels, and associated cases for structured legal team delivery.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.8),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Form Body
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                  child: Form(
                    key: _formKey,
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFDBEAFE),
                            ),
                          ),
                          child: Text(
                            isEditing
                                ? 'UPDATE TASK'
                                : 'NEW TASK SPECIFICATION',
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
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Title Field
                        Text(
                          'Task Title *',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'e.g., File reply to show cause notice',
                            prefixIcon: const Icon(
                              Icons.edit_note_rounded,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                            color: isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF334155),
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
                            fillColor: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Associated Case Dropdown
                        Text(
                          'Associated Case (Optional)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        casesAsync.when(
                          data: (cases) {
                            final selectedCase = _selectedCaseId != null
                                ? cases
                                    .where((c) => c.id == _selectedCaseId)
                                    .firstOrNull
                                : null;

                            return InkWell(
                              onTap: () async {
                                final items = <SearchablePickerItem<int>>[
                                  const SearchablePickerItem<int>(
                                    value: -1,
                                    label: 'None (General Practice Task)',
                                    subtitle: 'No specific case association',
                                    icon: Icons.remove_circle_outline_rounded,
                                    iconColor: Color(0xFF64748B),
                                  ),
                                  ...cases.map((c) {
                                    return SearchablePickerItem<int>(
                                      value: c.id,
                                      label: c.caseNumber,
                                      subtitle: '${c.title} • ${c.courtName}',
                                      icon: Icons.folder_rounded,
                                      iconColor: const Color(0xFF2563EB),
                                    );
                                  }),
                                ];

                                final pickedId =
                                    await showSearchablePicker<int>(
                                  context: context,
                                  title: 'Select Associated Case',
                                  searchHint:
                                      'Search case number, title, or court...',
                                  selectedValue: _selectedCaseId ?? -1,
                                  items: items,
                                );

                                if (pickedId != null) {
                                  setState(() {
                                    _selectedCaseId =
                                        pickedId == -1 ? null : pickedId;
                                  });
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 13,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.folder_open_rounded,
                                      size: 19,
                                      color: _selectedCaseId != null
                                          ? const Color(0xFF2563EB)
                                          : (isDark
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFF64748B)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: selectedCase != null
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  selectedCase.caseNumber,
                                                  style: TextStyle(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: isDark
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFF0F172A),
                                                  ),
                                                ),
                                                Text(
                                                  '${selectedCase.title} • ${selectedCase.courtName}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 11.5,
                                                    color: isDark
                                                        ? const Color(
                                                            0xFF94A3B8)
                                                        : const Color(
                                                            0xFF64748B),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Text(
                                              'None (General Practice Task)',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isDark
                                                    ? const Color(0xFF94A3B8)
                                                    : const Color(0xFF64748B),
                                              ),
                                            ),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down_rounded,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (err, stack) => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 16),

                        // Assignee Dropdown (Searchable)
                        Text(
                          'Assignee (Optional)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        teamAsync.when(
                          data: (members) {
                            final selectedMember = _selectedAssigneeId != null
                                ? members
                                    .where((m) => m.id == _selectedAssigneeId)
                                    .firstOrNull
                                : null;

                            return InkWell(
                              onTap: () async {
                                final items = <SearchablePickerItem<int>>[
                                  const SearchablePickerItem<int>(
                                    value: -1,
                                    label: 'Unassigned (General Firm Task)',
                                    subtitle: 'Any available staff or lawyer',
                                    icon: Icons.person_off_outlined,
                                    iconColor: Color(0xFF64748B),
                                  ),
                                  ...members.map((m) {
                                    final name = (m.name != null &&
                                            m.name!.trim().isNotEmpty)
                                        ? m.name!
                                        : m.username;
                                    return SearchablePickerItem<int>(
                                      value: m.id,
                                      label: name,
                                      subtitle:
                                          '${m.username} • ${m.displayRole}',
                                      icon: Icons.person_outline_rounded,
                                      iconColor: const Color(0xFF10B981),
                                    );
                                  }),
                                ];

                                final pickedId =
                                    await showSearchablePicker<int>(
                                  context: context,
                                  title: 'Select Assignee',
                                  searchHint:
                                      'Search team member by name or role...',
                                  selectedValue: _selectedAssigneeId ?? -1,
                                  items: items,
                                );

                                if (pickedId != null) {
                                  setState(() {
                                    _selectedAssigneeId =
                                        pickedId == -1 ? null : pickedId;
                                  });
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 13,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline_rounded,
                                      size: 19,
                                      color: _selectedAssigneeId != null
                                          ? const Color(0xFF10B981)
                                          : (isDark
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFF64748B)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: selectedMember != null
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  (selectedMember.name !=
                                                              null &&
                                                          selectedMember
                                                              .name!
                                                              .trim()
                                                              .isNotEmpty)
                                                      ? selectedMember.name!
                                                      : selectedMember.username,
                                                  style: TextStyle(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: isDark
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFF0F172A),
                                                  ),
                                                ),
                                                Text(
                                                  '${selectedMember.username} • ${selectedMember.displayRole}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 11.5,
                                                    color: isDark
                                                        ? const Color(
                                                            0xFF94A3B8)
                                                        : const Color(
                                                            0xFF64748B),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Text(
                                              'Unassigned (General Firm Task)',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isDark
                                                    ? const Color(0xFF94A3B8)
                                                    : const Color(0xFF64748B),
                                              ),
                                            ),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down_rounded,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                    ),
                                  ],
                                ),
                              ),
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
                                    color: isDark
                                        ? const Color(0xFFCBD5E1)
                                        : const Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<TaskPriority>(
                                  isExpanded: true,
                                  initialValue: _selectedPriority,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 12,
                                    ),
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
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: pColor,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              p.displayName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedPriority = val);
                                    }
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
                                    color: isDark
                                        ? const Color(0xFFCBD5E1)
                                        : const Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<TaskStatus>(
                                  isExpanded: true,
                                  initialValue: _selectedStatus,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 12,
                                    ),
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
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: sColor,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              s.displayName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedStatus = val);
                                    }
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
                            color: isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickDueDate,
                          borderRadius: BorderRadius.circular(12),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              hintText: 'Select task deadline',
                              prefixIcon: const Icon(
                                Icons.calendar_month_outlined,
                                size: 19,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _selectedDueDate != null
                                  ? DateFormat('MMMM d, yyyy')
                                        .format(_selectedDueDate!)
                                  : 'No due date set',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: _selectedDueDate != null
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: _selectedDueDate != null
                                    ? (isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A))
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
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F1F38),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isEditing
                                      ? Icons.task_alt_rounded
                                      : Icons.add_task_rounded,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isEditing ? 'Save Changes' : 'Create Task',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  ),
),
);
  }
}

