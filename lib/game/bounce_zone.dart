import 'dart:math';
import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════
// BOUNCE ZONE — Survival Dodge Arena
// ══════════════════════════════════════════════════════════════

// ── Enums ──
enum GameStatus { menu, playing, paused, gameOver }
enum HazardType { spinner, chaser, laser }
enum PowerUpType { shield, slowTime, repel }

// ══════════════════════════════════════════════════════════════
// MODELS
// ══════════════════════════════════════════════════════════════

class BallModel {
  double x, y, vx, vy;
  double radius;
  final List<Offset> trail = [];
  double speed;
  double invincibleTimer = 0; // Shield remaining time
  bool isInvincible = false; // True after shield pickup until timer expires
  bool active = true;

  BallModel({
    required this.x,
    required this.y,
    this.vx = 0,
    this.vy = 0,
    this.radius = 10,
    this.speed = 0,
    this.active = true,
  });

  void updateTrail() {
    trail.add(Offset(x, y));
    if (trail.length > 15) trail.removeAt(0);
  }

  void clearTrail() => trail.clear();

  double get currentSpeed => sqrt(vx * vx + vy * vy);

  /// Normalize velocity to match current speed setting
  void normalizeSpeed() {
    final current = currentSpeed;
    if (current > 0 && speed > 0) {
      final scale = speed / current;
      vx *= scale;
      vy *= scale;
    }
  }
}

/// Spinner — rotating dangerous bar
class SpinnerModel {
  double cx, cy; // Center position
  double length;
  double angle;
  double angularSpeed;
  double radius; // Tip radius for collision
  bool active = true;
  double spawnTime;

  SpinnerModel({
    required this.cx,
    required this.cy,
    this.length = 80,
    this.angle = 0,
    this.angularSpeed = 2.0,
    this.radius = 6,
  }) : spawnTime = 0;

  Offset get tip => Offset(
        cx + cos(angle) * length,
        cy + sin(angle) * length,
      );

  Offset get oppositeTip => Offset(
        cx - cos(angle) * length,
        cy - sin(angle) * length,
      );

  /// Check collision with a circle (the ball)
  bool collidesWith(double bx, double by, double br) {
    // Check distance from ball to the spinner line (center to tip)
    return _pointToSegmentDistance(bx, by, cx, cy, tip.dx, tip.dy) <
            br + radius ||
        _pointToSegmentDistance(bx, by, cx, cy, oppositeTip.dx, oppositeTip.dy) <
            br + radius ||
        // Also check the hub (center)
        sqrt(pow(bx - cx, 2) + pow(by - cy, 2)) < br + radius + 4;
  }

  double _pointToSegmentDistance(
      double px, double py, double ax, double ay, double bx, double by) {
    final dx = bx - ax;
    final dy = by - ay;
    final lengthSq = dx * dx + dy * dy;
    if (lengthSq == 0) return sqrt(pow(px - ax, 2) + pow(py - ay, 2));

    var t = ((px - ax) * dx + (py - ay) * dy) / lengthSq;
    t = t.clamp(0.0, 1.0);

    final projX = ax + t * dx;
    final projY = ay + t * dy;
    return sqrt(pow(px - projX, 2) + pow(py - projY, 2));
  }
}

/// Chaser — enemy ball that pursues the player
class ChaserModel {
  double x, y;
  double radius;
  double speed;
  bool active = true;

  ChaserModel({
    required this.x,
    required this.y,
    this.radius = 8,
    this.speed = 120,
  });

  /// Update chase toward target
  void chase(double targetX, double targetY, double dt) {
    final dx = targetX - x;
    final dy = targetY - y;
    final dist = sqrt(dx * dx + dy * dy);
    if (dist < 1) return;
    x += (dx / dist) * speed * dt;
    y += (dy / dist) * speed * dt;
  }

  bool collidesWith(double bx, double by, double br) {
    return sqrt(pow(bx - x, 2) + pow(by - y, 2)) < br + radius;
  }
}

