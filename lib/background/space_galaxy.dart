import 'dart:math';
import 'package:flutter/material.dart';

class SpaceGalaxyBackground extends StatefulWidget {
  final AnimationController controller;
  const SpaceGalaxyBackground({super.key, required this.controller});

  @override
  State<SpaceGalaxyBackground> createState() => _SpaceGalaxyBackgroundState();
}

class _SpaceGalaxyBackgroundState extends State<SpaceGalaxyBackground> {
  final Random random = Random();

  // Random stars
  final List<Offset> stars = List.generate(
    80,
        (index) => Offset(
      Random().nextDouble() * 400,
      Random().nextDouble() * 800,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (_, __) {
        double t = widget.controller.value;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Twinkling Stars
              ...stars.map((star) {
                double twinkle =
                (0.4 + 0.6 * sin(t * 2 * pi * random.nextDouble())).clamp(0.0, 1.0);

                return Positioned(
                  left: star.dx,
                  top: star.dy,
                  child: Opacity(
                    opacity: twinkle,
                    child: const Icon(Icons.star, color: Colors.white, size: 5),
                  ),
                );
              }),

              // Orbiting Planet 🪐
              Positioned(
                left: width * 0.5 + 80 * cos(t * 2 * pi) - 25,
                top: height * 0.3 + 40 * sin(t * 2 * pi) - 25,
                child: const Text("🪐", style: TextStyle(fontSize: 50)),
              ),

              // Floating Earth 🌍
              Positioned(
                left: width * 0.2,
                top: height * 0.2 + 20 * sin(t * 2 * pi),
                child: const Text("🌍", style: TextStyle(fontSize: 45)),
              ),

              // Alien 👽 bobbing up and down
              Positioned(
                right: 50,
                top: height * 0.5 + 40 * sin(t * 4 * pi),
                child: const Text("👽", style: TextStyle(fontSize: 40)),
              ),

              // Rocket 🚀 flying across and looping
              Positioned(
                left: (width + 100) * (t % 1.0) - 100,
                top: height * 0.6 - 80 * sin(t * 2 * pi),
                child: const Text("🚀", style: TextStyle(fontSize: 55)),
              ),

              // UFO 🛸 slowly moving diagonally
              Positioned(
                left: width * (0.1 + 0.8 * (t % 1.0)),
                top: height * (0.1 + 0.2 * (sin(t * 2 * pi))),
                child: const Text("🛸", style: TextStyle(fontSize: 45)),
              ),
            ],
          ),
        );
      },
    );
  }
}
