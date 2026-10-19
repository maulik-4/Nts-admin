import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../providers/client_portal_notifier.dart';

class ClientDocumentPreviewScreen extends ConsumerStatefulWidget {
  final int documentId;
  final String title;
  final String? fileExt;

  const ClientDocumentPreviewScreen({
    super.key,
    required this.documentId,
    required this.title,
    this.fileExt,
  });

  @override
  ConsumerState<ClientDocumentPreviewScreen> createState() =>
      _ClientDocumentPreviewScreenState();
}

class _ClientDocumentPreviewScreenState
    extends ConsumerState<ClientDocumentPreviewScreen> {
  bool _isSaving = false;

  Future<void> _saveToDevice(List<int> bytes) async {
    setState(() => _isSaving = true);
    try {
      final ext = widget.fileExt ?? 'pdf';
      final dir = await getApplicationDocumentsDirectory();
      final sanitizedTitle = widget.title
          .replaceAll(RegExp(r'[^\w\s\.-]'), '_')
          .trim();
      final fileName = '$sanitizedTitle.$ext';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Document saved: $fileName'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save file: $e'),
          backgroundColor: LexColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytesAsync = ref.watch(
      clientDocumentBytesProvider(widget.documentId),
    );
    final isPdf = (widget.fileExt?.toLowerCase() ?? 'pdf') == 'pdf';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          bytesAsync.when(
            data: (bytes) => IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_rounded),
              tooltip: 'Save to Device',
              onPressed: _isSaving ? null : () => _saveToDevice(bytes),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: bytesAsync.when(
        data: (bytes) {
          if (bytes.isEmpty) {
            return const Center(
              child: Text('Document is empty or unavailable.'),
            );
          }

          if (isPdf) {
            return SfPdfViewer.memory(bytes);
          } else {
            // Interactive Image Viewer
            return Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.memory(
                  bytes,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Text('Unable to display file format.'),
                  ),
                ),
              ),
            );
          }
        },
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Retrieving signed secure document stream...',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        error: (err, stack) => ErrorStateWidget(
          message: err.toString(),
          onRetry: () =>
              ref.refresh(clientDocumentBytesProvider(widget.documentId)),
        ),
      ),
    );
  }
}
