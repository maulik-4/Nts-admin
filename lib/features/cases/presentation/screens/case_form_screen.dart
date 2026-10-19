import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../core/utils/validators.dart';
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
    if (!_formKey.currentState!.validate()) return;

    if (_selectedClientId == null) {
      AppAlerts.showError(context, 'Please select a client for this case.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authNotifierProvider).user;
      final firmId = user?.firmId ?? 15;

      if (isEdit) {
        final request = UpdateCaseRequest(
          title: _titleController.text.trim(),
          caseNumber: _caseNumberController.text.trim(),
          caseType: _caseType,
          courtName: _courtNameController.text.trim(),
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
          AppAlerts.showSuccess(context, 'Case updated successfully.');
          context.pop();
        }
      } else {
        final request = CreateCaseRequest(
          title: _titleController.text.trim(),
          caseNumber: _caseNumberController.text.trim(),
          caseType: _caseType,
          courtName: _courtNameController.text.trim(),
          status: _status,
          client: _selectedClientId!,
          firm: firmId,
          nextHearingDate: _nextHearingDateController.text.trim().isNotEmpty
              ? _nextHearingDateController.text.trim()
              : null,
        );
        await ref.read(casesNotifierProvider.notifier).createCase(request);
        if (mounted) {
          AppAlerts.showSuccess(context, 'Case created successfully.');
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
    final clientsAsync = ref.watch(clientsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Case' : 'New Legal Case',
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
                          isEdit
                              ? 'CASE METADATA UPDATE'
                              : 'CASE SPECIFICATION',
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
                        'Case Metadata',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Title
                      LexTextField(
                        controller: _titleController,
                        label: 'Case Title / Heading *',
                        hintText: 'e.g. State of HP vs Rajesh Kumar',
                        prefixIcon: Icons.description_outlined,
                        validator: (val) =>
                            Validators.required(val, 'Case title'),
                      ),
                      const SizedBox(height: 16),

                      // Case Number
                      LexTextField(
                        controller: _caseNumberController,
                        label: 'Case Number / Docket ID *',
                        hintText: 'e.g. CWP-2026-4401',
                        prefixIcon: Icons.numbers_outlined,
                        validator: (val) =>
                            Validators.required(val, 'Case number'),
                      ),
                      const SizedBox(height: 16),

                      // Client Selector Dropdown
                      Text(
                        'Associated Client *',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 6),
                      clientsAsync.when(
                        data: (clients) {
                          if (clients.isEmpty) {
                            return TextButton.icon(
                              onPressed: () =>
                                  context.push('/app/clients/create'),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Add a client first'),
                            );
                          }

                          return DropdownButtonFormField<int>(
                            initialValue: _selectedClientId,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              prefixIcon: const Icon(
                                Icons.person_outline_rounded,
                                size: 19,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                            ),
                            hint: const Text(
                              'Select Associated Client',
                              style: TextStyle(fontSize: 13),
                            ),
                            items: clients.map((c) {
                              return DropdownMenuItem<int>(
                                value: c.id,
                                child: Text(
                                  '${c.name} (${c.phone})',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
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
                        'Case Category',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _caseType,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          prefixIcon: const Icon(
                            Icons.category_outlined,
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
                        items: _caseTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              type,
                              style: const TextStyle(fontSize: 13),
                            ),
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
                        label: 'Court Name *',
                        hintText: 'e.g. High Court of Delhi',
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
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _status,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'open',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: Color(0xFF10B981),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Open / Active Case',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'closed',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: Color(0xFF94A3B8),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Closed / Resolved',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
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
                            isEdit ? 'Save Case Changes' : 'Create Case',
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
