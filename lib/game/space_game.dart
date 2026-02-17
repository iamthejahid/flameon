import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
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
    _startOrRestart();
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
    final speed =
        GameConfig.enemySpeedMin +
        _random.nextDouble() *
            (GameConfig.enemySpeedMax - GameConfig.enemySpeedMin);
    add(Enemy(speed: speed));
  }
}
