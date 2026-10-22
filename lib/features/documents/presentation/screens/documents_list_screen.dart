import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/capability_gate.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../auth/domain/models/role_capabilities.dart';
import '../../../cases/data/models/case_model.dart';
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

          // Case Filter Bar
          casesAsync.when(
            data: (cases) {
              if (cases.isEmpty) return const SizedBox.shrink();
              final selectedCase = selectedCaseId == null
                  ? null
                  : cases.where((c) => c.id == selectedCaseId).firstOrNull;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    _buildFilterPill(
                      context: context,
                      label: 'All Documents',
                      isSelected: selectedCaseId == null,
                      onTap: () =>
                          ref.read(documentCaseFilterProvider.notifier).state =
                              null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCaseFilterDropdownButton(
                        context: context,
                        cases: cases,
                        selectedCase: selectedCase,
                        isDark: isDark,
                      ),
                    ),
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

  Widget _buildCaseFilterDropdownButton({
    required BuildContext context,
    required List<Case> cases,
    required Case? selectedCase,
    required bool isDark,
  }) {
    final hasSelection = selectedCase != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            _showCaseSearchModal(context, cases: cases, isDark: isDark),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: hasSelection
                ? (isDark
                    ? const Color(0xFF1E3A8A).withValues(alpha: 0.35)
                    : const Color(0xFFEFF6FF))
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasSelection
                  ? (isDark
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF2563EB))
                  : (isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0)),
              width: 1,
            ),
            boxShadow: hasSelection
                ? [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                hasSelection ? Icons.balance_rounded : Icons.tune_rounded,
                size: 16,
                color: hasSelection
                    ? const Color(0xFF2563EB)
                    : (isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B)),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  hasSelection
                      ? '${selectedCase.caseNumber} • ${selectedCase.title}'
                      : 'Filter by Case',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight:
                        hasSelection ? FontWeight.w700 : FontWeight.w500,
                    color: hasSelection
                        ? (isDark
                            ? const Color(0xFF60A5FA)
                            : const Color(0xFF1D4ED8))
                        : (isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF475569)),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              if (hasSelection)
                GestureDetector(
                  onTap: () {
                    ref.read(documentCaseFilterProvider.notifier).state = null;
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFDBEAFE),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 13,
                      color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                    ),
                  ),
                )
              else
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCaseSearchModal(
    BuildContext context, {
    required List<Case> cases,
    required bool isDark,
  }) {
    final searchController = TextEditingController();
    List<Case> filtered = List.from(cases);
    final selectedId = ref.read(documentCaseFilterProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF131D33) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.45,
              maxChildSize: 0.92,
              expand: false,
              builder: (ctx, scrollController) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    18,
                    12,
                    18,
                    MediaQuery.of(ctx).viewInsets.bottom + 18,
                  ),
                  child: Column(
                    children: [
                      // Handle
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title & Subtitle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Filter by Case',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Select a case to view its documents',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          if (selectedId != null)
                            TextButton(
                              onPressed: () {
                                ref
                                    .read(documentCaseFilterProvider.notifier)
                                    .state = null;
                                Navigator.pop(ctx);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFFEF4444),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              child: const Text('Reset'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Search Field
                      TextField(
                        controller: searchController,
                        autofocus: false,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search by case number, title, court...',
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
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    setModalState(() {
                                      searchController.clear();
                                      filtered = List.from(cases);
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            final q = val.toLowerCase().trim();
                            if (q.isEmpty) {
                              filtered = List.from(cases);
                            } else {
                              filtered = cases.where((c) {
                                return c.caseNumber
                                        .toLowerCase()
                                        .contains(q) ||
                                    c.title.toLowerCase().contains(q) ||
                                    c.courtName.toLowerCase().contains(q);
                              }).toList();
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      // "All Cases" option item
                      InkWell(
                        onTap: () {
                          ref.read(documentCaseFilterProvider.notifier).state =
                              null;
                          Navigator.pop(ctx);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedId == null
                                ? (isDark
                                    ? const Color(0xFF1E3A8A)
                                        .withValues(alpha: 0.3)
                                    : const Color(0xFFEFF6FF))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedId == null
                                  ? const Color(0xFF2563EB)
                                  : (isDark
                                      ? const Color(0xFF1E2D4A)
                                      : const Color(0xFFE2E8F0)),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: selectedId == null
                                      ? const Color(0xFF2563EB)
                                      : (isDark
                                          ? const Color(0xFF1E2D4A)
                                          : const Color(0xFFF1F5F9)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.layers_outlined,
                                  size: 18,
                                  color: selectedId == null
                                      ? Colors.white
                                      : (isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'All Cases',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: selectedId == null
                                            ? const Color(0xFF2563EB)
                                            : (isDark
                                                ? Colors.white
                                                : const Color(0xFF0F172A)),
                                      ),
                                    ),
                                    Text(
                                      'Show documents from all cases',
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
                              if (selectedId == null)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF2563EB),
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Cases List
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.search_off_rounded,
                                        size: 38,
                                        color: isDark
                                            ? const Color(0xFF475569)
                                            : const Color(0xFF94A3B8),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'No matching cases found',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          color: isDark
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFF64748B),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                itemCount: filtered.length,
                                separatorBuilder: (context, index) => Divider(
                                  color: isDark
                                      ? const Color(0xFF1E2D4A)
                                      : const Color(0xFFF1F5F9),
                                  height: 1,
                                ),
                                itemBuilder: (ctx, idx) {
                                  final c = filtered[idx];
                                  final isSelected = selectedId == c.id;
                                  return InkWell(
                                    onTap: () {
                                      ref
                                          .read(documentCaseFilterProvider
                                              .notifier)
                                          .state = c.id;
                                      Navigator.pop(ctx);
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 10),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? const Color(0xFF2563EB)
                                                  : (isDark
                                                      ? const Color(0xFF1E2D4A)
                                                      : const Color(
                                                          0xFFEFF6FF)),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              Icons.balance_rounded,
                                              size: 18,
                                              color: isSelected
                                                  ? Colors.white
                                                  : const Color(0xFF2563EB),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 6,
                                                          vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: isDark
                                                            ? const Color(
                                                                0xFF0F172A)
                                                            : const Color(
                                                                0xFFF1F5F9),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                      child: Text(
                                                        c.caseNumber,
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color:
                                                              Color(0xFF2563EB),
                                                        ),
                                                      ),
                                                    ),
                                                    if (c.courtName
                                                        .isNotEmpty) ...[
                                                      const SizedBox(width: 6),
                                                      Expanded(
                                                        child: Text(
                                                          c.courtName,
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: isDark
                                                                ? const Color(
                                                                    0xFF94A3B8)
                                                                : const Color(
                                                                    0xFF64748B),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  c.title,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 13.5,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w700
                                                        : FontWeight.w600,
                                                    color: isSelected
                                                        ? const Color(
                                                            0xFF2563EB)
                                                        : (isDark
                                                            ? Colors.white
                                                            : const Color(
                                                                0xFF0F172A)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (isSelected)
                                            const Icon(
                                              Icons.check_circle_rounded,
                                              color: Color(0xFF2563EB),
                                              size: 20,
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
