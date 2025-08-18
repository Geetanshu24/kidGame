import 'package:flutter/material.dart';
import 'dart:math';

class PastelBackground extends StatefulWidget {
  final AnimationController controller;
  const PastelBackground({super.key, required this.controller});

  @override
  State<PastelBackground> createState() => _PastelBackgroundState();
}

class _PastelBackgroundState extends State<PastelBackground> {
  final List<List<Color>> palettes = [
    [Color(0xFFFFE4E1), Color(0xFFFFB6C1)], // Light Pink
    [Color(0xFFFFF9C4), Color(0xFFFFECB3)], // Light Yellow
    [Color(0xFFB3E5FC), Color(0xFF81D4FA)], // Light Blue
    [Color(0xFFC8E6C9), Color(0xFFA5D6A7)], // Light Green
    [Color(0xFFD1C4E9), Color(0xFFB39DDB)], // Light Purple
    [Color(0xFFFFF0F5), Color(0xFFFFC1E3)], // Soft Lavender Pink
  ];

  late List<Color> currentColors;
  late List<Color> nextColors;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    currentColors = palettes[random.nextInt(palettes.length)];
    nextColors = palettes[random.nextInt(palettes.length)];
    widget.controller.addListener(_updateColors);
  }

  void _updateColors() {
    if (widget.controller.isCompleted) {
      currentColors = nextColors;
      nextColors = palettes[random.nextInt(palettes.length)];
      widget.controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(currentColors[0], nextColors[0], widget.controller.value)!,
                Color.lerp(currentColors[1], nextColors[1], widget.controller.value)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      },
    );
  }
}
