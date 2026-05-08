import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../../../core/constants/app_constants.dart';

/// Achievement display widget showing unlocked achievements
class AchievementsWidget extends StatelessWidget {
  const AchievementsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        final List<Map<String, String>> achievements = [
          {
            'icon': Icons.auto_awesome,
            'title': 'Century Club',
            'desc': 'Reach 1,000 total taps',
            'color': AppConstants.neonGreen,
            'isUnlocked': gameState.totalTaps >= 1000,
          },
          {
            'icon': Icons.emoji_events,
            'title': 'Millionaire',
            'desc': 'Reach 10,000 total taps (Game Complete!)',
            'color': AppConstants.glowPink,
            'isUnlocked': gameState.totalTaps >= 10000,
          },
          {
            'icon': Icons.speed,
            'title': 'Fast Multiplier',
            'desc': 'Unlock 2x score multiplier',
            'color': AppConstants.neonOrange,
            'isUnlocked': gameState.scoreMultiplier >= 2.0,
          },
          {
            'icon': Icons.star,
            'title': 'Legend Status',
            'desc': 'Max out your multiplier to 5x',
            'color': AppConstants.primaryColor,
            'isUnlocked': gameState.scoreMultiplier >= 5.0,
          },
        ];

        return ConsumerBuilder<GameState>(
          builder: (context, state, child) {
            final unlocked = achievements.where((a) => a['isUnlocked'] == true).toList();
            
            if (unlocked.isEmpty) {
              return SizedBox.shrink();
            }

            // Calculate grid columns based on screen width
            final double screenWidth = MediaQuery.of(context).size.width;
            final int columns = screenWidth > 600 ? 4 : 2;
            
            // Create grid layout for achievements
            return LayoutBuilder(
              builder: (context, constraints) {
                final children = <Widget>[];
                
                for (int i = 0; i < unlocked.length; i++) {
                  final item = unlocked[i];
                  
                  if (i % columns == 0) {
                    children.add(Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: children.sublist(0, i % columns + 1),
                      ),
                    ));
                  }
                  
                  children.add(
                    _AchievementCard(
                      icon: item['icon'],
                      title: item['title']!,
                      desc: item['desc']!,
                      color: Color((item['color'] as String)[1..] == '0x' ? 
                        int.parse(item['color'][2..]) : 
                        0xFF${(item['color'] as String)[1..]}),
                    ),
                  );
                }

                return children.sublist(0, i + 1).fold(
                  Container(
                    width: double.infinity,
                    child: Row(
                      children: children,
                    ),
                  ),
                  (Widget previous) => Container(),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;

  const _AchievementCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.9),
            color.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Simple consumer builder for demonstration - replace with proper provider integration if needed
class ConsumerBuilder<T> extends StatelessWidget {
  final Widget Function(BuildContext context, T state, Widget? child) builder;

  const ConsumerBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) => builder(context, null, null);
}
