import 'dart:io';
import 'dart:ui' as ui;

import 'package:beadneko/components/grid_view.dart'; // To access BeadGridPainter
import 'package:beadneko/core/palette.dart';
import 'package:beadneko/core/pixel_processor.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';

class ImageSaver {
  static Future<bool> saveGridImage(
    List<List<ProcessedPixel>> grid,
    int pixelSize,
  ) async {
    try {
      final int rows = grid.length;
      final int cols = grid[0].length;
      final double beadSize = 80.0; // High resolution for clear export

      // Calculate color statistics
      final Map<BeadColor, int> colorStats = {};
      for (var row in grid) {
        for (var pixel in row) {
          if (pixel.bead != null) {
            colorStats.update(
              pixel.bead!,
              (value) => value + 1,
              ifAbsent: () => 1,
            );
          }
        }
      }

      // Sort colors by count (descending)
      final sortedColors = colorStats.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Layout dimensions
      const double borderPadding = 80.0; // White border around entire image
      const double headerHeight = 200.0; // Increased header height
      const double itemHeight = 120.0; // Height per color item (increased)
      const double itemsPerRow = 5; // Colors per row
      final int colorRows = (sortedColors.length / itemsPerRow).ceil();
      final double footerHeight = 200 + (colorRows * itemHeight); // Dynamic footer height with more padding

      final double gridWidth = cols * beadSize;
      final double gridHeight = rows * beadSize;
      final double totalWidth = gridWidth + (borderPadding * 2);
      final double totalHeight = borderPadding + headerHeight + gridHeight + footerHeight + borderPadding;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, totalWidth, totalHeight));

      // Draw white background
      canvas.drawRect(
        Rect.fromLTWH(0, 0, totalWidth, totalHeight),
        Paint()..color = Colors.white,
      );

      // Draw app name at top left (larger font)
      final appNamePainter = TextPainter(
        text: const TextSpan(
          text: 'Beadneko',
          style: TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF4081),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      appNamePainter.layout();
      appNamePainter.paint(canvas, Offset(borderPadding + 30, borderPadding + 50));

      // Draw grid size info in header
      final gridSizePainter = TextPainter(
        text: TextSpan(
          text: 'Grid: ${cols} × $rows  |  Pixels: $pixelSize',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      gridSizePainter.layout();
      gridSizePainter.paint(
        canvas,
        Offset(totalWidth - gridSizePainter.width - borderPadding - 30, borderPadding + 65),
      );

      // Draw grid below header
      canvas.save();
      canvas.translate(borderPadding, borderPadding + headerHeight);

      // Draw gray border around grid
      final borderRect = Rect.fromLTWH(0, 0, gridWidth, gridHeight);
      final gridBorderPaint = Paint()
        ..color = Colors.grey[400]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawRect(borderRect, gridBorderPaint);

      final painter = BeadGridPainter(
        grid: grid,
        beadSize: beadSize,
        showCodes: true,
      );
      painter.paint(canvas, Size(gridWidth, gridHeight));
      canvas.restore();

      // Draw color statistics footer
      final double footerY = borderPadding + headerHeight + gridHeight;

      // Draw section title
      final titlePainter = TextPainter(
        text: TextSpan(
          text: 'Color Statistics (${sortedColors.length} types)',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1C1E),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      titlePainter.layout();
      titlePainter.paint(
        canvas,
        Offset(borderPadding + 30, footerY + 80),
      );

      // Draw color items in a grid layout
      final double itemWidth = gridWidth / itemsPerRow;

      for (int i = 0; i < sortedColors.length; i++) {
        final entry = sortedColors[i];
        final row = i ~/ itemsPerRow;
        final col = i % itemsPerRow;

        final double x = borderPadding + (col * itemWidth);
        final double y = footerY + 180 + (row * itemHeight);

        // Draw bead shadow (glow effect)
        final shadowOffset = 12.0;
        final shadowBlur = 16.0;
        final shadowPaint = Paint()
          ..color = entry.key.color.withOpacity(0.3)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlur);
        canvas.drawCircle(
          Offset(x + 60, y + 50 + shadowOffset),
          40,
          shadowPaint,
        );

        // Draw bead (circle)
        final beadPaint = Paint()
          ..color = entry.key.color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(x + 60, y + 50),
          40,
          beadPaint,
        );

        // Draw border
        final borderPaint = Paint()
          ..color = Colors.black12
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(
          Offset(x + 60, y + 50),
          40,
          borderPaint,
        );

        // Draw small center square decoration
        final centerRect = Rect.fromLTWH(x + 52, y + 42, 16, 16);
        final centerPaint = Paint()
          ..color = Colors.black12
          ..style = PaintingStyle.fill;
        canvas.drawRect(centerRect, centerPaint);

        // Draw color code text
        final codePainter = TextPainter(
          text: TextSpan(
            text: entry.key.code,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1C1E),
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        codePainter.layout();
        codePainter.paint(canvas, Offset(x + 115, y + 15));

        // Draw color count
        final countPainter = TextPainter(
          text: TextSpan(
            text: '× ${entry.value}',
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF4081),
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        countPainter.layout();
        countPainter.paint(canvas, Offset(x + 115, y + 52));
      }

      final picture = recorder.endRecording();
      final uiImage = await picture.toImage(
        totalWidth.toInt(),
        totalHeight.toInt(),
      );
      final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return false;

      // Convert PNG to JPG using image package
      final pngBytes = byteData.buffer.asUint8List();
      final decodedImage = img.decodePng(pngBytes);

      if (decodedImage == null) return false;

      // Encode as JPG with high quality
      final jpgBytes = img.encodeJpg(decodedImage, quality: 100);

      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/beadneko_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(jpgBytes);

      // Save to gallery
      final result = await ImageGallerySaverPlus.saveFile(file.path);
      return result['isSuccess'] ?? false;
    } catch (e) {
      debugPrint("Error saving image: $e");
      return false;
    }
  }
}
