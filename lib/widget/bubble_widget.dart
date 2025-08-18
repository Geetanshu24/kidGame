import 'package:flutter/material.dart';

class BubbleWidget extends StatefulWidget {
  final int value;
  final double size;
  final List<Color> colors;

  const BubbleWidget({
    Key? key,
    required this.value,
    required this.size,
    required this.colors,
  }) : super(key: key);

  @override
  State<BubbleWidget> createState() => _BubbleWidgetState();
}

class _BubbleWidgetState extends State<BubbleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _bounce = Tween<double>(begin: -2, end: 2)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounce,
      builder: (_, __) {
        return Transform.translate(
          offset: Offset(0, _bounce.value),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: widget.colors,
                center: Alignment.topLeft,
                radius: 0.95,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.colors.last.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ],
            ),
            child: Stack(
              children: [
                // glossy highlight
                Positioned(
                  top: widget.size * 0.15,
                  left: widget.size * 0.2,
                  child: Container(
                    width: widget.size * 0.4,
                    height: widget.size * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(widget.size),
                    ),
                  ),
                ),
                // number
                Center(
                  child: Text(
                    '${widget.value}',
                    style: TextStyle(
                      fontSize: widget.size * 0.4,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(1, 1))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
