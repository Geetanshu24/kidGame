import 'dart:math';

class MathGameLogic {
  final String mode;
  final Random _r = Random();
  late String question;
  late List<int> answers;
  late int correctAnswer;

  int score = 0;
  int level = 1; // Track level
  int timePerQuestion = 8;

  MathGameLogic({this.mode = 'Addition'}) {
    generateQuestion();
  }

  void generateQuestion() {
    int a, b;

    // Difficulty control — start small, increase gradually
    if (level <= 10) {
      a = 1 + _r.nextInt(5);
      b = 1 + _r.nextInt(5);
    } else if (level <= 20) {
      a = 2 + _r.nextInt(8);
      b = 1 + _r.nextInt(8);
    } else if (level <= 30) {
      a = 3 + _r.nextInt(12);
      b = 1 + _r.nextInt(12);
    } else {
      // After level 30 — allow bigger numbers & carry
      a = 5 + _r.nextInt(25);
      b = 5 + _r.nextInt(25);
    }

    switch (mode) {
      case 'Subtraction':
      // Ensure subtraction always positive for early levels
        if (level <= 30 && b > a) {
          int temp = a;
          a = b;
          b = temp;
        }
        correctAnswer = a - b;
        question = '$a - $b = ?';
        break;

      case 'Multiplication':
      // Small numbers for multiplication at first
        if (level <= 20) {
          a = 2 + _r.nextInt(5);
          b = 2 + _r.nextInt(5);
        }
        correctAnswer = a * b;
        question = '$a × $b = ?';
        break;

      case 'Division':
      // Keep division simple (no decimals) early on
        b = 1 + _r.nextInt(5);
        correctAnswer = a * b ~/ b;
        a = correctAnswer * b;
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
      return true;
    }
    return false;
  }
}
