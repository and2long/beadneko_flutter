import 'dart:ui';
import 'package:flutter/material.dart';

class BeadColor {
  final String code;
  final String name;
  final Color color;

  const BeadColor({
    required this.code,
    required this.name,
    required this.color,
  });
}

class Palette {
  // Base colors (approx 100 high quality ones)
  static final List<BeadColor> _baseColors = [
    // Grayscale (10)
    BeadColor(code: 'C001', name: 'White', color: Color(0xFFFFFFFF)),
    BeadColor(code: 'C002', name: 'Cream', color: Color(0xFFF0F8FF)),
    BeadColor(code: 'C003', name: 'Snow', color: Color(0xFFFFFAFA)),
    BeadColor(code: 'C004', name: 'Light Grey', color: Color(0xFFD3D3D3)),
    BeadColor(code: 'C005', name: 'Grey', color: Color(0xFF808080)),
    BeadColor(code: 'C006', name: 'Dark Grey', color: Color(0xFFA9A9A9)),
    BeadColor(code: 'C007', name: 'Charcoal', color: Color(0xFF36454F)),
    BeadColor(code: 'C008', name: 'Slate', color: Color(0xFF708090)),
    BeadColor(code: 'C009', name: 'Black', color: Color(0xFF000000)),
    BeadColor(code: 'C010', name: 'Clear', color: Color(0x80FFFFFF)),

    // Reds (15)
    BeadColor(code: 'C011', name: 'Red', color: Color(0xFFFF0000)),
    BeadColor(code: 'C012', name: 'Dark Red', color: Color(0xFF8B0000)),
    BeadColor(code: 'C013', name: 'Crimson', color: Color(0xFFDC143C)),
    BeadColor(code: 'C014', name: 'Firebrick', color: Color(0xFFB22222)),
    BeadColor(code: 'C015', name: 'Pink', color: Color(0xFFFFC0CB)),
    BeadColor(code: 'C016', name: 'Light Pink', color: Color(0xFFFFB6C1)),
    BeadColor(code: 'C017', name: 'Hot Pink', color: Color(0xFFFF69B4)),
    BeadColor(code: 'C018', name: 'Deep Pink', color: Color(0xFFFF1493)),
    BeadColor(code: 'C019', name: 'Magenta', color: Color(0xFFFF00FF)),
    BeadColor(code: 'C020', name: 'Orchid', color: Color(0xFFDA70D6)),
    BeadColor(code: 'C021', name: 'Salmon', color: Color(0xFFFA8072)),
    BeadColor(code: 'C022', name: 'Coral', color: Color(0xFFFF7F50)),
    BeadColor(code: 'C023', name: 'Tomato', color: Color(0xFFFF6347)),
    BeadColor(code: 'C024', name: 'Indian Red', color: Color(0xFFCD5C5C)),
    BeadColor(code: 'C025', name: 'Maroon', color: Color(0xFF800000)),

    // Oranges & Yellows (15)
    BeadColor(code: 'C026', name: 'Orange', color: Color(0xFFFFA500)),
    BeadColor(code: 'C027', name: 'Dark Orange', color: Color(0xFFFF8C00)),
    BeadColor(code: 'C028', name: 'Gold', color: Color(0xFFFFD700)),
    BeadColor(code: 'C029', name: 'Yellow', color: Color(0xFFFFFF00)),
    BeadColor(code: 'C030', name: 'Light Yellow', color: Color(0xFFFFFFE0)),
    BeadColor(code: 'C031', name: 'Lemon', color: Color(0xFFFFFACD)),
    BeadColor(code: 'C032', name: 'Papaya', color: Color(0xFFFFEFD5)),
    BeadColor(code: 'C033', name: 'Moccasin', color: Color(0xFFFFE4B5)),
    BeadColor(code: 'C034', name: 'Peach', color: Color(0xFFFFDAB9)),
    BeadColor(code: 'C035', name: 'Khaki', color: Color(0xFFF0E68C)),
    BeadColor(code: 'C036', name: 'Dark Khaki', color: Color(0xFFBDB76B)),
    BeadColor(code: 'C037', name: 'Goldenrod', color: Color(0xFFDAA520)),
    BeadColor(code: 'C038', name: 'Dark Goldenrod', color: Color(0xFFB8860B)),
    BeadColor(code: 'C039', name: 'Peru', color: Color(0xFFCD853F)),
    BeadColor(code: 'C040', name: 'Chocolate', color: Color(0xFFD2691E)),

    // Greens (20)
    BeadColor(code: 'C041', name: 'Green', color: Color(0xFF008000)),
    BeadColor(code: 'C042', name: 'Dark Green', color: Color(0xFF006400)),
    BeadColor(code: 'C043', name: 'Lime', color: Color(0xFF00FF00)),
    BeadColor(code: 'C044', name: 'Lime Green', color: Color(0xFF32CD32)),
    BeadColor(code: 'C045', name: 'Pale Green', color: Color(0xFF98FB98)),
    BeadColor(code: 'C046', name: 'Light Green', color: Color(0xFF90EE90)),
    BeadColor(code: 'C047', name: 'Spring Green', color: Color(0xFF00FF7F)),
    BeadColor(code: 'C048', name: 'Sea Green', color: Color(0xFF2E8B57)),
    BeadColor(code: 'C049', name: 'Forest Green', color: Color(0xFF228B22)),
    BeadColor(code: 'C050', name: 'Olive', color: Color(0xFF808000)),
    BeadColor(code: 'C051', name: 'Olive Drab', color: Color(0xFF6B8E23)),
    BeadColor(code: 'C052', name: 'Dark Olive', color: Color(0xFF556B2F)),
    BeadColor(code: 'C053', name: 'Teal', color: Color(0xFF008080)),
    BeadColor(code: 'C054', name: 'Dark Cyan', color: Color(0xFF008B8B)),
    BeadColor(code: 'C055', name: 'Light Sea Green', color: Color(0xFF20B2AA)),
    BeadColor(code: 'C056', name: 'Aquamarine', color: Color(0xFF7FFFD4)),
    BeadColor(code: 'C057', name: 'Turquoise', color: Color(0xFF40E0D0)),
    BeadColor(code: 'C058', name: 'Medium Turquoise', color: Color(0xFF48D1CC)),
    BeadColor(code: 'C059', name: 'Dark Turquoise', color: Color(0xFF00CED1)),
    BeadColor(code: 'C060', name: 'Cadet Blue', color: Color(0xFF5F9EA0)),

    // Blues (15)
    BeadColor(code: 'C061', name: 'Blue', color: Color(0xFF0000FF)),
    BeadColor(code: 'C062', name: 'Medium Blue', color: Color(0xFF0000CD)),
    BeadColor(code: 'C063', name: 'Dark Blue', color: Color(0xFF00008B)),
    BeadColor(code: 'C064', name: 'Navy', color: Color(0xFF000080)),
    BeadColor(code: 'C065', name: 'Midnight Blue', color: Color(0xFF191970)),
    BeadColor(code: 'C066', name: 'Royal Blue', color: Color(0xFF4169E1)),
    BeadColor(code: 'C067', name: 'Cornflower', color: Color(0xFF6495ED)),
    BeadColor(code: 'C068', name: 'Dodger Blue', color: Color(0xFF1E90FF)),
    BeadColor(code: 'C069', name: 'Deep Sky Blue', color: Color(0xFF00BFFF)),
    BeadColor(code: 'C070', name: 'Light Sky Blue', color: Color(0xFF87CEFA)),
    BeadColor(code: 'C071', name: 'Sky Blue', color: Color(0xFF87CEEB)),
    BeadColor(code: 'C072', name: 'Steel Blue', color: Color(0xFF4682B4)),
    BeadColor(code: 'C073', name: 'Light Steel Blue', color: Color(0xFFB0C4DE)),
    BeadColor(code: 'C074', name: 'Powder Blue', color: Color(0xFFB0E0E6)),
    BeadColor(code: 'C075', name: 'Light Blue', color: Color(0xFFADD8E6)),

    // Purples (10)
    BeadColor(code: 'C076', name: 'Purple', color: Color(0xFF800080)),
    BeadColor(code: 'C077', name: 'Indigo', color: Color(0xFF4B0082)),
    BeadColor(code: 'C078', name: 'Dark Slate Blue', color: Color(0xFF483D8B)),
    BeadColor(code: 'C079', name: 'Slate Blue', color: Color(0xFF6A5ACD)),
    BeadColor(
      code: 'C080',
      name: 'Medium Slate Blue',
      color: Color(0xFF7B68EE),
    ),
    BeadColor(code: 'C081', name: 'Medium Purple', color: Color(0xFF9370DB)),
    BeadColor(code: 'C082', name: 'Blue Violet', color: Color(0xFF8A2BE2)),
    BeadColor(code: 'C083', name: 'Dark Violet', color: Color(0xFF9400D3)),
    BeadColor(code: 'C084', name: 'Dark Orchid', color: Color(0xFF9932CC)),
    BeadColor(code: 'C085', name: 'Thistle', color: Color(0xFFD8BFD8)),

    // Browns & Misc (10)
    BeadColor(code: 'C086', name: 'Saddle Brown', color: Color(0xFF8B4513)),
    BeadColor(code: 'C087', name: 'Sienna', color: Color(0xFFA0522D)),
    BeadColor(code: 'C088', name: 'Brown', color: Color(0xFFA52A2A)),
    BeadColor(code: 'C089', name: 'Rosy Brown', color: Color(0xFFBC8F8F)),
    BeadColor(code: 'C090', name: 'Sandy Brown', color: Color(0xFFF4A460)),
    BeadColor(code: 'C091', name: 'Goldenrod', color: Color(0xFFDAA520)),
    BeadColor(code: 'C092', name: 'Tan', color: Color(0xFFD2B48C)),
    BeadColor(code: 'C093', name: 'Burlywood', color: Color(0xFFDEB887)),
    BeadColor(code: 'C094', name: 'Wheat', color: Color(0xFFF5DEB3)),
    BeadColor(code: 'C095', name: 'Navajo White', color: Color(0xFFFFDEAD)),
  ];