/// Laser — charges then fires a beam
class LaserModel {
  bool charging = true;
  double chargeTime = 0;
  double chargeDuration = 1.5;
  bool firing = false;
  double fireTime = 0;
  double fireDuration = 0.8;
  double x, y; // Position
  bool horizontal; // Beam direction
  double beamWidth = 8;
  bool active = true;

  LaserModel({
    required this.x,
    required this.y,
    this.horizontal = true,
  });

  Rect get beamRect {
    if (horizontal) {
      return Rect.fromLTWH(x - 1000, y - beamWidth / 2, 2000, beamWidth);
    } else {
      return Rect.fromLTWH(x - beamWidth / 2, y - 1000, beamWidth, 2000);
    }
  }

  bool collidesWith(double bx, double by, double br) {
    if (!firing) return false;
    return beamRect.inflate(br).contains(Offset(bx, by));
  }
}

/// Power-up model
class PowerUpModel {
  double x, y;
  final PowerUpType type;
  double speed = 80; // Falling speed
  bool collected = false;
  double animTimer = 0;
  bool active = true;

  PowerUpModel({
    required this.x,
    required this.y,
    required this.type,
  });

  Rect get rect =>
      Rect.fromCenter(center: Offset(x, y), width: 28, height: 28);

  bool collidesWith(double bx, double by, double br) {
    return sqrt(pow(bx - x, 2) + pow(by - y, 2)) < br + 14;
  }

  Color get color {
    switch (type) {
      case PowerUpType.shield:
        return const Color(0xFFFFD700);
      case PowerUpType.slowTime:
        return const Color(0xFF76FF03);
      case PowerUpType.repel:
        return const Color(0xFFFF6B9D);
    }
  }

  String get label {
    switch (type) {
      case PowerUpType.shield:
        return 'SHIELD';
      case PowerUpType.slowTime:
        return 'SLOW';
      case PowerUpType.repel:
        return 'REPEL';
    }
  }

  IconData get icon {
    switch (type) {
      case PowerUpType.shield:
        return Icons.shield;
      case PowerUpType.slowTime:
        return Icons.hourglass_bottom;
      case PowerUpType.repel:
        return Icons.radar;
    }
  }
}

/// Particle for visual effects
class ParticleModel {
  double x, y, vx, vy;
  double lifetime = 0, maxLifetime;
  double radius;
  Color color;

  ParticleModel({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    this.maxLifetime = 0.6,
    this.radius = 2.5,
    this.color = Colors.white,
  });

  bool get isDead => lifetime >= maxLifetime;
  double get progress => lifetime / maxLifetime;
}

// ══════════════════════════════════════════════════════════════
// GAME STATE — Core Engine
// ══════════════════════════════════════════════════════════════

class BounceZoneState {
  GameStatus status = GameStatus.menu;
  double survivalTime = 0;
  int wave = 1;
  int score = 0;
  int highScore = 0;
  int totalPowerUpsCollected = 0;

  double timeUntilNextWave = 12.0;
  double waveCooldown = 3.0; // Brief pause between waves
  bool waveTransition = false;
  String waveAnnouncement = '';
  double waveAnnounceTimer = 0;

  // Entities
  final BallModel ball;
  final List<SpinnerModel> spinners = [];
  final List<ChaserModel> chasers = [];
  final List<LaserModel> lasers = [];
  final List<PowerUpModel> powerUps = [];
  final List<ParticleModel> particles = [];

  // Power-up timers
  double shieldTimer = 0;
  double slowMoTimer = 0;

  // Arena bounds (set during reset)
  double arenaLeft = 20;
  double arenaTop = 70;
  double arenaRight = 0;
  double arenaBottom = 0;

  // Screen shake
  double shakeIntensity = 0;
  double shakeDuration = 0;

  // Random
  final Random _random = Random();

  // Difficulty scaling
  double get baseBallSpeed => 300 + (wave - 1) * 8;
  double get maxBallSpeed => 500;
  double get spinnerAngularSpeed => 1.5 + (wave - 1) * 0.2;
  double get spinnerLength => 60 + min((wave - 1) * 3, 40);
  double get chaserSpeed => 100 + (wave - 1) * 10;
  double get chaserRadius => 7 + min((wave - 1) * 0.3, 5);
  double get timeBetweenWaves => max(12.0 - (wave - 1) * 0.5, 6.0);
  int get spinnersPerWave => min(1 + (wave - 1) ~/ 3, 5);
  int get chasersPerWave => max(0, (wave - 3) ~/ 2 + 1);

