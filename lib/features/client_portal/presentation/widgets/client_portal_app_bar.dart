import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_notifier.dart';
import '../providers/client_portal_notifier.dart';
import '../theme/client_portal_theme.dart';

class ClientPortalAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showBrandIcon;
  final List<Widget>? extraActions;

  const ClientPortalAppBar({
    super.key,
    this.title = 'Client Portal',
    this.showBrandIcon = true,
    this.extraActions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text(
          'Are you sure you want to log out of your client portal?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: ClientPortalColors.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      await ref.read(authNotifierProvider.notifier).logout();
      if (context.mounted) {
        context.go('/client/login');
      }
    }
  }

  void _handleRefresh(BuildContext context, WidgetRef ref) {
    ref.invalidate(clientDashboardProvider);
    ref.invalidate(clientDocumentsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing client portal data...'),
        duration: Duration(milliseconds: 1000),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: isDark
          ? ClientPortalColors.darkPageBackground
          : ClientPortalColors.cardBackground,
      surfaceTintColor: Colors.transparent,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showBrandIcon) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: ClientPortalColors.primaryNavy,
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: ClientPortalColors.primaryNavy.withValues(
                      alpha: 0.25,
                    ),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.balance_rounded,
                size: 19,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: isDark
                  ? ClientPortalColors.darkPrimaryText
                  : ClientPortalColors.primaryNavy,
            ),
          ),
        ],
      ),
      actions: [
        ...?extraActions,
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh Portal',
          color: isDark
              ? ClientPortalColors.darkSecondaryText
              : ClientPortalColors.primaryNavy,
          onPressed: () => _handleRefresh(context, ref),
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Log Out',
          color: isDark
              ? ClientPortalColors.darkSecondaryText
              : ClientPortalColors.primaryNavy,
          onPressed: () => _handleLogout(context, ref),
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: isDark
              ? ClientPortalColors.darkBorder
              : ClientPortalColors.border,
          height: 1,
        ),
      ),
    );
  }
}
