import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

/// A tactile micro-interaction wrapper providing smooth spring-damped
/// scale feedback on press, adhering to iOS HIG tactile standards.
class BouncingPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDownFactor;
  final Duration duration;
  final HitTestBehavior behavior;

  const BouncingPressable({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDownFactor = 0.97,
    this.duration = const Duration(milliseconds: 130),
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<BouncingPressable> createState() => _BouncingPressableState();
}

class _BouncingPressableState extends State<BouncingPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.duration,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDownFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap != null) {
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) return widget.child;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: widget.behavior,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}

/// A modern container following Material 3 & iOS HIG guidelines:
/// - Soft 14-16px border radius
/// - Multi-stop gradient blending surface with subtle primary accent hue
/// - Translucent subtle border with directional gradient highlights
/// - Ambient diffuse shadows tailored for dark and light palettes
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final Gradient? customGradient;
  final Color? customSurfaceColor;
  final VoidCallback? onTap;
  final bool hasGlow;
  final Color? glowColor;

  const ModernCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.borderRadius = 16.0,
    this.borderColor,
    this.borderWidth = 1.0,
    this.customGradient,
    this.customSurfaceColor,
    this.onTap,
    this.hasGlow = false,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = isDark
        ? AppColors.darkPrimaryGold
        : AppColors.lightPrimaryTerracotta;
    final Color surfaceColor = customSurfaceColor ??
        (isDark ? AppColors.darkSurface : AppColors.lightSurface);

    // Subtle gradient blending surface with micro-accent
    final Gradient effectiveGradient = customGradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  surfaceColor,
                  Color.alphaBlend(
                    primaryColor.withValues(alpha: 0.04),
                    surfaceColor,
                  ),
                ]
              : [
                  surfaceColor,
                  Color.alphaBlend(
                    primaryColor.withValues(alpha: 0.025),
                    surfaceColor,
                  ),
                ],
        );

    final Color effectiveBorderColor = borderColor ??
        (isDark
            ? primaryColor.withValues(alpha: 0.18)
            : primaryColor.withValues(alpha: 0.14));

    final effectiveGlowColor = glowColor ?? primaryColor;

    final boxDecoration = BoxDecoration(
      gradient: effectiveGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: effectiveBorderColor,
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.32)
              : Colors.black.withValues(alpha: 0.05),
          blurRadius: 18,
          offset: const Offset(0, 6),
          spreadRadius: 0,
        ),
        if (hasGlow)
          BoxShadow(
            color: effectiveGlowColor.withValues(alpha: isDark ? 0.15 : 0.10),
            blurRadius: 24,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
      ],
    );

    Widget content = Container(
      margin: margin,
      padding: padding,
      decoration: boxDecoration,
      child: child,
    );

    if (onTap != null) {
      return BouncingPressable(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}

/// Standardized iOS HIG / Material 3 Section Header with uppercase tracking label
class M3SectionHeader extends StatelessWidget {
  final String title;
  final String? overline;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const M3SectionHeader({
    super.key,
    required this.title,
    this.overline,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 4.0),
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = isDark
        ? AppColors.darkPrimaryGold
        : AppColors.lightPrimaryTerracotta;

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (overline != null) ...[
                  Text(
                    overline!.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                      color: primaryColor.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
