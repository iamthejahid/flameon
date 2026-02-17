import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../config/game_config.dart';
import '../space_game.dart';
import 'player.dart';

class Enemy extends SpriteComponent
    with HasGameReference<SpaceGame>, CollisionCallbacks {
  final double speed;
  static final _random = Random();

  Enemy({required this.speed})
    : super(size: Vector2.all(GameConfig.enemySize), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await game.loadSprite('enemy.png');
    add(RectangleHitbox());

    // Start at a random X position at the top
    final x = _random.nextDouble() * (game.size.x - size.x) + size.x / 2;
    position = Vector2(x, -size.y);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;

    if (position.y > game.size.y + size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      game.onPlayerDeath();
    }
  }
}
