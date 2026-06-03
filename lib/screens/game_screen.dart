import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../game/game_engine.dart';
import '../game/game_painter.dart';

class GameScreen extends StatefulWidget {
  final BounceGameState gameState;
  final int startLevel;
  final VoidCallback onLevelComplete;
  final VoidCallback onGameOver;
  final VoidCallback onQuit;

  const GameScreen({
    super.key,
    required this.gameState,
    required this.startLevel,
    required this.onLevelComplete,
    required this.onGameOver,
    required this.onQuit,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _animTime = 0;
  double _lastTime = 0;
  bool _showPauseMenu = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    widget.gameState.reset(widget.startLevel);
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1000000.0;
    final dt = _lastTime == 0 ? 0.016 : (now - _lastTime).clamp(0.001, 0.05);
    _lastTime = now;
    _animTime += dt;

    if (!_showPauseMenu) {
      widget.gameState.update(dt);
    }

    if (mounted) {
      setState(() {});

      if (widget.gameState.status == GameStatus.levelComplete) {
        _ticker.stop();
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) widget.onLevelComplete();
        });
      } else if (widget.gameState.status == GameStatus.gameOver) {
        _ticker.stop();
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) widget.onGameOver();
        });
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final gs = widget.gameState;
    final isPaused = _showPauseMenu;
    final isWide = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape ||
                event.logicalKey == LogicalKeyboardKey.pause) {
              setState(() => _showPauseMenu = !_showPauseMenu);
              return KeyEventResult.handled;
            }
            // Arrow keys for paddle
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              gs.movePaddleTo(gs.paddle.x - 30);
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              gs.movePaddleTo(gs.paddle.x + 30);
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.space) {
              if (!gs.ballLaunched) gs.launchBall();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Stack(
          children: [
            // ── Game Canvas ──
            GestureDetector(
              onPanUpdate: (details) {
                gs.movePaddleTo(gs.paddle.x + details.delta.dx);
              },
              onTapDown: (details) {
                if (!gs.ballLaunched && gs.lives > 0) {
                  gs.launchBall();
                }
              },
              child: CustomPaint(
                size: Size(size.width, size.height),
                painter: BounceGamePainter(gs, _animTime),
              ),
            ),

            // ── HUD ──
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: isWide ? 12 : 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Level
                        _HudChip(
                          icon: Icons.flag,
                          label: 'Level ${gs.currentLevel}',
                          color: const Color(0xFF00E5FF),
                        ),
                        // Score
                        _HudChip(
                          icon: Icons.stars,
                          label: _formatScore(gs.score),
                          color: const Color(0xFFFFD700),
                        ),
                        // Combo
                        if (gs.combo > 1)
                          _HudChip(
                            icon: Icons.auto_awesome,
                            label: '${gs.combo}x',
                            color: const Color(0xFFFF6B9D),
                          ),
                        // Lives
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            gs.lives.clamp(0, 5),
                            (i) => const Padding(
                              padding: EdgeInsets.only(left: 2),
                              child: Icon(
                                Icons.favorite,
                                size: 20,
                                color: Color(0xFFFF1744),
                              ),
                            ),
                          ),
                        ),
                        // Pause button
                        IconButton(
                          icon: const Icon(Icons.pause_circle_outline,
                              color: Colors.white70, size: 28),
                          onPressed: () =>
                              setState(() => _showPauseMenu = true),
                        ),
                      ],
                    ),
                  ),
                  // Combo indicator
                  if (gs.combo > 5)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 200),
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color(0xFFFF6B9D),
                                Color(0xFFFFD700),
                                Color(0xFF00E5FF),
                              ],
                            ).createShader(bounds),
                            child: Text(
                              '🔥 ${gs.combo}x COMBO 🔥',
                              style: TextStyle(
                                fontSize: isWide ? 24 : 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  const Spacer(),
                  // Launch hint
                  if (!gs.ballLaunched && gs.lives > 0)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.6, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, opacity, child) {
                        return Opacity(
                          opacity: opacity,
                          child: const Padding(
                            padding: EdgeInsets.only(bottom: 40),
                            child: Text(
                              'TAP TO LAUNCH',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 16,
                                letterSpacing: 4,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),

            // ── Power-up indicators ──
            if (gs.fireballTimer > 0 || gs.widenTimer > 0 || gs.slowMoTimer > 0)
              Positioned(
                top: 80,
                left: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (gs.fireballTimer > 0)
                      _PowerUpBar(
                        label: 'FIRE',
                        value: gs.fireballTimer,
                        maxValue: 10,
                        color: const Color(0xFFFF6D00),
                      ),
                    if (gs.widenTimer > 0)
                      _PowerUpBar(
                        label: 'WIDE',
                        value: gs.widenTimer,
                        maxValue: 8,
                        color: const Color(0xFF00E5FF),
                      ),
                    if (gs.slowMoTimer > 0)
                      _PowerUpBar(
                        label: 'SLOW',
                        value: gs.slowMoTimer,
                        maxValue: 6,
                        color: const Color(0xFF76FF03),
                      ),
                  ],
                ),
              ),

            // ── Pause Overlay ──
            if (isPaused) _buildPauseOverlay(context),

            // ── Game Over Overlay ──
            if (gs.status == GameStatus.gameOver) _buildGameOverOverlay(context),

            // ── Level Complete Overlay ──
            if (gs.status == GameStatus.levelComplete)
              _buildLevelCompleteOverlay(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPauseOverlay(BuildContext context) {
    return Container(
      color: const Color(0xCC0D0D1A),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PAUSED',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 32),
            _NeonButton(
              label: 'RESUME',
              color: const Color(0xFF7C4DFF),
              onPressed: () => setState(() => _showPauseMenu = false),
            ),
            const SizedBox(height: 16),
            _NeonButton(
              label: 'QUIT',
              color: const Color(0xFFFF1744),
              onPressed: widget.onQuit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay(BuildContext context) {
    final gs = widget.gameState;
    return Container(
      color: const Color(0xDD0D0D1A),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF1744),
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Score: ${_formatScore(gs.score)}',
              style: const TextStyle(
                fontSize: 28,
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (gs.score >= gs.highScore && gs.highScore > 0)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '🏆 NEW HIGH SCORE! 🏆',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF00E5FF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 32),
            _NeonButton(
              label: 'RETRY',
              color: const Color(0xFF7C4DFF),
              onPressed: () {
                widget.gameState.reset(gs.currentLevel);
                setState(() {
                  _lastTime = 0;
                  _showPauseMenu = false;
                });
                _ticker.start();
              },
            ),
            const SizedBox(height: 16),
            _NeonButton(
              label: 'MENU',
              color: const Color(0xFFFF6B9D),
              onPressed: widget.onQuit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCompleteOverlay(BuildContext context) {
    final gs = widget.gameState;
    final isLastLevel = gs.currentLevel >= 15;
    return Container(
      color: const Color(0xCC0D0D1A),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉 LEVEL COMPLETE! 🎉',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF76FF03),
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Score: ${_formatScore(gs.score)}',
              style: const TextStyle(
                fontSize: 24,
                color: Color(0xFFFFD700),
              ),
            ),
            Text(
              'Combo: ${gs.combo}x',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFFFF6B9D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatScore(int score) {
    if (score >= 1000000) return '${(score / 1000000).toStringAsFixed(1)}M';
    if (score >= 1000) return '${(score / 1000).toStringAsFixed(1)}K';
    return '$score';
  }
}

// ── Helper Widgets ──

class _HudChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _HudChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
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

class _PowerUpBar extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;
  final Color color;

  const _PowerUpBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = (value / maxValue).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        width: 80,
        height: 20,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Stack(
          children: [
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fraction,
              child: Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Center(
              child: Text(
                '$label ${value.toStringAsFixed(1)}s',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeonButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _NeonButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<_NeonButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.color,
                widget.color.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ]
                : [],
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
