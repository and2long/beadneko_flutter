import 'dart:io';
import 'dart:ui' as ui;

import 'package:beadneko/components/grid_view.dart'; // To access BeadGridPainter
import 'package:beadneko/core/pixel_processor.dart';
import 'package:flutter/material.dart';
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
      final double beadSize = 20.0; // High res for export
      final double width = cols * beadSize;
      final double height = rows * beadSize;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

      // Draw white background
      canvas.drawRect(
        Rect.fromLTWH(0, 0, width, height),
        Paint()..color = Colors.white,
      );

      final painter = BeadGridPainter(
        grid: grid,
        beadSize: beadSize,
        showCodes: true,
      );
      painter.paint(canvas, Size(width, height));

      final picture = recorder.endRecording();
      final img = await picture.toImage(width.toInt(), height.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return false;

      final buffer = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/beadneko_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(buffer);

      // Save to gallery
      final result = await ImageGallerySaverPlus.saveFile(file.path);
      return result['isSuccess'] ?? false;
    } catch (e) {
      debugPrint("Error saving image: $e");
      return false;
    }
  }
}