  // Power-up drop timer
  double _powerUpTimer = 0;
  double _powerUpInterval = 15.0;

  BounceZoneState()
      : ball = BallModel(x: 0, y: 0);

  /// Full game reset
  void resetGame() {
    survivalTime = 0;
    wave = 1;
    score = 0;
    totalPowerUpsCollected = 0;
    timeUntilNextWave = 12.0;
    waveCooldown = 0;
    waveTransition = false;
    waveAnnouncement = '';
    waveAnnounceTimer = 0;
    shieldTimer = 0;
    slowMoTimer = 0;
    _powerUpTimer = 0;

    spinners.clear();
    chasers.clear();
    lasers.clear();
    powerUps.clear();
    particles.clear();

    // Reset ball
    ball.speed = 0;
    ball.vx = 0;
    ball.vy = 0;
    ball.isInvincible = false;
    ball.invincibleTimer = 0;
    ball.active = true;
    ball.clearTrail();

    // Set ball at center
    ball.x = (arenaLeft + arenaRight) / 2;
    ball.y = (arenaTop + arenaBottom) / 2;

    status = GameStatus.playing;
  }

  /// Set arena bounds (call when screen size is known)
  void setArenaSize(Size size) {
    arenaLeft = 20;
    arenaTop = 70;
    arenaRight = size.width - 20;
    arenaBottom = size.height - 20;
  }

  /// Push ball toward tap position
  void pushBall(double tapX, double tapY) {
    if (status != GameStatus.playing) return;
    if (!ball.active) return;

    final dx = tapX - ball.x;
    final dy = tapY - ball.y;
    final dist = sqrt(dx * dx + dy * dy);
    if (dist < 5) return; // Too close, ignore

    // If ball hasn't been launched yet (speed = 0), set it up
    if (ball.speed <= 0) {
      ball.speed = baseBallSpeed.clamp(200, maxBallSpeed);
    }

    // Set velocity toward tap point
    ball.vx = (dx / dist) * ball.speed;
    ball.vy = (dy / dist) * ball.speed;

    // Spawn push particles
    _spawnPushParticles(tapX, tapY);
  }

  /// Main update loop
  void update(double dt) {
    if (status != GameStatus.playing) return;

    // ── Slow motion ──
    if (slowMoTimer > 0) {
      dt *= 0.45;
      slowMoTimer -= dt / 0.45;
      if (slowMoTimer <= 0) slowMoTimer = 0;
    }

    survivalTime += dt;

    // ── Screen shake ──
    if (shakeDuration > 0) {
      shakeDuration -= dt;
      if (shakeDuration <= 0) {
        shakeIntensity = 0;
        shakeDuration = 0;
      }
    }

    // ── Power-up timers ──
    if (shieldTimer > 0) {
      shieldTimer -= dt;
      ball.isInvincible = true;
      ball.invincibleTimer = shieldTimer;
      if (shieldTimer <= 0) {
        shieldTimer = 0;
        ball.isInvincible = false;
        ball.invincibleTimer = 0;
      }
    }

    // ── Wave announcement ──
    if (waveAnnounceTimer > 0) {
      waveAnnounceTimer -= dt;
      if (waveAnnounceTimer <= 0 && waveAnnouncement.isNotEmpty) {
        waveAnnouncement = '';
        waveTransition = false;
      }
    }

    // ── Wave system ──
    if (!waveTransition) {
      timeUntilNextWave -= dt;
      if (timeUntilNextWave <= 0) {
        _nextWave();
      }
    }

    // ── Power-up spawning ──
    _powerUpTimer += dt;
    if (_powerUpTimer >= _powerUpInterval) {
      _powerUpTimer = 0;
      _spawnPowerUp();
      // Gradually shorten interval
      _powerUpInterval = max(10.0, _powerUpInterval - 0.5);
    }

    // ── Update ball ──
    _updateBall(dt);

    // ── Update hazards ──
    _updateSpinners(dt);
    _updateChasers(dt);
    _updateLasers(dt);

    // ── Update power-ups falling ──
    _updatePowerUps(dt);

    // ── Update particles ──
    _updateParticles(dt);

    // ── Collision check ──
    _checkCollisions();

    // ── Update score (time-based) ──
    score = (survivalTime * 10).round() + totalPowerUpsCollected * 50;
  }

