import 'package:flutter/material.dart';

/// Responsive grid layout for dashboard metric cards.
///
/// Responsive Breakpoints:
/// - Mobile (< 400px): 1 column (vertical stack with intrinsic height for zero text clipping)
/// - Small Tablet / Wide Phone (400px - 720px): 2 columns
/// - Tablet (720px - 1100px): 3 columns
/// - Desktop (>= 1100px): 4 columns
class ResponsiveMetricGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const ResponsiveMetricGrid({
    super.key,
    required this.children,
    this.spacing = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Stack as single column only on extremely narrow viewports (< 280px)
        if (width < 280) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(height: spacing),
                children[i],
              ],
            ],
          );
        }

        // Multi-column row grouping based on available width (2 columns on mobile phones)
        final int columns = width >= 1100
            ? 4
            : width >= 720
            ? 3
            : 2;

        final List<Widget> rows = [];
        for (int i = 0; i < children.length; i += columns) {
          final rowChildren = <Widget>[];
          for (int c = 0; c < columns; c++) {
            final index = i + c;
            if (index < children.length) {
              if (c > 0) rowChildren.add(SizedBox(width: spacing));
              rowChildren.add(Expanded(child: children[index]));
            } else {
              // Empty spacer to balance last row
              if (c > 0) rowChildren.add(SizedBox(width: spacing));
              rowChildren.add(const Expanded(child: SizedBox.shrink()));
            }
          }

          if (rows.isNotEmpty) rows.add(SizedBox(height: spacing));
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rowChildren,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }
}
