import 'package:flutter/material.dart';

import '../../../../shared/widgets/lex_card.dart';
import '../../data/models/client_document_model.dart';

class SharedDocumentCard extends StatelessWidget {
  final ClientDocumentItem document;
  final VoidCallback onPreview;
  final VoidCallback onDownload;
  final bool isDownloading;

  const SharedDocumentCard({
    super.key,
    required this.document,
    required this.onPreview,
    required this.onDownload,
    this.isDownloading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    IconData fileIcon = Icons.insert_drive_file_outlined;
    Color iconColor = const Color(0xFF64748B);

    if (document.isPdf) {
      fileIcon = Icons.picture_as_pdf_rounded;
      iconColor = const Color(0xFFEF4444);
    } else if (document.isImage) {
      fileIcon = Icons.image_rounded;
      iconColor = const Color(0xFF10B981);
    } else if (['doc', 'docx'].contains(document.fileExt.toLowerCase())) {
      fileIcon = Icons.description_rounded;
      iconColor = const Color(0xFF2563EB);
    }

    return LexCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(fileIcon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (document.caseTitle != null &&
                        document.caseTitle!.isNotEmpty)
                      Text(
                        document.caseTitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      '${document.formattedFileSize} • Shared by ${document.sharedByName}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (document.expiresAt != null && document.expiresAt!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withAlpha(20),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withAlpha(60),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 12,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Expires: ${document.expiresAt!.split("T").first}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Divider(height: 20),

          // Actions: Preview and Download
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('Preview'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isDownloading ? null : onDownload,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
