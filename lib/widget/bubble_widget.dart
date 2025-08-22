import 'package:flutter/material.dart';

class BubbleWidget extends StatefulWidget {
  final int value;
  final double size;
  final List<Color>? colors;
  final VoidCallback? onGone;

  const BubbleWidget({
    Key? key,
    required this.value,
    required this.size,
    this.colors,
    this.onGone,
  }) : super(key: key);

  @override
  State<BubbleWidget> createState() => _BubbleWidgetState();
}

class _BubbleWidgetState extends State<BubbleWidget>
    with TickerProviderStateMixin {
  late AnimationController _flyCtrl;
  late AnimationController _spawnCtrl;
  late Animation<Offset> _flyAnim;
  bool _flying = false;

  @override
  void initState() {
    super.initState();
    _flyCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flyAnim = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -2), // fly up
    ).animate(CurvedAnimation(parent: _flyCtrl, curve: Curves.easeIn));

    _flyCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        widget.onGone?.call();
      }
    });

    // spawn animation
    _spawnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _flyCtrl.dispose();
    _spawnCtrl.dispose();
    super.dispose();
  }

  void flyAway() {
    if (!_flying) {
      setState(() => _flying = true);
      _flyCtrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 Default soft, kid-friendly pastel palette
    final defaultColors = [
      Colors.pink.shade200,
      Colors.purple.shade100,
    ];

    final bubble = ScaleTransition(
      scale: CurvedAnimation(parent: _spawnCtrl, curve: Curves.elasticOut),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: widget.colors ?? defaultColors,
            center: Alignment.topLeft,
            radius: 0.9,
          ),
          boxShadow: [
            BoxShadow(
              color: (widget.colors ?? defaultColors).last.withOpacity(0.25),
              blurRadius: 8,
              spreadRadius: 1,
            )
          ],
        ),
        child: Center(
          child: Text(
            '${widget.value}',
            style: TextStyle(
              fontSize: widget.size * 0.36,
              fontWeight: FontWeight.bold,
              color: Colors.black87, // softer text (not pure white)
              shadows: const [
                Shadow(
                  blurRadius: 2,
                  offset: Offset(1, 1),
                  color: Colors.white30,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return _flying
        ? SlideTransition(position: _flyAnim, child: bubble)
        : bubble;
  }
}
