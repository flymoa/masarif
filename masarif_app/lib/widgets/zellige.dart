import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Motif dyal zellige maghribi: njma dyal l khatam (dhbiya) + njma sghira khdra
/// f lwost + noqta, o morab3at m3awjin binathom. Kayt3awd kol [tile] px.
class ZelligePainter extends CustomPainter {
  ZelligePainter({this.tile = 38, this.opacity = 0.45, this.originX = 0, this.originY = 0});

  final double tile;
  final double opacity;
  final double originX, originY;

  static const _gold = Color(0xFFE8B53C);
  static const _dark = Color(0xFF0B2E22);
  static const _mint = Color(0xFF7FBF9B);
  static const _gem = Color(0xFF2E6B52);

  void _star(Canvas c, Offset o, double half, Paint p) {
    final r = Rect.fromCenter(center: Offset.zero, width: half * 2, height: half * 2);
    c.save();
    c.translate(o.dx, o.dy);
    c.drawRect(r, p);
    c.rotate(math.pi / 4);
    c.drawRect(r, p);
    c.restore();
  }

  void _diamond(Canvas c, Offset o, double half, Paint p) {
    c.save();
    c.translate(o.dx, o.dy);
    c.rotate(math.pi / 4);
    c.drawRect(Rect.fromCenter(center: Offset.zero, width: half * 2, height: half * 2), p);
    c.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final a = (255 * opacity).round();
    final gold = Paint()..color = _gold.withAlpha(a);
    final dark = Paint()..color = _dark.withAlpha(a);
    final mint = Paint()..color = _mint.withAlpha(a);
    final gem = Paint()..color = _gem.withAlpha(a);
    final s = tile;
    final startX = originX - s * ((originX / s).ceil());
    final startY = originY - s * ((originY / s).ceil());
    for (var y = startY; y < size.height + s; y += s) {
      for (var x = startX; x < size.width + s; x += s) {
        final center = Offset(x + s / 2, y + s / 2);
        _star(canvas, center, s * 0.224, gold);
        _star(canvas, center, s * 0.132, dark);
        canvas.drawCircle(center, s * 0.063, mint);
        _diamond(canvas, Offset(x, y), s * 0.1, gem);
      }
    }
  }

  @override
  bool shouldRepaint(ZelligePainter old) => old.tile != tile || old.opacity != opacity;
}

/// Zellige li kaytghbber l jiha wa7da (bach l texte yb9a wad7).
class ZelligeBackground extends StatelessWidget {
  const ZelligeBackground({
    super.key,
    required this.color,
    this.fadeFrom = Alignment.centerLeft,
    this.fadeTo = Alignment.centerRight,
    this.opacity = 0.5,
    this.tile = 44,
    this.stops = const [0.35, 0.9],
  });

  final Color color;
  final Alignment fadeFrom, fadeTo;
  final double opacity;
  final double tile;
  final List<double> stops;

  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
        CustomPaint(painter: ZelligePainter(tile: tile, opacity: opacity)),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: fadeFrom, end: fadeTo, colors: [color, color.withAlpha(0)], stops: stops),
          ),
        ),
      ]);
}

/// Bab maghribi (9aws) m3ammar b zellige — l carte dyal Dwayr zman.
class ArchZellige extends StatelessWidget {
  const ArchZellige({super.key, this.width = 124, this.height = 170});
  final double width, height;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width + 24,
        height: height,
        child: CustomPaint(painter: _ArchPainter(width)),
      );
}

class _ArchPainter extends CustomPainter {
  _ArchPainter(this.w);
  final double w;

  Path _arch(double left, double width, double h) {
    final r = width / 2;
    return Path()
      ..moveTo(left, h)
      ..lineTo(left, r)
      ..arcToPoint(Offset(left + width, r), radius: Radius.circular(r))
      ..lineTo(left + width, h);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final left = (size.width - w) / 2;
    final inner = _arch(left, w, size.height)..close();
    canvas.save();
    canvas.clipPath(inner);
    canvas.translate(left, 0);
    ZelligePainter(tile: w / 4, opacity: 1).paint(canvas, Size(w, size.height));
    canvas.restore();
    canvas.drawPath(
      _arch(left, w, size.height),
      Paint()
        ..color = const Color(0xFFE8B53C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    canvas.drawPath(
      _arch(left - 12, w + 24, size.height),
      Paint()
        ..color = const Color(0x80E8B53C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_ArchPainter old) => old.w != w;
}
