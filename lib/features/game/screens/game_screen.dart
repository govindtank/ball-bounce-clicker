import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../widgets/ball_widget.dart';
import '../widgets/score_display.dart';
import '../widgets/particle_effect.dart';
import '../models/game_state.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  Offset lastTapPosition = Offset.zero;
  bool showParticles = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // Game over screen state
  bool showGameOver = false;
  int finalScore = 0;
  int finalTaps = 0;
  
  // Web-optimized layout
  bool get isWeb => MediaQuery.of(context).size.width > 600;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void handleTap(TapDownDetails details) {
    final position = Offset(
      details.localPosition.dx,
      details.localPosition.dy,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<GameState>().incrementScore();
        setState(() {
          lastTapPosition = position;
          showParticles = true;
        });
        
        // Check for game over (example: 10000 taps)
        final gameState = context.read<GameState>();
        if (gameState.totalTaps >= 10000 && !showGameOver) {
          _showGameOverScreen(gameState);
        }
      }
    });
  }

  void _showGameOverScreen(GameState gameState) {
    setState(() {
      showGameOver = true;
      finalScore = gameState.score;
      finalTaps = gameState.totalTaps;
    });
  }

  void hideParticles() {
    setState(() {
      showParticles = false;
    });
  }

  void restartGame() {
    context.read<GameState>().resetGame();
    setState(() {
      showGameOver = false;
      showParticles = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundDark,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Color(0xFF1A1A2E),
                  AppConstants.backgroundDark,
                  AppConstants.backgroundDarker,
                ],
              ),
            ),
          ),
          
          // Animated background grid
          CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: GridPainter(),
          ),
          
          // Particle effect overlay
          if (showParticles && lastTapPosition != Offset.zero)
            ParticleEffect(
              position: lastTapPosition,
              onComplete: hideParticles,
            ),
          
          // Main game content
          if (!showGameOver)
            Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = isWeb ? 600.0 : constraints.maxWidth;
                  return ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: _buildGameContent(constraints),
                  );
                },
              ),
            ),
          
          // Game over screen
          if (showGameOver) _buildGameOverScreen(),
          
          // Top bar with menu
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(),
          ),
          
          // Bottom info bar
          if (!showGameOver)
            Consumer<GameState>(
              builder: (context, gameState, child) {
                if (gameState.totalTaps > 0) {
                  return Positioned(
                    bottom: AppConstants.paddingStandard + 8,
                    left: AppConstants.paddingStandard,
                    right: AppConstants.paddingStandard,
                    child: _buildBottomBar(gameState),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildGameContent(BoxConstraints constraints) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Score display
        Consumer<GameState>(
          builder: (context, gameState, child) {
            return ScoreDisplay(
              points: gameState.score,
              onPointsChanged: (int newScore) {},
            );
          },
        ),
        
        const SizedBox(height: 60),
        
        // Tap area with animated ball
        GestureDetector(
          onTapDown: handleTap,
          child: AnimatedBuilder(
            listenable: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: isWeb ? 200 : 150,
                  height: isWeb ? 200 : 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        AppConstants.glowPurple,
                        AppConstants.primaryColor,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryColor.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: AppConstants.glowPink.withOpacity(0.3),
                        blurRadius: 50,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.touch_app,
                      size: isWeb ? 80 : 60,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppConstants.backgroundDarker.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppConstants.glowPurple, AppConstants.accentColor],
              ).createShader(bounds),
              child: const Text(
                'BALL BOUNCE',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
            
            // Menu button
            PopupMenuButton<String>(
              icon: Icon(
                Icons.menu,
                color: Colors.white.withOpacity(0.8),
              ),
              color: AppConstants.surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == 'reset') {
                  _showResetDialog(context);
                } else if (value == 'about') {
                  _showAboutDialog(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'about',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppConstants.accentColor),
                      SizedBox(width: 8),
                      Text('About', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'reset',
                  child: Row(
                    children: [
                      Icon(Icons.refresh, color: AppConstants.neonOrange),
                      SizedBox(width: 8),
                      Text('Reset Game', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(GameState gameState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _InfoChip(
          icon: Icons.auto_awesome,
          label: 'Multiplier',
          value: '${gameState.scoreMultiplier.toStringAsFixed(1)}x',
          color: AppConstants.neonGreen,
        ),
        
        _InfoChip(
          icon: Icons.touch_app,
          label: 'Taps',
          value: '${gameState.totalTaps}',
          color: AppConstants.accentColor,
        ),
        
        _InfoChip(
          icon: Icons.star,
          label: 'Goal',
          value: '${(gameState.totalTaps / 100).floor()}/100',
          color: AppConstants.glowPink,
        ),
      ],
    );
  }

  Widget _buildGameOverScreen() {
    return Container(
      color: AppConstants.backgroundDarker.withOpacity(0.95),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2A2A4E),
                Color(0xFF1A1A2E),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppConstants.glowPink.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppConstants.glowPink.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppConstants.glowPink, AppConstants.primaryColor],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.glowPink.withOpacity(0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppConstants.glowPink, AppConstants.accentColor],
                ).createShader(bounds),
                child: const Text(
                  'GAME COMPLETE!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Stats
              _StatRow(label: 'Final Score', value: _formatNumber(finalScore)),
              const SizedBox(height: 12),
              _StatRow(label: 'Total Taps', value: '$finalTaps'),
              const SizedBox(height: 12),
              _StatRow(label: 'Max Multiplier', value: '5.0x'),
              
              const SizedBox(height: 32),
              
              // Play again button
              ElevatedButton.icon(
                onPressed: restartGame,
                icon: const Icon(Icons.replay),
                label: const Text('PLAY AGAIN'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Reset Game',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Clear all progress and start over?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<GameState>().resetGame();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppConstants.glowPurple, AppConstants.accentColor],
              ).createShader(bounds),
              child: const Text(
                '🎮 Ball Bounce',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'An idle clicker game where you tap to earn points and unlock multipliers!',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              'How to Play:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('• Tap the ball to earn points', style: TextStyle(color: Colors.grey)),
            Text('• Every 100 taps increases your multiplier', style: TextStyle(color: Colors.grey)),
            Text('• Reach 10,000 taps to complete!', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 16),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoChip({
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
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
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
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppConstants.accentColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

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

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppConstants.primaryColor.withOpacity(0.05)
      ..strokeWidth = 1;

    const spacing = 40.0;
    
    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
