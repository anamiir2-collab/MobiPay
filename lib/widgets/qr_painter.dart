import 'dart:math';

import 'package:flutter/material.dart';

/// Deterministic demo QR pattern.
///
/// ⚠️ This is a VISUAL PLACEHOLDER — the rendered modules are not a valid
/// QR symbol. Production must use qr_flutter (or the PSP SDK) with a real
/// EMVCo/InstaPay payload so terminals and banking apps can parse it.
class DemoQrPainter extends CustomPainter {
  final String seed;
  final Color color;
  DemoQrPainter({this.seed = 'mobipay-demo', this.color = const Color(0xFF101828)});

  @override
  void paint(Canvas canvas, Size size) {
    const modules = 25;
    final cell = size.width / modules;
    final paint = Paint()..color = color;
    final rnd = Random(seed.hashCode);

    // finder patterns (three corners)
    void finder(int ox, int oy) {
      for (var y = 0; y < 7; y++) {
        for (var x = 0; x < 7; x++) {
          final edge = x == 0 || y == 0 || x == 6 || y == 6;
          final core = x >= 2 && x <= 4 && y >= 2 && y <= 4;
          if (edge || core) {
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                  Rect.fromLTWH((ox + x) * cell, (oy + y) * cell, cell, cell),
                  const Radius.circular(1.5)),
              paint,
            );
          }
        }
      }
    }

    for (var y = 0; y < modules; y++) {
      for (var x = 0; x < modules; x++) {
        final inFinder = (x < 8 && y < 8) || (x >= modules - 8 && y < 8) || (x < 8 && y >= modules - 8);
        if (inFinder) continue;
        if (rnd.nextBool() && rnd.nextDouble() > 0.42) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(x * cell, y * cell, cell * 0.92, cell * 0.92),
                const Radius.circular(1)),
            paint,
          );
        }
      }
    }
    finder(0, 0);
    finder(modules - 7, 0);
    finder(0, modules - 7);
  }

  @override
  bool shouldRepaint(covariant DemoQrPainter oldDelegate) => oldDelegate.seed != seed;
}
