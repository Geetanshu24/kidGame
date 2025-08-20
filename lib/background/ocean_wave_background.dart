import 'dart:math';
import 'package:flutter/material.dart';

class OceanWaveBackground extends StatefulWidget {
  final AnimationController controller;
  const OceanWaveBackground({Key? key, required this.controller})
      : super(key: key);

  @override
  State<OceanWaveBackground> createState() => _OceanWaveBackgroundState();
}

class _OceanWaveBackgroundState extends State<OceanWaveBackground> {
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
                Color(0xff87ceeb), // light sky blue
                Color(0xff1e90ff), // ocean blue
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // Multiple animated wave layers
              ...List.generate(3, (i) {
                return Positioned(
                  bottom: i * 40.0,
                  left: 0,
                  right: 0,
                  child: CustomPaint(
                    size: Size(width, 120),
                    painter: WavePainter(
                      waveHeight: 30 + i * 10,
                      phase: widget.controller.value * 2 * pi + i,
                      color: Colors.white.withOpacity(0.3 - i * 0.05),
                    ),
                  ),
                );
              }),

              // Floating bubbles
              ...List.generate(8, (i) {
                final bubbleX = (i * width / 8) +
                    sin(widget.controller.value * 2 * pi + i) * 20;
                final bubbleY = height -
                    ((widget.controller.value * 300 + i * 80) % (height + 200));

                return Positioned(
                  left: bubbleX,
                  top: bubbleY,
                  child: Container(
                    width: 20 + random.nextInt(10).toDouble(),
                    height: 20 + random.nextInt(10).toDouble(),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                );
              }),

              // Cute fish swimming
              Positioned(
                left: width / 2 +
                    cos(widget.controller.value * 2 * pi) * (width / 3),
                bottom: 100 +
                    sin(widget.controller.value * 2 * pi) * 50,
                child: Icon(
                  Icons.favorite, // can replace with fish asset
                  color: Colors.orangeAccent,
                  size: 40,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double waveHeight;
  final double phase;
  final Color color;

  WavePainter({required this.waveHeight, required this.phase, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = sin((x / size.width * 2 * pi) + phase) * waveHeight +
          (size.height - waveHeight);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}
