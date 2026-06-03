import 'package:flutter/material.dart';
import 'game/bounce_zone.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BounceZoneApp());
}

class BounceZoneApp extends StatelessWidget {
  const BounceZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bounce Zone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D1A),
        fontFamily: 'monospace',
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final BounceZoneState _gameState = BounceZoneState();
  int _currentScreen = 0; // 0=home, 1=game

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final hs = await GameStorage.loadHighScore();
    if (mounted) {
      setState(() {
        _gameState.highScore = hs;
      });
    }
  }

  Future<void> _onGameOver() async {
    final gs = _gameState;
    // Save high score
    if (gs.score > gs.highScore) {
      gs.highScore = gs.score;
      await GameStorage.saveHighScore(gs.highScore);
    }
    // Save best time
    final currentBestTime = await GameStorage.loadBestTime();
    if (gs.survivalTime > currentBestTime) {
      await GameStorage.saveBestTime(gs.survivalTime);
    }
    // Save best wave
    final currentBestWave = await GameStorage.loadBestWave();
    if (gs.wave > currentBestWave) {
      await GameStorage.saveBestWave(gs.wave);
    }

    if (mounted) {
      setState(() => _currentScreen = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentScreen) {
      case 0:
        return HomeScreen(
          key: const ValueKey('home'),
          gameState: _gameState,
          onPlay: () => setState(() => _currentScreen = 1),
        );
      case 1:
        return GameScreen(
          key: ValueKey('game_${DateTime.now().millisecondsSinceEpoch}'),
          gameState: _gameState,
          onGameOver: _onGameOver,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
