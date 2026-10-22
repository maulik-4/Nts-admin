import 'package:flutter/material.dart';

class SearchablePickerItem<T> {
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;

  const SearchablePickerItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.trailing,
  });
}

/// A modern, responsive bottom sheet with instant search filter.
Future<T?> showSearchablePicker<T>({
  required BuildContext context,
  required String title,
  required List<SearchablePickerItem<T>> items,
  T? selectedValue,
  String searchHint = 'Search...',
  IconData searchIcon = Icons.search_rounded,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _SearchablePickerSheet<T>(
      title: title,
      items: items,
      selectedValue: selectedValue,
      searchHint: searchHint,
      searchIcon: searchIcon,
    ),
  );
}

class _SearchablePickerSheet<T> extends StatefulWidget {
  final String title;
  final List<SearchablePickerItem<T>> items;
  final T? selectedValue;
  final String searchHint;
  final IconData searchIcon;

  const _SearchablePickerSheet({
    required this.title,
    required this.items,
    this.selectedValue,
    required this.searchHint,
    required this.searchIcon,
  });

  @override
  State<_SearchablePickerSheet<T>> createState() =>
      _SearchablePickerSheetState<T>();
}

class _SearchablePickerSheetState<T> extends State<_SearchablePickerSheet<T>> {
  late final TextEditingController _searchCtrl;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;

    final filtered = widget.items.where((item) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      final inLabel = item.label.toLowerCase().contains(q);
      final inSub = item.subtitle?.toLowerCase().contains(q) ?? false;
      return inLabel || inSub;
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.78,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D33) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 38,
            height: 4.5,
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ],
            ),
          ),

          // Search Box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0B1426) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0),
                ),
              ),
              child: TextField(
                controller: _searchCtrl,
                autofocus: false,
                onChanged: (val) => setState(() => _query = val.trim()),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                  prefixIcon: Icon(
                    widget.searchIcon,
                    size: 19,
                    color: const Color(0xFF2563EB),
                  ),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // Items List
          Flexible(
            child: filtered.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 40,
                          color: isDark
                              ? const Color(0xFF475569)
                              : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No matching results found',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      indent: 64,
                      color: isDark
                          ? const Color(0xFF1E2D4A).withValues(alpha: 0.5)
                          : const Color(0xFFF1F5F9),
                    ),
                    itemBuilder: (ctx, idx) {
                      final item = filtered[idx];
                      final isSelected = item.value == widget.selectedValue;

                      return InkWell(
                        onTap: () => Navigator.of(context).pop(item.value),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 11,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: (item.iconColor ?? const Color(0xFF2563EB))
                                      .withValues(alpha: isDark ? 0.2 : 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  item.icon ?? Icons.circle_outlined,
                                  size: 19,
                                  color: item.iconColor ?? const Color(0xFF2563EB),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.label,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? const Color(0xFF2563EB)
                                            : (isDark
                                                ? Colors.white
                                                : const Color(0xFF0F172A)),
                                      ),
                                    ),
                                    if (item.subtitle != null &&
                                        item.subtitle!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        item.subtitle!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF2563EB),
                                  size: 20,
                                )
                              else if (item.trailing != null)
                                item.trailing!,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
