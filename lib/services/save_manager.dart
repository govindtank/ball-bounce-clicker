import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/game/models/game_state.dart';

/// SaveManager handles persisting game state to local storage
class SaveManager {
  static final SaveManager _instance = SaveManager._internal();
  factory SaveManager() => _instance;
  SaveManager._internal();
  
  SharedPreferences? _prefs;
  static const String _saveKey = 'ball_bounce_save';
  static const String _highScoreKey = 'high_score';
  
  /// Lazily initialize preferences on first use
  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }
  
  /// Initialize preferences (call once at app startup)
  Future<void> init() async {
    final prefs = await _preferences;
    final savedHighScore = prefs.getInt(_highScoreKey);
    if (savedHighScore != null) {
      print('Loaded high score: $savedHighScore');
    }
  }
  
  /// Save current game state
  Future<void> saveGameState(GameState state) async {
    try {
      final prefs = await _preferences;
      final now = DateTime.now();
      
      // Serialize state
      final data = {
        'score': state.score,
        'totalTaps': state.totalTaps,
        'scoreMultiplier': state.scoreMultiplier,
        'ballsCount': state.balls.length,
        'timestamp': now.millisecondsSinceEpoch,
        'sessionStart': await _getOrCreateSessionStartTime(prefs),
      };
      
      // Save to preferences
      await prefs.setString(_saveKey, jsonEncode(data));
    } catch (e) {
      print('Error saving game state: $e');
    }
  }
  
  /// Get current save data
  Future<Map<String, dynamic>?> getGameState() async {
    try {
      final prefs = await _preferences;
      final encoded = prefs.getString(_saveKey);
      if (encoded == null) return null;
      
      final data = jsonDecode(encoded) as Map<String, dynamic>;
      final now = DateTime.now();
      final sessionStart = await _getOrCreateSessionStartTime(prefs);
      
      // Check if save is from current session (< 24 hours)
      final saveTime = data['timestamp'] as int;
      final diffMs = now.millisecondsSinceEpoch - saveTime;
      final isInCurrentSession = saveTime > sessionStart;
      
      return {
        ...data,
        'inCurrentSession': isInCurrentSession,
        'saveDurationHours': (diffMs / 3.6e6).toStringAsFixed(1),
      };
    } catch (e) {
      print('Error loading game state: $e');
      return null;
    }
  }
  
  /// Get high score
  Future<int?> getHighScore() async {
    final prefs = await _preferences;
    return prefs.getInt(_highScoreKey);
  }
  
  /// Set/update high score
  Future<void> setHighScore(int score) async {
    final prefs = await _preferences;
    final currentHigh = prefs.getInt(_highScoreKey);
    if (score > (currentHigh ?? 0)) {
      await prefs.setInt(_highScoreKey, score);
      print('New high score set: $score');
    }
  }
  
  /// Clear all saves
  Future<void> clearSaves() async {
    final prefs = await _preferences;
    await prefs.remove(_saveKey);
    await prefs.remove(_highScoreKey);
    print('All saves cleared');
  }
  
  /// Get session start time (or current if first time)
  Future<int> _getOrCreateSessionStartTime(SharedPreferences prefs) async {
    final sessionStart = prefs.getInt('session_start');
    if (sessionStart != null) {
      return sessionStart;
    } else {
      final now = DateTime.now();
      await prefs.setInt('session_start', now.millisecondsSinceEpoch);
      print('New session started: $now');
      return now.millisecondsSinceEpoch;
    }
  }
}
