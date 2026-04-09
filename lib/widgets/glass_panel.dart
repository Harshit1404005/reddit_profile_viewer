import 'dart:ui';
import 'package:flutter/material.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final double blur;
  final double borderRadius;
  final Color? color;
  final Border? border;
  final EdgeInsets? padding;

  const GlassPanel({
    super.key,
    required this.child,
    this.blur = 24.0,
    this.borderRadius = 24.0,
    this.color,
    this.border,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? Colors.white.withAlpha((0.04 * 255).toInt()),
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ?? Border.all(
              color: Colors.white.withAlpha((0.1 * 255).toInt()),
              width: 0.5,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withAlpha((0.08 * 255).toInt()),
                Colors.white.withAlpha((0.02 * 255).toInt()),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
