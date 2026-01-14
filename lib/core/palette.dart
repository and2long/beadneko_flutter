import 'dart:math';
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
  // Perler Bead Colors - Official Color Palette (Complete List)
  static final List<BeadColor> _baseColors = [
    // Core Colors (13 colors - available in 1000/6000 bead bags)
    BeadColor(code: 'P01', name: 'White', color: Color(0xFFFFFFFF)),
    BeadColor(code: 'P02', name: 'Creme', color: Color(0xFFFFFDD0)),
    BeadColor(code: 'P03', name: 'Yellow', color: Color(0xFFFFFF00)),
    BeadColor(code: 'P04', name: 'Orange', color: Color(0xFFFFA500)),
    BeadColor(code: 'P05', name: 'Red', color: Color(0xFFE60000)),
    BeadColor(code: 'P08', name: 'Dark Blue', color: Color(0xFF00008B)),
    BeadColor(code: 'P09', name: 'Light Blue', color: Color(0xFFADD8E6)),
    BeadColor(code: 'P10', name: 'Dark Green', color: Color(0xFF006400)),
    BeadColor(code: 'P11', name: 'Light Green', color: Color(0xFF90EE90)),
    BeadColor(code: 'P12', name: 'Brown', color: Color(0xFFA52A2A)),
    BeadColor(code: 'P17', name: 'Grey', color: Color(0xFF808080)),
    BeadColor(code: 'P18', name: 'Black', color: Color(0xFF000000)),
    BeadColor(code: 'P19', name: 'Clear', color: Color(0x80FFFFFF)),

    // Extended Solid Colors
    BeadColor(code: 'P20', name: 'Rust', color: Color(0xFFB7410E)),
    BeadColor(code: 'P21', name: 'Light Brown', color: Color(0xFFC4A484)),
    BeadColor(code: 'P33', name: 'Peach', color: Color(0xFFFFDAB9)),
    BeadColor(code: 'P35', name: 'Tan', color: Color(0xFFD2B48C)),
    BeadColor(code: 'P38', name: 'Magenta', color: Color(0xFFFF00FF)),
    BeadColor(code: 'P47', name: 'Neon Yellow', color: Color(0xFFFFFF00)),
    BeadColor(code: 'P48', name: 'Neon Orange', color: Color(0xFFFF6600)),
    BeadColor(code: 'P49', name: 'Neon Green', color: Color(0xFF39FF14)),
    BeadColor(code: 'P50', name: 'Neon Pink', color: Color(0xFFFF6FFF)),
    BeadColor(code: 'P52', name: 'Pastel Blue', color: Color(0xFFB0E0E6)),
    BeadColor(code: 'P53', name: 'Pastel Green', color: Color(0xFF98FB98)),
    BeadColor(code: 'P54', name: 'Pastel Lavender', color: Color(0xFFE6E6FA)),
    BeadColor(code: 'P56', name: 'Pastel Yellow', color: Color(0xFFFFFFE0)),
    BeadColor(code: 'P57', name: 'Cheddar', color: Color(0xFFFFC845)),
    BeadColor(code: 'P58', name: 'Toothpaste', color: Color(0xFF40E0D0)),
    BeadColor(code: 'P59', name: 'Hot Coral', color: Color(0xFFFF6B6B)),
    BeadColor(code: 'P60', name: 'Plum', color: Color(0xFFDDA0DD)),
    BeadColor(code: 'P61', name: 'Kiwi Lime', color: Color(0xFF9ACD32)),
    BeadColor(code: 'P62', name: 'Turquoise', color: Color(0xFF40E0D0)),
    BeadColor(code: 'P63', name: 'Blush', color: Color(0xFFDE5D83)),
    BeadColor(code: 'P70', name: 'Periwinkle Blue', color: Color(0xFFCCCCFF)),
    BeadColor(code: 'P75', name: 'Glow in the Dark Green', color: Color(0xFF66FF66)),
    BeadColor(code: 'P79', name: 'Light Pink', color: Color(0xFFFFB6C1)),
    BeadColor(code: 'P80', name: 'Bright Green', color: Color(0xFF00FF00)),
    BeadColor(code: 'P83', name: 'Pink', color: Color(0xFFFF69B4)),
    BeadColor(code: 'P84', name: 'Gold Metallic', color: Color(0xFFFFD700)),
    BeadColor(code: 'P85', name: 'Raspberry', color: Color(0xFFE30B5D)),
    BeadColor(code: 'P90', name: 'Butterscotch', color: Color(0xFFE6B800)),
    BeadColor(code: 'P91', name: 'Parrot Green', color: Color(0xFF32CD32)),
    BeadColor(code: 'P92', name: 'Dark Grey', color: Color(0xFFA9A9A9)),
    BeadColor(code: 'P93', name: 'Blueberry Cream', color: Color(0xFFE3F2FD)),
    BeadColor(code: 'P96', name: 'Cranapple', color: Color(0xFFDC143C)),
    BeadColor(code: 'P97', name: 'Prickly Pear', color: Color(0xFFB06F00)),
    BeadColor(code: 'P98', name: 'Sand', color: Color(0xFFC2B280)),
    BeadColor(code: 'P105', name: 'Pearl Silver', color: Color(0xFFC0C0C0)),
    BeadColor(code: 'P179', name: 'Evergreen', color: Color(0xFF1B4D3E)),
    BeadColor(code: 'P181', name: 'Light Grey', color: Color(0xFFD3D3D3)),
    BeadColor(code: 'P182', name: 'Lavender', color: Color(0xFFE6E6FA)),
    BeadColor(code: 'P184', name: 'Clear Blue', color: Color(0x800000FF)),
    BeadColor(code: 'P185', name: 'Copper', color: Color(0xFFB87333)),
    BeadColor(code: 'P187', name: 'Clear Glitter', color: Color(0x80FFFFFF)),
    BeadColor(code: 'P188', name: 'Kiwi Glitter', color: Color(0xFF98FF98)),
    BeadColor(code: 'P191', name: 'Pink Glitter', color: Color(0xFFFFB6C1)),
    BeadColor(code: 'P192', name: 'White Glitter', color: Color(0xFFFFFAFA)),
    BeadColor(code: 'P199', name: 'Shamrock', color: Color(0xFF009900)),
    BeadColor(code: 'P200', name: 'Cobalt', color: Color(0xFF0047AB)),
    BeadColor(code: 'P201', name: 'Midnight', color: Color(0xFF191970)),
    BeadColor(code: 'P202', name: "Robin's Egg", color: Color(0xFF87CEEB)),
    BeadColor(code: 'P203', name: 'Flamingo', color: Color(0xFFFF99CC)),
    BeadColor(code: 'P204', name: 'Salmon', color: Color(0xFFFA8072)),
    BeadColor(code: 'P205', name: 'Fawn', color: Color(0xFFE5CAA8)),
    BeadColor(code: 'P206', name: 'Pewter', color: Color(0xFFB9B9B9)),
    BeadColor(code: 'P207', name: 'Charcoal', color: Color(0xFF36454F)),
    BeadColor(code: 'P208', name: 'Toasted Marshmallow', color: Color(0xFFF5E6D3)),
    BeadColor(code: 'P210', name: 'Orchid', color: Color(0xFFDA70D6)),
    BeadColor(code: 'P211', name: 'Tomato', color: Color(0xFFFF6347)),
    BeadColor(code: 'P212', name: 'Spice', color: Color(0xFFCD853F)),
    BeadColor(code: 'P213', name: 'Apricot', color: Color(0xFFFBCEB1)),
    BeadColor(code: 'P214', name: 'Sherbet', color: Color(0xFFFFE4C4)),
    BeadColor(code: 'P215', name: 'Mist', color: Color(0xFFD3D3D3)),
    BeadColor(code: 'P216', name: 'Sky', color: Color(0xFF87CEEB)),
    BeadColor(code: 'P217', name: 'Lagoon', color: Color(0xFF0099CC)),
    BeadColor(code: 'P218', name: 'Teal', color: Color(0xFF008080)),
    BeadColor(code: 'P219', name: 'Fern', color: Color(0xFF4F7942)),
    BeadColor(code: 'P220', name: 'Olive', color: Color(0xFF808000)),
    BeadColor(code: 'P240', name: 'Mint', color: Color(0xFF98FF98)),
    BeadColor(code: 'P241', name: 'Sour Apple', color: Color(0xFF76FF03)),
    BeadColor(code: 'P242', name: 'Cotton Candy', color: Color(0xFFFFB7C5)),
    BeadColor(code: 'P243', name: 'Grape', color: Color(0xFF800080)),
    BeadColor(code: 'P244', name: 'Rose', color: Color(0xFFFF007F)),
    BeadColor(code: 'P245', name: 'Iris', color: Color(0xFF5A4FCF)),
    BeadColor(code: 'P246', name: 'Tangerine', color: Color(0xFFFF9966)),
    BeadColor(code: 'P247', name: 'Forest', color: Color(0xFF228B22)),
    BeadColor(code: 'P248', name: 'Eggplant', color: Color(0xFF4B0082)),
    BeadColor(code: 'P249', name: 'Honey', color: Color(0xFFECB21E)),
    BeadColor(code: 'P250', name: 'Gingerbread', color: Color(0xFFC68E17)),
    BeadColor(code: 'P251', name: 'Thistle', color: Color(0xFFD8BFD8)),
    BeadColor(code: 'P252', name: 'Denim', color: Color(0xFF5F7DCE)),
    BeadColor(code: 'P253', name: 'Sage', color: Color(0xFF9DC183)),
    BeadColor(code: 'P254', name: 'Orange Cream', color: Color(0xFFFFCC80)),
    BeadColor(code: 'P255', name: 'Fruit Punch', color: Color(0xFFFF6B9D)),
    BeadColor(code: 'P256', name: 'Fuchsia', color: Color(0xFFFF77FF)),
    BeadColor(code: 'P257', name: 'Mulberry', color: Color(0xFF870083)),
    BeadColor(code: 'P258', name: 'Slime', color: Color(0xFFA0C020)),
    BeadColor(code: 'P259', name: 'Stone', color: Color(0xFF788890)),
    BeadColor(code: 'P260', name: 'Dark Spruce', color: Color(0xFF0F4F3E)),
    BeadColor(code: 'P261', name: 'Cocoa', color: Color(0xFF403010)),
    BeadColor(code: 'P262', name: 'Slate Blue', color: Color(0xFF6A5ACD)),
    BeadColor(code: 'P265', name: 'Twilight Plum', color: Color(0xFF6A0DAD)),
    BeadColor(code: 'P266', name: 'Caribbean Sea', color: Color(0xFF1E90FF)),
    BeadColor(code: 'P267', name: 'Frosted Lilac', color: Color(0xFFDCD0FF)),
    BeadColor(code: 'P961', name: 'Cherry', color: Color(0xFFC4081F)),

    // Striped Beads
    BeadColor(code: 'P108', name: 'Zebra Stripe', color: Color(0xFF000000)),
    BeadColor(code: 'P113', name: 'Cucumber Stripe', color: Color(0xFF32CD32)),
    BeadColor(code: 'P136', name: 'Cinnamon Stripe', color: Color(0xFF8B0000)),
    BeadColor(code: 'P161', name: 'Buttercream Stripe', color: Color(0xFFFFFF00)),
    BeadColor(code: 'P172', name: 'Camo Stripe', color: Color(0xFF556B2F)),
    BeadColor(code: 'P174', name: 'Cherry Blossom Stripe', color: Color(0xFFFFB7C5)),
    BeadColor(code: 'P177', name: 'Patriotic Stripe', color: Color(0xFF0000FF)),
  ];

  static List<BeadColor>? _cachedAllColors;

  static List<BeadColor> get allColors {
    if (_cachedAllColors != null) return _cachedAllColors!;
    _cachedAllColors = _baseColors;
    return _cachedAllColors!;
  }

  static List<BeadColor> getPalette(int size) {
    final full = allColors;
    // Ensure we don't exceed bounds
    int safeSize = size;
    if (safeSize > full.length) safeSize = full.length;
    if (safeSize < 1) safeSize = full.length;

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
    final lab1 = _toLab(c1);
    final lab2 = _toLab(c2);
    final dL = lab1[0] - lab2[0];
    final dA = lab1[1] - lab2[1];
    final dB = lab1[2] - lab2[2];
    return dL * dL + dA * dA + dB * dB;
  }

  static List<double> _toLab(Color color) {
    // sRGB -> linear RGB
    double r = color.red / 255.0;
    double g = color.green / 255.0;
    double b = color.blue / 255.0;

    r = r <= 0.04045 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4).toDouble();
    g = g <= 0.04045 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4).toDouble();
    b = b <= 0.04045 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4).toDouble();

    // linear RGB -> XYZ (D65)
    final x = (r * 0.4124 + g * 0.3576 + b * 0.1805);
    final y = (r * 0.2126 + g * 0.7152 + b * 0.0722);
    final z = (r * 0.0193 + g * 0.1192 + b * 0.9505);

    // XYZ -> Lab
    const xn = 0.95047;
    const yn = 1.00000;
    const zn = 1.08883;

    double fx = _pivotLab(x / xn);
    double fy = _pivotLab(y / yn);
    double fz = _pivotLab(z / zn);

    final l = (116.0 * fy) - 16.0;
    final a = 500.0 * (fx - fy);
    final b2 = 200.0 * (fy - fz);
    return [l, a, b2];
  }

  static double _pivotLab(double t) {
    return t > 0.008856 ? pow(t, 1.0 / 3.0).toDouble() : (7.787 * t) + 16 / 116;
  }
}
