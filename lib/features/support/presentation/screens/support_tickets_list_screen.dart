import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/lex_text_field.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../data/models/support_ticket.dart';
import '../providers/support_notifier.dart';

class SupportTicketsListScreen extends ConsumerWidget {
  const SupportTicketsListScreen({super.key});

  void _showCreateTicketModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _CreateTicketSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(supportNotifierProvider);
    final statsAsync = ref.watch(supportStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? LexColors.canvasDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Help & Support'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Tickets',
            onPressed: () {
              ref.read(supportNotifierProvider.notifier).loadTickets();
              ref.invalidate(supportStatsProvider);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTicketModal(context, ref),
        backgroundColor: LexColors.slatePrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          'New Ticket',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          // Stats Row
          statsAsync.maybeWhen(
            data: (stats) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? LexColors.surfaceDark : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  _buildStatItem(
                    'Total',
                    stats.total.toString(),
                    LexColors.slatePrimary,
                  ),
                  _buildStatItem(
                    'Open',
                    stats.open.toString(),
                    LexColors.warning,
                  ),
                  _buildStatItem(
                    'In Progress',
                    stats.inProgress.toString(),
                    Colors.blue,
                  ),
                  _buildStatItem(
                    'Resolved',
                    stats.resolved.toString(),
                    LexColors.success,
                  ),
                ],
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),

          // Tickets List
          Expanded(
            child: ticketsAsync.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (ctx, idx) => ShimmerBox(
                  width: double.infinity,
                  height: 110,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: LexColors.error,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Error loading tickets: $err',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(supportNotifierProvider.notifier)
                            .loadTickets(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: LexColors.slatePrimary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (tickets) {
                if (tickets.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? LexColors.surfaceDark
                                  : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.support_agent_rounded,
                              size: 54,
                              color: isDark
                                  ? LexColors.textSecondaryDark
                                  : LexColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'No support tickets found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Need technical, billing, or legal platform assistance?\nTap "New Ticket" to contact support.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark
                                  ? LexColors.textSecondaryDark
                                  : LexColors.textSecondaryLight,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: tickets.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (ctx, idx) =>
                      _buildTicketCard(context, tickets[idx], isDark),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: LexColors.textSecondaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(
    BuildContext context,
    SupportTicket ticket,
    bool isDark,
  ) {
    return InkWell(
      onTap: () => context.push('/app/more/support/${ticket.id}'),
      borderRadius: BorderRadius.circular(16),
      child: LexCard(
        borderRadius: 16,
        leftAccentColor: ticket.statusColor,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ticket.ticketNumber,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : LexColors.slatePrimary,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: ticket.statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ticket.statusColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ticket.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: ticket.statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: ticket.priorityColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ticket.priority.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: ticket.priorityColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              ticket.subject,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              ticket.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: isDark
                    ? LexColors.textSecondaryDark
                    : LexColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.label_outline_rounded,
                  size: 13,
                  color: isDark ? Colors.white54 : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    ticket.category.toUpperCase(),
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
                if (ticket.createdAt != null) ...[
                  Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: isDark ? Colors.white54 : Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat.yMMMd().format(ticket.createdAt!),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? LexColors.textSecondaryDark
                          : LexColors.textSecondaryLight,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateTicketSheet extends ConsumerStatefulWidget {
  const _CreateTicketSheet();

  @override
  ConsumerState<_CreateTicketSheet> createState() => _CreateTicketSheetState();
}

class _CreateTicketSheetState extends ConsumerState<_CreateTicketSheet> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = 'technical';
  String _priority = 'normal';
  bool _isLoading = false;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      final ticket = await ref
          .read(supportNotifierProvider.notifier)
          .createTicket(
            subject: _subjectCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            category: _category,
            priority: _priority,
          );
      ref.invalidate(supportStatsProvider);
      if (mounted) {
        Navigator.of(context).pop();
        AppAlerts.showSuccess(
          context,
          'Support ticket #${ticket.ticketNumber} created successfully!',
        );
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(context, 'Failed to create ticket: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? LexColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: LexColors.accentGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: LexColors.accentGold,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CLIENT ASSISTANCE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: LexColors.accentGold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Open Support Ticket',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),

              LexTextField(
                controller: _subjectCtrl,
                label: 'Subject *',
                hintText: 'Summary of the issue',
                prefixIcon: Icons.title_rounded,
                validator: (v) =>
                    v?.trim().isEmpty == true ? 'Subject required' : null,
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category_outlined),
                  filled: true,
                  fillColor: isDark
                      ? LexColors.cardBackgroundDark
                      : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'technical',
                    child: Text('Technical Issue'),
                  ),
                  DropdownMenuItem(
                    value: 'billing',
                    child: Text('Billing & Invoicing'),
                  ),
                  DropdownMenuItem(
                    value: 'feature',
                    child: Text('Feature Request'),
                  ),
                  DropdownMenuItem(
                    value: 'account',
                    child: Text('Account Access'),
                  ),
                  DropdownMenuItem(value: 'legal', child: Text('Legal Query')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _category = v);
                },
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                initialValue: _priority,
                decoration: InputDecoration(
                  labelText: 'Priority Level',
                  prefixIcon: const Icon(Icons.flag_outlined),
                  filled: true,
                  fillColor: isDark
                      ? LexColors.cardBackgroundDark
                      : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low Priority')),
                  DropdownMenuItem(
                    value: 'normal',
                    child: Text('Normal Priority'),
                  ),
                  DropdownMenuItem(value: 'high', child: Text('High Priority')),
                  DropdownMenuItem(
                    value: 'critical',
                    child: Text('Critical Priority'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _priority = v);
                },
              ),
              const SizedBox(height: 14),

              LexTextField(
                controller: _descCtrl,
                label: 'Description *',
                hintText: 'Detailed explanation of the problem or request',
                maxLines: 4,
                prefixIcon: Icons.description_outlined,
                validator: (v) =>
                    v?.trim().isEmpty == true ? 'Description required' : null,
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LexColors.slatePrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Submit Ticket',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
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
    );
  }
}
