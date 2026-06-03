import 'package:shared_preferences/shared_preferences.dart';

class GameStorage {
  static const _highScoreKey = 'bounce_zone_highscore';
  static const _bestTimeKey = 'bounce_zone_besttime';
  static const _bestWaveKey = 'bounce_zone_bestwave';

  // ── High Score ──

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

  // ── Best Survival Time (seconds) ──

  static Future<double> loadBestTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_bestTimeKey) ?? 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  static Future<void> saveBestTime(double time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_bestTimeKey, time);
    } catch (_) {}
  }

  // ── Best Wave Reached ──

  static Future<int> loadBestWave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_bestWaveKey) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  static Future<void> saveBestWave(int wave) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_bestWaveKey, wave);
    } catch (_) {}
  }
}
