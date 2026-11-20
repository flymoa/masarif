import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Logo "Khatam": njma maghribiya dhbiya, dirham f lwost, o harf M.
/// [progress] 0 → 1 kaydir l animation dyal dekhla (1 = logo kamel).
class KhatamLogo extends StatelessWidget {
  const KhatamLogo({super.key, this.size = 96, this.progress = 1, this.gold = const Color(0xFFE9B949), this.green = const Color(0xFF134232)});

  final double size;
  final double progress;
  final Color gold, green;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Masarif',
        image: true,
        child: CustomPaint(size: Size.square(size), painter: _KhatamPainter(progress, gold, green)),
      );
}

double _seg(double t, double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);

class _KhatamPainter extends CustomPainter {
  _KhatamPainter(this.t, this.gold, this.green);
  final double t;
  final Color gold, green;

  @override
  void paint(Canvas canvas, Size size) {
    // Koulchi mrsoum f espace 100×100 mcentré.
    final s = size.width / 100;
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(s);

    final star = Paint()..color = gold;
    final sq = RRect.fromRectAndRadius(const Rect.fromLTWH(-30, -30, 60, 60), const Radius.circular(6));

    // 1) Jouj morab3at kaydkhlo b rotation (0 → 0.45)
    for (var i = 0; i < 2; i++) {
      final k = Curves.easeOutBack.transform(_seg(t, 0.05 * i, 0.45 + 0.05 * i));
      if (k <= 0) continue;
      canvas.save();
      canvas.rotate((i * 45 + (1 - k) * -135) * math.pi / 180);
      canvas.scale(k);
      canvas.drawRRect(sq, star);
      canvas.restore();
    }

    // 2) Dirham f lwost (0.35 → 0.6)
    final core = Curves.easeOutBack.transform(_seg(t, 0.35, 0.6));
    if (core > 0) {
      canvas.save();
      canvas.scale(core);
      canvas.drawCircle(Offset.zero, 21, Paint()..color = green);
      canvas.drawCircle(
        Offset.zero,
        14,
        Paint()
          ..color = gold
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
      canvas.restore();
    }

    // 3) Harf M kayttrsem (0.55 → 0.85)
    final draw = Curves.easeOut.transform(_seg(t, 0.55, 0.85));
    if (draw > 0) {
      final m = Path()
        ..moveTo(-6, 6)
        ..lineTo(-6, -6)
        ..lineTo(0, 1)
        ..lineTo(6, -6)
        ..lineTo(6, 6);
      final metric = m.computeMetrics().first;
      canvas.drawPath(
        metric.extractPath(0, metric.length * draw),
        Paint()
          ..color = gold
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(_KhatamPainter old) => old.t != t || old.gold != gold || old.green != green;
}