  void _updateBall(double dt) {
    if (!ball.active) return;

    // Increase speed slightly over time
    if (ball.speed > 0) {
      ball.speed += dt * 2; // Very gradual speedup
      ball.speed = ball.speed.clamp(0, maxBallSpeed);
      ball.normalizeSpeed();
    }

    // Move ball
    ball.x += ball.vx * dt;
    ball.y += ball.vy * dt;

    // Wall bouncing
    if (ball.x - ball.radius < arenaLeft) {
      ball.x = arenaLeft + ball.radius;
      ball.vx = ball.vx.abs();
      _spawnWallParticles(ball.x, ball.y);
    }
    if (ball.x + ball.radius > arenaRight) {
      ball.x = arenaRight - ball.radius;
      ball.vx = -ball.vx.abs();
      _spawnWallParticles(ball.x, ball.y);
    }
    if (ball.y - ball.radius < arenaTop) {
      ball.y = arenaTop + ball.radius;
      ball.vy = ball.vy.abs();
      _spawnWallParticles(ball.x, ball.y);
    }
    if (ball.y + ball.radius > arenaBottom) {
      ball.y = arenaBottom - ball.radius;
      ball.vy = -ball.vy.abs();
      _spawnWallParticles(ball.x, ball.y);
    }

    // Update trail
    ball.updateTrail();

    // Bound velocity to maintain speed
    ball.normalizeSpeed();
  }

  void _updateSpinners(double dt) {
    for (final s in spinners) {
      if (!s.active) continue;
      s.angle += s.angularSpeed * dt;
      s.spawnTime += dt;
    }
  }

  void _updateChasers(double dt) {
    final speedMult = slowMoTimer > 0 ? 0.5 : 1.0;
    for (final c in chasers) {
      if (!c.active) continue;
      c.chase(ball.x, ball.y, dt * speedMult);
    }
  }

  void _updateLasers(double dt) {
    for (final l in lasers) {
      if (!l.active) continue;
      if (l.charging) {
        l.chargeTime += dt;
        if (l.chargeTime >= l.chargeDuration) {
          l.charging = false;
          l.firing = true;
          l.fireTime = 0;
        }
      } else if (l.firing) {
        l.fireTime += dt;
        if (l.fireTime >= l.fireDuration) {
          l.active = false;
        }
      }
    }
    lasers.removeWhere((l) => !l.active);
  }

  void _updatePowerUps(double dt) {
    for (final pu in powerUps) {
      if (pu.collected) continue;
      pu.y += pu.speed * dt;
      pu.animTimer += dt * 3;

      // Check collection with ball
      if (pu.collidesWith(ball.x, ball.y, ball.radius)) {
        pu.collected = true;
        _applyPowerUp(pu);
      }

      // Remove if fallen off screen
      if (pu.y > arenaBottom + 40) {
        pu.collected = true;
      }
    }
    powerUps.removeWhere((p) => p.collected);
  }

  void _updateParticles(double dt) {
    for (final p in particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += 200 * dt; // Gravity
      p.lifetime += dt;
    }
    particles.removeWhere((p) => p.isDead);
  }

  void _checkCollisions() {
    if (!ball.active) return;

    // ── Spinner collision ──
    for (final s in spinners) {
      if (!s.active) continue;
      if (s.collidesWith(ball.x, ball.y, ball.radius)) {
        _onHit();
        return;
      }
    }

    // ── Chaser collision ──
    for (final c in chasers) {
      if (!c.active) continue;
      if (c.collidesWith(ball.x, ball.y, ball.radius)) {
        _onHit();
        return;
      }
    }

    // ── Laser collision ──
    for (final l in lasers) {
      if (!l.active) continue;
      if (l.collidesWith(ball.x, ball.y, ball.radius)) {
        _onHit();
        return;
      }
    }
  }

