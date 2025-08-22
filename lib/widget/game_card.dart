import 'package:flutter/material.dart';

class GameHud extends StatelessWidget {
  final int score;
  final int level;
  final String question;

  const GameHud({
    super.key,
    required this.score,
    required this.level,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🎈 Left Column → Score + Level
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBubble(
                icon: "🌟",
                label: "Score",
                value: "$score",
                color1: Colors.yellowAccent,
                color2: Colors.orange,
              ),
              const SizedBox(height: 10),
              _buildBubble(
                icon: "🚀",
                label: "Level",
                value: "$level",
                color1: Colors.lightBlueAccent,
                color2: Colors.blue,
              ),
            ],
          ),

          // ❓ Question Bubble (Right Side in SAME Row)
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.pinkAccent, Colors.deepPurpleAccent],
                ),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              child: Text(
                question,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis, // ✅ keeps in one line
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 4,
                      color: Colors.black38,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🧩 Reusable Bubble Widget
  Widget _buildBubble({
    required String icon,
    required String label,
    required String value,
    required Color color1,
    required Color color2,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color1, color2]),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color2.withOpacity(0.5),
            blurRadius: 6,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 6),
          Text(
            "$label: $value",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(1.5, 1.5),
                  blurRadius: 3,
                  color: Colors.black26,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
