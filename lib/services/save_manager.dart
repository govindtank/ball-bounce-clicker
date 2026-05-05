import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/game/models/game_state.dart';

/// SaveManager handles persisting game state to local storage
class SaveManager {
  static final SaveManager _instance = SaveManager._internal();
  factory SaveManager() => _instance;
  SaveManager._internal();
  
  late final SharedPreferences _prefs;
  static const String _saveKey = 'ball_bounce_save';
  static const String _highScoreKey = 'high_score';
  
  /// Initialize preferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Load high score on startup
    final savedHighScore = _prefs.getInt(_highScoreKey);
    if (savedHighScore != null) {
      print('Loaded high score: $savedHighScore');
    }
  }
  
  /// Save current game state
  Future<void> saveGameState(GameState state) async {
    try {
      final now = DateTime.now();
      
      // Serialize state
      final data = {
        'score': state.score,
        'totalTaps': state.totalTaps,
        'scoreMultiplier': state.scoreMultiplier,
        'ballsCount': state.balls.length,
        'timestamp': now.millisecondsSinceEpoch,
        'sessionStart': _getOrCreateSessionStartTime(),
      };
      
      // Save to preferences
      await _prefs.setString(_saveKey, jsonEncode(data));
    } catch (e) {
      print('Error saving game state: $e');
    }
  }
  
  /// Get current save data
  Future<Map<String, dynamic>?> getGameState() async {
    try {
      final encoded = _prefs.getString(_saveKey);
      if (encoded == null) return null;
      
      final data = jsonDecode(encoded) as Map<String, dynamic>;
      final now = DateTime.now();
      final sessionStart = _getOrCreateSessionStartTime();
      
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
  int? getHighScore() {
    return _prefs.getInt(_highScoreKey);
  }
  
  /// Set/update high score
  Future<void> setHighScore(int score) async {
    final currentHigh = getHighScore();
    if (score > (currentHigh ?? 0)) {
      await _prefs.setInt(_highScoreKey, score);
      print('New high score set: $score');
    }
  }
  
  /// Clear all saves
  Future<void> clearSaves() async {
    await _prefs.remove(_saveKey);
    await _prefs.remove(_highScoreKey);
    print('All saves cleared');
  }
  
  /// Get session start time (or current if first time)
  int _getOrCreateSessionStartTime() {
    final sessionStart = _prefs.getInt('session_start');
    if (sessionStart != null) {
      return sessionStart;
    } else {
      final now = DateTime.now();
      _prefs.setInt('session_start', now.millisecondsSinceEpoch);
      print('New session started: $now');
      return now.millisecondsSinceEpoch;
    }
  }
}
