import 'dart:math';
import 'package:flutter/material.dart';

class CarnivalBackground extends StatelessWidget {
  final AnimationController controller;
  const CarnivalBackground({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              colors: [Colors.pinkAccent, Colors.deepPurple],
              center: Alignment(0.0, -0.4),
              radius: 1.2,
            ),
          ),
          child: Stack(
            children: [
              // 🎈 Floating balloons
              ...List.generate(6, (i) {
                final progress = (controller.value + i * 0.15) % 1;
                final dx = (i.isEven ? i * 50.0 : i * 70.0) % size.width;
                final dy = size.height - (progress * size.height);

                return Positioned(
                  left: dx,
                  top: dy,
                  child: Transform.scale(
                    scale: 0.8 + 0.2 * sin(progress * 2 * pi),
                    child: Icon(
                      Icons.circle,
                      size: 30 + (i % 3) * 15,
                      color: Colors.primaries[i * 2 % Colors.primaries.length],
                    ),
                  ),
                );
              }),

              // 🎉 Falling confetti
              ...List.generate(15, (i) {
                final progress = (controller.value * 2 + i * 0.07) % 1;
                final dx = (i * 40.0 + progress * 200) % size.width;
                final dy = progress * size.height;

                return Positioned(
                  left: dx,
                  top: dy,
                  child: Transform.rotate(
                    angle: progress * 6.28,
                    child: Container(
                      width: 6,
                      height: 12,
                      color: Colors.accents[i % Colors.accents.length],
                    ),
                  ),
                );
              }),

              // 💡 Twinkling carnival lights
              ...List.generate(12, (i) {
                final blink = sin(controller.value * 8 * pi + i);
                final color = blink > 0
                    ? Colors.yellowAccent
                    : Colors.orangeAccent.withOpacity(0.5);

                return Positioned(
                  left: (i * 50) % size.width,
                  top: i.isEven ? 20 : 50,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color,
                          blurRadius: 6,
                          spreadRadius: 2,
                        )
                      ],
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
