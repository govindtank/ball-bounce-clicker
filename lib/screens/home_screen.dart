import 'dart:math';
import 'package:flutter/material.dart';
import '../game/bounce_zone.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  final BounceZoneState gameState;
  final VoidCallback onPlay;

  const HomeScreen({
    super.key,
    required this.gameState,
    required this.onPlay,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  int _highScore = 0;
  double _bestTime = 0;
  int _bestWave = 0;

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
    final bt = await GameStorage.loadBestTime();
    final bw = await GameStorage.loadBestWave();
    if (mounted) {
      setState(() {
        _highScore = hs;
        _bestTime = bt;
        _bestWave = bw;
        widget.gameState.highScore = hs;
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
          // Animated background particles
          _buildAnimatedBackground(size, _animController),

          // Main content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Title
                  _buildTitle(),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'DODGE. SURVIVE. CONQUER.',
                    style: TextStyle(
                      fontSize: isWide ? 16 : 12,
                      letterSpacing: 5,
                      color: Colors.white38,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Play button
                  _buildNeonButton(
                    label: '▶  PLAY',
                    color: const Color(0xFF7C4DFF),
                    width: isWide ? 280 : 220,
                    onTap: widget.onPlay,
                  ),
                  const SizedBox(height: 32),

                  // Best stats
                  _buildStatsPanel(isWide),

                  const SizedBox(height: 32),

                  // How to play
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
              Color(0xFFFF6B9D),
              Color(0xFF00E5FF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
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
              'ZONE',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w100,
                color: Color.fromRGBO(255, 107, 157, glow),
                letterSpacing: 14,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsPanel(bool isWide) {
    return Container(
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
        children: [
          const Text(
            'BEST RUN',
            style: TextStyle(
              color: Color(0xFF7C4DFF),
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatCard(
                icon: Icons.emoji_events,
                label: 'SCORE',
                value: '$_highScore',
                color: const Color(0xFFFFD700),
              ),
              if (isWide) const SizedBox(width: 24) else const SizedBox(width: 12),
              _StatCard(
                icon: Icons.timer,
                label: 'TIME',
                value: _formatTime(_bestTime),
                color: const Color(0xFF00E5FF),
              ),
              if (isWide) const SizedBox(width: 24) else const SizedBox(width: 12),
              _StatCard(
                icon: Icons.timeline,
                label: 'WAVE',
                value: '$_bestWave',
                color: const Color(0xFFFF6B9D),
              ),
            ],
          ),
        ],
      ),
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
          _HowToItem(
            icon: '👆',
            text: 'Tap anywhere to push the ball in that direction',
          ),
          _HowToItem(
            icon: '⚡',
            text: 'Dodge spinning bars, chasing enemies, and lasers',
          ),
          _HowToItem(
            icon: '🛡️',
            text: 'Collect power-ups: Shield, Slow Time, and Repel',
          ),
          _HowToItem(
            icon: '🏆',
            text: 'Survive as long as possible — each wave is harder!',
          ),
        ],
      ),
    );
  }

  String _formatTime(double seconds) {
    if (seconds <= 0) return '0s';
    final mins = seconds ~/ 60;
    final secs = (seconds % 60).toInt();
    if (mins > 0) return '${mins}m ${secs}s';
    return '${secs}s';
  }

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

class _HowToItem extends StatelessWidget {
  final String icon;
  final String text;

  const _HowToItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.6),
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
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
            final glow = _pulseController.value * 0.5;
            return Container(
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
            );
          },
        ),
      ),
    );
  }
}

// Animated background
class _AnimatedBackgroundPainter extends CustomPainter {
  final double animValue;

  _AnimatedBackgroundPainter(this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (int i = 0; i < 20; i++) {
      final x = (i * size.width / 20 + animValue * 50) % size.width;
      final y = (sin(i * 1.3 + animValue * 2) * 0.5 + 0.5) * size.height;
      paint.color = Color.fromRGBO(
        255,
        107 + i * 5 % 100,
        157,
        0.03 + sin(i + animValue * 3) * 0.02,
      );
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 2 + sin(i + animValue) * 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedBackgroundPainter old) => true;
}

Widget _buildAnimatedBackground(Size size, AnimationController animController) {
  return Positioned.fill(
    child: AnimatedBuilder(
      animation: animController,
      builder: (context, child) {
        return CustomPaint(
          size: size,
          painter: _AnimatedBackgroundPainter(animController.value),
        );
      },
    ),
  );
}
