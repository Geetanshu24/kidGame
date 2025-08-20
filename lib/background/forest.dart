import 'dart:math';
import 'package:flutter/material.dart';

class ForestBackground extends StatefulWidget {
  final AnimationController controller;
  const ForestBackground({Key? key, required this.controller})
      : super(key: key);

  @override
  State<ForestBackground> createState() => _ForestBackgroundState();
}

class _ForestBackgroundState extends State<ForestBackground> {
  final Random random = Random();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (_, __) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xffa8e063), // light green
                Color(0xff56ab2f), // dark green
                Color(0xff6dd5ed), // sky blue
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // Sun
              Positioned(
                top: 60,
                left: width * 0.3,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.yellowAccent,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow,
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),

              // Cartoon trees at the bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: Size(width, 180),
                  painter: CartoonForestPainter(),
                ),
              ),

              // Cute animals
              const Positioned(
                left: 40,
                bottom: 140,
                child: Text("🦊", style: TextStyle(fontSize: 40)),
              ),
              const Positioned(
                right: 40,
                bottom: 150,
                child: Text("🐰", style: TextStyle(fontSize: 40)),
              ),

              // Animated Butterfly
              AnimatedButterfly(controller: widget.controller),
            ],
          ),
        );
      },
    );
  }
}

class CartoonForestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Grass base
    paint.color = Colors.green.shade700;
    canvas.drawRect(Rect.fromLTWH(0, size.height - 50, size.width, 50), paint);

    // Trees
    final treePositions = [50.0, 150.0, 250.0, 350.0, 450.0];
    for (var x in treePositions) {
      // Trunk
      paint.color = Colors.brown;
      canvas.drawRect(Rect.fromLTWH(x, size.height - 100, 20, 50), paint);

      // Leaves (circle bushy top)
      paint.color = Colors.greenAccent.shade700;
      canvas.drawCircle(Offset(x + 10, size.height - 110), 40, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// 🦋 Animated Butterfly Widget
class AnimatedButterfly extends StatelessWidget {
  final AnimationController controller;
  const AnimatedButterfly({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        // Circular flying path
        final dx = width / 2 + 100 * cos(controller.value * 2 * pi);
        final dy = height / 2 + 80 * sin(controller.value * 2 * pi);

        // Wing flapping (scale)
        final flap = 0.8 + 0.4 * sin(controller.value * 6 * pi);

        return Positioned(
          left: dx,
          top: dy,
          child: Transform.scale(
            scale: flap,
            child: const Text(
              "🦋",
              style: TextStyle(fontSize: 40),
            ),
          ),
        );
      },
    );
  }
}