  void _onHit() {
    if (ball.isInvincible) {
      // Absorb hit, lose shield
      ball.isInvincible = false;
      shieldTimer = 0;
      ball.invincibleTimer = 0;

      // Big particle burst
      for (int i = 0; i < 40; i++) {
        final angle = _random.nextDouble() * 2 * pi;
        final speed = 50 + _random.nextDouble() * 200;
        particles.add(ParticleModel(
          x: ball.x,
          y: ball.y,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed,
          maxLifetime: 0.6,
          radius: 2 + _random.nextDouble() * 3,
          color: const Color(0xFFFFD700),
        ));
      }
      triggerShake(intensity: 5, duration: 0.2);
      return;
    }

    // Game over
    ball.active = false;
    status = GameStatus.gameOver;
    if (score > highScore) highScore = score;

    // Death explosion
    for (int i = 0; i < 60; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 50 + _random.nextDouble() * 300;
      final colors = [
        const Color(0xFFFF1744),
        const Color(0xFFFF6B9D),
        const Color(0xFF7C4DFF),
        const Color(0xFFFFFFFF),
      ];
      particles.add(ParticleModel(
        x: ball.x,
        y: ball.y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        maxLifetime: 0.5 + _random.nextDouble() * 0.8,
        radius: 2 + _random.nextDouble() * 4,
        color: colors[_random.nextInt(colors.length)],
      ));
    }
    triggerShake(intensity: 12, duration: 0.5);
  }

  void _nextWave() {
    wave++;
    waveAnnouncement = 'WAVE $wave';
    waveAnnounceTimer = 2.0;
    waveTransition = true;
    timeUntilNextWave = timeBetweenWaves;

    triggerShake(intensity: 3, duration: 0.15);

    // ── Spawn hazards ──
    final sw = spinnersPerWave;
    final cw = chasersPerWave;

    for (int i = 0; i < sw; i++) {
      _spawnSpinner();
    }
    for (int i = 0; i < cw; i++) {
      _spawnChaser();
    }

    // ── Laser every 5 waves ──
    if (wave % 5 == 0) {
      _spawnLaser();
    }

    // ── Give power-up on milestone waves ──
    if (wave % 3 == 0) {
      _spawnPowerUp();
    }
  }

  void _spawnSpinner() {
    // Find a good position (not too close to ball)
    double cx, cy;
    int attempts = 0;
    do {
      cx = arenaLeft + 40 + _random.nextDouble() * (arenaRight - arenaLeft - 80);
      cy = arenaTop + 40 + _random.nextDouble() * (arenaBottom - arenaTop - 80);
      attempts++;
    } while (sqrt(pow(cx - ball.x, 2) + pow(cy - ball.y, 2)) < 120 &&
        attempts < 10);

    spinners.add(SpinnerModel(
      cx: cx,
      cy: cy,
      length: spinnerLength,
      angularSpeed: spinnerAngularSpeed,
    ));
  }

  void _spawnChaser() {
    // Spawn from edges
    final side = _random.nextInt(4);
    double cx, cy;
    switch (side) {
      case 0: // Top
        cx = arenaLeft + _random.nextDouble() * (arenaRight - arenaLeft);
        cy = arenaTop - 30;
        break;
      case 1: // Bottom
        cx = arenaLeft + _random.nextDouble() * (arenaRight - arenaLeft);
        cy = arenaBottom + 30;
        break;
      case 2: // Left
        cx = arenaLeft - 30;
        cy = arenaTop + _random.nextDouble() * (arenaBottom - arenaTop);
        break;
      default: // Right
        cx = arenaRight + 30;
        cy = arenaTop + _random.nextDouble() * (arenaBottom - arenaTop);
        break;
    }

    chasers.add(ChaserModel(
      x: cx,
      y: cy,
      radius: chaserRadius,
      speed: chaserSpeed,
    ));
  }

