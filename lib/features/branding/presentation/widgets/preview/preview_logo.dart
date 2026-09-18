import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/lex_colors.dart';

class PreviewLogo extends StatelessWidget {
  final PlatformFile? pickedFile;
  final String? existingUrl;
  final double size;
  final double borderRadius;
  final BoxFit fit;
  final Color primaryColor;
  final Color accentColor;
  final String? fallbackInitial;

  const PreviewLogo({
    super.key,
    this.pickedFile,
    this.existingUrl,
    this.size = 32,
    this.borderRadius = 8,
    this.fit = BoxFit.contain,
    this.primaryColor = LexColors.slatePrimary,
    this.accentColor = LexColors.accentGold,
    this.fallbackInitial,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildImageContent(),
    );
  }

  Widget _buildImageContent() {
    if (pickedFile != null) {
      if (kIsWeb && pickedFile!.bytes != null) {
        return Image.memory(
          pickedFile!.bytes!,
          width: size,
          height: size,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      } else if (pickedFile!.path != null) {
        return Image.file(
          File(pickedFile!.path!),
          width: size,
          height: size,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      }
    }

    if (existingUrl != null && existingUrl!.isNotEmpty) {
      return Image.network(
        existingUrl!,
        width: size,
        height: size,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }

    return _buildFallback();
  }

  Widget _buildFallback() {
    if (fallbackInitial != null && fallbackInitial!.trim().isNotEmpty) {
      final trimmed = fallbackInitial!.trim();
      final chars = trimmed.length > 2 ? trimmed.substring(0, 2) : trimmed;
      return Center(
        child: Text(
          chars.toUpperCase(),
          style: TextStyle(
            color: accentColor,
            fontSize: size * (chars.length > 1 ? 0.38 : 0.45),
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return Center(
      child: Icon(Icons.balance_rounded, size: size * 0.55, color: accentColor),
    );
  }
}
