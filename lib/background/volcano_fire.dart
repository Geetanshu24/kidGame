import 'dart:math';
import 'package:flutter/material.dart';

class VolcanoFireBackground extends StatefulWidget {
  final AnimationController controller;
  const VolcanoFireBackground({Key? key, required this.controller})
      : super(key: key);

  @override
  State<VolcanoFireBackground> createState() => _VolcanoFireBackgroundState();
}

class _VolcanoFireBackgroundState extends State<VolcanoFireBackground> {
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
                Color(0xfffff176), // bright yellow
                Color(0xffff7043), // orange
                Color(0xffe53935), // red
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // Lava bubbles floating up
              ...List.generate(10, (i) {
                final bubbleX = (i * width / 10) +
                    sin(widget.controller.value * 2 * pi + i) * 25;
                final bubbleY =
                    height - ((widget.controller.value * 250 + i * 120) % (height + 200));

                return Positioned(
                  left: bubbleX,
                  top: bubbleY,
                  child: Container(
                    width: 18 + random.nextInt(12).toDouble(),
                    height: 18 + random.nextInt(12).toDouble(),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orangeAccent.withOpacity(0.7),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellow.withOpacity(0.9),
                          blurRadius: 10,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // Colorful sparks
              ...List.generate(20, (i) {
                final sparkX = random.nextDouble() * width;
                final sparkY = (widget.controller.value * 400 + i * 50) % height;

                final sparkColors = [
                  Colors.yellowAccent,
                  Colors.orangeAccent,
                  Colors.pinkAccent,
                  Colors.redAccent
                ];

                return Positioned(
                  left: sparkX,
                  bottom: sparkY,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: sparkColors[i % sparkColors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),

              // Lava splashes out of crater
              ...List.generate(6, (i) {
                final splashX =
                    width * 0.5 + cos(widget.controller.value * 2 * pi + i) * 50;
                final splashY =
                    120 - sin(widget.controller.value * 2 * pi + i) * 60;

                return Positioned(
                  left: splashX,
                  top: splashY,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.deepOrangeAccent,
                    ),
                  ),
                );
              }),

              // Cartoon volcano at the bottom
              Positioned(
                bottom: 0,
                left: width * 0.2,
                child: CustomPaint(
                  size: Size(width * 0.6, 180),
                  painter: CuteVolcanoPainter(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CuteVolcanoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Volcano base
    paint.color = Colors.brown.shade700;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.35, 0)
      ..lineTo(size.width * 0.65, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);

    // Lava flowing
    paint.color = Colors.orangeAccent;
    final lavaPath = Path()
      ..moveTo(size.width * 0.45, 0)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.5,
          size.width * 0.48, size.height)
      ..lineTo(size.width * 0.52, size.height)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.5,
          size.width * 0.55, 0)
      ..close();
    canvas.drawPath(lavaPath, paint);

    // Cartoon Eyes
    paint.color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.4), 12, paint);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.4), 12, paint);

    paint.color = Colors.black;
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.4), 6, paint);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.4), 6, paint);

    // Smile
    final smilePath = Path()
      ..moveTo(size.width * 0.42, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.65,
          size.width * 0.58, size.height * 0.55);
    paint
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(smilePath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
