import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_button.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../providers/documents_notifier.dart';
import '../../data/models/client_document_access_model.dart';
import '../../data/repositories/document_sharing_repository.dart';

class DocumentShareDialog extends ConsumerStatefulWidget {
  final int clientId;
  final String clientName;
  final int? preselectedDocId;

  const DocumentShareDialog({
    super.key,
    required this.clientId,
    required this.clientName,
    this.preselectedDocId,
  });

  static Future<void> show(
    BuildContext context, {
    required int clientId,
    required String clientName,
    int? preselectedDocId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DocumentShareDialog(
        clientId: clientId,
        clientName: clientName,
        preselectedDocId: preselectedDocId,
      ),
    );
  }

  @override
  ConsumerState<DocumentShareDialog> createState() =>
      _DocumentShareDialogState();
}

class _DocumentShareDialogState extends ConsumerState<DocumentShareDialog> {
  int? _selectedDocId;
  int _expiresInDays = 30;
  final _messageController = TextEditingController();

  bool _isLoadingShared = true;
  bool _isSharing = false;
  String? _errorMessage;
  List<ClientDocumentAccessItem> _sharedList = [];

  final List<int> _expiryOptions = [7, 30, 90, 0];

  @override
  void initState() {
    super.initState();
    _selectedDocId = widget.preselectedDocId;
    _fetchSharedDocuments();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchSharedDocuments() async {
    setState(() => _isLoadingShared = true);
    try {
      final repo = ref.read(documentSharingRepositoryProvider);
      final list = await repo.listSharedDocuments(widget.clientId);
      if (mounted) {
        setState(() {
          _sharedList = list;
          _isLoadingShared = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingShared = false);
    }
  }

  Future<void> _shareDocument() async {
    if (_selectedDocId == null) {
      setState(() => _errorMessage = 'Please select a document to share');
      return;
    }

    setState(() {
      _isSharing = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(documentSharingRepositoryProvider);
      await repo.shareDocumentWithClient(
        widget.clientId,
        _selectedDocId!,
        expiresInDays: _expiresInDays,
        message: _messageController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Document shared with ${widget.clientName}'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _messageController.clear();
      _fetchSharedDocuments();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _errorMessage = 'Failed to share document. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _revokeAccess(int docId) async {
    try {
      final repo = ref.read(documentSharingRepositoryProvider);
      await repo.revokeDocumentSharing(widget.clientId, docId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document access revoked'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _fetchSharedDocuments();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: LexColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final docsAsync = ref.watch(documentsNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary
                            .withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.share_outlined,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Shared Documents Manager',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Client: ${widget.clientName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: LexColors.errorLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: LexColors.error.withAlpha(50),
                          ),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: LexColors.error,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Section: Share New Document
                    const Text(
                      'Share Document',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Document Dropdown
                    docsAsync.when(
                      data: (docs) {
                        return DropdownButtonFormField<int>(
                          initialValue: _selectedDocId,
                          hint: const Text('Select a firm document'),
                          isExpanded: true,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: docs.map((doc) {
                            return DropdownMenuItem<int>(
                              value: doc.id,
                              child: Text(
                                '${doc.displayTitle} (${doc.fileExtension.toUpperCase()})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedDocId = val),
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (_, _) =>
                          const Text('Unable to load firm documents'),
                    ),
                    const SizedBox(height: 14),

                    // Expiration Options
                    const Text(
                      'Access Duration',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _expiryOptions.map((days) {
                        final isSelected = _expiresInDays == days;
                        final label = days == 0
                            ? 'Never Expires'
                            : '$days Days';
                        return ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _expiresInDays = days);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Message (Optional)
                    TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        labelText: 'Message for client (Optional)',
                        hintText: 'e.g. Please review before next hearing...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    LexButton(
                      label: _isSharing
                          ? 'Sharing Document...'
                          : 'Share Document Access',
                      icon: Icons.send_rounded,
                      onPressed: _isSharing ? null : _shareDocument,
                    ),

                    const Divider(height: 36),

                    // Currently Shared Documents
                    Row(
                      children: [
                        const Text(
                          'Active Document Shares',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          onPressed: _fetchSharedDocuments,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (_isLoadingShared)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_sharedList.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'No documents currently shared with this client.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      )
                    else
                      ..._sharedList.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: LexCard(
                            borderRadius: 14,
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.file_present_rounded,
                                  color: Color(0xFF2563EB),
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.documentTitle,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.expiresAt != null
                                            ? 'Expires: ${item.expiresAt!.split("T").first}'
                                            : 'No expiration',
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
                                TextButton.icon(
                                  icon: const Icon(
                                    Icons.link_off_rounded,
                                    size: 16,
                                    color: Color(0xFFEF4444),
                                  ),
                                  label: const Text(
                                    'Revoke',
                                    style: TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontSize: 12,
                                    ),
                                  ),
                                  onPressed: () =>
                                      _revokeAccess(item.documentId),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
