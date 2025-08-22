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
    int a, b, c;

    // Base numbers
    a = min + _r.nextInt(max - min + 1);
    b = min + _r.nextInt(max - min + 1);
    c = min + _r.nextInt(max - min + 1);

    // 🎯 Difficulty boost har 15 level ke baad
    int difficultyBoost = (level ~/ 15);

    if (difficultyBoost > 0) {
      a += _r.nextInt(3 * difficultyBoost + 1);
      b += _r.nextInt(3 * difficultyBoost + 1);
      c += _r.nextInt(3 * difficultyBoost + 1);
    }

    switch (mode) {
      case 'Addition':
        if (level >= 15 && _r.nextInt(100) < 30) {
          // 👉 30% chance of 3-number addition
          correctAnswer = a + b + c;
          question = '$a + $b + $c = ?';
        } else {
          // Normal 2-number addition
          correctAnswer = a + b;
          question = '$a + $b = ?';
        }
        break;

      case 'Subtraction':
        if (b > a) {
          int temp = a;
          a = b;
          b = temp;
        }
        correctAnswer = a - b;
        question = '$a - $b = ?';
        break;

      case 'Multiplication':
        if (level < 10) {
          a = 2 + _r.nextInt(5);
          b = 2 + _r.nextInt(5);
        }
        correctAnswer = a * b;
        question = '$a × $b = ?';
        break;

      case 'Division':
        b = math.max(1, min + _r.nextInt(max - min + 1));
        correctAnswer = a ~/ b;
        a = correctAnswer * b; // ensure divisible
        question = '$a ÷ $b = ?';
        break;

      default:
        correctAnswer = a + b;
        question = '$a + $b = ?';
    }

    // 🎯 Generate 4 options
    answers = [];
    int correctIndex = _r.nextInt(4);
    for (int i = 0; i < 4; i++) {
      if (i == correctIndex) {
        answers.add(correctAnswer);
      } else {
        int delta = (_r.nextBool() ? 1 : -1) * (1 + _r.nextInt(3 + difficultyBoost));
        int wrong = correctAnswer + delta;
        if (answers.contains(wrong) || wrong < 0) {
          wrong = correctAnswer + (i + 1) * (difficultyBoost + 1);
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