  static List<BeadColor>? _cachedAllColors;

  static List<BeadColor> get allColors {
    if (_cachedAllColors != null) return _cachedAllColors!;

    // Start with base colors
    List<BeadColor> colors = List.from(_baseColors);

    // Algorithmic expansion to reach user requested 291
    int index = 96;
    for (var base in _baseColors) {
      if (index > 291) break;
      // Lighter
      colors.add(
        BeadColor(
          code: 'C${index.toString().padLeft(3, '0')}',
          name: 'Light ${base.name}',
          color: Color.alphaBlend(Colors.white.withOpacity(0.3), base.color),
        ),
      );
      index++;

      if (index > 291) break;
      // Darker
      colors.add(
        BeadColor(
          code: 'C${index.toString().padLeft(3, '0')}',
          name: 'Deep ${base.name}',
          color: Color.alphaBlend(Colors.black.withOpacity(0.3), base.color),
        ),
      );
      index++;
    }

    // Fill remaining if any
    while (index <= 291) {
      // Create some random pastel or varying hues
      final double hue = (index * 137.5) % 360;
      final HSVColor hsv = HSVColor.fromAHSV(1.0, hue, 0.7, 0.9);
      colors.add(
        BeadColor(
          code: 'C${index.toString().padLeft(3, '0')}',
          name: 'Custom $index',
          color: hsv.toColor(),
        ),
      );
      index++;
    }

    _cachedAllColors = colors;
    return colors;
  }

  static List<BeadColor> getPalette(int size) {
    final full = allColors;
    // Ensure we don't exceed bounds
    int safeSize = size;
    if (safeSize > full.length) safeSize = full.length;
    if (safeSize < 0) safeSize = full.length;

    return full.sublist(0, safeSize);
  }

  static BeadColor findClosestColor(Color target, List<BeadColor> palette) {
    BeadColor? closest;
    double minDistance = double.infinity;

    for (var bead in palette) {
      double distance = _colorDistance(target, bead.color);
      if (distance < minDistance) {
        minDistance = distance;
        closest = bead;
      }
    }
    return closest!;
  }

  static double _colorDistance(Color c1, Color c2) {
    double r = (c1.r - c2.r);
    double g = (c1.g - c2.g);
    double b = (c1.b - c2.b);
    return r * r + g * g + b * b;
  }
}
