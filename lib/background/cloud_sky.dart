import 'dart:math';
import 'package:flutter/material.dart';

class CloudySkyBackground extends StatelessWidget {
  final AnimationController controller;
  const CloudySkyBackground({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightBlueAccent, Colors.cyanAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // ☀️ Sun
              Positioned(
                top: 80,
                right: 40,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.yellowAccent,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.6),
                        blurRadius: 50,
                        spreadRadius: 20,
                      )
                    ],
                  ),
                ),
              ),

              // ☁️ Clouds (different speeds & sizes)
              ...List.generate(8, (i) {
                final speed = 0.2 + (i % 3) * 0.15; // parallax speed
                final size = 80.0 + (i % 3) * 40.0; // varied cloud sizes
                final x = (t * width * speed + i * 200) % (width + size) - size;
                final y = 50.0 + (i * 60) % (height * 0.6);

                return Positioned(
                  left: x,
                  top: y + 5 * sin(t * 2 * pi + i), // gentle wobble
                  child: Opacity(
                    opacity: 0.85,
                    child: Container(
                      width: size,
                      height: size * 0.6,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.7),
                            blurRadius: 20,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // 🕊️ Birds flying
              ...List.generate(3, (i) {
                final x = width - (t * width * 0.5 + i * 250) % (width + 100);
                final y = 150.0 + 60 * sin(t * 2 * pi + i);
                return Positioned(
                  left: x,
                  top: y,
                  child: const Text(
                    "🕊️",
                    style: TextStyle(fontSize: 30),
                  ),
                );
              }),

              // 🎈 Balloons drifting
              ...List.generate(2, (i) {
                final y = height - (t * height * 0.2 + i * 300) % (height + 100);
                final x = 50.0 + i * 120 + 30 * sin(t * 2 * pi + i);
                return Positioned(
                  left: x,
                  top: y,
                  child: const Text(
                    "🎈",
                    style: TextStyle(fontSize: 40),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
