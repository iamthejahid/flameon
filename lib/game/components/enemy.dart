import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../config/game_config.dart';
import '../space_game.dart';
import 'player.dart';
import 'explosion_particle.dart';

enum EnemyType { standard, scout, tank, kamikaze }

class Enemy extends SpriteComponent
    with HasGameReference<SpaceGame>, CollisionCallbacks {
  final double speed;
  final EnemyType type;
  int health;

  static final _random = Random();
  double _time = 0;
  double _startX = 0;

  Enemy({required this.speed, this.type = EnemyType.standard, this.health = 1})
    : super(size: Vector2.all(_getSize(type)), anchor: Anchor.center);

  static double _getSize(EnemyType type) {
    switch (type) {
      case EnemyType.scout:
        return GameConfig.scoutSize;
      case EnemyType.tank:
        return GameConfig.tankSize;
      case EnemyType.kamikaze:
        return GameConfig.kamikazeSize;
      default:
        return GameConfig.enemySize;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    String spritePath;
    switch (type) {
      case EnemyType.scout:
        spritePath = 'enemy_scout.png';
        break;
      case EnemyType.kamikaze:
        spritePath = 'enemy_kamikaze.png';
        break;
      case EnemyType.tank:
        spritePath = 'enemy.png';
        break; // Using standard for now since gen failed
      default:
        spritePath = 'enemy.png';
    }

    sprite = await game.loadSprite(spritePath);
    add(RectangleHitbox());

    if (type == EnemyType.tank) {
      // Tint the tank since it uses the same sprite
      paint.color = const Color(0xff8800ff);
    }

    _startX = _random.nextDouble() * (game.size.x - size.x) + size.x / 2;
    position = Vector2(_startX, -size.y);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    switch (type) {
      case EnemyType.scout:
        position.y += speed * dt;
        position.x =
            _startX +
            sin(_time * GameConfig.scoutZigZagSpeed) *
                GameConfig.scoutZigZagAmplitude;
        break;
      case EnemyType.kamikaze:
        position.y += speed * dt;
        break;
      case EnemyType.tank:
        position.y += speed * dt;
        break;
      default:
        position.y += speed * dt;
    }

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
      die(force: true);
      game.onPlayerDeath();
    }
  }

  void takeDamage(int amount) {
    health -= amount;
    if (health <= 0) {
      die();
      game.score += _getScore();
    } else {
      // Visual feedback for hit
      paint.colorFilter = const ColorFilter.mode(
        Color(0xffffffff),
        BlendMode.srcIn,
      );
      Future.delayed(const Duration(milliseconds: 50), () {
        if (!isRemoving) {
          paint.colorFilter = null;
        }
      });
    }
  }

  int _getScore() {
    switch (type) {
      case EnemyType.scout:
        return 30;
      case EnemyType.tank:
        return 50;
      case EnemyType.kamikaze:
        return 20;
      default:
        return 10;
    }
  }

  void die({bool force = false}) {
    if (!force && health > 0) return;
    removeFromParent();
    game.add(ExplosionParticle(position: position.clone()));
    game.playSfx(GameConfig.sfxExplosion);
  }
}
