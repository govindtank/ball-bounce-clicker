import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/constants/app_constants.dart';

/// Vector2D class for physics calculations
class Vector2d {
  final double x;
  final double y;
  
  const Vector2d(this.x, this.y);
  
  Vector2d operator+(Vector2d other) => Vector2d(x + other.x, y + other.y);
  Vector2d operator-(Vector2d other) => Vector2d(x - other.x, y - other.y);
  Vector2d operator*(double scalar) => Vector2d(x * scalar, y * scalar);
  
  double magnitude() => math.sqrt(x * x + y * y);
  
  @override
  String toString() => 'Vector2d($x, $y)';
}

/// Physics simulation helper
class PhysicsHelper {
  /// Check if ball is within bounds
  static bool isInBounds(Vector2d position, double screenWidth, double screenHeight) {
    final radius = AppConstants.ballRadius;
    return (position.x + radius >= 0 && 
            position.x - radius <= screenWidth &&
            position.y + radius >= 0 &&
            position.y - radius <= screenHeight);
  }
  
  /// Check if ball is near boundary
  static bool isNearBoundary(Vector2d position, {double threshold = AppConstants.ballRadius}) {
    return position.x < threshold || 
           position.x > 4000 - threshold || // Safe upper bound
           position.y < threshold ||
           position.y > 3000 - threshold;   // Safe upper bound
  }
  
  /// Calculate simple bounce reflection
  static Vector2d reflectVelocity(Vector2d velocity, double normalX, double normalY) {
    final dotProduct = velocity.x * normalX + velocity.y * normalY;
    return velocity - (Vector2d(normalX, normalY) * (dotProduct * 2));
  }
}
