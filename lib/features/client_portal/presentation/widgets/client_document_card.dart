import 'package:flutter/material.dart';

import '../theme/client_portal_theme.dart';
import '../../data/models/client_document_model.dart';

class ClientDocumentCard extends StatelessWidget {
  final ClientDocumentItem document;
  final VoidCallback onPreview;
  final VoidCallback onDownload;
  final bool isDownloading;

  const ClientDocumentCard({
    super.key,
    required this.document,
    required this.onPreview,
    required this.onDownload,
    this.isDownloading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    IconData fileIcon = Icons.description_outlined;
    Color iconColor = ClientPortalColors.primaryBlue;
    Color iconBg = const Color(0xFFEFF6FF);

    if (document.isPdf) {
      fileIcon = Icons.picture_as_pdf_rounded;
      iconColor = const Color(0xFFEF4444);
      iconBg = const Color(0xFFFEE2E2);
    } else if (document.isImage) {
      fileIcon = Icons.image_rounded;
      iconColor = ClientPortalColors.success;
      iconBg = const Color(0xFFE8F5E9);
    } else if (['doc', 'docx'].contains(document.fileExt.toLowerCase())) {
      fileIcon = Icons.article_rounded;
      iconColor = ClientPortalColors.primaryBlue;
      iconBg = const Color(0xFFEFF6FF);
    }

    final formattedDate =
        document.sharedAt != null && document.sharedAt!.isNotEmpty
        ? document.sharedAt!.split('T').first
        : (document.createdAt.isNotEmpty
              ? document.createdAt.split('T').first
              : '');

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? ClientPortalColors.darkCardBackground
            : ClientPortalColors.cardBackground,
        borderRadius: BorderRadius.circular(ClientPortalDimensions.cardRadius),
        border: Border.all(
          color: isDark
              ? ClientPortalColors.darkBorder
              : ClientPortalColors.border,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A)
                .withValues(alpha: isDark ? 0.3 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Icon, Title, and Overflow Menu
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? iconColor.withValues(alpha: 0.18) : iconBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: iconColor.withValues(alpha: isDark ? 0.35 : 0.2),
                    ),
                  ),
                  child: Icon(fileIcon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          color: isDark
                              ? ClientPortalColors.darkPrimaryText
                              : ClientPortalColors.primaryText,
                        ),
                      ),
                      if (document.caseTitle != null &&
                          document.caseTitle!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          document.caseTitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ClientPortalColors.primaryBlue,
                          ),
                        ),
                      ],
                      const SizedBox(height: 3),
                      Text(
                        '${document.formattedFileSize}${formattedDate.isNotEmpty ? ' • $formattedDate' : ''}${document.sharedByName.isNotEmpty ? ' • Shared by ${document.sharedByName}' : ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: isDark
                        ? ClientPortalColors.darkSecondaryText
                        : ClientPortalColors.secondaryText,
                  ),
                  tooltip: 'Document Actions',
                  onSelected: (value) {
                    if (value == 'preview') onPreview();
                    if (value == 'download') onDownload();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'preview',
                      child: Row(
                        children: [
                          Icon(Icons.visibility_outlined, size: 18),
                          SizedBox(width: 10),
                          Text('Preview Document'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'download',
                      child: Row(
                        children: [
                          Icon(Icons.download_rounded, size: 18),
                          SizedBox(width: 10),
                          Text('Download to Device'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Action Buttons: Preview & Download
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('Preview'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark
                          ? ClientPortalColors.darkPrimaryText
                          : ClientPortalColors.primaryNavy,
                      side: BorderSide(
                        color: isDark
                            ? ClientPortalColors.darkBorder
                            : ClientPortalColors.border,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ClientPortalDimensions.buttonRadius,
                        ),
                      ),
                    ),
                    onPressed: onPreview,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    icon: isDownloading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.download_rounded, size: 16),
                    label: Text(isDownloading ? 'Saving...' : 'Download'),
                    style: FilledButton.styleFrom(
                      backgroundColor: ClientPortalColors.primaryNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ClientPortalDimensions.buttonRadius,
                        ),
                      ),
                    ),
                    onPressed: isDownloading ? null : onDownload,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
