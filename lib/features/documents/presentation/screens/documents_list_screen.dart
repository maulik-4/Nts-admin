import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/capability_gate.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../auth/domain/models/role_capabilities.dart';
import '../../../cases/presentation/providers/cases_notifier.dart';
import '../providers/documents_notifier.dart';
import '../widgets/document_card.dart';

class DocumentsListScreen extends ConsumerStatefulWidget {
  const DocumentsListScreen({super.key});

  @override
  ConsumerState<DocumentsListScreen> createState() =>
      _DocumentsListScreenState();
}

class _DocumentsListScreenState extends ConsumerState<DocumentsListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildFilterPill({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? primaryColor : const Color(0xFF0F1F38))
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isDark ? primaryColor : const Color(0xFF0F1F38))
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F1F38).withAlpha(35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final docsAsync = ref.watch(filteredDocumentsProvider);
    final selectedCaseId = ref.watch(documentCaseFilterProvider);
    final casesAsync = ref.watch(casesNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalDocs = docsAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Documents',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFDBEAFE),
                ),
              ),
              child: Text(
                '$totalDocs Documents',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () {
              ref.read(documentsNotifierProvider.notifier).loadDocuments();
            },
          ),
        ],
      ),
      floatingActionButton: CapabilityGate(
        capability: UserCapability.uploadDocuments,
        child: FloatingActionButton.extended(
          heroTag: 'fab_upload_doc',
          onPressed: () => context.push('/app/more/documents/upload'),
          backgroundColor: const Color(0xFF0F1F38),
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.upload_file_rounded, size: 20),
          label: const Text(
            'Upload File',
            style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                ref.read(documentSearchQueryProvider.notifier).state = val;
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search documents by filename or case...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(documentSearchQueryProvider.notifier).state =
                              '';
                          setState(() {});
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
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
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Case Filters Row
          casesAsync.when(
            data: (cases) {
              if (cases.isEmpty) return const SizedBox.shrink();
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    _buildFilterPill(
                      context: context,
                      label: 'All Cases',
                      isSelected: selectedCaseId == null,
                      onTap: () =>
                          ref.read(documentCaseFilterProvider.notifier).state =
                              null,
                    ),
                    const SizedBox(width: 8),
                    ...cases.map((c) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildFilterPill(
                          context: context,
                          label: c.caseNumber.isNotEmpty
                              ? c.caseNumber
                              : c.title,
                          isSelected: selectedCaseId == c.id,
                          onTap: () =>
                              ref
                                  .read(documentCaseFilterProvider.notifier)
                                  .state = selectedCaseId == c.id
                              ? null
                              : c.id,
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),

          // Documents List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(documentsNotifierProvider.notifier).loadDocuments(),
              child: docsAsync.when(
                data: (docs) {
                  if (docs.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 60),
                        EmptyStateWidget(
                          title: 'No Documents Found',
                          message: 'Upload your first legal document or clear active filters.',
                          icon: Icons.folder_shared_outlined,
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
                    itemCount: docs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      return DocumentCard(
                        document: doc,
                        onTap: () =>
                            context.push('/app/more/documents/${doc.id}'),
                      );
                    },
                  );
                },
                loading: () => ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: 5,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      const SkeletonLoader(height: 76, borderRadius: 16),
                ),
                error: (err, stack) => Center(
                  child: ErrorStateWidget(
                    message: 'Unable to load documents: $err',
                    onRetry: () => ref
                        .read(documentsNotifierProvider.notifier)
                        .loadDocuments(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
