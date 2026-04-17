import 'package:flutter/material.dart';

/// A wrapper that provides the specific brand-tiled background:
/// Solid white everywhere, with a massive, primary-colored,
/// custom-shaped logo watermark in the bottom-right corner.
class BaseBackground extends StatelessWidget {
  final Widget child;

  const BaseBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Collect specific theme colors and device size information
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    // We calculate a large size relative to the screen,
    // roughly 85% of the width, for maximum visual impact.
    final watermarkSize = size.width * 0.85;

    return Scaffold(
      backgroundColor: Colors.white, // The primary background color
      body: Stack(
        children: [
          // 1. The Large, Custom Watermark
          // We position it with significant negative offsets to crop
          // exactly 3/4ths of the logo (25% visible on each axis).
          Positioned(
            right: -watermarkSize * 0.25,
            bottom: -watermarkSize * 0.25,
            child: Opacity(
              // Using a subtle opacity makes it less distracting than a solid block
              opacity: 0.1,
              child: CustomPaint(
                size: Size(watermarkSize, watermarkSize),
                painter: _BrandLogoWatermarkPainter(
                  backgroundColor: colorScheme.primary, // The solid part
                  dashColor: Colors.white,            // The cut-out dash part
                ),
              ),
            ),
          ),

          // 2. The Actual Screen Content
          // We ensure content is placed above the background watermark.
          SafeArea(child: child),
        ],
      ),
    );
  }
}

/// A highly efficient painter that draws the entire brand shape
/// as a single graphic operation, ensuring consistency.
class _BrandLogoWatermarkPainter extends CustomPainter {
  final Color backgroundColor;
  final Color dashColor;

  _BrandLogoWatermarkPainter({
    required this.backgroundColor,
    required this.dashColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Scale all dimensions relative to the target size for perfect proportion.
    final w = size.width;
    final h = size.height;

    // Define the overall shape geometry
    final cornerRadius = w * 0.22;
    final dashHeight = w * 0.12;
    final dashYOffset = h * 0.35;
    final dashPaddingX = w * 0.20;

    // --- 1. Draw the Solid, Primary-Colored Background Container ---
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromLTRBR(
        0, 0, w, h,
        Radius.circular(cornerRadius),
      ),
      backgroundPaint,
    );

    // --- 2. Draw the Single White Dash to 'Cut Out' of the Shape ---
    final dashPaint = Paint()
      ..color = dashColor
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromLTRBR(
        dashPaddingX,
        dashYOffset,
        w - dashPaddingX,
        dashYOffset + dashHeight,
        Radius.circular(cornerRadius),
      ),
      dashPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BrandLogoWatermarkPainter oldDelegate) {
    // Only repaint if the colors change (e.g., when toggling light/dark mode)
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.dashColor != dashColor;
  }
}