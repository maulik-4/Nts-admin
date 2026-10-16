import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../../core/theme/lex_colors.dart';
import '../../../../../core/utils/app_alerts.dart';
import '../../../data/models/document_model.dart';
import '../../../data/repositories/documents_repository.dart';
import 'pdf_document_renderer.dart';
import 'pdf_viewer_bottom_bar.dart';
import 'pdf_viewer_toolbar.dart';

class PdfViewerModal extends ConsumerStatefulWidget {
  final Document document;

  const PdfViewerModal({super.key, required this.document});

  static Future<void> show(BuildContext context, Document document) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => PdfViewerModal(document: document),
    );
  }

  @override
  ConsumerState<PdfViewerModal> createState() => _PdfViewerModalState();
}

class _PdfViewerModalState extends ConsumerState<PdfViewerModal> {
  late final PdfViewerController _pdfViewerController;
  final FocusNode _focusNode = FocusNode();

  Uint8List? _pdfBytes;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isFullscreen = false;
  bool _isDownloading = false;

  int _currentPage = 1;
  int _pageCount = 0;
  double _zoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _loadDocument();
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    _focusNode.dispose();
    _pdfBytes = null;
    super.dispose();
  }

  Future<void> _loadDocument() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(documentsRepositoryProvider);
      final bytes = await repo.getDocumentBytes(
        id: widget.document.id,
        fileUrl: widget.document.file,
      );

      if (mounted) {
        setState(() {
          _pdfBytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    // Do not trigger shortcuts while user is typing in a text field
    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus != null &&
        primaryFocus.context != null &&
        primaryFocus.context!.widget is EditableText) {
      return;
    }

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.escape) {
      if (_isFullscreen) {
        setState(() => _isFullscreen = false);
      } else {
        Navigator.of(context).pop();
      }
    } else if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.pageUp) {
      _goToPreviousPage();
    } else if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.pageDown) {
      _goToNextPage();
    } else if (key == LogicalKeyboardKey.equal ||
        key == LogicalKeyboardKey.add ||
        key == LogicalKeyboardKey.numpadAdd) {
      _zoomIn();
    } else if (key == LogicalKeyboardKey.minus ||
        key == LogicalKeyboardKey.numpadSubtract) {
      _zoomOut();
    } else if (key == LogicalKeyboardKey.digit0 ||
        key == LogicalKeyboardKey.numpad0) {
      _setZoom(1.0);
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 1) {
      _pdfViewerController.previousPage();
    }
  }

  void _goToNextPage() {
    if (_pageCount > 0 && _currentPage < _pageCount) {
      _pdfViewerController.nextPage();
    }
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= _pageCount) {
      _pdfViewerController.jumpToPage(page);
      setState(() => _currentPage = page);
    }
  }

  void _zoomIn() {
    final next = (_zoomLevel + 0.25).clamp(0.5, 3.0);
    _setZoom(next);
  }

  void _zoomOut() {
    final next = (_zoomLevel - 0.25).clamp(0.5, 3.0);
    _setZoom(next);
  }

  void _setZoom(double zoom) {
    setState(() => _zoomLevel = zoom);
    try {
      _pdfViewerController.zoomLevel = zoom;
    } catch (_) {}
  }

  Future<void> _handleDownload() async {
    setState(() => _isDownloading = true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/${widget.document.fileName}';

      if (_pdfBytes != null) {
        final file = File(savePath);
        await file.writeAsBytes(_pdfBytes!);
      } else {
        final repo = ref.read(documentsRepositoryProvider);
        await repo.downloadDocument(id: widget.document.id, savePath: savePath);
      }

      if (mounted) {
        AppAlerts.showSuccess(context, 'Document saved to: $savePath');
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(context, 'Failed to download document: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobileWidth = screenSize.width < 540;
    final isShortScreen = screenSize.height < 500;
    final occupyFull = _isFullscreen || isMobileWidth || isShortScreen;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Dialog(
        insetPadding: occupyFull
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        backgroundColor: isDark
            ? LexColors.surfaceDark
            : LexColors.surfaceLight,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(occupyFull ? 0 : 16),
        ),
        elevation: 12,
        child: SizedBox(
          width: occupyFull ? screenSize.width : screenSize.width * 0.9,
          height: occupyFull ? screenSize.height : screenSize.height * 0.9,
          child: SafeArea(
            top: occupyFull,
            bottom: occupyFull,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompactLayout = constraints.maxWidth < 540;

                return Column(
                  children: [
                    // Top Toolbar
                    PdfViewerToolbar(
                      title: widget.document.fileName,
                      currentPage: _currentPage,
                      pageCount: _pageCount,
                      zoomLevel: _zoomLevel,
                      isFullscreen: _isFullscreen,
                      isDownloading: _isDownloading,
                      isMobile: isCompactLayout,
                      onClose: () => Navigator.of(context).pop(),
                      onPageSelected: _goToPage,
                      onZoomChanged: _setZoom,
                      onDownload: _handleDownload,
                      onToggleFullscreen: () {
                        setState(() => _isFullscreen = !_isFullscreen);
                      },
                    ),

                    // PDF Rendering Area
                    Expanded(
                      child: PdfDocumentRenderer(
                        pdfBytes: _pdfBytes,
                        isLoading: _isLoading,
                        errorMessage: _errorMessage,
                        controller: _pdfViewerController,
                        onRetry: _loadDocument,
                        onPageCountDetermined: (count) {
                          if (mounted) {
                            setState(() {
                              _pageCount = count;
                              if (_currentPage > count) _currentPage = 1;
                            });
                          }
                        },
                        onPageChanged: (newPage) {
                          if (mounted) {
                            setState(() => _currentPage = newPage);
                          }
                        },
                        onZoomLevelChanged: (newZoom) {
                          if (mounted && (_zoomLevel - newZoom).abs() > 0.05) {
                            setState(() => _zoomLevel = newZoom);
                          }
                        },
                        onLoadFailed: (details) {
                          if (mounted) {
                            setState(() {
                              _errorMessage =
                                  'Invalid or corrupt PDF: $details';
                            });
                          }
                        },
                      ),
                    ),

                    // Bottom Bar on Mobile/Compact Screens
                    if (isCompactLayout)
                      PdfViewerBottomBar(
                        currentPage: _currentPage,
                        pageCount: _pageCount,
                        zoomLevel: _zoomLevel,
                        onPageSelected: _goToPage,
                        onZoomChanged: _setZoom,
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
