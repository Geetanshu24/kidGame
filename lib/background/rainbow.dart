import 'dart:math';
import 'package:flutter/material.dart';

class RainbowBackground extends StatefulWidget {
  final AnimationController controller;
  const RainbowBackground({Key? key, required this.controller}) : super(key: key);

  @override
  State<RainbowBackground> createState() => _RainbowBackgroundState();
}

class _RainbowBackgroundState extends State<RainbowBackground>
    with SingleTickerProviderStateMixin {
  late Animation<double> rotation;

  @override
  void initState() {
    super.initState();
    rotation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: widget.controller, curve: Curves.linear),
    );
    widget.controller.repeat(period: const Duration(seconds: 25)); // slower rotation
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: rotation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: SweepGradient(
              center: FractionalOffset.center,
              startAngle: rotation.value,
              endAngle: rotation.value + 2 * pi,
              colors: const [
                Colors.red,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.indigo,
                Colors.purple,
                Colors.red,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Floating clouds
              Positioned.fill(child: CloudLayer()),

              // Twinkling stars
              Positioned.fill(child: TwinklingStars()),
            ],
          ),
        );
      },
    );
  }
}

/// Cloud Layer: adds soft, animated clouds floating horizontally
class CloudLayer extends StatefulWidget {
  @override
  _CloudLayerState createState() => _CloudLayerState();
}

class _CloudLayerState extends State<CloudLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController cloudController;

  @override
  void initState() {
    super.initState();
    cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    cloudController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: cloudController,
      builder: (context, child) {
        final offset = cloudController.value * MediaQuery.of(context).size.width;

        return Stack(
          children: [
            Positioned(
              left: -200 + offset,
              top: 80,
              child: Cloud(),
            ),
            Positioned(
              right: -200 + offset,
              top: 200,
              child: Cloud(),
            ),
            Positioned(
              left: -250 + offset,
              bottom: 100,
              child: Cloud(),
            ),
          ],
        );
      },
    );
  }
}

/// Simple fluffy cloud widget
class Cloud extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(color: Colors.white.withOpacity(0.6), blurRadius: 20),
        ],
      ),
    );
  }
}

/// Twinkling stars painter
class TwinklingStars extends StatefulWidget {
  @override
  _TwinklingStarsState createState() => _TwinklingStarsState();
}

class _TwinklingStarsState extends State<TwinklingStars>
    with SingleTickerProviderStateMixin {
  late AnimationController starController;

  @override
  void initState() {
    super.initState();
    starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: starController,
      builder: (context, child) {
        return CustomPaint(
          painter: StarPainter(starController.value),
        );
      },
    );
  }
}

class StarPainter extends CustomPainter {
  final double opacity;
  final Random _random = Random();

  StarPainter(this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3 + opacity * 0.7)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 50; i++) {
      final dx = _random.nextDouble() * size.width;
      final dy = _random.nextDouble() * size.height;
      final radius = _random.nextDouble() * 2 + 1;
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarPainter oldDelegate) => true;
}
