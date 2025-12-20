import 'dart:typed_data';

import 'package:flutter/material.dart'
    as material; // Alias to avoid conflict with image package
import 'package:image/image.dart' as img;

import 'palette.dart';

class ProcessedPixel {
  final BeadColor? bead; // Null means transparent/no bead
  final int x;
  final int y;

  ProcessedPixel({required this.bead, required this.x, required this.y});
}

class PixelProcessor {
  static Future<List<List<ProcessedPixel>>> processImage(
    Uint8List imageBytes,
    int targetSize,
    List<BeadColor> palette,
  ) async {
    // 1. Decode image
    final cmd = img.Command()
      ..decodeImage(imageBytes)
      ..copyResize(
        width: targetSize,
        height: targetSize,
        interpolation: img.Interpolation.nearest,
      )
      ..execute();

    final decodedImage = await cmd.getImageThread();

    if (decodedImage == null) {
      throw Exception("Failed to decode image");
    }

    // 2. Map pixels to palette
    List<List<ProcessedPixel>> grid = [];

    for (int y = 0; y < decodedImage.height; y++) {
      List<ProcessedPixel> row = [];
      for (int x = 0; x < decodedImage.width; x++) {
        final pixel = decodedImage.getPixel(x, y);

        // Check transparency
        if (pixel.a < 10) {
          row.add(ProcessedPixel(bead: null, x: x, y: y));
          continue;
        }

        final color = material.Color.fromARGB(
          pixel.a.toInt(),
          pixel.r.toInt(),
          pixel.g.toInt(),
          pixel.b.toInt(),
        );

        // Basic heuristic: if white (R=G=B=255), treat as transparent?
        // User said "Pattern inside, area outside no color".
        // Often easier to just assume pure white is background for now or rely on PNG alpha.
        // I'll stick to alpha for now. If user uploads JPEG, they might need white removal.
        // Let's add a simple check: if >250 on all channels, treat as bg?
        // Maybe unsafe for white beads.
        // Sticking to Alpha for now as "Identification" implies finding the object.
        // If image has no alpha, we can't easily guess.
        // BUT, user's input implies automatic "recognition".
        // Without ML, I can't do object detection.
        // I will rely on Alpha channel. Most "bead pattern" makers expect transparent PNGs or create them.

        final bead = Palette.findClosestColor(color, palette);
        row.add(ProcessedPixel(bead: bead, x: x, y: y));
      }
      grid.add(row);
    }

    return grid;
  }
}
