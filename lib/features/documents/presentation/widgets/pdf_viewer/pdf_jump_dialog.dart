import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/lex_colors.dart';

class PdfJumpDialog extends StatefulWidget {
  final int currentPage;
  final int pageCount;

  const PdfJumpDialog({
    super.key,
    required this.currentPage,
    required this.pageCount,
  });

  @override
  State<PdfJumpDialog> createState() => _PdfJumpDialogState();
}

class _PdfJumpDialogState extends State<PdfJumpDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.currentPage}');
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    final page = int.tryParse(text);
    if (page == null || page < 1 || page > widget.pageCount) {
      setState(() {
        _errorText = 'Enter a page between 1 and ${widget.pageCount}';
      });
      return;
    }
    Navigator.of(context).pop(page);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? LexColors.surfaceDark : LexColors.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        'Go to Page',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: isDark ? LexColors.textPrimaryDark : LexColors.slatePrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total pages: ${widget.pageCount}',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? LexColors.textSecondaryDark
                  : LexColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'Page number',
              errorText: _errorText,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? LexColors.borderDark : LexColors.borderLight,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: LexColors.accentBronze,
                  width: 1.5,
                ),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark
                  ? LexColors.textSecondaryDark
                  : LexColors.textSecondaryLight,
            ),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: LexColors.slatePrimary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _submit,
          child: const Text('Go'),
        ),
      ],
    );
  }
}
