import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kid_game/screen/pastal_background.dart';
import 'package:kid_game/widget/bubble_widget.dart';
import 'package:kid_game/widget/canon_painter.dart';
import 'package:kid_game/widget/particle_painter.dart';

import '../model/particles.dart';
import '../utils/math_game_logic.dart';

class ArcadeBubbleGameScreen extends StatefulWidget {
  final String mode;
  const ArcadeBubbleGameScreen({super.key, this.mode = 'Addition'});

  @override
  State<ArcadeBubbleGameScreen> createState() =>
      _ArcadeBubbleGameScreenState();
}

class _ArcadeBubbleGameScreenState extends State<ArcadeBubbleGameScreen>
    with TickerProviderStateMixin {

  List<Color> _randomGradient() {
    final palette = [
      [Color(0xFFFFE4E1), Color(0xFFFFB6C1)], // Light Pink
      [Color(0xFFFFF9C4), Color(0xFFFFECB3)], // Light Yellow
      [Color(0xFFB3E5FC), Color(0xFF81D4FA)], // Light Blue
      [Color(0xFFC8E6C9), Color(0xFFA5D6A7)], // Light Green
      [Color(0xFFD1C4E9), Color(0xFFB39DDB)], // Light Purple
      [Color(0xFFFFF0F5), Color(0xFFFFC1E3)], // Soft Lavender Pink
    ];
    palette.shuffle();
    return palette.first;
  }



  late MathGameLogic logic;
  final Random _r = Random();

  // Static bubbles (positions computed from screen width)
  List<Offset> bubblePositions = [];
  List<double> bubbleSizes = [];
  List<List<Color>> bubbleColors = [];
  List<int> bubbleValues = [];

  // Cannon & bullet
  late Offset cannonPos;
  double cannonAngle = -pi / 2;
  Offset? bulletPos;
  Offset? bulletVelocity;
  bool bulletActive = false;

  // Bullet trail (list of recent bullet positions)
  final List<Offset> bulletTrail = [];

  // Particles for pop
  final List<Particle> particles = [];

  // Timer & game loop
  Timer? gameLoop;
  int timeLeft = 8;
  Timer? questionTimer;

  // Gameplay
  int combo = 0;
  int level = 1;

  // Animation controllers
  late AnimationController recoilController;
  late AnimationController bgController;

  @override
  void initState() {
    super.initState();
    logic = MathGameLogic(mode: widget.mode);

    recoilController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
    bgController =
    AnimationController(vsync: this, duration: const Duration(seconds: 16))
      ..repeat();

    // Defer initialization that uses MediaQuery
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupStaticBubbles();
      startGameLoop();
    });
  }

  void _setupStaticBubbles() {
    bubblePositions.clear();
    bubbleSizes.clear();
    bubbleColors.clear();
    bubbleValues.clear();

    final w = MediaQuery.of(context).size.width;
    final centerX = w / 2;
    final spacing = min(86.0, (w - 80) / 4);
    final startX = centerX - (1.5 * spacing);

    // ensure logic has a question
    logic.generateQuestion();
    final answers = logic.answers;

    for (int i = 0; i < 4; i++) {
      double x = startX + i * spacing;
      double y = MediaQuery.of(context).size.height * 0.28; // static vertical
      bubblePositions.add(Offset(x, y));
      bubbleSizes.add(64.0 + _r.nextDouble() * 6);
      bubbleColors.add(_randomGradient());
      bubbleValues.add(answers[i]);
    }

    timeLeft = logic.timePerQuestion;
    setState(() {});
  }


  void startGameLoop() {
    gameLoop?.cancel();
    gameLoop = Timer.periodic(const Duration(milliseconds: 1), (_) => _tick());
  }



  void _tick() {
    // update bullet
    if (bulletActive && bulletPos != null && bulletVelocity != null) {
      bulletPos = bulletPos! + bulletVelocity!;
      bulletTrail.insert(0, bulletPos!);
      if (bulletTrail.length > 8) bulletTrail.removeLast();

      // off-screen check
      final size = MediaQuery.of(context).size;
      if (bulletPos!.dy < -20 ||
          bulletPos!.dx < -50 ||
          bulletPos!.dx > size.width + 50) {
        _deactivateBullet();
      } else {
        // collision vs static bubbles
        for (int i = 0; i < bubblePositions.length; i++) {
          final dist = (bulletPos! - bubblePositions[i]).distance;
          if (dist < bubbleSizes[i] * 0.55) {
            _onBubbleHit(i);
            break;
          }
        }
      }
    }

    // update particles
    particles.removeWhere((p) => p.life <= 0);
    for (final p in particles) {
      p.update();
    }

    if (mounted) setState(() {});
  }

  void _onBubbleHit(int idx) {
    if (!bulletActive) return;
    _deactivateBullet();

    int picked = bubbleValues[idx];
    bool correct = logic.checkAnswer(picked);
    if (correct) {
      combo++;
      // level progression example
      if (logic.score % 50 == 0) level = 1 + (logic.score ~/ 100);
      // spawn particles at bubble center
      _spawnParticles(bubblePositions[idx], bubbleColors[idx]);
      // next question: regenerate answers and update values but keep bubble positions static
      logic.generateQuestion();
      final newAnswers = logic.answers;
      for (int i = 0; i < newAnswers.length && i < bubbleValues.length; i++) {
        bubbleValues[i] = newAnswers[i];
        bubbleColors[i] = _randomGradient();
      }
      // reward time (cap at timePerQuestion)
      timeLeft = min(logic.timePerQuestion, timeLeft + 2);
    } else {
      combo = 0;
      // show wrong color briefly
      final old = bubbleColors[idx];
      bubbleColors[idx] = [Colors.grey, Colors.black];
      Timer(const Duration(milliseconds: 350), () {
        if (mounted) {
          setState(() {
            bubbleColors[idx] = old;
          });
        }
      });
    }
  }

  void _spawnParticles(Offset center, List<Color> colors) {
    final int count = 18 + _r.nextInt(8);
    for (int i = 0; i < count; i++) {
      double dir = _r.nextDouble() * pi * 2;
      double speed = 2.0 + _r.nextDouble() * 4;
      particles.add(Particle(
        pos: center + Offset(_r.nextDouble() * 10 - 5, _r.nextDouble() * 10 - 5),
        vel: Offset(cos(dir) * speed, sin(dir) * speed - (_r.nextDouble() * 0.5)),
        color: colors[_r.nextInt(colors.length)],
        life: 30 + _r.nextInt(22),
      ));
    }
  }

  void _deactivateBullet() {
    bulletActive = false;
    bulletPos = null;
    bulletVelocity = null;
    bulletTrail.clear();
    recoilController.reverse();
  }

  void _fireAt(Offset target) {
    if (bulletActive) return;
    // aim cannon to target
    double dx = target.dx - cannonPos.dx;
    double dy = target.dy - cannonPos.dy;
    double angle = atan2(dy, dx);
    setState(() {
      cannonAngle = angle;
    });

    // bullet start a bit ahead of cannon center
    Offset start = cannonPos + Offset(cos(angle) * 36, sin(angle) * 36);
    // speed: larger for snappy feel
    double speed = 18.0 + level * 1.6;
    // velocity normalized by 1/frameFactor (game ticks ~28ms)
    double frameFactor = 28 / 1000;
    Offset vel = Offset(cos(angle) * speed * frameFactor * 1.0,
        sin(angle) * speed * frameFactor * 1.0);

    bulletPos = start;
    bulletVelocity = vel;
    bulletActive = true;
    bulletTrail.clear();
    bulletTrail.add(start);
    recoilController.forward(from: 0);
    // (optional) play shoot sound hook
  }

  @override
  void dispose() {
    gameLoop?.cancel();
    questionTimer?.cancel();
    recoilController.dispose();
    bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    cannonPos = Offset(size.width / 2, size.height - 100);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          PastelBackground(controller: bgController),


          // HUD top
          Positioned(top: 36, left: 16, right: 16, child: _hudCard()),

          // static bubbles (visuals + taps)
          ...List.generate(bubblePositions.length, (i) {
            final pos = bubblePositions[i];
            final s = bubbleSizes[i];
            final colors = bubbleColors[i];
            return Positioned(
              left: pos.dx - s / 2,
              top: pos.dy - s / 2,
              child: GestureDetector(
                onTap: () => _fireAt(bubblePositions[i]),
                child: BubbleWidget(value: bubbleValues[i], size: s, colors: colors),
              ),
            );
          }),

          // bullet trail (drawn under bullet)
          Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: BulletTrailPainter(trail: bulletTrail)))),

          // particle painter
          Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: ParticlePainter(particles)))),

          // bullet widget
          if (bulletActive && bulletPos != null)
            Positioned(
              left: bulletPos!.dx - 8,
              top: bulletPos!.dy - 8,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(colors: [Colors.white, Colors.orangeAccent]),
                  boxShadow: [BoxShadow(color: Colors.orangeAccent.withOpacity(0.7), blurRadius: 8, spreadRadius: 1)],
                ),
              ),
            ),

          // cannon (on top)
          Positioned(
            left: cannonPos.dx - 44,
            top: cannonPos.dy - 44,
            child: Transform.translate(
              offset: Offset(0, -recoilController.value * 6),
              child: Transform.rotate(
                angle: cannonAngle,
                alignment: const Alignment(0.0, 0.6),
                child: CustomPaint(
                  size: const Size(88, 88),
                  painter: CannonPainter(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _hudCard() {
    return Row(
      children: [
        // Scoreboard
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.yellowAccent, Colors.orangeAccent]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⭐ Score: ${logic.score}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  fontFamily: 'ComicNeue',
                ),
              ),
              SizedBox(height: 4),
              Text(
                '🔥 Combo: x$combo  🚀 Level: $level',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent,
                  fontFamily: 'ComicNeue',
                ),
              ),
            ],
          ),
        ),
        Spacer(),
        // Math Question Display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.pinkAccent, Colors.purpleAccent]),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
          ),
          child: Text(
            logic.question,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Baloo2',
            ),
          ),
        ),
      ],
    );
  }
}





