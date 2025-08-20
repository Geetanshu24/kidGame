import 'package:flutter/material.dart';
import 'dart:math';

/// 🌈 1. Magical Kids Background (Your existing one)
class MagicalKids1Background extends StatelessWidget {
  final AnimationController controller;
  const MagicalKids1Background({Key? key, required this.controller})
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
              colors: [Color(0xFF81D4FA), Color(0xFF4FC3F7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Stars
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
                    child: const CircleAvatar(radius: 2, backgroundColor: Colors.white),
                  ),
                );
              }),

              // Rainbow bubbles
              ...List.generate(14, (i) {
                final x = (i * 120 +
                    sin(controller.value * 2 * pi + i) * 100 +
                    controller.value * width * 0.5) %
                    width;
                final y = (height -
                    ((controller.value * height * 0.9) + (i * 70) % height)) %
                    height;
                final scale = 1.0 + 0.4 * sin(controller.value * 2 * pi + i * 0.5);
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
                            color: rainbowColors[i % rainbowColors.length].withOpacity(0.6),
                            blurRadius: 20,
                            spreadRadius: 2,
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

/// 🌟 2. Starry Night Background


/// 🌊 3. Ocean Wave Background


/// ☁️ 4. Cloudy Sky Background


/// 🍃 5. Forest Background

/// 🎡 6. Carnival Background


/// 🌋 7. Volcano Fire Background


/// 🏖️ 8. Beach Background


/// 🎨 9. Rainbow Gradient Background


/// 🚀 10. Space Galaxy Background

