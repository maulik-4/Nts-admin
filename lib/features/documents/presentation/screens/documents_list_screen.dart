import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/capability_gate.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/lex_text_field.dart';
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

  @override
  Widget build(BuildContext context) {
    final docsAsync = ref.watch(filteredDocumentsProvider);
    final selectedCaseId = ref.watch(documentCaseFilterProvider);
    final casesAsync = ref.watch(casesNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
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
          onPressed: () => context.push('/app/more/documents/upload'),
          backgroundColor: isDark
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.primary,
          foregroundColor: isDark ? Colors.black : Colors.white,
          icon: const Icon(Icons.upload_file),
          label: const Text(
            'Upload File',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: LexTextField(
              controller: _searchController,
              hintText: 'Search documents by filename or case...',
              prefixIcon: Icons.search,
              suffix: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(documentSearchQueryProvider.notifier).state =
                            '';
                        setState(() {});
                      },
                    )
                  : null,
              onChanged: (val) {
                ref.read(documentSearchQueryProvider.notifier).state = val;
                setState(() {});
              },
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
                    _buildFilterChip(
                      label: 'All Cases',
                      isSelected: selectedCaseId == null,
                      onSelected: () =>
                          ref.read(documentCaseFilterProvider.notifier).state =
                              null,
                    ),
                    const SizedBox(width: 8),
                    ...cases.map((c) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildFilterChip(
                          label: c.title,
                          isSelected: selectedCaseId == c.id,
                          onSelected: () =>
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

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isTablet = constraints.maxWidth >= 600;

                      if (isTablet) {
                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 3.2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            return DocumentCard(
                              document: doc,
                              onTap: () =>
                                  context.push('/app/more/documents/${doc.id}'),
                            );
                          },
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
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
                  );
                },
                loading: () => ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: 5,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      const SkeletonLoader(height: 76),
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

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected
              ? (isDark ? LexColors.slatePrimary : Colors.white)
              : (isDark
                    ? LexColors.textSecondaryDark
                    : LexColors.textSecondaryLight),
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: isDark
          ? Theme.of(context).colorScheme.secondary
          : Theme.of(context).colorScheme.primary,
      backgroundColor: isDark ? LexColors.surfaceDark : const Color(0xFFF1F5F9),
      side: BorderSide(
        color: isSelected
            ? Colors.transparent
            : (isDark ? LexColors.borderDark : LexColors.borderLight),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      showCheckmark: false,
    );
  }
}
