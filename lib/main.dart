import 'package:flutter/material.dart';
import 'game/game_engine.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BounceArenaApp());
}

class BounceArenaApp extends StatelessWidget {
  const BounceArenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bounce Arena',
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
  final BounceGameState _gameState = BounceGameState();
  int _currentScreen = 0; // 0=home, 1=game, 2=levels
  int _startLevel = 1;
  int _unlockedLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final level = await GameStorage.loadUnlockedLevel();
    final hs = await GameStorage.loadHighScore();
    if (mounted) {
      setState(() {
        _unlockedLevel = level;
        _gameState.maxUnlockedLevel = level;
        _gameState.highScore = hs;
      });
    }
  }

  Future<void> _onLevelComplete() async {
    final nextLevel = _gameState.currentLevel + 1;
    if (nextLevel > _unlockedLevel && nextLevel <= 15) {
      _unlockedLevel = nextLevel;
      _gameState.maxUnlockedLevel = nextLevel;
      await GameStorage.saveUnlockedLevel(nextLevel);
    }
    await GameStorage.saveHighScore(_gameState.highScore);
    if (mounted) {
      setState(() {
        if (nextLevel <= 15) {
          _startLevel = nextLevel;
          // Continue playing
        } else {
          _currentScreen = 0; // Back to home after all levels
        }
      });
    }
  }

  Future<void> _onGameOver() async {
    await GameStorage.saveHighScore(_gameState.highScore);
    if (mounted) {
      setState(() => _currentScreen = 0);
    }
  }

  void goToLevel(int level) {
    setState(() {
      _startLevel = level;
      _currentScreen = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentScreen) {
      case 0:
        return HomeScreen(
          key: ValueKey('home'),
          gameState: _gameState,
          onPlay: () => goToLevel(1),
          onLevelSelect: () => setState(() => _currentScreen = 2),
        );
      case 1:
        return GameScreen(
          key: ValueKey('game_$_startLevel'),
          gameState: _gameState,
          startLevel: _startLevel,
          onLevelComplete: _onLevelComplete,
          onGameOver: _onGameOver,
          onQuit: () {
            _gameState.status = GameStatus.menu;
            setState(() => _currentScreen = 0);
          },
        );
      case 2:
        return _LevelSelectScreen(
          unlockedLevel: _unlockedLevel,
          currentScore: _gameState.highScore,
          onSelect: goToLevel,
          onBack: () => setState(() => _currentScreen = 0),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ══════════════════════════════════════════════════════════════
// LEVEL SELECT SCREEN
// ══════════════════════════════════════════════════════════════

class _LevelSelectScreen extends StatelessWidget {
  final int unlockedLevel;
  final int currentScore;
  final ValueChanged<int> onSelect;
  final VoidCallback onBack;

  const _LevelSelectScreen({
    required this.unlockedLevel,
    required this.currentScore,
    required this.onSelect,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;
    final crossAxisCount = isWide ? 5 : 3;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: onBack,
        ),
        title: const Text(
          'SELECT LEVEL',
          style: TextStyle(
            color: Colors.white70,
            letterSpacing: 3,
            fontWeight: FontWeight.w300,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(isWide ? 40 : 16),
        child: Column(
          children: [
            // Score display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events,
                      size: 18, color: Color(0xFFFFD700)),
                  const SizedBox(width: 8),
                  Text(
                    'High Score: $currentScore',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Level grid
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 15,
                itemBuilder: (context, index) {
                  final level = index + 1;
                  final isUnlocked = level <= unlockedLevel;
                  return _LevelTile(
                    level: level,
                    unlocked: isUnlocked,
                    onTap: isUnlocked ? () => onSelect(level) : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelTile extends StatefulWidget {
  final int level;
  final bool unlocked;
  final VoidCallback? onTap;

  const _LevelTile({
    required this.level,
    required this.unlocked,
    this.onTap,
  });

  @override
  State<_LevelTile> createState() => _LevelTileState();
}

class _LevelTileState extends State<_LevelTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF7C4DFF),
      const Color(0xFFFF6B9D),
      const Color(0xFF00E5FF),
      const Color(0xFFFF9800),
      const Color(0xFF76FF03),
    ];
    final color = colors[(widget.level - 1) % colors.length];

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.unlocked ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.unlocked
                ? color.withOpacity(0.15)
                : const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.unlocked
                  ? color.withOpacity(_hovered ? 0.8 : 0.3)
                  : const Color(0xFF2A2A3E).withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: _hovered && widget.unlocked
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.level}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: widget.unlocked
                      ? color
                      : const Color(0xFF3A3A4E),
                ),
              ),
              const SizedBox(height: 4),
              if (widget.unlocked)
                Icon(
                  Icons.lock_open,
                  size: 14,
                  color: color.withOpacity(0.5),
                )
              else
                const Icon(
                  Icons.lock,
                  size: 14,
                  color: Color(0xFF3A3A4E),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
