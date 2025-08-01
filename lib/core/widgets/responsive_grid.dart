import 'package:flutter/material.dart';

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int minItemsPerRow;
  final int maxItemsPerRow;
  final double minItemWidth;
  final double maxItemWidth;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.minItemsPerRow = 1,
    this.maxItemsPerRow = 4,
    this.minItemWidth = 150.0,
    this.maxItemWidth = 300.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        
        // Calculate optimal number of items per row
        int itemsPerRow = minItemsPerRow;
        
        for (int i = minItemsPerRow; i <= maxItemsPerRow; i++) {
          final itemWidth = (availableWidth - (spacing * (i - 1))) / i;
          if (itemWidth >= minItemWidth && itemWidth <= maxItemWidth) {
            itemsPerRow = i;
          }
        }
        
        // Ensure we don't exceed maxItemsPerRow
        itemsPerRow = itemsPerRow.clamp(minItemsPerRow, maxItemsPerRow);
        
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children.map((child) {
            final itemWidth = (availableWidth - (spacing * (itemsPerRow - 1))) / itemsPerRow;
            return SizedBox(
              width: itemWidth,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}

class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }
  
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints) mobile;
  final Widget Function(BuildContext context, BoxConstraints constraints)? tablet;
  final Widget Function(BuildContext context, BoxConstraints constraints)? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveBreakpoints.desktop && desktop != null) {
          return desktop!(context, constraints);
        } else if (constraints.maxWidth >= ResponsiveBreakpoints.mobile && tablet != null) {
          return tablet!(context, constraints);
        } else {
          return mobile(context, constraints);
        }
      },
    );
  }
}

class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding = const EdgeInsets.all(16),
    this.tabletPadding,
    this.desktopPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ResponsiveBreakpoints.responsive(
        context,
        mobile: mobilePadding,
        tablet: tabletPadding,
        desktop: desktopPadding,
      ),
      child: child,
    );
  }
}