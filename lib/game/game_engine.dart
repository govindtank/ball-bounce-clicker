import 'dart:math';
import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════
// BOUNCE ARENA - Core Game Engine
// ══════════════════════════════════════════════════════════════

// ── Enums ──
enum GameStatus { menu, playing, paused, levelComplete, gameOver }
enum BrickType { standard, tough, steel, explosive, golden }
enum PowerUpType { widePaddle, multiBall, fireBall, slowMotion, extraLife }

// ── Level Pattern Definition ──
// 0=empty, 1=standard, 2=tough, 3=steel, 4=explosive, 5=golden
// Row 0 = top of screen
const List<List<List<int>>> levelPatterns = [
  // Level 1 - Intro
  [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [0, 0, 0, 0, 0, 0, 0, 0],
  ],
  // Level 2 - Full grid
  [
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
  ],
  // Level 3 - Tough mix
  [
    [2, 1, 1, 2, 2, 1, 1, 2],
    [1, 2, 1, 1, 1, 1, 2, 1],
    [1, 1, 2, 1, 1, 2, 1, 1],
    [2, 1, 1, 2, 2, 1, 1, 2],
    [1, 2, 1, 1, 1, 1, 2, 1],
  ],
  // Level 4 - Diamond pattern
  [
    [0, 0, 1, 1, 1, 1, 0, 0],
    [0, 1, 3, 1, 1, 3, 1, 0],
    [1, 1, 1, 2, 2, 1, 1, 1],
    [0, 1, 1, 1, 1, 1, 1, 0],
    [0, 0, 1, 1, 1, 1, 0, 0],
  ],
  // Level 5 - Fortress
  [
    [3, 3, 3, 3, 3, 3, 3, 3],
    [3, 1, 1, 1, 1, 1, 1, 3],
    [3, 1, 2, 2, 2, 2, 1, 3],
    [3, 1, 1, 1, 1, 1, 1, 3],
    [3, 3, 3, 3, 3, 3, 3, 3],
  ],
  // Level 6 - Explosive mayhem
  [
    [4, 1, 4, 1, 1, 4, 1, 4],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [4, 1, 4, 1, 1, 4, 1, 4],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [4, 1, 4, 1, 1, 4, 1, 4],
    [1, 1, 1, 1, 1, 1, 1, 1],
  ],
  // Level 7 - Checkerboard tough
  [
    [2, 1, 2, 1, 2, 1, 2, 1],
    [1, 3, 1, 2, 2, 1, 3, 1],
    [2, 1, 2, 1, 1, 2, 1, 2],
    [1, 3, 1, 2, 2, 1, 3, 1],
    [2, 1, 2, 1, 2, 1, 2, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
  ],
  // Level 8 - Golden hunt
  [
    [5, 1, 1, 5, 5, 1, 1, 5],
    [1, 2, 1, 1, 1, 1, 2, 1],
    [1, 1, 3, 1, 1, 3, 1, 1],
    [1, 2, 1, 1, 1, 1, 2, 1],
    [5, 1, 1, 5, 5, 1, 1, 5],
  ],
  // Level 9 - The wall
  [
    [0, 0, 3, 3, 3, 3, 0, 0],
    [0, 3, 1, 2, 2, 1, 3, 0],
    [3, 1, 2, 4, 4, 2, 1, 3],
    [0, 3, 1, 2, 2, 1, 3, 0],
    [0, 0, 3, 3, 3, 3, 0, 0],
  ],
  // Level 10 - Chaos
  [
    [4, 2, 1, 4, 4, 1, 2, 4],
    [2, 5, 2, 1, 1, 2, 5, 2],
    [1, 2, 3, 2, 2, 3, 2, 1],
    [2, 5, 2, 1, 1, 2, 5, 2],
    [4, 2, 1, 4, 4, 1, 2, 4],
    [1, 1, 2, 1, 1, 2, 1, 1],
  ],
  // Level 11 - Diamond fortress
  [
    [0, 0, 0, 3, 3, 0, 0, 0],
    [0, 0, 3, 2, 2, 3, 0, 0],
    [0, 3, 2, 1, 1, 2, 3, 0],
    [3, 2, 1, 5, 5, 1, 2, 3],
    [0, 3, 2, 1, 1, 2, 3, 0],
    [0, 0, 3, 2, 2, 3, 0, 0],
    [0, 0, 0, 3, 3, 0, 0, 0],
  ],
  // Level 12 - Pyramids
  [
    [0, 0, 1, 1, 1, 1, 0, 0],
    [0, 1, 2, 2, 2, 2, 1, 0],
    [1, 2, 3, 4, 4, 3, 2, 1],
    [0, 1, 2, 2, 2, 2, 1, 0],
    [0, 0, 1, 1, 1, 1, 0, 0],
    [0, 0, 0, 5, 5, 0, 0, 0],
  ],
  // Level 13 - The gauntlet
  [
    [1, 1, 1, 1, 1, 1, 1, 1],
    [2, 2, 2, 2, 2, 2, 2, 2],
    [3, 3, 3, 3, 3, 3, 3, 3],
    [4, 4, 4, 4, 4, 4, 4, 4],
    [2, 2, 2, 2, 2, 2, 2, 2],
    [1, 1, 1, 1, 1, 1, 1, 1],
  ],
  // Level 14 - Checkmate
  [
    [3, 1, 3, 1, 3, 1, 3, 1],
    [1, 2, 1, 2, 1, 2, 1, 2],
    [3, 1, 3, 1, 3, 1, 3, 1],
    [1, 2, 1, 4, 4, 1, 2, 1],
    [3, 1, 3, 1, 3, 1, 3, 1],
    [1, 2, 1, 2, 1, 2, 1, 2],
    [3, 1, 3, 1, 3, 1, 3, 1],
  ],
  // Level 15 - Final boss
  [
    [3, 3, 5, 3, 3, 5, 3, 3],
    [3, 2, 2, 4, 4, 2, 2, 3],
    [5, 2, 1, 1, 1, 1, 2, 5],
    [3, 4, 1, 2, 2, 1, 4, 3],
    [3, 2, 1, 1, 1, 1, 2, 3],
    [5, 2, 2, 4, 4, 2, 2, 5],
    [3, 3, 5, 3, 3, 5, 3, 3],
  ],
];

// ══════════════════════════════════════════════════════════════
// MODELS
// ══════════════════════════════════════════════════════════════

class BallModel {
  double x, y, vx, vy, radius;
  final List<Offset> trail = [];
  bool active = true;

  BallModel({
    required this.x,
    required this.y,
    this.vx = 0,
    this.vy = 0,
    this.radius = 7,
    this.active = true,
  });

  void updateTrail() {
    trail.add(Offset(x, y));
    if (trail.length > 12) trail.removeAt(0);
  }

  void clearTrail() => trail.clear();

  double get speed => sqrt(vx * vx + vy * vy);
}

class PaddleModel {
  double x, y, width, height;
  final double originalWidth;

  PaddleModel({
    required this.x,
    required this.y,
    this.width = 110,
    this.height = 14,
  }) : originalWidth = width;

  Rect get rect => Rect.fromLTWH(x - width / 2, y - height / 2, width, height);
}

class BrickModel {
  double x, y, width, height;
  final BrickType type;
  final int maxHits;
  int hits = 0;
  bool destroyed = false;
  double destroyAnimProgress = 0;
  Color color;
  Color hitColor;

  BrickModel({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.type,
    Color? color,
    this.hits = 0,
  })  : maxHits = (type == BrickType.tough || type == BrickType.explosive) ? 2 : 1,
        color = color ?? _defaultColor(type),
        hitColor = _hitColor(type) {
    if (type == BrickType.steel) hits = 0; // Steel never breaks
  }

  static Color _defaultColor(BrickType t) {
    switch (t) {
      case BrickType.standard:
        return const Color(0xFF7C4DFF);
      case BrickType.tough:
        return const Color(0xFFFF6B9D);
      case BrickType.steel:
        return const Color(0xFF616161);
      case BrickType.explosive:
        return const Color(0xFFFF9800);
      case BrickType.golden:
        return const Color(0xFFFFD700);
    }
  }

  static Color _hitColor(BrickType t) {
    switch (t) {
      case BrickType.standard:
        return const Color(0xFFB388FF);
      case BrickType.tough:
        return const Color(0xFFFF8A80);
      case BrickType.steel:
        return const Color(0xFF9E9E9E);
      case BrickType.explosive:
        return const Color(0xFFFFB74D);
      case BrickType.golden:
        return const Color(0xFFFFF176);
    }
  }

  Rect get rect => Rect.fromLTWH(x, y, width, height);
  bool get isAlive => !destroyed && (type == BrickType.steel || hits < maxHits);
  bool get canBeDestroyed => type != BrickType.steel;
  bool get isOneHitLeft => canBeDestroyed && hits == maxHits - 1;

  void hit() {
    if (type == BrickType.steel) return;
    hits++;
    if (hits >= maxHits) destroyed = true;
  }

  Color get displayColor => isOneHitLeft ? hitColor : color;
}

class PowerUpModel {
  double x, y;
  final PowerUpType type;
  final double speed = 120;
  bool collected = false;
  double animTime = 0;

  PowerUpModel({required this.x, required this.y, required this.type});

  Rect get rect => Rect.fromLTWH(x - 12, y - 12, 24, 24);

  Color get color {
    switch (type) {
      case PowerUpType.widePaddle:  return const Color(0xFF00E5FF);
      case PowerUpType.multiBall:   return const Color(0xFFD500F9);
      case PowerUpType.fireBall:    return const Color(0xFFFF6D00);
      case PowerUpType.slowMotion:  return const Color(0xFF76FF03);
      case PowerUpType.extraLife:   return const Color(0xFFFF1744);
    }
  }

  IconData get icon {
    switch (type) {
      case PowerUpType.widePaddle:  return Icons.swap_horiz;
      case PowerUpType.multiBall:   return Icons.splitscreen;
      case PowerUpType.fireBall:    return Icons.local_fire_department;
      case PowerUpType.slowMotion:  return Icons.hourglass_bottom;
      case PowerUpType.extraLife:   return Icons.favorite;
    }
  }

  String get label {
    switch (type) {
      case PowerUpType.widePaddle:  return 'WIDE';
      case PowerUpType.multiBall:   return 'MULTI';
      case PowerUpType.fireBall:    return 'FIRE';
      case PowerUpType.slowMotion:  return 'SLOW';
      case PowerUpType.extraLife:   return '1UP';
    }
  }
}

class ParticleModel {
  double x, y, vx, vy, lifetime = 0, maxLifetime, radius;
  final Color color;

  ParticleModel({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    this.maxLifetime = 0.8,
    this.radius = 3,
    this.color = Colors.white,
  });

  bool get isDead => lifetime >= maxLifetime;
  double get progress => lifetime / maxLifetime;
}

// ══════════════════════════════════════════════════════════════
// GAME STATE
// ══════════════════════════════════════════════════════════════

class BounceGameState {
  GameStatus status = GameStatus.menu;
  int currentLevel = 1;
  int maxUnlockedLevel = 1;
  int score = 0;
  int highScore = 0;
  int lives = 3;
  int combo = 0;
  int destroyedBricks = 0;
  int totalDestroyableBricks = 0;
  bool ballLaunched = false;

  final BallModel ball;
  final PaddleModel paddle;
  final List<BrickModel> bricks = [];
  final List<PowerUpModel> powerUps = [];
  final List<ParticleModel> particles = [];
  final Random _random = Random();
  Size gameSize = Size.zero;

  // Power-up timers
  double fireballTimer = 0;
  double widenTimer = 0;
  double slowMoTimer = 0;

  // Screen shake
  double shakeIntensity = 0;
  double shakeDuration = 0;

  BounceGameState()
      : ball = BallModel(x: 0, y: 0),
        paddle = PaddleModel(x: 0, y: 0);

  void reset(int level) {
    currentLevel = level;
    score = 0;
    lives = 3;
    combo = 0;
    ballLaunched = false;
    fireballTimer = 0;
    widenTimer = 0;
    slowMoTimer = 0;
    powerUps.clear();
    particles.clear();
    _buildLevel();
    _resetBall();
    status = GameStatus.playing;
  }

  void startLevel(int level) {
    currentLevel = level;
    ballLaunched = false;
    fireballTimer = 0;
    widenTimer = 0;
    slowMoTimer = 0;
    powerUps.clear();
    paddle.width = paddle.originalWidth;
    _buildLevel();
    _resetBall();
    status = GameStatus.playing;
  }

  void _buildLevel() {
    bricks.clear();
    destroyedBricks = 0;
    totalDestroyableBricks = 0;

    if (currentLevel < 1 || currentLevel > levelPatterns.length) return;

    final pattern = levelPatterns[currentLevel - 1];
    final rows = pattern.length;
    final cols = pattern[0].length;

    // Calculate brick dimensions based on screen width
    final gap = 4.0;
    final edgeGap = 8.0;
    final brickWidth = (gameSize.width - edgeGap * 2 - gap * (cols - 1)) / cols;
    final brickHeight = 20.0;
    final topY = 60.0; // Below the HUD

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final brickType = pattern[row][col];
        if (brickType == 0) continue;

        final x = edgeGap + col * (brickWidth + gap);
        final y = topY + row * (brickHeight + gap);

        final bt = <int, BrickType>{
          1: BrickType.standard,
          2: BrickType.tough,
          3: BrickType.steel,
          4: BrickType.explosive,
          5: BrickType.golden,
        }[brickType]!;

        bricks.add(BrickModel(
          x: x,
          y: y,
          width: brickWidth,
          height: brickHeight,
          type: bt,
        ));

        if (bt != BrickType.steel) totalDestroyableBricks++;
      }
    }
  }

  void _resetBall() {
    ball.x = paddle.x;
    ball.y = paddle.y - paddle.height / 2 - ball.radius - 2;
    ball.vx = 0;
    ball.vy = 0;
    ball.active = true;
    ball.clearTrail();
    ballLaunched = false;
  }

  void launchBall() {
    if (ballLaunched) return;
    final angle = -pi / 2 + (_random.nextDouble() - 0.5) * pi / 2.5;
    final speed = 380.0;
    ball.vx = cos(angle) * speed;
    ball.vy = sin(angle) * speed;
    ballLaunched = true;
  }

  void movePaddleTo(double x) {
    paddle.x = x.clamp(paddle.width / 2, gameSize.width - paddle.width / 2);
    if (!ballLaunched) {
      ball.x = paddle.x;
      ball.y = paddle.y - paddle.height / 2 - ball.radius - 2;
    }
  }

  void triggerShake({double intensity = 4, double duration = 0.2}) {
    shakeIntensity = intensity;
    shakeDuration = duration;
  }

  void update(double dt) {
    if (status != GameStatus.playing) return;

    // ── Screen shake ──
    if (shakeDuration > 0) {
      shakeDuration -= dt;
      if (shakeDuration <= 0) {
        shakeIntensity = 0;
        shakeDuration = 0;
      }
    }

    // ── Slow motion ──
    if (slowMoTimer > 0) {
      dt *= 0.4;
      slowMoTimer -= dt / 0.4 * (1 / 0.4); // compensate for time scale
      if (slowMoTimer <= 0) slowMoTimer = 0;
    }

    // ── Power-up timers ──
    if (fireballTimer > 0) {
      fireballTimer -= dt;
      if (fireballTimer <= 0) fireballTimer = 0;
    }
    if (widenTimer > 0) {
      widenTimer -= dt;
      if (widenTimer <= 0) {
        widenTimer = 0;
        paddle.width = paddle.originalWidth;
      }
    }

    // ── Update ball ──
    if (ball.active && ballLaunched) {
      ball.x += ball.vx * dt;
      ball.y += ball.vy * dt;

      // Left wall
      if (ball.x - ball.radius <= 0) {
        ball.x = ball.radius;
        ball.vx = ball.vx.abs();
      }
      // Right wall
      if (ball.x + ball.radius >= gameSize.width) {
        ball.x = gameSize.width - ball.radius;
        ball.vx = -ball.vx.abs();
      }
      // Top wall
      if (ball.y - ball.radius <= 0) {
        ball.y = ball.radius;
        ball.vy = ball.vy.abs();
      }
      // Bottom — lose life
      if (ball.y - ball.radius > gameSize.height) {
        loseLife();
        return;
      }

      // ── Paddle collision ──
      if (ball.vy > 0 && _checkPaddleCollision()) {
        final hitPos = ((ball.x - paddle.x) / (paddle.width / 2)).clamp(-1.0, 1.0);
        final angle = hitPos * pi / 3.5; // max ~51 degrees
        final speed = ball.speed.clamp(350, 600);
        ball.vx = sin(angle) * speed;
        ball.vy = -cos(angle) * speed;
        ball.y = paddle.y - paddle.height / 2 - ball.radius;
        combo = 0;
        triggerShake(intensity: 1.5, duration: 0.08);
      }

      // ── Brick collisions ──
      for (final brick in bricks) {
        if (!brick.isAlive) continue;
        if (_checkBrickCollision(brick)) {
          if (fireballTimer > 0 && brick.canBeDestroyed) {
            // Fireball instant break
            if (!brick.destroyed) {
              brick.hits = brick.maxHits;
              brick.destroyed = true;
            }
          } else {
            brick.hit();
          }

          if (brick.destroyed) {
            _onBrickDestroyed(brick);
          } else {
            triggerShake(intensity: 1, duration: 0.05);
          }
          break;
        }
      }

      // Fireball visual - brick-like hit on steel
      if (fireballTimer > 0) {
        for (final brick in bricks) {
          if (brick.type == BrickType.steel && !brick.destroyed) {
            // Check if ball overlaps steel with fireball - small spark effect
            if (_brickOverlapsBall(brick)) {
              _spawnSparks(brick);
            }
          }
        }
      }

      // Update trail
      ball.updateTrail();
    }

    // ── Update power-ups ──
    for (final pu in powerUps) {
      if (pu.collected) continue;
      pu.y += pu.speed * dt;
      pu.animTime += dt * 3;
      if (pu.y > paddle.y && pu.x > paddle.x - paddle.width / 2 && pu.x < paddle.x + paddle.width / 2) {
        pu.collected = true;
        _applyPowerUp(pu);
      }
      if (pu.y > gameSize.height + 30) {
        pu.collected = true;
      }
    }
    powerUps.removeWhere((p) => p.collected);

    // ── Update particles ──
    for (final p in particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += 300 * dt; // Gravity
      p.lifetime += dt;
    }
    particles.removeWhere((p) => p.isDead);

    // ── Check level complete ──
    if (destroyedBricks >= totalDestroyableBricks && totalDestroyableBricks > 0) {
      status = GameStatus.levelComplete;
    }
  }

  bool _checkPaddleCollision() {
    if (ball.y + ball.radius < paddle.y - paddle.height / 2) return false;
    if (ball.y - ball.radius > paddle.y + paddle.height / 2) return false;
    if (ball.x + ball.radius < paddle.x - paddle.width / 2) return false;
    if (ball.x - ball.radius > paddle.x + paddle.width / 2) return false;
    return ball.vy > 0;
  }

  bool _brickOverlapsBall(BrickModel brick) {
    return ball.x + ball.radius > brick.x &&
        ball.x - ball.radius < brick.x + brick.width &&
        ball.y + ball.radius > brick.y &&
        ball.y - ball.radius < brick.y + brick.height;
  }

  bool _checkBrickCollision(BrickModel brick) {
    if (!_brickOverlapsBall(brick)) return false;

    // Determine which side was hit
    final bx = brick.x + brick.width / 2;
    final by = brick.y + brick.height / 2;
    final dx = (ball.x - bx) / (brick.width / 2 + ball.radius);
    final dy = (ball.y - by) / (brick.height / 2 + ball.radius);

    if (dx.abs() >= dy.abs()) {
      // Hit left or right
      ball.vx = -ball.vx;
      if (ball.x < bx) {
        ball.x = brick.x - ball.radius;
      } else {
        ball.x = brick.x + brick.width + ball.radius;
      }
    } else {
      // Hit top or bottom
      ball.vy = -ball.vy;
      if (ball.y < by) {
        ball.y = brick.y - ball.radius;
      } else {
        ball.y = brick.y + brick.height + ball.radius;
      }
    }
    return true;
  }

  void _onBrickDestroyed(BrickModel brick) {
    destroyedBricks++;
    combo++;
    combo = combo.clamp(0, 50);

    // Score with combo
    final basePoints = _basePoints(brick.type);
    final comboMult = 1.0 + (combo - 1) * 0.1;
    final earned = (basePoints * comboMult).round();
    score += earned;

    // Shake
    triggerShake(intensity: 2, duration: 0.1);

    // Explosion particles
    final bx = brick.x + brick.width / 2;
    final by = brick.y + brick.height / 2;
    final count = brick.type == BrickType.explosive ? 30 : 15;
    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 50 + _random.nextDouble() * 200;
      particles.add(ParticleModel(
        x: bx + (_random.nextDouble() - 0.5) * brick.width,
        y: by + (_random.nextDouble() - 0.5) * brick.height,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        maxLifetime: 0.5 + _random.nextDouble() * 0.5,
        radius: 1.5 + _random.nextDouble() * 3,
        color: brick.type == BrickType.golden
            ? const Color(0xFFFFD700)
            : brick.type == BrickType.explosive
                ? const Color(0xFFFF9800)
                : brick.displayColor,
      ));
    }

    // Explosive brick chain reaction
    if (brick.type == BrickType.explosive) {
      _triggerExplosion(brick);
    }

    // Power-up drop (20% chance, golden always drops)
    if (brick.type == BrickType.golden || _random.nextDouble() < 0.2) {
      final types = PowerUpType.values;
      powerUps.add(PowerUpModel(
        x: bx,
        y: by,
        type: brick.type == BrickType.golden ? PowerUpType.extraLife : types[_random.nextInt(types.length)],
      ));
    }
  }

  void _triggerExplosion(BrickModel source) {
    final sx = source.x + source.width / 2;
    final sy = source.y + source.height / 2;
    final blastRadius = 50.0;

    for (final brick in bricks) {
      if (brick.destroyed || !brick.canBeDestroyed) continue;
      final bx = brick.x + brick.width / 2;
      final by = brick.y + brick.height / 2;
      final dist = sqrt(pow(bx - sx, 2) + pow(by - sy, 2));
      if (dist < blastRadius) {
        brick.destroyed = true;
        _onBrickDestroyed(brick);
      }
    }
  }

  void _spawnSparks(BrickModel brick) {
    for (int i = 0; i < 3; i++) {
      particles.add(ParticleModel(
        x: brick.x + _random.nextDouble() * brick.width,
        y: brick.y + _random.nextDouble() * brick.height,
        vx: (_random.nextDouble() - 0.5) * 150,
        vy: (_random.nextDouble() - 0.5) * 150,
        maxLifetime: 0.3,
        radius: 1,
        color: const Color(0xFFFFAB00),
      ));
    }
  }

  int _basePoints(BrickType type) {
    switch (type) {
      case BrickType.standard:  return 10;
      case BrickType.tough:     return 25;
      case BrickType.steel:     return 0;
      case BrickType.explosive: return 30;
      case BrickType.golden:    return 100;
    }
  }

  void _applyPowerUp(PowerUpModel pu) {
    switch (pu.type) {
      case PowerUpType.widePaddle:
        widenTimer = 8.0;
        paddle.width = paddle.originalWidth * 1.6;
      case PowerUpType.multiBall:
        triggerShake(intensity: 3, duration: 0.15);
      case PowerUpType.fireBall:
        fireballTimer = 10.0;
      case PowerUpType.slowMotion:
        slowMoTimer = 6.0;
      case PowerUpType.extraLife:
        lives++;
    }
    // Particle burst for collection
    for (int i = 0; i < 20; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 30 + _random.nextDouble() * 120;
      particles.add(ParticleModel(
        x: pu.x,
        y: pu.y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        maxLifetime: 0.6,
        radius: 2 + _random.nextDouble() * 2,
        color: pu.color,
      ));
    }
  }

  void loseLife() {
    lives--;
    ball.active = false;
    triggerShake(intensity: 8, duration: 0.3);

    if (lives <= 0) {
      status = GameStatus.gameOver;
      if (score > highScore) highScore = score;
    } else {
      _resetBall();
    }
  }

  void multiBallSplit() {
    if (ball.active) {
      final angle = (_random.nextDouble() - 0.5) * pi * 0.5;
      final speed = ball.speed;
      ball.vx = cos(atan2(ball.vy, ball.vx) + angle) * speed;
      ball.vy = sin(atan2(ball.vy, ball.vx) + angle) * speed;
    }
  }
}
