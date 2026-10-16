import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../core/utils/app_alerts.dart';
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
        AppAlerts.showError(context, 'Could not open file picker: $e');
      }
    }
  }

  Future<void> _handleUpload() async {
    if (_selectedCaseId == null) {
      AppAlerts.showError(context, 'Please select an associated case.');
      return;
    }

    if (_pickedFile == null || _pickedFile!.path == null) {
      AppAlerts.showError(context, 'Please select a file to upload.');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      await ref.read(documentsNotifierProvider.notifier).uploadDocument(
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
        AppAlerts.showSuccess(context, 'Document uploaded successfully.');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(context, 'Failed to upload document: $e');
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
      appBar: AppBar(
        title: const Text(
          'Upload Document',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LexCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge & Title
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFDBEAFE),
                                ),
                              ),
                              child: const Text(
                                'FILE SPECIFICATION',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Upload Legal File',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Attach petitions, evidence, contracts, or court transcripts to an active case.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Case Selector
                        Text(
                          'Associated Case *',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        casesAsync.when(
                          data: (cases) {
                            return DropdownButtonFormField<int>(
                              initialValue: _selectedCaseId,
                              decoration: InputDecoration(
                                hintText: 'Select case',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                ),
                                prefixIcon: Icon(
                                  Icons.balance_rounded,
                                  size: 19,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                  ),
                                ),
                              ),
                              items: cases.map((c) {
                                return DropdownMenuItem<int>(
                                  value: c.id,
                                  child: Text(
                                    '${c.caseNumber} - ${c.title}',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
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

                        // Dropzone Area
                        Text(
                          'Document File *',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: _isUploading ? null : _pickFile,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _pickedFile != null
                                    ? const Color(0xFF10B981)
                                    : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: _pickedFile != null
                                        ? const Color(0xFFECFDF5)
                                        : const Color(0xFFEFF6FF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _pickedFile != null
                                        ? Icons.check_circle_rounded
                                        : Icons.cloud_upload_outlined,
                                    size: 28,
                                    color: _pickedFile != null
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF2563EB),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _pickedFile != null
                                      ? _pickedFile!.name
                                      : 'Tap to browse files or drop document here',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _pickedFile != null
                                      ? '${(_pickedFile!.size / 1024).toStringAsFixed(1)} KB'
                                      : 'Supports PDF, DOC, DOCX, TXT, JPG, PNG up to 25MB',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                ElevatedButton.icon(
                                  onPressed: _isUploading ? null : _pickFile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark ? const Color(0xFF334155) : Colors.white,
                                    foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                                    side: BorderSide(
                                      color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                                    ),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                  icon: const Icon(Icons.folder_open_rounded, size: 16),
                                  label: Text(
                                    _pickedFile != null ? 'Change File' : 'Browse Files',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Security Assurance Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          size: 18,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'End-to-end encrypted legal document storage adhering to Bar compliance.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
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
                      backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      color: const Color(0xFF0F1F38),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Uploading file (${(_uploadProgress * 100).toInt()}%)...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Submit Button
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _handleUpload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F1F38),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Upload Document',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                                letterSpacing: 0.2,
                              ),
                            ),
                    ),
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
