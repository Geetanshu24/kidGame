import 'package:flutter/material.dart';
import 'dart:math';

class MagicalKidsBackground extends StatelessWidget {
  final AnimationController controller;
  const MagicalKidsBackground({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rainbowColors = [
      Colors.redAccent,
      Colors.orangeAccent,
      Colors.yellowAccent,
      Colors.greenAccent,
      Colors.blueAccent,
      Colors.indigoAccent,
      Colors.purpleAccent,
    ];

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final width = MediaQuery.of(context).size.width;
        final height = MediaQuery.of(context).size.height;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF81D4FA), // light sky blue
                Color(0xFF4FC3F7), // deeper sky
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Twinkling stars ✨
              ...List.generate(40, (i) {
                final x = (i * 80 + controller.value * width * 0.3) % width;
                final y = (i * 100 + controller.value * height * 0.4) % height;
                final twinkle =
                    0.5 + 0.5 * sin(controller.value * 6 * pi + i);

                return Positioned(
                  left: x,
                  top: y,
                  child: Opacity(
                    opacity: twinkle,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),

              // Floating rainbow bubbles 🌈
              ...List.generate(14, (i) {
                final x = (i * 120 +
                    sin(controller.value * 2 * pi + i) * 100 +
                    controller.value * width * 0.5) %
                    width;

                final y = (height -
                    ((controller.value * height * 0.9) +
                        (i * 70) % height)) %
                    height;

                final scale = 1.0 +
                    0.4 * sin(controller.value * 2 * pi + i * 0.5);

                return Positioned(
                  left: x,
                  top: y,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 20 + (i % 4) * 5,
                      height: 20 + (i % 4) * 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            rainbowColors[i % rainbowColors.length],
                            Colors.white,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: rainbowColors[i % rainbowColors.length]
                                .withOpacity(0.6),
                            blurRadius: 20,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // Cartoon clouds ☁️
              ...List.generate(10, (i) {
                final x = (controller.value * width * 0.2 + i * 200) % width;
                final y = 100.0 + (i * 80);

                return Positioned(
                  left: x,
                  top: y,
                  child: Opacity(
                    opacity: 0.6,
                    child: Container(
                      width: 120,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            blurRadius: 20,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                    ),
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
