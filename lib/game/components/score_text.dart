import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../space_game.dart';

class ScoreText extends TextComponent with HasGameReference<SpaceGame> {
  ScoreText()
    : super(
        text: 'Score: 0',
        position: Vector2(20, 40),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  @override
  void update(double dt) {
    super.update(dt);
    text = 'Score: ${game.score}';
  }
}
