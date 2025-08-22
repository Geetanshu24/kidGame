import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:kid_game/background/beach.dart';
import 'package:kid_game/background/carnival.dart';
import 'package:kid_game/background/cloud_sky.dart';
import 'package:kid_game/background/forest.dart';
import 'package:kid_game/background/magical_kid.dart';
import 'package:kid_game/background/ocean_wave_background.dart';
import 'package:kid_game/background/rainbow.dart';
import 'package:kid_game/background/space_galaxy.dart';
import 'package:kid_game/background/staryy_night.dart';
import 'package:kid_game/background/volcano_fire.dart';
import 'package:kid_game/widget/bubble_widget.dart';
import 'package:kid_game/widget/canon_painter.dart';
import 'package:kid_game/widget/game_card.dart';
import 'package:kid_game/widget/particle_painter.dart';

import '../model/particles.dart';
import '../utils/math_game_logic.dart';

class ArcadeBubbleGameScreen extends StatefulWidget {
  final String mode;
  final int minNumber;
  final int maxNumber;
  const ArcadeBubbleGameScreen({
    super.key,
    this.mode = 'Addition',
    this.minNumber = 1,
    this.maxNumber = 10,
  });

  @override
  State<ArcadeBubbleGameScreen> createState() => _ArcadeBubbleGameScreenState();
}

