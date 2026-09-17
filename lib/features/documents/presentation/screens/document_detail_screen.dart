import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/lex_button.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../data/models/document_model.dart';
import '../../data/repositories/documents_repository.dart';
import '../providers/documents_notifier.dart';

class DocumentDetailScreen extends ConsumerStatefulWidget {
  final int documentId;

  const DocumentDetailScreen({super.key, required this.documentId});

  @override
  ConsumerState<DocumentDetailScreen> createState() =>
      _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends ConsumerState<DocumentDetailScreen> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _downloadedFilePath;

  Future<void> _handleDownload(Document doc) async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/${doc.fileName}';

      final repo = ref.read(documentsRepositoryProvider);
      await repo.downloadDocument(
        id: doc.id,
        savePath: savePath,
        onProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      final file = File(savePath);
      final exists = await file.exists();
      final sizeBytes = exists ? await file.length() : 0;

      if (mounted) {
        setState(() => _downloadedFilePath = savePath);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Downloaded ${doc.fileName} ($sizeBytes bytes) to: $savePath',
            ),
            backgroundColor: LexColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download document: $e'),
            backgroundColor: LexColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text(
          'Are you sure you want to permanently delete this document?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: LexColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await ref
          .read(documentsNotifierProvider.notifier)
          .deleteDocument(widget.documentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document deleted successfully.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete document: $e'),
            backgroundColor: LexColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final docAsync = ref.watch(documentDetailProvider(widget.documentId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: LexColors.error),
            tooltip: 'Delete Document',
            onPressed: _handleDelete,
          ),
        ],
      ),
      body: docAsync.when(
        data: (doc) {
          final dateFormat = DateFormat('MMM d, yyyy, h:mm a');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top File Overview Card
                LexCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildHeaderIcon(doc),
                      const SizedBox(height: 16),
                      Text(
                        doc.fileName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? LexColors.textPrimaryDark
                              : LexColors.slatePrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          doc.fileExtension.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? LexColors.accentGold
                                : LexColors.slatePrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // File Metadata Card
                LexCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Metadata & Relations',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? LexColors.textPrimaryDark
                              : LexColors.slatePrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        context,
                        'Associated Case',
                        doc.caseTitle ?? '#${doc.caseId}',
                        Icons.folder_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        context,
                        'Document ID',
                        '#${doc.id}',
                        Icons.tag_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        context,
                        'Firm ID',
                        '#${doc.firm}',
                        Icons.business_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        context,
                        'Uploaded At',
                        doc.createdAt != null
                            ? dateFormat.format(doc.createdAt!.toLocal())
                            : 'Unknown',
                        Icons.access_time_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Download Progress (if actively downloading)
                if (_isDownloading) ...[
                  LinearProgressIndicator(
                    value: _downloadProgress > 0 ? _downloadProgress : null,
                    color: isDark
                        ? LexColors.accentGold
                        : LexColors.slatePrimary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Downloading document (${(_downloadProgress * 100).toInt()}%)...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? LexColors.textSecondaryDark
                          : LexColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Download Action Button
                LexButton(
                  label: _downloadedFilePath != null
                      ? 'Download Again'
                      : 'Download Document',
                  icon: Icons.download_rounded,
                  isLoading: _isDownloading,
                  onPressed: _isDownloading ? null : () => _handleDownload(doc),
                ),

                if (_downloadedFilePath != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Saved at: $_downloadedFilePath',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      color: LexColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SkeletonLoader(height: 160),
              SizedBox(height: 16),
              SkeletonLoader(height: 140),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: ErrorStateWidget(
            message: 'Unable to load document details: $err',
            onRetry: () =>
                ref.invalidate(documentDetailProvider(widget.documentId)),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(Document doc) {
    IconData icon;
    Color iconColor;
    Color bgColor;

    if (doc.isPdf) {
      icon = Icons.picture_as_pdf;
      iconColor = const Color(0xFFDC2626);
      bgColor = const Color(0xFFFEF2F2);
    } else if (doc.isImage) {
      icon = Icons.image_outlined;
      iconColor = const Color(0xFF059669);
      bgColor = const Color(0xFFECFDF5);
    } else if (doc.isDoc) {
      icon = Icons.description_outlined;
      iconColor = const Color(0xFF2563EB);
      bgColor = const Color(0xFFEFF6FF);
    } else {
      icon = Icons.insert_drive_file_outlined;
      iconColor = LexColors.slateLight;
      bgColor = const Color(0xFFF1F5F9);
    }

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: iconColor.withAlpha(50)),
      ),
      child: Icon(icon, color: iconColor, size: 36),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark
              ? LexColors.textSecondaryDark
              : LexColors.textSecondaryLight,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark
                ? LexColors.textSecondaryDark
                : LexColors.textSecondaryLight,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark
                ? LexColors.textPrimaryDark
                : LexColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
