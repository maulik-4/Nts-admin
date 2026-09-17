import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../data/models/document_model.dart';

class DocumentCard extends StatelessWidget {
  final Document document;
  final VoidCallback onTap;

  const DocumentCard({super.key, required this.document, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = document.createdAt != null
        ? DateFormat('MMM d, yyyy').format(document.createdAt!.toLocal())
        : '';

    return LexCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // File Icon Avatar
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? LexColors.textPrimaryDark
                        : LexColors.slatePrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (document.caseTitle != null &&
                        document.caseTitle!.isNotEmpty) ...[
                      Icon(
                        Icons.folder_outlined,
                        size: 13,
                        color: isDark
                            ? LexColors.accentGold
                            : LexColors.slateLight,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          document.caseTitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? LexColors.textSecondaryDark
                                : LexColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ],
                    if (dateStr.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        dateStr,
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
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            size: 20,
            color: isDark
                ? LexColors.textSecondaryDark
                : LexColors.textSecondaryLight,
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
      icon = Icons.picture_as_pdf;
      iconColor = isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
      bgColor = isDark
          ? iconColor.withValues(alpha: 0.18)
          : const Color(0xFFFEF2F2);
    } else if (document.isImage) {
      icon = Icons.image_outlined;
      iconColor = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
      bgColor = isDark
          ? iconColor.withValues(alpha: 0.18)
          : const Color(0xFFECFDF5);
    } else if (document.isDoc) {
      icon = Icons.description_outlined;
      iconColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
      bgColor = isDark
          ? iconColor.withValues(alpha: 0.18)
          : const Color(0xFFEFF6FF);
    } else {
      icon = Icons.insert_drive_file_outlined;
      iconColor = isDark ? LexColors.textSecondaryDark : LexColors.slateLight;
      bgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: iconColor.withAlpha(40)),
      ),
      child: Icon(icon, color: iconColor, size: 24),
    );
  }
}
