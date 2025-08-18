import 'package:flutter/material.dart';

import '../model/particles.dart';

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      final opacity = (p.life / 60).clamp(0.0, 1.0);
      paint.color = p.color.withOpacity(opacity);
      canvas.drawCircle(p.pos, p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}

class BulletTrailPainter extends CustomPainter {
  final List<Offset> trail;
  BulletTrailPainter({required this.trail});

  @override
  void paint(Canvas canvas, Size size) {
    if (trail.isEmpty) return;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < trail.length; i++) {
      final p = trail[i];
      final alpha = (1 - (i / trail.length)).clamp(0.0, 1.0);
      paint.color = Colors.orange.withOpacity(0.9 * alpha);
      canvas.drawCircle(p, 6.0 * (1 - i / (trail.length + 2)), paint);
    }
  }

  @override
  bool shouldRepaint(covariant BulletTrailPainter oldDelegate) => true;
}