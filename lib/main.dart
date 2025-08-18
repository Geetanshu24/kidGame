import 'package:flutter/material.dart';
import 'package:kid_game/screen/mode_selection_screen.dart';

void main() {
  runApp(MathShootingApp());
}

class MathShootingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ModeSelectionScreen(),
    );
  }
}