class _ArcadeBubbleGameScreenState extends State<ArcadeBubbleGameScreen>
    with TickerProviderStateMixin {
  late MathGameLogic logic;
  final Random _r = Random();

  // bubble data
  List<Offset> bubblePositions = [];
  List<double> bubbleSizes = [];
  List<List<Color>> bubbleColors = [];
  List<int> bubbleValues = [];
  List<AnimationController?> bubbleFlyControllers = [];

  // Cannon & bullet
  late Offset cannonPos;
  double cannonAngle = -pi / 2;
  Offset? bulletPos;
  Offset? bulletVelocity;
  bool bulletActive = false;
  final List<Offset> bulletTrail = [];

  // Particles
  final List<Particle> particles = [];

  // Game loop
  Timer? gameLoop;
  int combo = 0;
  int level = 1;

  // Animation controllers
  late AnimationController recoilController;
  late AnimationController bgController;

  late AudioPlayer bgPlayer;
  late AudioPlayer sfxPlayer;

  // ✅ Track current background index
  int currentBgIndex = 1;

  @override
  void initState() {
    super.initState();
    bgPlayer = AudioPlayer();
    sfxPlayer = AudioPlayer();

    logic = MathGameLogic(
      mode: widget.mode,
      min: widget.minNumber,
      max: widget.maxNumber,
    );

    recoilController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
    bgController =
    AnimationController(vsync: this, duration: const Duration(seconds: 16))
      ..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupStaticBubbles();
      startGameLoop();
    });

    // loop background music
    playBgMusic();

    // start me ek background set
    _updateBackground();
  }

  List<Color> _randomGradient() {
    final palette = [
      [Color(0xFFFFE4E1), Color(0xFFFFB6C1)],
      [Color(0xFFFFF9C4), Color(0xFFFFECB3)],
      [Color(0xFFB3E5FC), Color(0xFF81D4FA)],
      [Color(0xFFC8E6C9), Color(0xFFA5D6A7)],
      [Color(0xFFD1C4E9), Color(0xFFB39DDB)],
      [Color(0xFFFFF0F5), Color(0xFFFFC1E3)],
    ];
    return palette[_r.nextInt(palette.length)];
  }

  void _setupStaticBubbles() {
    bubblePositions.clear();
    bubbleSizes.clear();
    bubbleColors.clear();
    bubbleValues.clear();
    bubbleFlyControllers.clear();

    final w = MediaQuery.of(context).size.width;
    final spacing = min(86.0, (w - 80) / 4);
    final startX = w / 2 - (1.5 * spacing);

    logic.generateQuestion();
    final answers = logic.answers;

    for (int i = 0; i < 4; i++) {
      bubblePositions.add(Offset(startX + i * spacing,
          MediaQuery.of(context).size.height * 0.28));
      bubbleSizes.add(70.0);
      bubbleColors.add(_randomGradient());
      bubbleValues.add(answers[i]);
      bubbleFlyControllers.add(null);
    }

    setState(() {});
  }

  Future<void> playBgMusic() async {
    await bgPlayer.setVolume(0); // start muted
    await bgPlayer.setReleaseMode(ReleaseMode.loop);
    await bgPlayer.play(AssetSource('audio/background_sound.mp3'));

    // fade-in effect
    double vol = 0;
    while (vol < 0.2) {
      vol += 0.02;
      if (vol > 0.2) vol = 0.2;
      await bgPlayer.setVolume(vol);
      await Future.delayed(const Duration(milliseconds: 150));
    }
  }

  void startGameLoop() {
    gameLoop?.cancel();
    gameLoop = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
  }

  void _tick() {
    if (bulletActive && bulletPos != null && bulletVelocity != null) {
      bulletPos = bulletPos! + bulletVelocity!;
      bulletTrail.insert(0, bulletPos!);
      if (bulletTrail.length > 8) bulletTrail.removeLast();

      final size = MediaQuery.of(context).size;
      if (bulletPos!.dy < -20 ||
          bulletPos!.dx < -50 ||
          bulletPos!.dx > size.width + 50) {
        _deactivateBullet();
      } else {
        for (int i = 0; i < bubblePositions.length; i++) {
          final dist = (bulletPos! - bubblePositions[i]).distance;
          if (dist < bubbleSizes[i] * 0.55) {
            _onBubbleHit(i);
            break;
          }
        }
      }
    }

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

      // 🔊 Play level up sound on every win
      _playLevelUpSound();

      _spawnParticles(bubblePositions[idx], bubbleColors[idx]);
      _flyBubbleAway(idx);

      // ✅ background change only after every 5 wins
      if ((logic.score ~/ 10) % 5 == 0) {
        _updateBackground();
      }
    } else {
      combo = 0;
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

  void _updateBackground() {
    setState(() {
      currentBgIndex = (currentBgIndex % 9) + 1;
    });
  }


  void _playLevelUpSound() {
    final player = AudioPlayer(); // fresh instance
    player.play(AssetSource('audio/level_up.mp3')).catchError((e) {
      print("❌ Error playing sound: $e");
    });

    // optional: dispose after done
    player.onPlayerComplete.listen((_) {
      player.dispose();
    });
  }

  void _flyBubbleAway(int idx) {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    bubbleFlyControllers[idx] = controller;
    controller.forward().then((_) {
      logic.generateQuestion();
      final answers = logic.answers;

      setState(() {
        for (int i = 0; i < bubbleValues.length; i++) {
          if (i == idx) {
            bubbleValues[i] = answers[i];
            bubbleColors[i] = _randomGradient();
          } else {
            _slingTransition(i, answers[i]);
          }
        }
      });

      controller.dispose();
      bubbleFlyControllers[idx] = null;
    });
  }

  void _slingTransition(int idx, int newValue) {
    final oldColor = bubbleColors[idx];
    final newColor = _randomGradient();

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.elasticOut,
    );

    controller.addListener(() {
      if (mounted) {
        setState(() {
          double t = animation.value;
          bubbleColors[idx] = [
            Color.lerp(oldColor.first, newColor.first, t)!,
            Color.lerp(oldColor.last, newColor.last, t)!,
          ];
          if (t > 0.6) {
            bubbleValues[idx] = newValue;
          }
        });
      }
    });

    controller.forward().then((_) => controller.dispose());
  }

  void _spawnParticles(Offset center, List<Color> colors) {
    final int count = 18 + _r.nextInt(8);
    for (int i = 0; i < count; i++) {
      double dir = _r.nextDouble() * pi * 2;
      double speed = 2.0 + _r.nextDouble() * 4;
      particles.add(Particle(
        pos: center,
        vel: Offset(cos(dir) * speed, sin(dir) * speed - 1),
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
    double dx = target.dx - cannonPos.dx;
    double dy = target.dy - cannonPos.dy;
    double angle = atan2(dy, dx);
    setState(() => cannonAngle = angle);

    Offset start = cannonPos + Offset(cos(angle) * 36, sin(angle) * 36);
    double speed = 120.0 + level * 10;
    double frameFactor = 28 / 1000;
    Offset vel = Offset(cos(angle) * speed * frameFactor,
        sin(angle) * speed * frameFactor);

    bulletPos = start;
    bulletVelocity = vel;
    bulletActive = true;
    bulletTrail.clear();
    recoilController.forward(from: 0);
  }

  @override
  void dispose() {
    gameLoop?.cancel();
    recoilController.dispose();
    bgController.dispose();
    for (var c in bubbleFlyControllers) {
      c?.dispose();
    }
    bgPlayer.dispose();
    sfxPlayer.dispose();
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
          /// ✅ Smooth Background Transition (only when bg changes)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 2200),
            layoutBuilder:
                (Widget? currentChild, List<Widget> previousChildren) {
              return Stack(
                children: <Widget>[
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            transitionBuilder: (Widget child, Animation<double> animation) {
              final inAnimation = Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              ));

              final outAnimation = Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(0, -1),
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              ));

              return SlideTransition(
                position: child.key == ValueKey(currentBgIndex)
                    ? inAnimation
                    : outAnimation,
                child: child,
              );
            },
            child: _getBackgroundWidget(),
          ),

          Positioned(top: 36, left: 16, right: 16, child: GameHud(level:  logic.level,question:logic.question ,score:  logic.score,)),

          // Bubbles
          ...List.generate(bubblePositions.length, (i) {
            final pos = bubblePositions[i];
            final s = bubbleSizes[i];
            final colors = bubbleColors[i];

            final flyController = bubbleFlyControllers[i];
            double dyOffset = 0;
            double opacity = 1;
            if (flyController != null) {
              dyOffset = -300 * flyController.value;
              opacity = 1 - flyController.value;
            }

            return Positioned(
              left: pos.dx - s / 2,
              top: pos.dy - s / 2 + dyOffset,
              child: Opacity(
                opacity: opacity,
                child: GestureDetector(
                  onTap: () => _fireAt(bubblePositions[i]),
                  child: BubbleWidget(
                    value: bubbleValues[i],
                    size: s,
                    colors: colors,
                  ),
                ),
              ),
            );
          }),

          // bullet trail
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: BulletTrailPainter(trail: bulletTrail)),
            ),
          ),

          // particle painter
          Positioned.fill(
            child: IgnorePointer(child: CustomPaint(painter: ParticlePainter(particles))),
          ),

          // bullet
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
                  boxShadow: [
                    BoxShadow(
                        color: Colors.orangeAccent.withOpacity(0.7),
                        blurRadius: 8,
                        spreadRadius: 1)
                  ],
                ),
              ),
            ),

          // cannon
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


  Widget _getBackgroundWidget() {
    switch (currentBgIndex) {
      case 1:
        return OceanWaveBackground(
            key: ValueKey(1), controller: bgController);
      case 2:
        return SpaceGalaxyBackground(
            key: ValueKey(2), controller: bgController);
      case 3:
        return ForestBackground(
            key: ValueKey(3), controller: bgController);
      case 4:
        return RainbowBackground(
            key: ValueKey(4), controller: bgController);
      case 5:
        return CloudySkyBackground(
            key: ValueKey(5), controller: bgController);
      case 6:
        return StarryNightBackground(
            key: ValueKey(6), controller: bgController);
      case 7:
        return VolcanoFireBackground(
            key: ValueKey(7), controller: bgController);
      case 8:
        return MagicalKids1Background(
            key: ValueKey(8), controller: bgController);
      case 9:
        return BeachBackground(
            key: ValueKey(9), controller: bgController);
      default:
        return CarnivalBackground(
            key: ValueKey(0), controller: bgController);
    }
  }
}
