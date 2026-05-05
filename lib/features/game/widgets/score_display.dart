import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../models/game_state.dart';

class ScoreDisplay extends StatefulWidget {
  final int points;
  final Function(int) onPointsChanged;
  
  const ScoreDisplay({
    super.key,
    required this.points,
    required this.onPointsChanged,
  });
  
  @override
  State<ScoreDisplay> createState() => _ScoreDisplayState();
}

class _ScoreDisplayState extends State<ScoreDisplay> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _displayedScore = 0;
  int _lastAnimationScore = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _displayedScore = widget.points;
  }

  @override
  void didUpdateWidget(ScoreDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.points != _lastAnimationScore) {
      _lastAnimationScore = widget.points;
      _animateScoreChange();
    }
  }

  void _animateScoreChange() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    
    // Animate the score number
    _animateNumber(_displayedScore, widget.points);
  }

  void _animateNumber(int from, int to) async {
    final duration = const Duration(milliseconds: 300);
    final steps = 10;
    final stepDuration = duration.inMilliseconds ~/ steps;
    final diff = to - from;
    
    for (int i = 1; i <= steps; i++) {
      await Future.delayed(Duration(milliseconds: stepDuration));
      if (mounted) {
        setState(() {
          _displayedScore = from + (diff * i ~/ steps);
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Score text with bounce effect
            AnimatedBuilder(
              listenable: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        AppConstants.glowPurple,
                        AppConstants.accentColor,
                        AppConstants.glowPink,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      _formatNumber(_displayedScore),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 80,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 4),
            
            // Points per tap indicator with glow
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppConstants.primaryColor.withOpacity(0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                '+${AppConstants.pointsPerTap * gameState.scoreMultiplier.round()} pts/tap',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppConstants.accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatChip(
                  icon: Icons.touch_app,
                  label: 'Taps',
                  value: '${gameState.totalTaps}',
                  color: AppConstants.glowPurple,
                ),
                const SizedBox(width: 16),
                _StatChip(
                  icon: Icons.bolt,
                  label: 'Multiplier',
                  value: '${gameState.scoreMultiplier.toStringAsFixed(1)}x',
                  color: AppConstants.accentColor,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom AnimatedBuilder widget
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
