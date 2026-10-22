import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/lex_text_field.dart';
import '../../../../shared/widgets/searchable_picker_modal.dart';
import '../../../cases/presentation/providers/cases_notifier.dart';
import '../../data/models/hearing_model.dart';
import '../providers/hearings_notifier.dart';

class HearingFormScreen extends ConsumerStatefulWidget {
  final int? hearingId;
  final int? initialCaseId;

  const HearingFormScreen({super.key, this.hearingId, this.initialCaseId});

  @override
  ConsumerState<HearingFormScreen> createState() => _HearingFormScreenState();
}

class _HearingFormScreenState extends ConsumerState<HearingFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _courtNameController = TextEditingController();
  final _judgeNameController = TextEditingController();
  final _notesController = TextEditingController();

  int? _selectedCaseId;
  bool _isLoading = false;
  bool _initialized = false;

  bool get isEdit => widget.hearingId != null;

  @override
  void initState() {
    super.initState();
    if (widget.initialCaseId != null) {
      _selectedCaseId = widget.initialCaseId;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized && isEdit) {
      _loadExistingHearing();
      _initialized = true;
    }
  }

  void _loadExistingHearing() {
    final list = ref.read(hearingsNotifierProvider).valueOrNull;
    if (list != null) {
      final match = list.where((h) => h.id == widget.hearingId);
      if (match.isNotEmpty) {
        final h = match.first;
        _titleController.text = h.title;
        _dateController.text = h.date;
        _startTimeController.text = h.startTime ?? '';
        _endTimeController.text = h.endTime ?? '';
        _courtNameController.text = h.courtName;
        _judgeNameController.text = h.judgeName ?? '';
        _notesController.text = h.notes ?? '';
        _selectedCaseId = h.caseId;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _courtNameController.dispose();
    _judgeNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    DateTime initialDate = now;
    if (_dateController.text.isNotEmpty) {
      final parsed = DateTime.tryParse(_dateController.text);
      if (parsed != null) initialDate = parsed;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 30),
    );
    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      setState(() {
        _startTimeController.text = '$hour:$minute:00';
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 11, minute: 30),
    );
    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      setState(() {
        _endTimeController.text = '$hour:$minute:00';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCaseId == null) {
      AppAlerts.showError(context, 'Please select a case for this hearing.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (isEdit) {
        final request = UpdateHearingRequest(
          title: _titleController.text.trim(),
          date: _dateController.text.trim(),
          startTime: _startTimeController.text.trim().isNotEmpty
              ? _startTimeController.text.trim()
              : null,
          endTime: _endTimeController.text.trim().isNotEmpty
              ? _endTimeController.text.trim()
              : null,
          courtName: _courtNameController.text.trim(),
          judgeName: _judgeNameController.text.trim().isNotEmpty
              ? _judgeNameController.text.trim()
              : null,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          caseId: _selectedCaseId,
        );
        await ref
            .read(hearingsNotifierProvider.notifier)
            .updateHearing(widget.hearingId!, request);
        if (mounted) {
          AppAlerts.showSuccess(context, 'Hearing updated successfully.');
          context.pop();
        }
      } else {
        final request = CreateHearingRequest(
          title: _titleController.text.trim(),
          date: _dateController.text.trim(),
          startTime: _startTimeController.text.trim().isNotEmpty
              ? _startTimeController.text.trim()
              : null,
          endTime: _endTimeController.text.trim().isNotEmpty
              ? _endTimeController.text.trim()
              : null,
          courtName: _courtNameController.text.trim(),
          judgeName: _judgeNameController.text.trim().isNotEmpty
              ? _judgeNameController.text.trim()
              : null,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          caseId: _selectedCaseId!,
        );
        await ref
            .read(hearingsNotifierProvider.notifier)
            .createHearing(request);
        if (mounted) {
          AppAlerts.showSuccess(context, 'Hearing scheduled successfully.');
          context.pop();
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        AppAlerts.showError(context, e.message);
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(context, 'An unexpected error occurred: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final casesAsync = ref.watch(casesNotifierProvider);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C1322) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Hearing' : 'Schedule Hearing',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Banner matching 2.png
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0B192C).withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/bg.png',
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
                                  const Color(0xFF081426).withValues(alpha: 0.95),
                                  const Color(0xFF0D2240).withValues(alpha: 0.75),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.65, 1.0],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 20,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: const [
                                        Text(
                                          'Schedule a ',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            letterSpacing: -0.4,
                                          ),
                                        ),
                                        Text(
                                          'Hearing',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFFFBBF24),
                                            letterSpacing: -0.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Add hearing details and set reminders\nto stay on track.',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        height: 1.35,
                                        color: Colors.white.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1D4ED8),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1D4ED8)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.calendar_month_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Form Card matching 2.png
                LexCard(
                  borderRadius: 22,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header inside card
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E3A8A).withValues(alpha: 0.3)
                                  : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.description_outlined,
                              size: 20,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hearing Details',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Fill in the details for the hearing agenda.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Associated Case Selector (Searchable)
                      Text(
                        'Associated Case *',
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
                          if (cases.isEmpty) {
                            return const Text('No active cases available.');
                          }

                          final selectedCase = _selectedCaseId != null
                              ? cases.where((c) => c.id == _selectedCaseId).firstOrNull
                              : null;

                          return InkWell(
                            onTap: () async {
                              final pickedId = await showSearchablePicker<int>(
                                context: context,
                                title: 'Select Associated Case',
                                searchHint: 'Search by case number or title...',
                                selectedValue: _selectedCaseId,
                                items: cases.map((c) {
                                  return SearchablePickerItem<int>(
                                    value: c.id,
                                    label: c.caseNumber,
                                    subtitle: '${c.title} • ${c.courtName}',
                                    icon: Icons.folder_rounded,
                                    iconColor: const Color(0xFF2563EB),
                                  );
                                }).toList(),
                              );
                              if (pickedId != null) {
                                setState(() => _selectedCaseId = pickedId);
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
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.folder_outlined,
                                    size: 19,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      selectedCase != null
                                          ? '${selectedCase.caseNumber} - ${selectedCase.title}'
                                          : 'Select Associated Case',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: selectedCase != null
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: selectedCase != null
                                            ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                            : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 20,
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
                        error: (err, stack) =>
                            const Text('Failed to load cases list'),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      LexTextField(
                        controller: _titleController,
                        label: 'Hearing Purpose / Title *',
                        hintText: 'e.g. Preliminary Hearing, Arguments, etc.',
                        prefixIcon: Icons.gavel_outlined,
                        validator: (val) =>
                            Validators.required(val, 'Hearing title'),
                      ),
                      const SizedBox(height: 16),

                      // Date Picker
                      GestureDetector(
                        onTap: _pickDate,
                        child: AbsorbPointer(
                          child: LexTextField(
                            controller: _dateController,
                            label: 'Hearing Date *',
                            hintText: 'Select Date',
                            prefixIcon: Icons.calendar_month_outlined,
                            suffix: const Icon(Icons.calendar_today_rounded, size: 20),
                            validator: (val) =>
                                Validators.required(val, 'Hearing date'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Start & End Time Row matching 2.png
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickStartTime,
                              child: AbsorbPointer(
                                child: LexTextField(
                                  controller: _startTimeController,
                                  label: 'Start Time *',
                                  hintText: 'HH:MM AM',
                                  prefixIcon: Icons.access_time_rounded,
                                  suffix: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                                  validator: (val) =>
                                      Validators.required(val, 'Start time'),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickEndTime,
                              child: AbsorbPointer(
                                child: LexTextField(
                                  controller: _endTimeController,
                                  label: 'End Time *',
                                  hintText: 'HH:MM AM',
                                  prefixIcon: Icons.access_time_rounded,
                                  suffix: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                                  validator: (val) =>
                                      Validators.required(val, 'End time'),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Court Name
                      LexTextField(
                        controller: _courtNameController,
                        label: 'Court / Bench Name *',
                        hintText: 'e.g. Courtroom 4, High Court of Delhi',
                        prefixIcon: Icons.account_balance_outlined,
                        validator: (val) =>
                            Validators.required(val, 'Courtroom name'),
                      ),
                      const SizedBox(height: 16),

                      // Judge Name
                      LexTextField(
                        controller: _judgeNameController,
                        label: 'Judge / Presiding Officer (Optional)',
                        hintText: 'e.g. Hon. Justice R. Sharma',
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      LexTextField(
                        controller: _notesController,
                        label: 'Additional Notes (Optional)',
                        hintText: 'Add any important notes, agenda points, or preparations...',
                        prefixIcon: Icons.description_outlined,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button matching 2.png
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF132B4F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.calendar_month_outlined, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                isEdit
                                    ? 'Save Hearing Changes'
                                    : 'Schedule Hearing',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
