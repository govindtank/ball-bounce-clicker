import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Power-up types that enhance gameplay
enum PowerUpType {
  /// Adds extra points for each tap
  extraPoints,
  
  /// Makes ball bounce faster
  speedBoost,
  
  /// Removes a chunk of score to reset progress (suicide button)
  resetProgress,
  
  /// Gives instant points
  instantScore,
  
  /// Slows time for precision tapping
  slowMotion,
}

/// Configuration for a power-up
class PowerUpConfig {
  final PowerUpType type;
  final IconData icon;
  final Duration duration; // For timed power-ups, null = permanent
  final String name;
  
  const PowerUpConfig({
    required this.type,
    required this.icon,
    this.duration,
    required this.name,
  });
}

/// Available power-ups in the game
final List<PowerUpConfig> powerUpTypes = [
  const PowerUpConfig(
    type: PowerUpType.extraPoints,
    icon: Icons.add_circle_outline,
    duration: null,
    name: '2x Points',
  ),
  const PowerUpConfig(
    type: PowerUpType.speedBoost,
    icon: Icons.speed,
    duration: const Duration(seconds: 5),
    name: 'Fast Ball',
  ),
  const PowerUpConfig(
    type: PowerUpType.resetProgress,
    icon: Icons.refresh_outlined,
    duration: null,
    name: 'Reset',
  ),
  const PowerUpConfig(
    type: PowerUpType.instantScore,
    icon: Icons.cake_outlined,
    duration: null,
    name: '+100 Points',
  ),
  const PowerUpConfig(
    type: PowerUpType.slowMotion,
    icon: Icons.pause_rounded,
    duration: Duration(seconds: 3),
    name: 'Slow Time',
  ),
];

/// Spawns a power-up at a given position
class PowerUpSpawner {
  static final PowerUpSpawner _instance = PowerUpSpawner._internal();
  factory PowerUpSpawner() => _instance;
  PowerUpSpawner._internal();
  
  /// Get random power-up type
  static PowerUpType getRandomType() {
    final rand = math.Random();
    return powerUpTypes
        .elementAt(rand.nextInt(powerUpTypes.length))
        .type;
  }
  
  /// Check if a spawn point is valid (not too close to ball)
  static bool isValidSpawnPosition(Offset position, Offset ballPosition, double minDistance) {
    final distance = (position - ballPosition).distance;
    return distance > minDistance && distance < 200; // Within bounds
  }
}
