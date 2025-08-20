import 'dart:math';

import 'package:flutter/material.dart';

class StarryNightBackground extends StatelessWidget {
  final AnimationController controller;
  const StarryNightBackground({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.indigo],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              ...List.generate(80, (i) {
                final x = (i * 50 + controller.value * width * 0.5) % width;
                final y = (i * 70 + controller.value * height * 0.3) % height;
                final twinkle = 0.5 + 0.5 * sin(controller.value * 8 * pi + i);
                return Positioned(
                  left: x,
                  top: y,
                  child: Opacity(
                    opacity: twinkle,
                    child: const CircleAvatar(radius: 1.5, backgroundColor: Colors.white),
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