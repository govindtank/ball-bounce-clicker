import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/vector2d.dart';
import '../../../services/save_manager.dart';
import 'dart:math';

class GameState extends ChangeNotifier {
  int _score = 0;
  int get score => _score;
  
  int _totalTaps = 0;
  int get totalTaps => _totalTaps;
  
  double _scoreMultiplier = AppConstants.scoreMultiplierBase;
  double get scoreMultiplier => _scoreMultiplier;
  
  final Map<int, BallState> _balls = {};
  Map<int, BallState> get balls => _balls;

  // Track last tap time for animation
  int _lastTapTimestamp = 0;
  int get lastTapTimestamp => _lastTapTimestamp;
  
  // Persistence support
  SaveManager get saveManager => SaveManager();
  
  void incrementScore() {
    _score += AppConstants.pointsPerTap * (_scoreMultiplier.round());
    _totalTaps++;
    _lastTapTimestamp = DateTime.now().millisecondsSinceEpoch;
    
    // Increase multiplier every 100 taps
    if (_totalTaps % 100 == 0) {
      _scoreMultiplier = 
          AppConstants.scoreMultiplierBase + 
          (min((_scoreMultiplier + 0.1), AppConstants.maxScoreMultiplier));
    }
    
    notifyListeners();
  }
  
  void addBall(double x, double y) {
    final ballId = DateTime.now().millisecondsSinceEpoch;
    _balls[ballId] = BallState(
      id: ballId,
      position: Offset(x, y),
      velocity: Vector2d(
        (Utils.randomNumber() - 0.5) * AppConstants.ballSpeedMin,
        (Utils.randomNumber() - 0.5) * AppConstants.ballSpeedMin
      ),
      radius: AppConstants.ballRadius,
    );
    notifyListeners();
  }
  
  void removeBall(int ballId) {
    _balls.remove(ballId);
    notifyListeners();
  }
  
  void resetGame() {
    _score = 0;
    _totalTaps = 0;
    _scoreMultiplier = AppConstants.scoreMultiplierBase;
    _balls.clear();
    notifyListeners();
  }
}

class BallState {
  final int id;
  final Offset position;
  final Vector2d velocity;
  final double radius;
  
  BallState({
    required this.id,
    required this.position,
    required this.velocity,
    required this.radius,
  });
}

// Utility class for random numbers - inline here to avoid import issues
class Utils {
  static double randomNumber() => DateTime.now().millisecondsSinceEpoch % 100;
  
  static Vector2d randomVelocity({double min = AppConstants.ballSpeedMin}) {
    return Vector2d(
      (randomNumber() - 50) * 0.01 * min,
      (randomNumber() - 50) * 0.01 * min
    );
  }
}
