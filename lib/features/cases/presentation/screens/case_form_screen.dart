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
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../clients/presentation/providers/clients_notifier.dart';
import '../../../dashboard/presentation/providers/dashboard_notifier.dart';
import '../../data/models/case_model.dart';
import '../providers/cases_notifier.dart';
import 'case_detail_screen.dart';

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
        ref.invalidate(caseDetailProvider(widget.caseId!));
        ref.invalidate(dashboardNotifierProvider);
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
        ref.invalidate(dashboardNotifierProvider);
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
                              isEdit ? 'Edit Case' : 'New Legal Case',
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
                                  const Icon(Icons.balance_rounded,
                                      size: 13, color: Color(0xFF93C5FD)),
                                  const SizedBox(width: 6),
                                  Text(
                                    isEdit
                                        ? 'CASE MODIFICATION'
                                        : 'LITIGATION RECORD',
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
                              isEdit
                                  ? 'Update Case File'
                                  : 'Register New Legal Case',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Establish legal matter profile, assign client representation, and configure court tracking.',
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

                      // Client Selector (Searchable)
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

                          final selectedClient = _selectedClientId != null
                              ? clients.where((c) => c.id == _selectedClientId).firstOrNull
                              : null;

                          return InkWell(
                            onTap: () async {
                              final pickedId = await showSearchablePicker<int>(
                                context: context,
                                title: 'Select Associated Client',
                                searchHint: 'Search by client name or phone...',
                                selectedValue: _selectedClientId,
                                items: clients.map((c) {
                                  return SearchablePickerItem<int>(
                                    value: c.id,
                                    label: c.name,
                                    subtitle: c.phone.isNotEmpty ? c.phone : c.email,
                                    icon: Icons.person_rounded,
                                    iconColor: const Color(0xFF2563EB),
                                  );
                                }).toList(),
                              );
                              if (pickedId != null) {
                                setState(() => _selectedClientId = pickedId);
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
                                    Icons.person_outline_rounded,
                                    size: 19,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      selectedClient != null
                                          ? '${selectedClient.name} (${selectedClient.phone})'
                                          : 'Select Associated Client',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: selectedClient != null
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: selectedClient != null
                                            ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                            : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF0B1426) : const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.search_rounded,
                                      size: 16,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

                      // Status Selector (Optimized Modern Pill UI)
                      Text(
                        'Case Status *',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _status = 'open'),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _status == 'open'
                                      ? (isDark
                                          ? const Color(0xFF064E3B).withValues(alpha: 0.4)
                                          : const Color(0xFFECFDF5))
                                      : (isDark
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFFF8FAFC)),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _status == 'open'
                                        ? const Color(0xFF10B981)
                                        : (isDark
                                            ? const Color(0xFF334155)
                                            : const Color(0xFFCBD5E1)),
                                    width: _status == 'open' ? 1.8 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _status == 'open'
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'OPEN',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                        color: _status == 'open'
                                            ? const Color(0xFF059669)
                                            : (isDark
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF64748B)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _status = 'closed'),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _status == 'closed'
                                      ? (isDark
                                          ? const Color(0xFF334155).withValues(alpha: 0.5)
                                          : const Color(0xFFF1F5F9))
                                      : (isDark
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFFF8FAFC)),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _status == 'closed'
                                        ? const Color(0xFF64748B)
                                        : (isDark
                                            ? const Color(0xFF334155)
                                            : const Color(0xFFCBD5E1)),
                                    width: _status == 'closed' ? 1.8 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _status == 'closed'
                                            ? const Color(0xFF64748B)
                                            : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'CLOSED',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                        color: _status == 'closed'
                                            ? (isDark ? Colors.white : const Color(0xFF1E293B))
                                            : (isDark
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF64748B)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
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
                                isEdit
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.add_circle_outline_rounded,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isEdit
                                    ? 'Save Case Changes'
                                    : 'Create Case Record',
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
