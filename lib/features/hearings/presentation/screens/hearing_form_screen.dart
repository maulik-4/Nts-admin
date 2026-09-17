import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/theme/lex_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/lex_button.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/lex_text_field.dart';
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
  String? _serverError;
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
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCaseId == null) {
      setState(() => _serverError = 'Please select a case for this hearing.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (isEdit) {
        final request = UpdateHearingRequest(
          title: _titleController.text,
          date: _dateController.text,
          startTime: _startTimeController.text.trim().isNotEmpty
              ? _startTimeController.text.trim()
              : null,
          endTime: _endTimeController.text.trim().isNotEmpty
              ? _endTimeController.text.trim()
              : null,
          courtName: _courtNameController.text,
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hearing updated successfully')),
          );
          context.pop();
        }
      } else {
        final request = CreateHearingRequest(
          title: _titleController.text,
          date: _dateController.text,
          startTime: _startTimeController.text.trim().isNotEmpty
              ? _startTimeController.text.trim()
              : null,
          endTime: _endTimeController.text.trim().isNotEmpty
              ? _endTimeController.text.trim()
              : null,
          courtName: _courtNameController.text,
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hearing scheduled successfully')),
          );
          context.pop();
        }
      }
    } on ApiException catch (e) {
      setState(() => _serverError = e.message);
    } catch (e) {
      setState(() => _serverError = 'An unexpected error occurred: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final casesAsync = ref.watch(casesNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Hearing' : 'Schedule Hearing')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_serverError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: LexColors.errorLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: LexColors.error.withAlpha(80)),
                    ),
                    child: Text(
                      _serverError!,
                      style: const TextStyle(
                        color: LexColors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],

                LexCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hearing Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? LexColors.textPrimaryDark
                              : LexColors.slatePrimary,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Associated Case Selector Dropdown
                      Text(
                        'Associated Case',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? LexColors.textPrimaryDark
                              : LexColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      casesAsync.when(
                        data: (cases) {
                          if (cases.isEmpty) {
                            return TextButton.icon(
                              onPressed: () =>
                                  context.push('/app/cases/create'),
                              icon: const Icon(Icons.add),
                              label: const Text('Add a case first'),
                            );
                          }

                          return DropdownButtonFormField<int>(
                            initialValue: _selectedCaseId,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? LexColors.surfaceDark
                                  : LexColors.canvasLight,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? LexColors.borderDark
                                      : LexColors.borderLight,
                                ),
                              ),
                            ),
                            hint: const Text('Select Associated Legal Case'),
                            items: cases.map((c) {
                              return DropdownMenuItem<int>(
                                value: c.id,
                                child: Text(
                                  '${c.caseNumber} - ${c.title}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedCaseId = val;
                                // Auto-fill court name if available
                                if (val != null) {
                                  final match = cases.where((c) => c.id == val);
                                  if (match.isNotEmpty &&
                                      _courtNameController.text.isEmpty) {
                                    _courtNameController.text =
                                        match.first.courtName;
                                  }
                                }
                              });
                            },
                            validator: (val) =>
                                val == null ? 'Case is required' : null,
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
                        label: 'Hearing Purpose / Title',
                        hintText:
                            'e.g. Bail Application Hearing or Evidence Stage',
                        prefixIcon: Icons.gavel_outlined,
                        validator: (val) =>
                            Validators.required(val, 'Hearing title'),
                      ),
                      const SizedBox(height: 16),

                      // Date picker
                      GestureDetector(
                        onTap: _pickDate,
                        child: AbsorbPointer(
                          child: LexTextField(
                            controller: _dateController,
                            label: 'Hearing Date',
                            hintText: 'YYYY-MM-DD',
                            prefixIcon: Icons.calendar_today_outlined,
                            validator: (val) =>
                                Validators.required(val, 'Hearing date'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Time Pickers Row
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickStartTime,
                              child: AbsorbPointer(
                                child: LexTextField(
                                  controller: _startTimeController,
                                  label: 'Start Time',
                                  hintText: 'HH:MM:SS',
                                  prefixIcon: Icons.schedule_outlined,
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
                                  label: 'End Time',
                                  hintText: 'HH:MM:SS',
                                  prefixIcon: Icons.timelapse_outlined,
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
                        label: 'Court Room / Venue',
                        hintText: 'e.g. Court Room 3, High Court of HP',
                        prefixIcon: Icons.account_balance_outlined,
                        validator: (val) =>
                            Validators.required(val, 'Court room / venue'),
                      ),
                      const SizedBox(height: 16),

                      // Judge Name
                      LexTextField(
                        controller: _judgeNameController,
                        label: 'Presiding Judge Name (Optional)',
                        hintText: 'e.g. Hon. Justice A. K. Sharma',
                        prefixIcon: Icons.person_pin_outlined,
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      LexTextField(
                        controller: _notesController,
                        label: 'Hearing Notes / Instructions (Optional)',
                        hintText:
                            'List required documents, orders, or arguments...',
                        prefixIcon: Icons.notes_outlined,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                LexButton(
                  label: isEdit ? 'Save Hearing Changes' : 'Schedule Hearing',
                  variant: LexButtonVariant.primary,
                  isLoading: _isLoading,
                  icon: isEdit
                      ? Icons.save_outlined
                      : Icons.event_available_outlined,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
