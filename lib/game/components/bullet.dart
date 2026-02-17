import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../config/game_config.dart';
import '../space_game.dart';
import 'enemy.dart';

class Bullet extends CircleComponent
    with HasGameReference<SpaceGame>, CollisionCallbacks {
  Bullet({required Vector2 position})
    : super(
        position: position,
        radius: GameConfig.bulletSize / 2,
        anchor: Anchor.center,
        paint: Paint()..color = Colors.yellow,
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y -= GameConfig.bulletSpeed * dt;

    if (position.y < -radius * 2) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Enemy) {
      removeFromParent();
      other.die();
      game.score += 10;
    }
  }
}
