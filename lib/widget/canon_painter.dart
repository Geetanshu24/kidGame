import 'package:flutter/material.dart';

class CannonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..shader = LinearGradient(colors: [Colors.grey.shade900, Colors.grey.shade700]).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final basePaint = Paint()..shader = LinearGradient(colors: [Colors.brown.shade700, Colors.brown.shade900]).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final accent = Paint()..color = Colors.yellowAccent.withOpacity(0.9);

    // draw barrel (rounded rectangle)
    final barrelRect = RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.18, size.height * 0.12, size.width * 0.64, size.height * 0.30), const Radius.circular(10));
    canvas.drawRRect(barrelRect, bodyPaint);

    // barrel inner shine
    final innerRect = RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.26, size.height * 0.16, size.width * 0.48, size.height * 0.18), const Radius.circular(8));
    canvas.drawRRect(innerRect, Paint()..color = Colors.grey.shade300.withOpacity(0.08));

    // muzzle glow
    final muzzleCenter = Offset(size.width * 0.82, size.height * 0.28);
    canvas.drawCircle(muzzleCenter, size.width * 0.07, Paint()..color = Colors.orangeAccent.withOpacity(0.25));

    // base
    final baseRect = RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.05, size.height * 0.46, size.width * 0.9, size.height * 0.36), const Radius.circular(12));
    canvas.drawRRect(baseRect, basePaint);

    // wheels / feet
    final wheelPaint = Paint()..color = Colors.black87;
    canvas.drawCircle(Offset(size.width * 0.20, size.height * 0.82), size.width * 0.10, wheelPaint);
    canvas.drawCircle(Offset(size.width * 0.80, size.height * 0.82), size.width * 0.10, wheelPaint);

    // small accent bolt
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.68), size.width * 0.04, accent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}