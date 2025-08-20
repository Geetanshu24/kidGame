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

  final List<String> classes = [
    "Nursery",
    "KG",
    "Class 1",
    "Class 2",
    "Class 3",
    "Class 4",
    "Class 5",
  ];

  String? selectedClass;

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

  /// 🎯 Function to get difficulty range according to class
  Map<String, dynamic> getDifficulty(String className) {
    switch (className) {
      case "Nursery":
      case "KG":
        return {"min": 1, "max": 5, "operations": ["Addition"]};
      case "Class 1":
        return {"min": 1, "max": 10, "operations": ["Addition", "Subtraction"]};
      case "Class 2":
        return {"min": 1, "max": 20, "operations": ["Addition", "Subtraction"]};
      case "Class 3":
        return {"min": 1, "max": 50, "operations": ["Addition", "Subtraction", "Multiplication"]};
      case "Class 4":
        return {"min": 1, "max": 100, "operations": ["Addition", "Subtraction", "Multiplication", "Division"]};
      case "Class 5":
        return {"min": 1, "max": 200, "operations": ["Addition", "Subtraction", "Multiplication", "Division"]};
      default:
        return {"min": 1, "max": 10, "operations": ["Addition"]};
    }
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
                  "🎓 Choose Your Class & Math Adventure 🎠",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade800,
                    fontFamily: 'ComicSans',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),

                // 🔹 Class dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      labelText: "Select Class",
                    ),
                    value: selectedClass,
                    items: classes.map((cls) {
                      return DropdownMenuItem(
                        value: cls,
                        child: Text(cls),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedClass = val;
                      });
                    },
                  ),
                ),
                SizedBox(height: 20),

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
                        return GestureDetector(
                          onTap: () {
                            if (selectedClass == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Please select class first!")),
                              );
                              return;
                            }

                            final difficulty = getDifficulty(selectedClass!);

                            // Check if mode is allowed for this class
                            if (!difficulty["operations"].contains(mode["name"])) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("${mode["name"]} not available for $selectedClass")),
                              );
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ArcadeBubbleGameScreen(
                                  mode: mode["name"],
                                  minNumber: difficulty["min"],
                                  maxNumber: difficulty["max"],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: mode["colors"],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
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
                                  style: TextStyle(fontSize: 60),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  mode["name"],
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'ComicSans',
                                  ),
                                ),
                              ],
                            ),
                          ),
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
