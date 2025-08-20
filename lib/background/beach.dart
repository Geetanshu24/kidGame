import 'dart:math';
import 'package:flutter/material.dart';

class BeachBackground extends StatelessWidget {
  final AnimationController controller;
  const BeachBackground({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightBlueAccent, Colors.yellowAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // 🌞 Sun at the top
              Positioned(
                top: 40,
                left: 30 + 20 * sin(controller.value * 2 * pi),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.yellow,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.6),
                        blurRadius: 30,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                  child: const Center(
                    child: Text("😊", style: TextStyle(fontSize: 30)),
                  ),
                ),
              ),

              // ☁️ Moving clouds
              ...List.generate(3, (i) {
                final dx = (controller.value * 200 + i * 150) % size.width;
                return Positioned(
                  top: 60.0 + i * 40,
                  left: dx,
                  child: Container(
                    width: 100,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                );
              }),

              // 🌊 Ocean waves
              ...List.generate(5, (i) {
                final dy = size.height - 100 + i * 15;
                return Positioned(
                  bottom: i * 10.0,
                  left: 0,
                  right: 0,
                  child: CustomPaint(
                    size: Size(size.width, 40),
                    painter: _WavePainter(
                      progress: controller.value + i * 0.2,
                      color: Colors.blueAccent.withOpacity(0.6 - i * 0.1),
                    ),
                  ),
                );
              }),

              // 🐠 Floating fish
              ...List.generate(4, (i) {
                final dx = (controller.value * size.width * 0.8 + i * 200) %
                    size.width;
                final dy = size.height - 120 - (i.isEven ? 30 : 60);
                return Positioned(
                  left: dx,
                  top: dy,
                  child: Text(
                    "🐠",
                    style: TextStyle(fontSize: 30 + (i % 2) * 10),
                  ),
                );
              }),

              // 🏖️ Beach ball at bottom
              Positioned(
                bottom: 20,
                right: 40,
                child: Text("🏖️", style: TextStyle(fontSize: 50)),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 🎨 Painter for animated waves
class _WavePainter extends CustomPainter {
  final double progress;
  final Color color;
  _WavePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    for (double x = 0; x <= size.width; x++) {
      final y = sin((x / size.width * 2 * pi) + progress * 2 * pi) * 8 + 20;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => true;
}
