import 'dart:math' as math;

class MathGameLogic {
  final String mode;
  final int min;
  final int max;
  final math.Random _r = math.Random();

  late String question;
  late List<int> answers;
  late int correctAnswer;

  int score = 0;
  int level = 1; // Track level
  int timePerQuestion = 8;

  // 🎯 Cannon Y position (0 = top, 1 = bottom)
  double cannonY = 0.8;

  MathGameLogic({
    required this.mode,
    this.min = 1,
    this.max = 10,
  }) {
    generateQuestion();
  }

  void generateQuestion() {
    int a, b;

    // 🎯 Base range according to class
    a = min + _r.nextInt(max - min + 1);
    b = min + _r.nextInt(max - min + 1);

    // 🎯 Extra scaling with level
    if (level > 15) {
      a += _r.nextInt(level);
      b += _r.nextInt(level);
    }

    switch (mode) {
      case 'Subtraction':
      // Ensure subtraction always positive for young learners
        if (b > a) {
          int temp = a;
          a = b;
          b = temp;
        }
        correctAnswer = a - b;
        question = '$a - $b = ?';
        break;

      case 'Multiplication':
      // Keep smaller numbers at low levels
        if (level < 10) {
          a = 2 + _r.nextInt(5);
          b = 2 + _r.nextInt(5);
        }
        correctAnswer = a * b;
        question = '$a × $b = ?';
        break;

      case 'Division':
      // Simple integer division (no decimals)
        b = math.max(1, min + _r.nextInt(max - min + 1));
        correctAnswer = a ~/ b;
        a = correctAnswer * b; // Ensure divisible
        question = '$a ÷ $b = ?';
        break;

      default:
        correctAnswer = a + b;
        question = '$a + $b = ?';
    }

    // Create 4 options
    answers = [];
    int correctIndex = _r.nextInt(4);
    for (int i = 0; i < 4; i++) {
      if (i == correctIndex) {
        answers.add(correctAnswer);
      } else {
        int delta = (_r.nextBool() ? 1 : -1) * (1 + _r.nextInt(4));
        int wrong = correctAnswer + delta;
        if (answers.contains(wrong) || wrong < 0) {
          wrong = correctAnswer + (i + 1);
        }
        answers.add(wrong);
      }
    }
  }

  bool checkAnswer(int picked) {
    if (picked == correctAnswer) {
      score += 10;
      level++;

      // 🎯 Har 5 level pe cannon nayi jagah smoothly jayega
      if (level % 2 == 0) {
        cannonY = 0.2 + _r.nextDouble() * 0.6; // random 0.2–0.8
      }

      return true;
    }
    return false;
  }
}
