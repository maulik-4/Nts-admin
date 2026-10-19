import 'package:flutter/material.dart';

import '../theme/client_portal_theme.dart';

class ClientSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const ClientSearchField({
    super.key,
    required this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;

        return TextField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark
                ? ClientPortalColors.darkPrimaryText
                : ClientPortalColors.primaryText,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 14,
              color: isDark
                  ? ClientPortalColors.darkSecondaryText
                  : ClientPortalColors.secondaryText,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 20,
              color: isDark
                  ? ClientPortalColors.darkSecondaryText
                  : ClientPortalColors.secondaryText,
            ),
            suffixIcon: hasText
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    tooltip: 'Clear',
                    onPressed: () {
                      controller.clear();
                      onChanged?.call('');
                      onClear?.call();
                    },
                  )
                : null,
            filled: true,
            fillColor: isDark
                ? ClientPortalColors.darkCardBackground
                : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ClientPortalDimensions.inputRadius,
              ),
              borderSide: BorderSide(
                color: isDark
                    ? ClientPortalColors.darkBorder
                    : ClientPortalColors.border,
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ClientPortalDimensions.inputRadius,
              ),
              borderSide: BorderSide(
                color: isDark
                    ? ClientPortalColors.darkBorder
                    : ClientPortalColors.border,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ClientPortalDimensions.inputRadius,
              ),
              borderSide: const BorderSide(
                color: ClientPortalColors.primaryBlue,
                width: 1.5,
              ),
            ),
          ),
        );
      },
    );
  }
}
