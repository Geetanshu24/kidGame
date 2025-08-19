import 'package:flutter/material.dart';
import 'dart:math';
import 'bubble_game_screen.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  _ModeSelectionScreenState createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> modes = [
    {"name": "Addition", "emoji": "➕", "colors": [Colors.orange, Colors.deepOrangeAccent]},
    {"name": "Subtraction", "emoji": "➖", "colors": [Colors.pinkAccent, Colors.redAccent]},
    {"name": "Multiplication", "emoji": "✖️", "colors": [Colors.lightBlueAccent, Colors.blueAccent]},
    {"name": "Division", "emoji": "➗", "colors": [Colors.greenAccent, Colors.teal]},
  ];

  late AnimationController _controller;
  late List<Bubble> bubbles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 10))..repeat();
    bubbles = List.generate(15, (_) => Bubble());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background bubbles
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: BubblePainter(bubbles, _controller.value),
                child: Container(),
              );
            },
          ),

          // Foreground
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  "🎈 Pick Your Math Adventure 🎠",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade800,
                    fontFamily: 'ComicSans',
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.white,
                        offset: Offset(2, 2),
                      )
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 1,
                      ),
                      itemCount: modes.length,
                      itemBuilder: (context, index) {
                        final mode = modes[index];
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 1, end: 1),
                          duration: Duration(milliseconds: 200),
                          builder: (context, scale, child) {
                            return GestureDetector(
                              onTapDown: (_) {
                                setState(() => scale = 0.95);
                              },
                              onTapUp: (_) {
                                setState(() => scale = 1);
                              },
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ArcadeBubbleGameScreen(mode: mode["name"]),
                                  ),
                                );
                              },
                              child: Transform.scale(
                                scale: scale,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: mode["colors"],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                    shape: BoxShape.rectangle, // playful round shape
                                    boxShadow: [
                                      BoxShadow(
                                        color: mode["colors"][1].withOpacity(0.6),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        mode["emoji"],
                                        style: TextStyle(
                                          fontSize: 60,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 10,
                                              color: Colors.white,
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        mode["name"],
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: 'ComicSans',
                                          shadows: [
                                            Shadow(
                                              blurRadius: 8,
                                              color: Colors.black45,
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Bubble {
  double x = Random().nextDouble();
  double y = Random().nextDouble();
  double size = Random().nextDouble() * 40 + 20;
  Color color = Colors.primaries[Random().nextInt(Colors.primaries.length)];
}

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final double progress;

  BubblePainter(this.bubbles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var bubble in bubbles) {
      paint.color = bubble.color.withOpacity(0.15);
      double dx = bubble.x * size.width;
      double dy = (bubble.y * size.height + progress * size.height) % size.height;
      canvas.drawCircle(Offset(dx, dy), bubble.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