  void _spawnLaser() {
    final horizontal = _random.nextBool();
    double lx, ly;
    if (horizontal) {
      ly = arenaTop + 40 + _random.nextDouble() * (arenaBottom - arenaTop - 80);
      lx = (arenaLeft + arenaRight) / 2;
    } else {
      lx = arenaLeft + 40 + _random.nextDouble() * (arenaRight - arenaLeft - 80);
      ly = (arenaTop + arenaBottom) / 2;
    }

    lasers.add(LaserModel(
      x: lx,
      y: ly,
      horizontal: horizontal,
    ));
  }

  void _spawnPowerUp() {
    final types = PowerUpType.values;
    final type = types[_random.nextInt(types.length)];
    final x = arenaLeft + 40 + _random.nextDouble() * (arenaRight - arenaLeft - 80);
    final y = arenaTop - 20;

    powerUps.add(PowerUpModel(x: x, y: y, type: type));
  }

  void _applyPowerUp(PowerUpModel pu) {
    totalPowerUpsCollected++;

    switch (pu.type) {
      case PowerUpType.shield:
        shieldTimer = 6.0;
        ball.isInvincible = true;
        ball.invincibleTimer = 6.0;
        break;
      case PowerUpType.slowTime:
        slowMoTimer = 5.0;
        break;
      case PowerUpType.repel:
        _repelAll();
        break;
    }

    // Collection particle burst
    for (int i = 0; i < 25; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 30 + _random.nextDouble() * 150;
      particles.add(ParticleModel(
        x: pu.x,
        y: pu.y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        maxLifetime: 0.5,
        radius: 1.5 + _random.nextDouble() * 2.5,
        color: pu.color,
      ));
    }
  }

  void _repelAll() {
    final pushStrength = 200.0;
    for (final s in spinners) {
      final dx = s.cx - ball.x;
      final dy = s.cy - ball.y;
      final dist = sqrt(dx * dx + dy * dy);
      if (dist > 0) {
        s.cx += (dx / dist) * pushStrength;
        s.cy += (dy / dist) * pushStrength;
        // Clamp to arena
        s.cx = s.cx.clamp(arenaLeft + s.length + 10, arenaRight - s.length - 10);
        s.cy = s.cy.clamp(arenaTop + s.length + 10, arenaBottom - s.length - 10);
      }
    }
    for (final c in chasers) {
      final dx = c.x - ball.x;
      final dy = c.y - ball.y;
      final dist = sqrt(dx * dx + dy * dy);
      if (dist > 0) {
        c.x += (dx / dist) * pushStrength;
        c.y += (dy / dist) * pushStrength;
      }
    }
    triggerShake(intensity: 4, duration: 0.2);
  }

  void _spawnPushParticles(double tx, double ty) {
    for (int i = 0; i < 8; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 20 + _random.nextDouble() * 80;
      particles.add(ParticleModel(
        x: ball.x,
        y: ball.y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        maxLifetime: 0.3,
        radius: 1.5 + _random.nextDouble() * 2,
        color: const Color(0xFFB388FF),
      ));
    }
  }

  void _spawnWallParticles(double wx, double wy) {
    for (int i = 0; i < 4; i++) {
      particles.add(ParticleModel(
        x: wx + (_random.nextDouble() - 0.5) * 10,
        y: wy + (_random.nextDouble() - 0.5) * 10,
        vx: (_random.nextDouble() - 0.5) * 80,
        vy: (_random.nextDouble() - 0.5) * 80,
        maxLifetime: 0.25,
        radius: 1.5,
        color: const Color(0xFF00E5FF).withOpacity(0.5),
      ));
    }
  }

  void _spawnNearMissParticles() {
    for (int i = 0; i < 6; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 30 + _random.nextDouble() * 60;
      particles.add(ParticleModel(
        x: ball.x + (_random.nextDouble() - 0.5) * 20,
        y: ball.y + (_random.nextDouble() - 0.5) * 20,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        maxLifetime: 0.2,
        radius: 1,
        color: Colors.white.withOpacity(0.6),
      ));
    }
  }

  void triggerShake({double intensity = 4, double duration = 0.2}) {
    shakeIntensity = intensity;
    shakeDuration = duration;
  }
}
