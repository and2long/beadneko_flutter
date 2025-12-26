import 'dart:io';
import 'dart:ui' as ui;

import 'package:beadneko/components/grid_view.dart'; // To access BeadGridPainter
import 'package:beadneko/core/palette.dart';
import 'package:beadneko/core/pixel_processor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';

// Top-level function for compute (must be static or top-level)
Future<Uint8List> _convertPngToJpg(Uint8List pngBytes) async {
  final decodedImage = img.decodePng(pngBytes);
  if (decodedImage == null) throw Exception('Failed to decode PNG');
  final jpgBytes = img.encodeJpg(decodedImage, quality: 92);
  return jpgBytes;
}

class ImageSaver {
  static Future<bool> saveGridImage(
    List<List<ProcessedPixel>> grid,
    int pixelSize,
    String languageCode,
    String appName,
  ) async {
    try {
      final int rows = grid.length;
      final int cols = grid[0].length;
      final double beadSize = 40.0; // Balanced resolution for quality and file size

      // Localized strings
      String colorStatsTitle;
      String gridLabel;
      String typesLabel;

      switch (languageCode) {
        case 'zh':
          colorStatsTitle = '颜色统计';
          gridLabel = '网格';
          typesLabel = '种';
          break;
        case 'ja':
          colorStatsTitle = 'カラー統計';
          gridLabel = 'グリッド';
          typesLabel = '種類';
          break;
        default:
          colorStatsTitle = 'Color Statistics';
          gridLabel = 'Grid';
          typesLabel = 'types';
      }

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

      // Calculate grid dimensions first
      final double gridWidth = cols * beadSize;
      final double gridHeight = rows * beadSize;

      // Calculate all dimensions based on grid width for consistent proportions
      const double borderPadding = 80.0; // White border around entire image
      final double headerHeight = gridWidth * 0.15; // Header is 15% of grid width
      final double itemHeight = gridWidth * 0.08; // Each color item is 8% of grid width
      const double itemsPerRow = 5; // Colors per row
      final int colorRows = (sortedColors.length / itemsPerRow).ceil();
      final double footerHeight = (gridWidth * 0.12) + (colorRows * itemHeight); // Footer with dynamic height

      final double totalWidth = gridWidth + (borderPadding * 2);
      final double totalHeight = borderPadding + headerHeight + gridHeight + footerHeight + borderPadding;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, totalWidth, totalHeight));

      // Draw white background
      canvas.drawRect(
        Rect.fromLTWH(0, 0, totalWidth, totalHeight),
        Paint()..color = Colors.white,
      );

      // Calculate all sizes based on grid width for consistent proportions
      final double appNameFontSize = gridWidth * 0.035; // 3.5% of grid width
      final double gridSizeFontSize = gridWidth * 0.014; // 1.4% of grid width
      final double footerTitleFontSize = gridWidth * 0.020; // 2% of grid width
      final double colorCodeFontSize = gridWidth * 0.014; // 1.4% of grid width
      final double colorCountFontSize = gridWidth * 0.016; // 1.6% of grid width
      final double beadRadius = gridWidth * 0.012; // 1.2% of grid width

      // Calculate spacing based on grid width
      final double headerTopPadding = headerHeight * 0.30; // 30% from top
      final double headerBottomPadding = headerHeight * 0.25; // 25% from bottom
      final double footerTitlePadding = gridWidth * 0.05; // 5% of grid width
      final double footerListPadding = gridWidth * 0.12; // 12% of grid width

      // Draw app name at top left (larger font)
      final appNamePainter = TextPainter(
        text: TextSpan(
          text: appName,
          style: TextStyle(
            fontSize: appNameFontSize,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF4081),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      appNamePainter.layout();
      appNamePainter.paint(canvas, Offset(borderPadding + 30, borderPadding + headerTopPadding));

      // Draw grid size info in header
      final gridSizePainter = TextPainter(
        text: TextSpan(
          text: '$gridLabel: $cols × $rows',
          style: TextStyle(
            fontSize: gridSizeFontSize,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      gridSizePainter.layout();
      gridSizePainter.paint(
        canvas,
        Offset(totalWidth - gridSizePainter.width - borderPadding - 30, borderPadding + headerHeight - headerBottomPadding - gridSizePainter.height),
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
          text: '$colorStatsTitle (${sortedColors.length} $typesLabel)',
          style: TextStyle(
            fontSize: footerTitleFontSize,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1C1E),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      titlePainter.layout();
      titlePainter.paint(
        canvas,
        Offset(borderPadding + 30, footerY + footerTitlePadding),
      );

      // Draw color items in a grid layout
      final double itemWidth = gridWidth / itemsPerRow;

      for (int i = 0; i < sortedColors.length; i++) {
        final entry = sortedColors[i];
        final row = i ~/ itemsPerRow;
        final col = i % itemsPerRow;

        final double x = borderPadding + (col * itemWidth);
        final double y = footerY + footerListPadding + (row * itemHeight);

        // Calculate bead position and size based on proportions
        final double beadCenterX = x + (beadRadius * 1.5);
        final double beadCenterY = y + (itemHeight * 0.45);
        final double shadowOffset = beadRadius * 0.25;
        final double shadowBlur = beadRadius * 0.4;
        final double textStartX = x + (beadRadius * 3.2);

        // Draw bead shadow (glow effect)
        final shadowPaint = Paint()
          ..color = entry.key.color.withValues(alpha: 0.3)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlur);
        canvas.drawCircle(
          Offset(beadCenterX, beadCenterY + shadowOffset),
          beadRadius,
          shadowPaint,
        );

        // Draw bead (circle)
        final beadPaint = Paint()
          ..color = entry.key.color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(beadCenterX, beadCenterY),
          beadRadius,
          beadPaint,
        );

        // Draw border
        final borderPaint = Paint()
          ..color = Colors.black12
          ..style = PaintingStyle.stroke
          ..strokeWidth = beadRadius * 0.05;
        canvas.drawCircle(
          Offset(beadCenterX, beadCenterY),
          beadRadius,
          borderPaint,
        );

        // Draw small center square decoration
        final centerSize = beadRadius * 0.4;
        final centerRect = Rect.fromLTWH(
          beadCenterX - (centerSize / 2),
          beadCenterY - (centerSize / 2),
          centerSize,
          centerSize,
        );
        final centerPaint = Paint()
          ..color = Colors.black12
          ..style = PaintingStyle.fill;
        canvas.drawRect(centerRect, centerPaint);

        // Draw color code text
        final codePainter = TextPainter(
          text: TextSpan(
            text: entry.key.code,
            style: TextStyle(
              fontSize: colorCodeFontSize,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1C1E),
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        codePainter.layout();
        codePainter.paint(canvas, Offset(textStartX, y + (itemHeight * 0.20)));

        // Draw color count
        final countPainter = TextPainter(
          text: TextSpan(
            text: '× ${entry.value}',
            style: TextStyle(
              fontSize: colorCountFontSize,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF4081),
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        countPainter.layout();
        countPainter.paint(canvas, Offset(textStartX, y + (itemHeight * 0.42)));
      }

      final picture = recorder.endRecording();

      final uiImage = await picture.toImage(
        totalWidth.toInt(),
        totalHeight.toInt(),
      );

      final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return false;

      // Convert PNG to JPG using image package in background thread
      final pngBytes = byteData.buffer.asUint8List();

      // Use compute to run conversion in isolate
      final jpgBytes = await compute(_convertPngToJpg, pngBytes);

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
