class GameConfig {
  static const double playerSpeed = 300.0;
  static const double playerSize = 64.0;

  static const double bulletSpeed = 500.0;
  static const double bulletSize = 16.0;

  static const double enemySpeedMin = 100.0;
  static const double enemySpeedMax = 250.0;
  static const double enemySize = 50.0;

  // Scout Config
  static const double scoutSpeed = 350.0;
  static const double scoutSize = 32.0;
  static const double scoutZigZagSpeed = 5.0;
  static const double scoutZigZagAmplitude = 150.0;

  // Tank Config
  static const double tankSpeed = 80.0;
  static const double tankSize = 80.0;
  static const int tankHealth = 3;

  // Kamikaze Config
  static const double kamikazeSpeed = 450.0;
  static const double kamikazeSize = 40.0;

  static const double spawnInterval = 1.5; // Initial seconds
  static const double minSpawnInterval = 0.4; // Fastest spawn rate
  static const double difficultyScaling =
      0.1; // Decrease interval by 0.1s every 10 seconds
  static const double fireInterval = 0.25; // seconds (4 shots per sec)

  // Audio Settings
  static bool sfxEnabled = true;
  static const String sfxShoot = 'shoot.wav';
  static const String sfxExplosion = 'explosion.wav';
}
