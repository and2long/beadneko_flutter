import 'package:beadneko/core/pixel_processor.dart';
import 'package:flutter/material.dart';

class BeadGridView extends StatelessWidget {
  final List<List<ProcessedPixel>> grid;

  const BeadGridView({super.key, required this.grid});

  @override
  Widget build(BuildContext context) {
    if (grid.isEmpty) return const SizedBox();

    final int rows = grid.length;
    final int cols = grid[0].length;

    return AspectRatio(
      aspectRatio: cols / rows,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double beadSize = constraints.maxWidth / cols;

          return CustomPaint(
            painter: BeadGridPainter(
              grid: grid,
              beadSize: beadSize,
              showCodes: false,
            ),
            size: Size(
              constraints.maxWidth,
              constraints.maxWidth * rows / cols,
            ),
          );
        },
      ),
    );
  }
}

class BeadGridPainter extends CustomPainter {
  final List<List<ProcessedPixel>> grid;
  final double beadSize;
  final bool showCodes;

  BeadGridPainter({
    required this.grid,
    required this.beadSize,
    this.showCodes = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black12
      ..strokeWidth = 0.5;

    for (var row in grid) {
      for (var pixel in row) {
        if (pixel.bead == null) continue; // Skip transparency

        paint.color = pixel.bead!.color;

        final rect = Rect.fromLTWH(
          pixel.x * beadSize,
          pixel.y * beadSize,
          beadSize,
          beadSize,
        );

        // Draw bead (square)
        // Using 0.9 scale to keep individual bead look, or 1.0 for full coverage?
        // User asked for "square instead of circle", usually implies shape change.
        // I will use 0.95 to make it look like tight square beads.
        final double padding = beadSize * 0.05;
        final squareRect = Rect.fromLTWH(
          pixel.x * beadSize + padding,
          pixel.y * beadSize + padding,
          beadSize - padding * 2,
          beadSize - padding * 2,
        );
        canvas.drawRect(squareRect, paint);

        // Draw grid lines
        canvas.drawRect(rect, borderPaint);

        // Draw Color Code if size permits
        if (showCodes && beadSize > 12) {
          final textStyle = TextStyle(
            color: pixel.bead!.color.computeLuminance() > 0.5
                ? Colors.black
                : Colors.white,
            fontSize: beadSize * 0.4,
            fontWeight: FontWeight.bold,
          );
          final textSpan = TextSpan(text: pixel.bead!.code, style: textStyle);
          final textPainter = TextPainter(
            text: textSpan,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout(minWidth: 0, maxWidth: beadSize);
          final textOffset = Offset(
            rect.center.dx - textPainter.width / 2,
            rect.center.dy - textPainter.height / 2,
          );
          textPainter.paint(canvas, textOffset);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Simplified for MVP
  }
}
