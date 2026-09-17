import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/firm_theme_provider.dart';
import '../../core/theme/lex_colors.dart';
import '../../features/auth/domain/models/role_capabilities.dart';

/// Centralized, theme-aware brand logo component for Vidhanta.
/// Displays official Vidhanta branding from assets/images/icon.png or firm logo,
/// fully covering its placeholder with BoxFit.cover and zero clipping/overflow.
class AppBrandLogo extends ConsumerWidget {
  final double size;
  final BorderRadius? borderRadius;
  final String? customLogoUrl;
  final bool? isSuperAdmin;
  final bool showBorder;
  final bool isCircular;

  const AppBrandLogo({
    super.key,
    this.size = 36.0,
    this.borderRadius,
    this.customLogoUrl,
    this.isSuperAdmin,
    this.showBorder = true,
    this.isCircular = false,
  });

  static const String officialLogoAsset = 'assets/image/icon.png';
  static const String fallbackLogoAsset = 'assets/images/icon.png';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firmTheme = ref.watch(firmThemeProvider);
    final userRole = ref.watch(currentUserRoleProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final superAdminMode = isSuperAdmin ?? userRole.isSuperAdmin;
    final logoUrl =
        customLogoUrl ?? (superAdminMode ? null : firmTheme.logoUrl);
    final hasCustomLogo = logoUrl != null && logoUrl.trim().isNotEmpty;

    final radius = isCircular
        ? BorderRadius.circular(size / 2)
        : (borderRadius ?? BorderRadius.circular(size * 0.22));

    final accentColor = superAdminMode
        ? (isDark ? LexColors.accentGold : LexColors.slatePrimary)
        : firmTheme.accentColor;
    final primaryColor = superAdminMode
        ? LexColors.slatePrimary
        : firmTheme.primaryColor;

    final containerBg = isDark ? const Color(0xFF131B2E) : Colors.white;

    final borderColor = isDark
        ? accentColor.withValues(alpha: 0.35)
        : (hasCustomLogo
              ? LexColors.borderLight
              : primaryColor.withValues(alpha: 0.25));

    Widget imageContent;
    if (hasCustomLogo) {
      imageContent = Image.network(
        logoUrl,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (ctx, err, stack) => _buildOfficialLogo(size),
      );
    } else {
      imageContent = _buildOfficialLogo(size);
    }

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: containerBg,
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircular ? null : radius,
        border: showBorder ? Border.all(color: borderColor, width: 1.2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: isCircular
          ? ClipOval(child: imageContent)
          : ClipRRect(borderRadius: radius, child: imageContent),
    );
  }

  Widget _buildOfficialLogo(double renderSize) {
    return Image.asset(
      officialLogoAsset,
      fit: BoxFit.cover,
      width: renderSize,
      height: renderSize,
      errorBuilder: (ctx, err, stack) {
        return Image.asset(
          fallbackLogoAsset,
          fit: BoxFit.cover,
          width: renderSize,
          height: renderSize,
          errorBuilder: (ctx2, err2, stack2) {
            return Container(
              color: LexColors.slatePrimary,
              child: Center(
                child: Icon(
                  Icons.balance,
                  size: renderSize * 0.55,
                  color: Colors.white,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
