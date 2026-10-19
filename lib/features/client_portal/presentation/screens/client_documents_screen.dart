import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import '../providers/client_portal_notifier.dart';
import '../theme/client_portal_theme.dart';
import '../widgets/client_document_card.dart';
import '../widgets/client_empty_state.dart';
import '../widgets/client_loading_skeleton.dart';
import '../widgets/client_portal_app_bar.dart';
import '../widgets/client_search_field.dart';
import '../../data/models/client_document_model.dart';
import '../../data/repositories/client_portal_repository.dart';

class ClientDocumentsScreen extends ConsumerStatefulWidget {
  const ClientDocumentsScreen({super.key});

  @override
  ConsumerState<ClientDocumentsScreen> createState() =>
      _ClientDocumentsScreenState();
}

class _ClientDocumentsScreenState extends ConsumerState<ClientDocumentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _downloadingDocIds = {};
  int _selectedCategoryIndex = 0; // 0: All, 1: PDFs, 2: Images, 3: Other

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleDownload(ClientDocumentItem doc) async {
    setState(() => _downloadingDocIds.add(doc.id));
    try {
      final repo = ref.read(clientPortalRepositoryProvider);
      final link = await repo.getAccessLink(doc.id);
      final bytes = await repo.downloadDocumentBytes(
        doc.id,
        link.token,
        disposition: 'attachment',
      );

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${doc.fileName}');
      await file.writeAsBytes(bytes);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text('Downloaded to ${doc.fileName}')),
            ],
          ),
          backgroundColor: ClientPortalColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text('Download failed: $e')),
            ],
          ),
          backgroundColor: ClientPortalColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _downloadingDocIds.remove(doc.id));
    }
  }

  List<ClientDocumentItem> _filterDocuments(
    List<ClientDocumentItem> docs,
    String query,
  ) {
    var list = docs;

    // Filter by category
    if (_selectedCategoryIndex == 1) {
      list = list.where((d) => d.isPdf).toList();
    } else if (_selectedCategoryIndex == 2) {
      list = list.where((d) => d.isImage).toList();
    } else if (_selectedCategoryIndex == 3) {
      list = list.where((d) => !d.isPdf && !d.isImage).toList();
    }

    // Filter by query
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((d) {
        return d.title.toLowerCase().contains(q) ||
            d.fileName.toLowerCase().contains(q) ||
            (d.caseTitle?.toLowerCase().contains(q) ?? false) ||
            d.sharedByName.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final documentsAsync = ref.watch(clientDocumentsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= 600;

    return Scaffold(
      backgroundColor: isDark
          ? ClientPortalColors.darkPageBackground
          : ClientPortalColors.pageBackground,
      appBar: const ClientPortalAppBar(
        title: 'Documents',
        showBrandIcon: false,
      ),
      body: documentsAsync.when(
        data: (allDocs) {
          final pdfsCount = allDocs.where((d) => d.isPdf).length;
          final imagesCount = allDocs.where((d) => d.isImage).length;
          final otherCount = allDocs
              .where((d) => !d.isPdf && !d.isImage)
              .length;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: ClientPortalDimensions.maxContentWidth,
              ),
              child: Column(
                children: [
                  // Controls Header
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      isTablet
                          ? ClientPortalDimensions.tabletPadding
                          : ClientPortalDimensions.mobilePadding,
                      16,
                      isTablet
                          ? ClientPortalDimensions.tabletPadding
                          : ClientPortalDimensions.mobilePadding,
                      12,
                    ),
                    color: isDark
                        ? ClientPortalColors.darkPageBackground
                        : ClientPortalColors.pageBackground,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Shared Files & Legal Documents',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? ClientPortalColors.darkSecondaryText
                                    : ClientPortalColors.secondaryText,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: ClientPortalColors.primaryBlue
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${allDocs.length} Total',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: ClientPortalColors.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClientSearchField(
                          controller: _searchController,
                          hintText:
                              'Search documents by title, case, or author...',
                          onChanged: (_) => setState(() {}),
                          onClear: () => setState(() {}),
                        ),
                        const SizedBox(height: 12),

                        // Category Filter Bar
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _CategoryChip(
                                label: 'All (${allDocs.length})',
                                isSelected: _selectedCategoryIndex == 0,
                                onTap: () =>
                                    setState(() => _selectedCategoryIndex = 0),
                                isDark: isDark,
                              ),
                              const SizedBox(width: 8),
                              _CategoryChip(
                                label: 'PDFs ($pdfsCount)',
                                isSelected: _selectedCategoryIndex == 1,
                                onTap: () =>
                                    setState(() => _selectedCategoryIndex = 1),
                                isDark: isDark,
                              ),
                              const SizedBox(width: 8),
                              _CategoryChip(
                                label: 'Images ($imagesCount)',
                                isSelected: _selectedCategoryIndex == 2,
                                onTap: () =>
                                    setState(() => _selectedCategoryIndex = 2),
                                isDark: isDark,
                              ),
                              const SizedBox(width: 8),
                              _CategoryChip(
                                label: 'Others ($otherCount)',
                                isSelected: _selectedCategoryIndex == 3,
                                onTap: () =>
                                    setState(() => _selectedCategoryIndex = 3),
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Documents List
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final filtered = _filterDocuments(
                          allDocs,
                          _searchController.text,
                        );

                        if (allDocs.isEmpty) {
                          return const ClientEmptyState(
                            icon: Icons.folder_open_rounded,
                            title: 'No Documents Shared',
                            description: 'Your legal counsel has not shared any documents with your portal account yet.',
                          );
                        }

                        if (filtered.isEmpty) {
                          return ClientEmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'No Matching Documents',
                            description: 'No documents match your query. Try a different search keyword or category filter.',
                            actionLabel: 'Reset Filters',
                            onAction: () {
                              _searchController.clear();
                              setState(() => _selectedCategoryIndex = 0);
                            },
                          );
                        }

                        return ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet
                                ? ClientPortalDimensions.tabletPadding
                                : ClientPortalDimensions.mobilePadding,
                            vertical: 12,
                          ),
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final doc = filtered[index];
                            final isDownloading = _downloadingDocIds.contains(
                              doc.id,
                            );

                            return ClientDocumentCard(
                              document: doc,
                              isDownloading: isDownloading,
                              onPreview: () {
                                context.push(
                                  '/client/documents/${doc.id}',
                                  extra: {
                                    'title': doc.title,
                                    'fileExt': doc.fileExt,
                                  },
                                );
                              },
                              onDownload: () => _handleDownload(doc),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const _LoadingView(),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 44,
                  color: ClientPortalColors.error,
                ),
                const SizedBox(height: 12),
                Text('Failed to load documents: $err'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(clientDocumentsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? ClientPortalColors.primaryNavy
              : (isDark ? ClientPortalColors.darkCardBackground : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? ClientPortalColors.primaryNavy
                : (isDark
                      ? ClientPortalColors.darkBorder
                      : ClientPortalColors.border),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark
                      ? ClientPortalColors.darkPrimaryText
                      : ClientPortalColors.primaryText),
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => const ClientLoadingSkeleton(height: 120),
    );
  }
}
