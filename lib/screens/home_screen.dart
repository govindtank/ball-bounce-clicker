import 'dart:math';
import 'package:flutter/material.dart';
import '../game/game_engine.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  final BounceGameState gameState;
  final VoidCallback onPlay;
  final VoidCallback onLevelSelect;

  const HomeScreen({
    super.key,
    required this.gameState,
    required this.onPlay,
    required this.onLevelSelect,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  int _highScore = 0;
  int _unlockedLevel = 1;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _loadData();
  }

  Future<void> _loadData() async {
    final hs = await GameStorage.loadHighScore();
    final ul = await GameStorage.loadUnlockedLevel();
    if (mounted) {
      setState(() {
        _highScore = hs;
        _unlockedLevel = ul;
        widget.gameState.highScore = hs;
        widget.gameState.maxUnlockedLevel = ul;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Stack(
        children: [
          // ── Animated background ──
          _buildAnimatedBackground(size),

          // ── Main content ──
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // ── Title ──
                  _buildTitle(),
                  const SizedBox(height: 8),

                  // ── Subtitle ──
                  Text(
                    'BREAK THE BRICKS. EARN THE GLORY.',
                    style: TextStyle(
                      fontSize: isWide ? 16 : 12,
                      letterSpacing: 4,
                      color: Colors.white38,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ── Play Button ──
                  _buildNeonButton(
                    label: '▶  PLAY',
                    color: const Color(0xFF7C4DFF),
                    width: isWide ? 280 : 220,
                    onTap: widget.onPlay,
                  ),
                  const SizedBox(height: 20),

                  // ── Level Select ──
                  _buildNeonButton(
                    label: '📋  LEVELS',
                    color: const Color(0xFF00E5FF),
                    width: isWide ? 280 : 220,
                    onTap: widget.onLevelSelect,
                  ),
                  const SizedBox(height: 24),

                  // ── Stats row ──
                  _buildStatsRow(isWide),

                  const SizedBox(height: 40),

                  // ── How to Play ──
                  _buildHowToPlay(isWide),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF7C4DFF),
              Color(0xFF00E5FF),
              Color(0xFFFF6B9D),
              Color(0xFFFFD700),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'BOUNCE',
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 8,
              height: 1.0,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            final glow = 0.6 + _animController.value * 0.4;
            return Text(
              'ARENA',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w100,
                color: Color.fromRGBO(124, 77, 255, glow),
                letterSpacing: 12,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsRow(bool isWide) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_highScore > 0)
          _StatChip(
            icon: Icons.emoji_events,
            label: 'High Score: $_highScore',
            color: const Color(0xFFFFD700),
          ),
        const SizedBox(width: 16),
        _StatChip(
          icon: Icons.grid_view,
          label: '$_unlockedLevel/15',
          color: const Color(0xFF7C4DFF),
        ),
      ],
    );
  }

  Widget _buildHowToPlay(bool isWide) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0A2E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF7C4DFF).withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: const Color(0xFF7C4DFF)),
              const SizedBox(width: 8),
              Text(
                'HOW TO PLAY',
                style: TextStyle(
                  color: const Color(0xFF7C4DFF),
                  fontSize: isWide ? 14 : 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._howToItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.icon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.text,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: isWide ? 14 : 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<({String icon, String text})> get _howToItems => [
        (
          icon: '🖱️',
          text: 'Drag or use arrow keys to move paddle'
        ),
        (
          icon: '🎯',
          text: 'Tap or press Space to launch the ball'
        ),
        (
          icon: '🧱',
          text: 'Break all destroyable bricks to clear the level'
        ),
        (
          icon: '⭐',
          text: 'Build combos for massive score multipliers'
        ),
        (
          icon: '⚡',
          text: 'Collect power-ups: Wide, Fire, Slow, 1UP'
        ),
      ];

  Widget _buildNeonButton({
    required String label,
    required Color color,
    required double width,
    required VoidCallback onTap,
  }) {
    return _NeonButtonWidget(
      label: label,
      color: color,
      width: width,
      onTap: onTap,
    );
  }
}

class _NeonButtonWidget extends StatefulWidget {
  final String label;
  final Color color;
  final double width;
  final VoidCallback onTap;

  const _NeonButtonWidget({
    required this.label,
    required this.color,
    required this.width,
    required this.onTap,
  });

  @override
  State<_NeonButtonWidget> createState() => _NeonButtonWidgetState();
}

class _NeonButtonWidgetState extends State<_NeonButtonWidget>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final pulse = _hovered ? 1.0 : 1.0; // Only pulse on hover
            final glow = !_hovered && !_pulseController.isAnimating
                ? 0.0
                : _pulseController.value * 0.5;
            return Transform.scale(
              scale: 1.0,
              child: Container(
                width: widget.width,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.color,
                      widget.color.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3 + glow),
                      blurRadius: 15 + glow * 20,
                      spreadRadius: _hovered ? 3 : 0,
                    ),
                  ],
                ),
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper for animated backgrounds
class _AnimatedBackgroundPainter extends CustomPainter {
  final double animationValue;

  _AnimatedBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (int i = 0; i < 20; i++) {
      final x = (i * size.width / 20 + animationValue * 50) % size.width;
      final y = (sin(i * 1.3 + animationValue * 2) * 0.5 + 0.5) * size.height;
      paint.color = Color.fromRGBO(
        124,
        77 + i * 5 % 100,
        255,
        0.03 + sin(i + animationValue * 3) * 0.02,
      );
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 2 + sin(i + animationValue) * 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedBackgroundPainter old) => true;
}

Widget _buildAnimatedBackground(Size size) {
  return AnimatedBuilder(
    animation: const AlwaysStoppedAnimation(0), // Will be replaced
    builder: (context, child) {
      // This is handled differently in the Stack
      return const SizedBox.expand();
    },
  );
}
