import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import '../config/game_config.dart';
import '../space_game.dart';
import 'bullet.dart';
import 'explosion_particle.dart';

class Player extends SpriteComponent
    with HasGameReference<SpaceGame>, KeyboardHandler {
  Player()
    : super(size: Vector2.all(GameConfig.playerSize), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await game.loadSprite('player.png');
    position = Vector2(game.size.x / 2, game.size.y - 100);
    add(RectangleHitbox());
  }

  double _fireTimer = 0;

  @override
  void update(double dt) {
    super.update(dt);

    // Keyboard movement
    final displacement = _moveDirection * GameConfig.playerSpeed * dt;
    position.add(displacement);

    // Auto-firing logic
    _fireTimer += dt;
    if (_fireTimer >= GameConfig.fireInterval) {
      _fireTimer = 0;
      fire();
    }

    // Keep player within screen bounds
    position.x = position.x.clamp(size.x / 2, game.size.x - size.x / 2);
    position.y = position.y.clamp(size.y / 2, game.size.y - size.y / 2);
  }

  final Vector2 _moveDirection = Vector2.zero();

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _moveDirection.setZero();

    if (keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      _moveDirection.y -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyS) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      _moveDirection.y += 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      _moveDirection.x -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      _moveDirection.x += 1;
    }

    if (_moveDirection.length > 0) {
      _moveDirection.normalize();
    }

    return true;
  }

  void fire() {
    game.add(Bullet(position: position.clone()..y -= size.y / 2));
    game.playSfx(GameConfig.sfxShoot);
  }

  void die() {
    removeFromParent();
    game.add(ExplosionParticle(position: position.clone()));
  }
}
