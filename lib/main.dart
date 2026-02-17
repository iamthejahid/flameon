import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/space_game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flame On',
      theme: ThemeData.dark(),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final SpaceGame _game;

  @override
  void initState() {
    super.initState();
    _game = SpaceGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: _game,
        overlayBuilderMap: {
          'PauseMenu': (context, SpaceGame game) {
            return Center(
              child: ElevatedButton(
                onPressed: () => game.overlays.remove('PauseMenu'),
                child: const Text('Resume'),
              ),
            );
          },
          'GameOver': (context, SpaceGame game) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'GAME OVER',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Score: ${game.score}',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => game.resetGame(),
                      child: const Text('Restart'),
                    ),
                  ],
                ),
              ),
            );
          },
        },
      ),
    );
  }
}
