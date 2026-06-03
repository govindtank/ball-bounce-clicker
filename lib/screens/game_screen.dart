import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../game/bounce_zone.dart';
import '../game/game_painter.dart';

class GameScreen extends StatefulWidget {
  final BounceZoneState gameState;
  final VoidCallback onGameOver;

  const GameScreen({
    super.key,
    required this.gameState,
    required this.onGameOver,
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
    widget.gameState.resetGame();
    widget.gameState.status = GameStatus.playing;
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

      if (widget.gameState.status == GameStatus.gameOver) {
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
          }
          return KeyEventResult.ignored;
        },
        child: Stack(
          children: [
            // ── Game Canvas ──
            GestureDetector(
              onTapDown: (details) {
                if (gs.status == GameStatus.playing) {
                  gs.pushBall(details.localPosition.dx, details.localPosition.dy);
                }
              },
              child: CustomPaint(
                size: Size(size.width, size.height),
                painter: BounceZonePainter(gs, _animTime),
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
                        // Wave
                        _HudChip(
                          icon: Icons.timeline,
                          label: 'Wave ${gs.wave}',
                          color: const Color(0xFF00E5FF),
                        ),
                        // Score
                        _HudChip(
                          icon: Icons.stars,
                          label: _formatScore(gs.score),
                          color: const Color(0xFFFFD700),
                        ),
                        // Survival time
                        _HudChip(
                          icon: Icons.timer,
                          label: _formatTime(gs.survivalTime),
                          color: const Color(0xFFFF6B9D),
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
                  const Spacer(),
                ],
              ),
            ),

            // ── Power-up indicators ──
            if (gs.shieldTimer > 0 || gs.slowMoTimer > 0)
              Positioned(
                top: 80,
                left: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (gs.shieldTimer > 0)
                      _PowerUpBar(
                        label: 'SHIELD',
                        value: gs.shieldTimer,
                        maxValue: 8,
                        color: const Color(0xFFFFD700),
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
              onPressed: () {
                _ticker.stop();
                widget.onGameOver();
              },
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
            const SizedBox(height: 16),
            Text(
              'Score: ${_formatScore(gs.score)}',
              style: const TextStyle(
                fontSize: 28,
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Wave: ${gs.wave}  •  Time: ${_formatTime(gs.survivalTime)}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white54,
                fontWeight: FontWeight.w400,
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
              label: 'PLAY AGAIN',
              color: const Color(0xFF7C4DFF),
              onPressed: () {
                gs.resetGame();
                gs.status = GameStatus.playing;
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
              onPressed: () {
                _ticker.stop();
                widget.onGameOver();
              },
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

  String _formatTime(double seconds) {
    final mins = seconds ~/ 60;
    final secs = (seconds % 60).toInt();
    if (mins > 0) return '${mins}m ${secs}s';
    return '${secs}s';
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
