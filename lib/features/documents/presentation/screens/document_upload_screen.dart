import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_button.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../cases/presentation/providers/cases_notifier.dart';
import '../providers/documents_notifier.dart';

class DocumentUploadScreen extends ConsumerStatefulWidget {
  final int? initialCaseId;

  const DocumentUploadScreen({super.key, this.initialCaseId});

  @override
  ConsumerState<DocumentUploadScreen> createState() =>
      _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends ConsumerState<DocumentUploadScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedCaseId;
  PlatformFile? _pickedFile;

  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedCaseId = widget.initialCaseId;
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _pickedFile = result.files.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file picker: $e'),
            backgroundColor: LexColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleUpload() async {
    if (_selectedCaseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an associated case.'),
          backgroundColor: LexColors.error,
        ),
      );
      return;
    }

    if (_pickedFile == null || _pickedFile!.path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file to upload.'),
          backgroundColor: LexColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      await ref
          .read(documentsNotifierProvider.notifier)
          .uploadDocument(
            caseId: _selectedCaseId!,
            filePath: _pickedFile!.path!,
            fileName: _pickedFile!.name,
            onProgress: (sent, total) {
              if (total > 0 && mounted) {
                setState(() => _uploadProgress = sent / total);
              }
            },
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document uploaded successfully.'),
            backgroundColor: LexColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload document: $e'),
            backgroundColor: LexColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final casesAsync = ref.watch(casesNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Document')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LexCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upload Legal File',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? LexColors.textPrimaryDark
                                : LexColors.slatePrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Upload petitions, evidences, judgments, or affidavits to your firm workspace.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? LexColors.textSecondaryDark
                                : LexColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Case Selector (Required)
                        casesAsync.when(
                          data: (cases) {
                            return DropdownButtonFormField<int>(
                              initialValue: _selectedCaseId,
                              decoration: InputDecoration(
                                labelText: 'Associated Case *',
                                hintText: 'Select case',
                                filled: true,
                                fillColor: isDark
                                    ? LexColors.surfaceDark
                                    : LexColors.surfaceLight,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: cases.map((c) {
                                return DropdownMenuItem<int>(
                                  value: c.id,
                                  child: Text(
                                    '${c.title} (${c.caseNumber})',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              validator: (val) {
                                if (val == null) {
                                  return 'Associated case is required';
                                }
                                return null;
                              },
                              onChanged: (val) {
                                setState(() => _selectedCaseId = val);
                              },
                            );
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (err, stack) => Text(
                            'Failed to load cases',
                            style: TextStyle(color: LexColors.error),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // File Picker Area
                        InkWell(
                          onTap: _isUploading ? null : _pickFile,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 24,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? LexColors.surfaceDark
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _pickedFile != null
                                    ? (isDark
                                          ? LexColors.accentGold
                                          : LexColors.slatePrimary)
                                    : (isDark
                                          ? LexColors.borderDark
                                          : LexColors.borderLight),
                                width: _pickedFile != null ? 1.5 : 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  _pickedFile != null
                                      ? Icons.check_circle_outline
                                      : Icons.cloud_upload_outlined,
                                  size: 40,
                                  color: _pickedFile != null
                                      ? LexColors.success
                                      : (isDark
                                            ? LexColors.accentGold
                                            : LexColors.slatePrimary),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _pickedFile != null
                                      ? _pickedFile!.name
                                      : 'Tap to browse device files',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? LexColors.textPrimaryDark
                                        : LexColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _pickedFile != null
                                      ? '${(_pickedFile!.size / 1024).toStringAsFixed(1)} KB'
                                      : 'Supported: PDF, DOC, DOCX, TXT, JPG, PNG',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? LexColors.textSecondaryDark
                                        : LexColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Upload Progress
                  if (_isUploading) ...[
                    LinearProgressIndicator(
                      value: _uploadProgress > 0 ? _uploadProgress : null,
                      color: isDark
                          ? LexColors.accentGold
                          : LexColors.slatePrimary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Uploading file (${(_uploadProgress * 100).toInt()}%)...',
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

                  // Submit Button
                  LexButton(
                    label: _isUploading ? 'Uploading...' : 'Start Upload',
                    icon: Icons.upload_file,
                    isLoading: _isUploading,
                    onPressed: _isUploading ? null : _handleUpload,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
