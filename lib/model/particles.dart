import 'package:flutter/animation.dart';

class Particle {
  Offset pos;
  Offset vel;
  Color color;
  int life;
  double size;
  Particle({
    required this.pos,
    required this.vel,
    required this.color,
    required this.life,
    this.size = 6.0,
  });

  void update() {
    vel = vel + const Offset(0, 0.12);
    pos = pos + vel;
    life -= 1;
    size *= 0.97;
  }
}

