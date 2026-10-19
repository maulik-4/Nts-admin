import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/client_portal_theme.dart';
import '../../data/models/client_dashboard_model.dart';
import '../../data/models/client_document_model.dart';
import 'client_status_badge.dart';

class ClientCaseDetailSheet extends StatelessWidget {
  final ClientCaseItem caseItem;
  final List<HearingItem> relatedHearings;
  final List<LegalPersonnel> assignedCounsel;
  final List<ClientDocumentItem> relatedDocuments;

  const ClientCaseDetailSheet({
    super.key,
    required this.caseItem,
    required this.relatedHearings,
    required this.assignedCounsel,
    required this.relatedDocuments,
  });

  static Future<void> show(
    BuildContext context, {
    required ClientCaseItem caseItem,
    required List<HearingItem> relatedHearings,
    required List<LegalPersonnel> assignedCounsel,
    required List<ClientDocumentItem> relatedDocuments,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClientCaseDetailSheet(
        caseItem: caseItem,
        relatedHearings: relatedHearings,
        assignedCounsel: assignedCounsel,
        relatedDocuments: relatedDocuments,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);

    return Container(
      constraints: BoxConstraints(maxHeight: size.height * 0.88),
      decoration: BoxDecoration(
        color: isDark
            ? ClientPortalColors.darkPageBackground
            : ClientPortalColors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: isDark
                ? ClientPortalColors.darkBorder
                : ClientPortalColors.border,
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Sheet Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        caseItem.caseNumber.isNotEmpty
                            ? caseItem.caseNumber
                            : 'Case #${caseItem.id}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: ClientPortalColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        caseItem.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: isDark
                              ? ClientPortalColors.darkPrimaryText
                              : ClientPortalColors.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                ),
                ClientStatusBadge(label: caseItem.status),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable Sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 1. Overview Section
                _SectionTitle(title: 'Case Overview', isDark: isDark),
                const SizedBox(height: 10),
                _InfoCard(
                  isDark: isDark,
                  children: [
                    _DetailRow(
                      label: 'Court',
                      value: caseItem.courtName.isNotEmpty
                          ? caseItem.courtName
                          : 'Not specified',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _DetailRow(
                      label: 'Matter Type',
                      value: caseItem.caseType.isNotEmpty
                          ? caseItem.caseType
                          : 'General Litigation',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _DetailRow(
                      label: 'Assigned Counsel',
                      value: caseItem.lawyerName.isNotEmpty
                          ? caseItem.lawyerName
                          : 'Firm Counsel',
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // 2. Related Hearings Section
                _SectionTitle(
                  title: 'Hearings (${relatedHearings.length})',
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                if (relatedHearings.isEmpty)
                  _EmptySectionNotice(
                    message: 'No hearings scheduled for this case.',
                    isDark: isDark,
                  )
                else
                  ...relatedHearings.map(
                    (h) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? ClientPortalColors.darkCardBackground
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? ClientPortalColors.darkBorder
                              : ClientPortalColors.border,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                h.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? ClientPortalColors.darkPrimaryText
                                      : ClientPortalColors.primaryText,
                                ),
                              ),
                              const Spacer(),
                              ClientStatusBadge(
                                label: h.isUpcoming ? 'Upcoming' : 'Past',
                                type: h.isUpcoming
                                    ? ClientStatusType.upcoming
                                    : ClientStatusType.closed,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${h.date}${h.startTime != null ? ' • ${h.startTime}' : ''} | ${h.courtName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? ClientPortalColors.darkSecondaryText
                                  : ClientPortalColors.secondaryText,
                            ),
                          ),
                          if (h.notes.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              h.notes,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontStyle: FontStyle.italic,
                                color: isDark
                                    ? ClientPortalColors.darkSecondaryText
                                    : ClientPortalColors.secondaryText,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 22),

                // 3. Related Documents Section
                _SectionTitle(
                  title: 'Shared Documents (${relatedDocuments.length})',
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                if (relatedDocuments.isEmpty)
                  _EmptySectionNotice(
                    message: 'No shared documents for this case yet.',
                    isDark: isDark,
                  )
                else
                  ...relatedDocuments.map(
                    (doc) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? ClientPortalColors.darkCardBackground
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? ClientPortalColors.darkBorder
                              : ClientPortalColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            doc.isPdf
                                ? Icons.picture_as_pdf_rounded
                                : Icons.description_outlined,
                            size: 20,
                            color: doc.isPdf
                                ? const Color(0xFFEF4444)
                                : ClientPortalColors.primaryBlue,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? ClientPortalColors.darkPrimaryText
                                        : ClientPortalColors.primaryText,
                                  ),
                                ),
                                Text(
                                  doc.formattedFileSize,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? ClientPortalColors.darkSecondaryText
                                        : ClientPortalColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.visibility_outlined,
                              size: 18,
                            ),
                            tooltip: 'Preview',
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.push(
                                '/client/documents/${doc.id}',
                                extra: {
                                  'title': doc.title,
                                  'fileExt': doc.fileExt,
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
        color: isDark
            ? ClientPortalColors.darkPrimaryText
            : ClientPortalColors.primaryNavy,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;

  const _InfoCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ClientPortalColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? ClientPortalColors.darkBorder
              : ClientPortalColors.border,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? ClientPortalColors.darkSecondaryText
                  : ClientPortalColors.secondaryText,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? ClientPortalColors.darkPrimaryText
                  : ClientPortalColors.primaryText,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptySectionNotice extends StatelessWidget {
  final String message;
  final bool isDark;

  const _EmptySectionNotice({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? ClientPortalColors.darkCardBackground
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 12,
          fontStyle: FontStyle.italic,
          color: isDark
              ? ClientPortalColors.darkSecondaryText
              : ClientPortalColors.secondaryText,
        ),
      ),
    );
  }
}
