import 'package:flutter/material.dart';

class BubbleWidget extends StatefulWidget {
  final int value;
  final double size;
  final List<Color> colors;
  final VoidCallback? onGone;

  const BubbleWidget({
    Key? key,
    required this.value,
    required this.size,
    required this.colors,
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
    final bubble = ScaleTransition(
      scale: CurvedAnimation(parent: _spawnCtrl, curve: Curves.elasticOut),
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
              color: widget.colors.last.withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 2,
            )
          ],
        ),
        child: Center(
          child: Text(
            '${widget.value}',
            style: TextStyle(
              fontSize: widget.size * 0.38,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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

