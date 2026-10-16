import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../core/utils/validators.dart';
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
      if (mounted) AppAlerts.showError(context, e.message);
    } catch (e) {
      if (mounted) AppAlerts.showError(context, 'An unexpected error occurred: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final casesAsync = ref.watch(casesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Hearing' : 'Schedule Hearing',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
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
                LexCard(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          isEdit ? 'UPDATE HEARING' : 'HEARING AGENDA SPECIFICATION',
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
                        'Hearing Details',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Associated Case Dropdown
                      Text(
                        'Associated Case *',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 6),
                      casesAsync.when(
                        data: (cases) {
                          if (cases.isEmpty) {
                            return const Text('No active cases available.');
                          }

                          return DropdownButtonFormField<int>(
                            initialValue: _selectedCaseId,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              prefixIcon: const Icon(Icons.folder_open_rounded, size: 19),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            hint: const Text('Select Associated Case', style: TextStyle(fontSize: 13)),
                            items: cases.map((c) {
                              return DropdownMenuItem<int>(
                                value: c.id,
                                child: Text(
                                  '${c.caseNumber} - ${c.title}',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedCaseId = val),
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
                        label: 'Hearing Purpose / Title *',
                        hintText: 'e.g. Preliminary Hearing, Arguments',
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
                            hintText: 'YYYY-MM-DD',
                            prefixIcon: Icons.calendar_today_outlined,
                            validator: (val) =>
                                Validators.required(val, 'Hearing date'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Start & End Time Row
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
                                  prefixIcon: Icons.access_time_rounded,
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
                                  prefixIcon: Icons.access_time_rounded,
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
                        prefixIcon: Icons.person_pin_outlined,
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      LexTextField(
                        controller: _notesController,
                        label: 'Hearing Notes / Instructions (Optional)',
                        hintText: 'Add preparation steps, client instructions, or documents to bring...',
                        prefixIcon: Icons.notes_outlined,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
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
                            isEdit ? 'Save Hearing Changes' : 'Schedule Hearing',
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
    );
  }
}
