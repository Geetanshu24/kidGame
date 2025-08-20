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
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: widget.controller, curve: Curves.linear),
    );
    widget.controller.repeat(period: const Duration(seconds: 20));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.red.shade300,
                Colors.orange.shade300,
                Colors.yellow.shade300,
                Colors.green.shade300,
                Colors.blue.shade300,
                Colors.purple.shade300,
              ],
              transform: GradientRotation(animation.value * 2 * pi),
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(child: CloudLayer()),       // Clouds
              Positioned.fill(child: TwinklingStars()),   // Stars
              Positioned.fill(child: FloatingBalloons()), // Balloons 🎈
              Positioned(top: 40, right: 40, child: CuteSun()), // Sun ☀️
            ],
          ),
        );
      },
    );
  }
}

/// Cute Sun ☀️
class CuteSun extends StatefulWidget {
  @override
  State<CuteSun> createState() => _CuteSunState();
}

class _CuteSunState extends State<CuteSun> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 10))
      ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [Colors.yellow.shade400, Colors.orange.shade700],
          ),
          boxShadow: [
            BoxShadow(color: Colors.yellow.withOpacity(0.6), blurRadius: 20),
          ],
        ),
        child: Center(
          child: Icon(Icons.tag_faces, size: 40, color: Colors.white),
        ),
      ),
    );
  }
}

/// Clouds ☁️
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
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    cloudController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return AnimatedBuilder(
      animation: cloudController,
      builder: (context, child) {
        final offset = cloudController.value * width;
        return Stack(
          children: [
            Positioned(left: -200 + offset, top: 80, child: Cloud()),
            Positioned(right: -300 + offset, top: 180, child: Cloud()),
            Positioned(left: -250 + offset, bottom: 100, child: Cloud()),
          ],
        );
      },
    );
  }
}

class Cloud extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 25),
        ],
      ),
      child: Stack(
        children: [
          Positioned(left: -25, top: 10, child: CircleAvatar(radius: 30, backgroundColor: Colors.white)),
          Positioned(right: -20, bottom: 8, child: CircleAvatar(radius: 25, backgroundColor: Colors.white)),
        ],
      ),
    );
  }
}

/// Stars ✨
class TwinklingStars extends StatefulWidget {
  @override
  _TwinklingStarsState createState() => _TwinklingStarsState();
}

class _TwinklingStarsState extends State<TwinklingStars>
    with SingleTickerProviderStateMixin {
  late AnimationController starController;
  final Random _random = Random();
  late List<Offset> starPositions;

  @override
  void initState() {
    super.initState();
    starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    starPositions = List.generate(
      40,
          (i) => Offset(_random.nextDouble() * 400, _random.nextDouble() * 200),
    );
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
          painter: StarPainter(starController.value, starPositions),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }
}

class StarPainter extends CustomPainter {
  final double opacity;
  final List<Offset> positions;
  StarPainter(this.opacity, this.positions);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3 + opacity * 0.7)
      ..style = PaintingStyle.fill;

    for (var pos in positions) {
      canvas.drawCircle(pos, 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarPainter oldDelegate) => true;
}

/// Floating Balloons 🎈
class FloatingBalloons extends StatefulWidget {
  @override
  _FloatingBalloonsState createState() => _FloatingBalloonsState();
}

class _FloatingBalloonsState extends State<FloatingBalloons>
    with SingleTickerProviderStateMixin {
  late AnimationController balloonController;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    balloonController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    balloonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: balloonController,
      builder: (context, child) {
        return Stack(
          children: List.generate(5, (i) {
            final dx = (i * 80).toDouble() + 50;
            final dy = height - (balloonController.value * (height + 100)) - (i * 60);
            return Positioned(
              left: dx,
              top: dy % height,
              child: Balloon(color: Colors.primaries[i % Colors.primaries.length]),
            );
          }),
        );
      },
    );
  }
}

class Balloon extends StatelessWidget {
  final Color color;
  const Balloon({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 55,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10)],
      ),
    );
  }
}
