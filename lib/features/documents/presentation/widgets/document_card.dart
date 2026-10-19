import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../data/models/document_model.dart';

class DocumentCard extends StatelessWidget {
  final Document document;
  final VoidCallback onTap;
  final VoidCallback? onMorePressed;

  const DocumentCard({
    super.key,
    required this.document,
    required this.onTap,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = document.createdAt != null
        ? DateFormat('MMM d, yyyy').format(document.createdAt!.toLocal())
        : '';

    return LexCard(
      onTap: onTap,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // File Icon Container
          _buildFileIcon(context),
          const SizedBox(width: 14),

          // File Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? LexColors.textPrimaryDark
                        : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (document.caseTitle != null &&
                        document.caseTitle!.isNotEmpty) ...[
                      Icon(
                        Icons.folder_open_rounded,
                        size: 13,
                        color: isDark
                            ? LexColors.accentGold
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          document.caseTitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                    if (dateStr.isNotEmpty) ...[
                      if (document.caseTitle != null &&
                          document.caseTitle!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '•',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Action / Menu
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, size: 20),
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            onPressed: onMorePressed ?? onTap,
          ),
        ],
      ),
    );
  }

  Widget _buildFileIcon(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    IconData icon;
    Color iconColor;
    Color bgColor;

    if (document.isPdf) {
      icon = Icons.picture_as_pdf_rounded;
      iconColor = const Color(0xFFEF4444);
      bgColor = isDark ? iconColor.withAlpha(40) : const Color(0xFFFEF2F2);
    } else if (document.isImage) {
      icon = Icons.image_rounded;
      iconColor = const Color(0xFF10B981);
      bgColor = isDark ? iconColor.withAlpha(40) : const Color(0xFFECFDF5);
    } else if (document.isDoc) {
      icon = Icons.description_rounded;
      iconColor = const Color(0xFF2563EB);
      bgColor = isDark ? iconColor.withAlpha(40) : const Color(0xFFEFF6FF);
    } else {
      icon = Icons.insert_drive_file_rounded;
      iconColor = const Color(0xFF64748B);
      bgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withAlpha(60)),
      ),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }
}
