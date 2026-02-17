import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'components/player.dart';
import 'components/enemy.dart';
import 'components/bullet.dart';
import 'components/score_text.dart';
import 'config/game_config.dart';

class SpaceGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection, PanDetector {
  late Player player;
  static final _random = Random();
  double _spawnTimer = 0;
  double _gameTime = 0;
  int score = 0;
  bool isGameOver = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Cache sounds (Try-catch added to avoid crashing if assets are missing)
    try {
      if (GameConfig.sfxEnabled) {
        await FlameAudio.audioCache.loadAll([
          GameConfig.sfxShoot,
          GameConfig.sfxExplosion,
        ]);
      }
    } catch (e) {
      debugPrint('Audio assets missing: $e');
    }
    _startOrRestart();
  }

  void playSfx(String file) {
    if (GameConfig.sfxEnabled) {
      try {
        FlameAudio.play(file);
      } catch (e) {
        // Silently fail if sfx is missing during gameplay
      }
    }
  }

  void _startOrRestart() {
    isGameOver = false;
    score = 0;
    _gameTime = 0;
    _spawnTimer = 0;

    // Clear existing components except game itself
    children.whereType<Enemy>().forEach((e) => e.removeFromParent());
    children.whereType<Bullet>().forEach((b) => b.removeFromParent());

    // Always add a fresh player on start/restart to avoid lifecycle issues
    children.whereType<Player>().forEach((p) => p.removeFromParent());
    player = Player();
    add(player);

    if (children.whereType<ScoreText>().isEmpty) {
      add(ScoreText());
    }
  }

  @override
  void update(double dt) {
    if (isGameOver) return;
    super.update(dt);
    _gameTime += dt;

    // Difficulty scaling: spawn interval decreases as gameTime increases
    final currentSpawnInterval =
        (GameConfig.spawnInterval -
                (_gameTime / 10) * GameConfig.difficultyScaling)
            .clamp(GameConfig.minSpawnInterval, GameConfig.spawnInterval);

    _spawnTimer += dt;
    if (_spawnTimer >= currentSpawnInterval) {
      _spawnTimer = 0;
      _spawnEnemy();
    }
  }

  void onPlayerDeath() {
    if (isGameOver) return;
    player.die();
    isGameOver = true;
    overlays.add('GameOver');
  }

  void resetGame() {
    _startOrRestart();
    overlays.remove('GameOver');
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (isGameOver) return;
    player.position += info.delta.global;
  }

  void _spawnEnemy() {
    final roll = _random.nextDouble();

    // As gameTime increases, special enemies become more common
    final specialChance =
        (_gameTime / 60) * 0.5; // Starts at 0, goes to 50% chance at 1 min

    if (roll < specialChance) {
      final subRoll = _random.nextDouble();
      if (subRoll < 0.33) {
        // Scout: Tiny, fast, zig-zag
        add(Enemy(type: EnemyType.scout, speed: GameConfig.scoutSpeed));
      } else if (subRoll < 0.66) {
        // Tank: Large, slow, tough
        add(
          Enemy(
            type: EnemyType.tank,
            speed: GameConfig.tankSpeed,
            health: GameConfig.tankHealth,
          ),
        );
      } else {
        // Kamikaze: Fast dive
        add(Enemy(type: EnemyType.kamikaze, speed: GameConfig.kamikazeSpeed));
      }
    } else {
      // Standard enemy
      final speed =
          GameConfig.enemySpeedMin +
          _random.nextDouble() *
              (GameConfig.enemySpeedMax - GameConfig.enemySpeedMin);
      add(Enemy(speed: speed, type: EnemyType.standard));
    }
  }
}
