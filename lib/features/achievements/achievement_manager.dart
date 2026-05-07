import 'dart:collection';

/// Achievement types unlocked through gameplay
enum AchievementType {
  /// First time reaching level 10
  reachLevel10,
  
  /// First time reaching level 25
  reachLevel25,
  
  /// First time reaching level 50
  reachLevel50,
  
  /// Reach 100,000 total taps
  hundredKTapMilestone,
  
  /// Reach 1,000,000 total taps
  millionTapMilestone,
  
  /// Collect all power-ups in a run
  collectAllPowerups,
  
  /// Achieve perfect tap streak (no misses for 5 minutes)
  perfectStreak,
  
  /// Use every power-up type at least once
  tryAllPowerups,
}

/// Data structure for an achievement
class Achievement {
  final AchievementType type;
  final String title;
  final String description;
  final IconData icon;
  final int points; // Points unlocked when completed
  
  /// Whether this achievement is currently unlocked
  bool unlocked = false;
  
  const Achievement({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
  });
  
  factory Achievement.fromType(AchievementType type) {
    switch (type) {
      case AchievementType.reachLevel10:
        return const Achievement(
          type: AchievementType.reachLevel10,
          title: 'Novice',
          description: 'Reach level 10',
          icon: Icons.child_friendly_outlined,
          points: 10,
        );
      case AchievementType.reachLevel25:
        return const Achievement(
          type: AchievementType.reachLevel25,
          title: 'Apprentice',
          description: 'Reach level 25',
          icon: Icons.local_drink_outlined,
          points: 25,
        );
      case AchievementType.reachLevel50:
        return const Achievement(
          type: AchievementType.reachLevel50,
          title: 'Master',
          description: 'Reach level 50',
          icon: Icons.local_fire_department_outlined,
          points: 50,
        );
      case AchievementType.hundredKTapMilestone:
        return const Achievement(
          type: AchievementType.hundredKTapMilestone,
          title: 'Centurion',
          description: 'Reach 100,000 total taps',
          icon: Icons.local_shipping_outlined,
          points: 100,
        );
      case AchievementType.millionTapMilestone:
        return const Achievement(
          type: AchievementType.millionTapMilestone,
          title: 'Legend',
          description: 'Reach 1,000,000 total taps',
          icon: Icons.emoji_events_outlined,
          points: 500,
        );
      case AchievementType.collectAllPowerups:
        return const Achievement(
          type: AchievementType.collectAllPowerups,
          title: 'Jack of All Trades',
          description: 'Collect all power-up types in a run',
          icon: Icons.strategery_outlined,
          points: 75,
        );
      case AchievementType.perfectStreak:
        return const Achievement(
          type: AchievementType.perfectStreak,
          title: 'Perfect Tap',
          description: 'No misses for 5 minutes straight',
          icon: Icons.favorite_outline,
          points: 200,
        );
      case AchievementType.tryAllPowerups:
        return const Achievement(
          type: AchievementType.tryAllPowerups,
          title: 'Collector',
          description: 'Use every power-up type at least once',
          icon: Icons.collect_all_outlined,
          points: 150,
        );
    }
  }
  
  /// Check if this achievement can be completed with the given state
  bool canComplete(GameState state) {
    switch (type) {
      case AchievementType.reachLevel10:
      case AchievementType.reachLevel25:
      case AchievementType.reachLevel50:
        return state.currentLevel >= type.index + 1;
      case AchievementType.hundredKTapMilestone:
      case AchievementType.millionTapMilestone:
        final threshold = type == AchievementType.hundredKTapMilestone ? 100000 : 1000000;
        return state.totalTaps >= threshold;
      default:
        return false;
    }
  }
  
  /// Unlock this achievement if conditions are met
  void unlockIfPossible(GameState state) {
    if (unlocked) return;
    
    if (canComplete(state)) {
      unlocked = true;
    }
  }
}

/// Manages all achievements for a game session
class AchievementManager {
  final List<Achievement> _achievements = [];
  
  /// Whether achievements are enabled (can be disabled in settings)
  bool get enabled => true;
  
  /// Initialize with all achievements
  void initialize() {
    for (final type in AchievementType.values) {
      _achievements.add(Achievement.fromType(type));
    }
  }
  
  /// Check if an achievement is unlocked
  bool isUnlocked(AchievementType type) {
    final achievement = _achievements.firstWhere(
      (a) => a.type == type,
      orElse: () => Achievement.fromType(type),
    );
    return achievement.unlocked;
  }
  
  /// Unlock an achievement and return the reward points
  int unlock(AchievementType type, {GameState? state}) {
    final achievement = _achievements.firstWhere(
      (a) => a.type == type,
      orElse: () => Achievement.fromType(type),
    );
    
    if (!achievement.unlocked) {
      achievement.unlocked = true;
      return achievement.points;
    }
    return 0;
  }
  
  /// Check all achievements against current state and unlock completed ones
  int checkGameState(GameState state) {
    int totalPoints = 0;
    
    for (final achievement in _achievements) {
      if (!achievement.unlocked && achievement.canComplete(state)) {
        achievement.unlocked = true;
        totalPoints += achievement.points;
      }
    }
    
    return totalPoints;
  }
  
  /// Get list of unlocked achievements with their reward
  List<Map<String, dynamic>> getUnlockedRewards() {
    final List<Map<String, dynamic>> rewards = [];
    
    for (final achievement in _achievements) {
      if (achievement.unlocked) {
        rewards.add({
          'title': achievement.title,
          'description': achievement.description,
          'points': achievement.points,
          'icon': achievement.icon,
        });
      }
    }
    
    return rewards;
  }
  
  /// Get list of locked achievements the player is close to unlocking
  List<Achievement> getNearbyAchievements(GameState state) {
    final List<Achievement> nearby = [];
    
    for (final achievement in _achievements) {
      if (!achievement.unlocked && achievement.canComplete(state)) {
        nearby.add(achievement);
      }
    }
    
    return nearby;
  }
}

/// Game state for checking achievements
class AchievementCheckState {
  final int currentLevel;
  final int totalTaps;
  
  const AchievementCheckState({
    required this.currentLevel,
    required this.totalTaps,
  });
}
