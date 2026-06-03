import 'dart:math';
import 'package:flutter/material.dart';
import 'bounce_zone.dart';

// ══════════════════════════════════════════════════════════════
// BOUNCE ZONE — Game Painter
// ══════════════════════════════════════════════════════════════

class BounceZonePainter extends CustomPainter {
  final BounceZoneState state;
  final double animTime;

  BounceZonePainter(this.state, this.animTime);

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawArenaBorder(canvas);
    _drawLasers(canvas);
    _drawSpinners(canvas);
    _drawChasers(canvas);
    _drawPowerUps(canvas);
    _drawBall(canvas);
    _drawParticles(canvas);
    _drawWaveAnnouncement(canvas, size);
  }

  // ── BACKGROUND ──

  void _drawBackground(Canvas canvas, Size size) {
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bgGradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0D0D1A),
          const Color(0xFF1A0A2E),
          const Color(0xFF0A0A1A),
        ],
      ).createShader(bgRect);
    canvas.drawRect(bgRect, bgGradient);

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFF1A1A3A).withOpacity(0.3)
      ..strokeWidth = 0.5;
    final gridSize = 30.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Ambient center glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF7C4DFF).withOpacity(0.06),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width * 0.6,
        ),
      );
    canvas.drawRect(bgRect, glowPaint);
  }

  // ── ARENA BORDER ──

  void _drawArenaBorder(Canvas canvas) {
    final arenaRect = Rect.fromLTWH(
      state.arenaLeft,
      state.arenaTop,
      state.arenaRight - state.arenaLeft,
      state.arenaBottom - state.arenaTop,
    );

    // Outer glow
    final glowPaint = Paint()
      ..color = const Color(0xFF7C4DFF).withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawRect(arenaRect.inflate(4), glowPaint);

    // Main border
    final borderPaint = Paint()
      ..color = const Color(0xFF7C4DFF).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(arenaRect, borderPaint);

    // Corner accents
    final cornerLen = 15.0;
    final cornerPaint = Paint()
      ..color = const Color(0xFFB388FF).withOpacity(0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Top-left
    canvas.drawLine(
      Offset(state.arenaLeft, state.arenaTop + cornerLen),
      Offset(state.arenaLeft, state.arenaTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(state.arenaLeft, state.arenaTop),
      Offset(state.arenaLeft + cornerLen, state.arenaTop),
      cornerPaint,
    );
    // Top-right
    canvas.drawLine(
      Offset(state.arenaRight - cornerLen, state.arenaTop),
      Offset(state.arenaRight, state.arenaTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(state.arenaRight, state.arenaTop),
      Offset(state.arenaRight, state.arenaTop + cornerLen),
      cornerPaint,
    );
    // Bottom-left
    canvas.drawLine(
      Offset(state.arenaLeft, state.arenaBottom - cornerLen),
      Offset(state.arenaLeft, state.arenaBottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(state.arenaLeft, state.arenaBottom),
      Offset(state.arenaLeft + cornerLen, state.arenaBottom),
      cornerPaint,
    );
    // Bottom-right
    canvas.drawLine(
      Offset(state.arenaRight - cornerLen, state.arenaBottom),
      Offset(state.arenaRight, state.arenaBottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(state.arenaRight, state.arenaBottom),
      Offset(state.arenaRight, state.arenaBottom - cornerLen),
      cornerPaint,
    );
  }

  // ── SPINNERS ──

  void _drawSpinners(Canvas canvas) {
    for (final s in state.spinners) {
      if (!s.active) continue;

      final tip = s.tip;
      final oppositeTip = s.oppositeTip;

      // Glow line
      final glowPaint = Paint()
        ..color = const Color(0xFFFF6B9D).withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawLine(Offset(oppositeTip.dx, oppositeTip.dy), Offset(tip.dx, tip.dy), glowPaint);

      // Main line
      final linePaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFFF1744).withOpacity(0.3),
            const Color(0xFFFF6B9D),
            const Color(0xFFFFAB00),
          ],
        ).createShader(
          Rect.fromPoints(Offset(oppositeTip.dx, oppositeTip.dy), Offset(tip.dx, tip.dy)),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawLine(Offset(oppositeTip.dx, oppositeTip.dy), Offset(tip.dx, tip.dy), linePaint);

      // Tip glow
      final tipGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFF6B9D).withOpacity(0.5),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(center: Offset(tip.dx, tip.dy), radius: s.radius * 3),
        );
      canvas.drawCircle(Offset(tip.dx, tip.dy), s.radius * 3, tipGlow);

      // Tip dot
      canvas.drawCircle(
        Offset(tip.dx, tip.dy),
        s.radius,
        Paint()..color = const Color(0xFFFF6B9D),
      );

      // Opposite tip dot (smaller)
      canvas.drawCircle(
        Offset(oppositeTip.dx, oppositeTip.dy),
        s.radius * 0.5,
        Paint()..color = const Color(0xFFFF6B9D).withOpacity(0.5),
      );

      // Center hub
      final hubPaint = Paint()
        ..color = const Color(0xFF7C4DFF).withOpacity(0.8);
      canvas.drawCircle(Offset(s.cx, s.cy), 5, hubPaint);
    }
  }

  // ── CHASERS ──

  void _drawChasers(Canvas canvas) {
    for (final c in state.chasers) {
      if (!c.active) continue;

      // Red glow
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFF1744).withOpacity(0.4),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(center: Offset(c.x, c.y), radius: c.radius * 4),
        );
      canvas.drawCircle(Offset(c.x, c.y), c.radius * 4, glowPaint);

      // Body
      final bodyPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFF5252),
            const Color(0xFFD50000),
            const Color(0xFFB71C1C),
          ],
        ).createShader(
          Rect.fromCircle(center: Offset(c.x - c.radius * 0.3, c.y - c.radius * 0.3), radius: c.radius),
        );
      canvas.drawCircle(Offset(c.x, c.y), c.radius, bodyPaint);

      // Angry eyes
      final eyeOffset = c.radius * 0.35;
      final eyeRadius = c.radius * 0.2;
      final eyePaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(c.x - eyeOffset, c.y - eyeOffset), eyeRadius * 0.8, eyePaint);
      canvas.drawCircle(Offset(c.x + eyeOffset, c.y - eyeOffset), eyeRadius * 0.8, eyePaint);

      // Pupils (look toward ball)
      final dx = state.ball.x - c.x;
      final dy = state.ball.y - c.y;
      final dist = sqrt(dx * dx + dy * dy);
      if (dist > 0) {
        final lookOffset = eyeRadius * 0.3;
        final lookX = dx / dist * lookOffset;
        final lookY = dy / dist * lookOffset;
        final pupilPaint = Paint()..color = const Color(0xFF1A1A1A);
        canvas.drawCircle(
          Offset(c.x - eyeOffset + lookX, c.y - eyeOffset + lookY),
          eyeRadius * 0.5,
          pupilPaint,
        );
        canvas.drawCircle(
          Offset(c.x + eyeOffset + lookX, c.y - eyeOffset + lookY),
          eyeRadius * 0.5,
          pupilPaint,
        );
      }
    }
  }

  // ── LASERS ──

  void _drawLasers(Canvas canvas) {
    for (final l in state.lasers) {
      if (!l.active) continue;

      if (l.charging) {
        // Charge indicator — pulsing circle at position
        final pulse = 0.5 + 0.5 * sin(l.chargeTime * 4);
        final chargePaint = Paint()
          ..color = const Color(0xFF00E5FF).withOpacity(0.3 + pulse * 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 + pulse * 2;
        canvas.drawCircle(Offset(l.x, l.y), 10 + pulse * 8, chargePaint);

        // Warn line
        final warnPaint = Paint()
          ..color = const Color(0xFF00E5FF).withOpacity(0.1 + pulse * 0.2)
          ..strokeWidth = 2;
        if (l.horizontal) {
          canvas.drawLine(
            Offset(state.arenaLeft, l.y),
            Offset(state.arenaRight, l.y),
            warnPaint,
          );
        } else {
          canvas.drawLine(
            Offset(l.x, state.arenaTop),
            Offset(l.x, state.arenaBottom),
            warnPaint,
          );
        }
      } else if (l.firing) {
        // Firing beam
        final beamPaint = Paint()
          ..shader = LinearGradient(
            begin: l.horizontal ? Alignment.centerLeft : Alignment.topCenter,
            end: l.horizontal ? Alignment.centerRight : Alignment.bottomCenter,
            colors: [
              const Color(0xFF00E5FF).withOpacity(0.8),
              const Color(0xFF00E5FF).withOpacity(0.5),
              const Color(0xFF00E5FF).withOpacity(0.8),
            ],
          ).createShader(l.beamRect);

        // Outer glow
        final glowBeam = Paint()
          ..color = const Color(0xFF00E5FF).withOpacity(0.3)
          ..strokeWidth = l.beamWidth * 3
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        if (l.horizontal) {
          canvas.drawLine(
            Offset(state.arenaLeft, l.y),
            Offset(state.arenaRight, l.y),
            glowBeam,
          );
        } else {
          canvas.drawLine(
            Offset(l.x, state.arenaTop),
            Offset(l.x, state.arenaBottom),
            glowBeam,
          );
        }

        // Core beam
        final corePaint = Paint()
          ..color = const Color(0xFFE0F7FA)
          ..strokeWidth = l.beamWidth;
        if (l.horizontal) {
          canvas.drawLine(
            Offset(state.arenaLeft, l.y),
            Offset(state.arenaRight, l.y),
            corePaint,
          );
        } else {
          canvas.drawLine(
            Offset(l.x, state.arenaTop),
            Offset(l.x, state.arenaBottom),
            corePaint,
          );
        }
      }
    }
  }

  // ── BALL ──

  void _drawBall(Canvas canvas) {
    if (!state.ball.active) return;
    final bx = state.ball.x;
    final by = state.ball.y;
    final r = state.ball.radius;

    // Trail
    if (state.ball.trail.length > 1) {
      for (int i = 0; i < state.ball.trail.length - 1; i++) {
        final t = i / state.ball.trail.length;
        final trailPaint = Paint()
          ..color = state.ball.isInvincible
              ? Color.lerp(const Color(0xFFFFD700).withOpacity(0), const Color(0xFFFFD700), t)!
              : Color.lerp(const Color(0xFF7C4DFF).withOpacity(0), const Color(0xFFB388FF), t)!;
        canvas.drawCircle(
          state.ball.trail[i],
          r * (0.3 + t * 0.5),
          trailPaint,
        );
      }
    }

    // Shield glow ring
    if (state.ball.isInvincible) {
      final ringPulse = 0.8 + 0.2 * sin(state.ball.trail.length * 0.3);
      final shieldPaint = Paint()
        ..color = const Color(0xFFFFD700).withOpacity(0.3 * ringPulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(Offset(bx, by), r + 6, shieldPaint);

      final shieldGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFD700).withOpacity(0.15),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(bx, by), radius: r * 4));
      canvas.drawCircle(Offset(bx, by), r * 4, shieldGlow);
    }

    // Ball glow
    final glowColor = state.ball.isInvincible
        ? const Color(0xFFFFD700)
        : const Color(0xFF7C4DFF);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          glowColor.withOpacity(0.4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(bx, by), radius: r * 3));
    canvas.drawCircle(Offset(bx, by), r * 3, glowPaint);

    // Ball body
    final bodyColors = state.ball.isInvincible
        ? [
            const Color(0xFFFFF176),
            const Color(0xFFFFD700),
            const Color(0xFFFF8F00),
          ]
        : [
            const Color(0xFFB388FF),
            const Color(0xFF7C4DFF),
            const Color(0xFF651FFF),
          ];

    final ballGradient = Paint()
      ..shader = RadialGradient(colors: bodyColors).createShader(
        Rect.fromCircle(center: Offset(bx - r * 0.3, by - r * 0.3), radius: r),
      );
    canvas.drawCircle(Offset(bx, by), r, ballGradient);

    // Highlight
    final highlight = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.6),
          Colors.transparent,
        ],
      ).createShader(
        Offset(bx - r * 0.3, by - r * 0.3) & const Size(8, 8),
      );
    canvas.drawCircle(Offset(bx - r * 0.2, by - r * 0.2), r * 0.4, highlight);
  }

  // ── POWER-UPS ──

  void _drawPowerUps(Canvas canvas) {
    for (final pu in state.powerUps) {
      if (pu.collected) continue;
      final pulse = 1.0 + sin(pu.animTimer) * 0.15;

      // Glow
      final glowPaint = Paint()
        ..color = pu.color.withOpacity(0.25);
      canvas.drawCircle(Offset(pu.x, pu.y), 20 * pulse, glowPaint);

      canvas.save();
      canvas.translate(pu.x, pu.y);
      canvas.scale(pulse);

      // Background
      final bgPaint = Paint()
        ..color = pu.color.withOpacity(0.85);
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-14, -14, 28, 28), const Radius.circular(6)),
        bgPaint,
      );

      // Border
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-14, -14, 28, 28), const Radius.circular(6)),
        borderPaint,
      );

      // Label
      final tp = TextPainter(
        text: TextSpan(
          text: pu.label.substring(0, 1), // First letter only
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));

      canvas.restore();
    }
  }

  // ── PARTICLES ──

  void _drawParticles(Canvas canvas) {
    for (final p in state.particles) {
      final alpha = 1.0 - p.progress;
      final paint = Paint()
        ..color = p.color.withOpacity(alpha);
      final radius = p.radius * (0.5 + 0.5 * (1.0 - p.progress));
      canvas.drawCircle(Offset(p.x, p.y), radius, paint);
    }
  }

  // ── WAVE ANNOUNCEMENT ──

  void _drawWaveAnnouncement(Canvas canvas, Size size) {
    if (state.waveAnnouncement.isEmpty) return;

    final progress = state.waveAnnounceTimer / 2.0; // 0 to 1 over 2 seconds
    final scale = min(1.0 + (1.0 - progress) * 0.5, 1.5);
    final opacity = progress > 0.3 ? 1.0 : progress / 0.3;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);

    // Glow behind text
    final glowRect = Rect.fromCenter(center: Offset.zero, width: 300, height: 80);
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF7C4DFF).withOpacity(0.15 * opacity),
          Colors.transparent,
        ],
      ).createShader(glowRect);
    canvas.drawRect(glowRect, bgPaint);

    final tp = TextPainter(
      text: TextSpan(
        text: state.waveAnnouncement,
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(opacity),
          letterSpacing: 6,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));

    // Subtitle
    if (progress > 0.2) {
      final subTp = TextPainter(
        text: TextSpan(
          text: 'SURVIVE',
          style: TextStyle(
            fontSize: 16,
            color: const Color(0xFF7C4DFF).withOpacity(0.6 * opacity),
            letterSpacing: 8,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      subTp.paint(canvas, Offset(-subTp.width / 2, 30));
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BounceZonePainter oldDelegate) => true;
}
