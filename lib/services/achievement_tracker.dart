import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import 'dart:convert';

/// Achievement tracking system for Ball Bounce Clicker
class AchievementTracker {
  static const String _key = 'achievements';
  
  // List of achievable milestones
  static const List<Achievement> _achievements = [
    Achievement(
      id: 'first_1k_taps',
      icon: Icons.auto_awesome,
      title: 'Century Club',
      description: 'Reach 1,000 total taps',
      threshold: 1000,
      type: .taps,
    ),
    Achievement(
      id: 'first_10k_taps',
      icon: Icons.emoji_events,
      title: 'Millionaire',
      description: 'Reach 10,000 total taps (Game Complete!)',
      threshold: 10000,
      type: .taps,
    ),
    Achievement(
      id: 'multiplier_2x',
      icon: Icons.speed,
      title: 'Fast Multiplier',
      description: 'Unlock 2x score multiplier',
      threshold: 2.0,
      type: .multiplier,
    ),
    Achievement(
      id: 'multiplier_5x',
      icon: Icons.star,
      title: 'Legend Status',
      description: 'Max out your multiplier to 5x',
      threshold: 5.0,
      type: .multiplier,
    ),
    Achievement(
      id: 'power_up_collector',
      icon: Icons.inventory,
      title: 'Collector',
      description: 'Collect all power-up types (demo)',
      threshold: 4,
      type: .collections,
    ),
  ];
  
  /// Check if an achievement has been unlocked
  static bool isUnlocked(String id) {
    final Map<String, dynamic> data = _loadData();
    if (!data.containsKey('unlocked')) return false;
    
    final List<dynamic> unlocks = data['unlocked'] as List? ?? [];
    return unlocks.any((u) => u['id'] == id);
  }
  
  /// Unlock an achievement if not already unlocked
  static void unlock(String id, Function onUnlocked) {
    final Map<String, dynamic> data = _loadData();
    
    if (!isUnlocked(id)) {
      data['unlocked'].add({
        'id': id,
        'unlockedAt': DateTime.now().toIso8601String(),
      });
      
      // Sort by unlock date (newest first)
      data['unlocked'].sort((a, b) {
        final aTime = DateTime.parse(a['unlockedAt'] as String);
        final bTime = DateTime.parse(b['unlockedAt'] as String);
        return bTime.compareTo(aTime);
      });
      
      _saveData(data);
      onUnlocked();
    }
  }
  
  /// Get list of unlocked achievements
  static List<Achievement> getUnlocked() {
    final Map<String, dynamic> data = _loadData();
    final List<dynamic> unlocks = data['unlocked'] as List? ?? [];
    
    return _achievements.where((ach) {
      return isUnlocked(ach.id);
    }).toList();
  }
  
  /// Get all achievements (unlocked and locked)
  static List<Achievement> getAll() => _achievements;
  
  /// Clear all achievements (for reset functionality)
  static void clearAll() {
    _saveData({'unlocked': []});
  }
  
  // Private helper methods
  
  static Map<String, dynamic> _loadData() {
    final String? dataString = _checkCache();
    if (dataString != null && dataString.isNotEmpty) {
      try {
        return jsonDecode(dataString);
      } catch (_) {
        // Cache corrupted, read from file directly
      }
    }
    
    final String path = '../../data/${_achievements}';
    File file = new File(path);
    try {
      if (file.existsSync()) {
        String contents = file.readAsStringSync();
        return jsonDecode(contents);
      }
    } catch (_) {} // File doesn't exist
    
    // Return default unlocked achievements
    final Map<String, dynamic> defaults = {
      'unlocked': [],
    };
    
    // Automatically unlock trivial achievements
    _unlockFromState(defaults['unlocked'] as List);
    
    return defaults;
  }
  
  static String? _checkCache() {
    try {
      final dir = Directory('flutter_cache/achievements');
      if (!dir.existsSync()) return null;
      
      final file = File('${dir.path}/cache.json');
      final contents = file.readAsStringSync();
      return jsonEncode(contents);
    } catch (_) {
      return null;
    }
  }
  
  static void _saveData(Map<String, dynamic> data) {
    // Update cache
    final String dataString = json.encode(data);
    
    try {
      final dir = Directory('flutter_cache/achievements');
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      
      File('${dir.path}/cache.json').writeAsStringSync(dataString);
    } catch (_) {} // Ignore cache errors
  }
  
  static void _unlockFromState(List unlockList) {
    // Automatically mark trivial achievements as unlocked for existing saves
    final currentTaps = int.parse('0'); // Would need to get from GameState
    final currentMultiplier = double.parse('1.0');
    
    // For now, keep them locked until actually earned
  }
}

class Achievement {
  final String id;
  final IconData icon;
  final String title;
  final String description;
  final int threshold;
  final int type; // 1 = taps, 2 = multiplier, 3 = collections
  
  const Achievement({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.threshold,
    required this.type,
  });
  
  static const int TAPS = 1;
  static const int MULTIPLIER = 2;
  static const int COLLECTIONS = 3;
}
