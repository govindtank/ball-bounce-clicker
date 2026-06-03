import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameStorage {
  static const _highScoreKey = 'bounce_arena_highscore';
  static const _unlockedKey = 'bounce_arena_unlocked';

  static Future<int> loadHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_highScoreKey) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  static Future<void> saveHighScore(int score) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_highScoreKey, score);
    } catch (_) {}
  }

  static Future<int> loadUnlockedLevel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_unlockedKey) ?? 1;
    } catch (_) {
      return 1;
    }
  }

  static Future<void> saveUnlockedLevel(int level) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_unlockedKey, level);
    } catch (_) {}
  }
}
