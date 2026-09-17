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
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../clients/presentation/providers/clients_notifier.dart';
import '../../data/models/case_model.dart';
import '../providers/cases_notifier.dart';

class CaseFormScreen extends ConsumerStatefulWidget {
  final int? caseId;
  final int? initialClientId;

  const CaseFormScreen({super.key, this.caseId, this.initialClientId});

  @override
  ConsumerState<CaseFormScreen> createState() => _CaseFormScreenState();
}

class _CaseFormScreenState extends ConsumerState<CaseFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _caseNumberController = TextEditingController();
  final _courtNameController = TextEditingController();
  final _nextHearingDateController = TextEditingController();

  String _caseType = 'Civil';
  String _status = 'open';
  int? _selectedClientId;
  bool _isLoading = false;
  String? _serverError;
  bool _initialized = false;

  bool get isEdit => widget.caseId != null;

  static const List<String> _caseTypes = [
    'Civil',
    'Criminal',
    'Corporate',
    'Family',
    'Constitutional',
    'Labor',
    'Taxation',
    'Property',
    'Appellate',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialClientId != null) {
      _selectedClientId = widget.initialClientId;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized && isEdit) {
      _loadExistingCase();
      _initialized = true;
    }
  }

  void _loadExistingCase() {
    final list = ref.read(casesNotifierProvider).valueOrNull;
    if (list != null) {
      final match = list.where((c) => c.id == widget.caseId);
      if (match.isNotEmpty) {
        final c = match.first;
        _titleController.text = c.title;
        _caseNumberController.text = c.caseNumber;
        _courtNameController.text = c.courtName;
        _caseType = _caseTypes.contains(c.caseType) ? c.caseType : 'Other';
        _status = c.status;
        _selectedClientId = c.client;
        if (c.nextHearingDate != null) {
          _nextHearingDateController.text = c.nextHearingDate!;
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _caseNumberController.dispose();
    _courtNameController.dispose();
    _nextHearingDateController.dispose();
    super.dispose();
  }

  Future<void> _pickNextHearingDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _nextHearingDateController.text = DateFormat('yyyy-MM-dd')
            .format(picked);
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate()) return;

    if (_selectedClientId == null) {
      setState(() => _serverError = 'Please select a client for this case.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authNotifierProvider).user;
      final firmId = user?.firmId ?? 15;

      if (isEdit) {
        final request = UpdateCaseRequest(
          title: _titleController.text,
          caseNumber: _caseNumberController.text,
          caseType: _caseType,
          courtName: _courtNameController.text,
          status: _status,
          client: _selectedClientId,
          nextHearingDate: _nextHearingDateController.text.trim().isNotEmpty
              ? _nextHearingDateController.text.trim()
              : null,
        );
        await ref
            .read(casesNotifierProvider.notifier)
            .updateCase(widget.caseId!, request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Case updated successfully')),
          );
          context.pop();
        }
      } else {
        final request = CreateCaseRequest(
          title: _titleController.text,
          caseNumber: _caseNumberController.text,
          caseType: _caseType,
          courtName: _courtNameController.text,
          status: _status,
          client: _selectedClientId!,
          firm: firmId,
          nextHearingDate: _nextHearingDateController.text.trim().isNotEmpty
              ? _nextHearingDateController.text.trim()
              : null,
        );
        await ref.read(casesNotifierProvider.notifier).createCase(request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Case created successfully')),
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
    final clientsAsync = ref.watch(clientsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Case' : 'New Legal Case')),
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
                        'Case Metadata',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? LexColors.textPrimaryDark
                              : LexColors.slatePrimary,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Title
                      LexTextField(
                        controller: _titleController,
                        label: 'Case Title / Heading',
                        hintText: 'e.g. State of HP vs Rajesh Kumar',
                        prefixIcon: Icons.description_outlined,
                        validator: (val) =>
                            Validators.required(val, 'Case title'),
                      ),
                      const SizedBox(height: 16),

                      // Case Number
                      LexTextField(
                        controller: _caseNumberController,
                        label: 'Case Number / Docket ID',
                        hintText: 'e.g. CWP-2026-4401',
                        prefixIcon: Icons.numbers_outlined,
                        validator: (val) =>
                            Validators.required(val, 'Case number'),
                      ),
                      const SizedBox(height: 16),

                      // Client Selector Dropdown
                      Text(
                        'Client',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? LexColors.textPrimaryDark
                              : LexColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      clientsAsync.when(
                        data: (clients) {
                          if (clients.isEmpty) {
                            return TextButton.icon(
                              onPressed: () =>
                                  context.push('/app/clients/create'),
                              icon: const Icon(Icons.add),
                              label: const Text('Add a client first'),
                            );
                          }

                          return DropdownButtonFormField<int>(
                            initialValue: _selectedClientId,
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
                            hint: const Text('Select Associated Client'),
                            items: clients.map((c) {
                              return DropdownMenuItem<int>(
                                value: c.id,
                                child: Text('${c.name} (${c.phone})'),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedClientId = val),
                            validator: (val) =>
                                val == null ? 'Client is required' : null,
                          );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (err, stack) =>
                            const Text('Failed to load clients list'),
                      ),
                      const SizedBox(height: 16),

                      // Case Type Dropdown
                      Text(
                        'Case Type',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? LexColors.textPrimaryDark
                              : LexColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _caseType,
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
                        items: _caseTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _caseType = val);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Court Name
                      LexTextField(
                        controller: _courtNameController,
                        label: 'Court Name',
                        hintText: 'e.g. High Court of Himachal Pradesh',
                        prefixIcon: Icons.account_balance_outlined,
                        validator: (val) =>
                            Validators.required(val, 'Court name'),
                      ),
                      const SizedBox(height: 16),

                      // Next Hearing Date (optional)
                      GestureDetector(
                        onTap: _pickNextHearingDate,
                        child: AbsorbPointer(
                          child: LexTextField(
                            controller: _nextHearingDateController,
                            label: 'Next Hearing Date (Optional)',
                            hintText: 'YYYY-MM-DD',
                            prefixIcon: Icons.calendar_today_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Status Dropdown
                      Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? LexColors.textPrimaryDark
                              : LexColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _status,
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
                        items: const [
                          DropdownMenuItem(value: 'open', child: Text('Open')),
                          DropdownMenuItem(
                            value: 'closed',
                            child: Text('Closed'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _status = val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                LexButton(
                  label: isEdit ? 'Save Case Changes' : 'Create Case',
                  variant: LexButtonVariant.primary,
                  isLoading: _isLoading,
                  icon: isEdit ? Icons.save_outlined : Icons.add_circle_outline,
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
