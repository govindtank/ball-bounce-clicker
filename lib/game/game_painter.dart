import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'game_engine.dart';

// ══════════════════════════════════════════════════════════════
// BOUNCE ARENA - Game Painter
// ══════════════════════════════════════════════════════════════

class BounceGamePainter extends CustomPainter {
  final BounceGameState state;
  final double animTime;

  BounceGamePainter(this.state, this.animTime);

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawBricks(canvas);
    _drawPowerUps(canvas);
    _drawBall(canvas);
    _drawPaddle(canvas);
    _drawParticles(canvas);
  }

  void _drawBackground(Canvas canvas, Size size) {
    // Dark gradient background
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

    // Grid overlay
    final gridPaint = Paint()
      ..color = const Color(0xFF1A1A3A).withOpacity(0.4)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Ambient glow on sides
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF7C4DFF).withOpacity(0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width * 0.8));
    canvas.drawRect(bgRect, glowPaint);
  }

  void _drawBricks(Canvas canvas) {
    for (final brick in state.bricks) {
      if (!brick.isAlive) continue;

      final rect = brick.rect;
      final c = brick.displayColor;

      // Shadow
      final shadowPaint = Paint()..color = c.withOpacity(0.3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.translate(1, 1), const Radius.circular(3)),
        shadowPaint,
      );

      // Main body with gradient
      final gradient = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.withOpacity(0.9),
            c,
            c.withOpacity(0.7),
          ],
        ).createShader(rect);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        gradient,
      );

      // Inner glow (top highlight)
      final glowRect = Rect.fromLTWH(rect.left + 2, rect.top + 1, rect.width - 4, rect.height * 0.4);
      if (glowRect.height > 0) {
        final glowPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.25),
              Colors.transparent,
            ],
          ).createShader(glowRect);
        canvas.drawRRect(
          RRect.fromRectAndRadius(glowRect, const Radius.circular(2)),
          glowPaint,
        );
      }

      // Border
      final borderPaint = Paint()
        ..color = c.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        borderPaint,
      );

      // Damage indicator for tough bricks
      if (brick.isOneHitLeft) {
        final crackPaint = Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..strokeWidth = 1.5;
        canvas.drawLine(
          Offset(rect.left + 4, rect.top + 4),
          Offset(rect.right - 4, rect.bottom - 4),
          crackPaint,
        );
        canvas.drawLine(
          Offset(rect.right - 4, rect.top + 4),
          Offset(rect.left + 4, rect.bottom - 4),
          crackPaint,
        );
      }
    }
  }

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
          ..color = state.fireballTimer > 0
              ? Color.lerp(const Color(0xFFFF6D00).withOpacity(0), const Color(0xFFFF6D00), t)!
              : Color.lerp(const Color(0xFF7C4DFF).withOpacity(0), const Color(0xFFB388FF), t)!;
        canvas.drawCircle(
          state.ball.trail[i],
          r * (0.3 + t * 0.5),
          trailPaint,
        );
      }
    }

    // Ball glow
    final glowColor = state.fireballTimer > 0
        ? const Color(0xFFFF6D00)
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
    final ballGradient = Paint()
      ..shader = RadialGradient(
        colors: state.fireballTimer > 0
            ? [
                const Color(0xFFFFAB00),
                const Color(0xFFFF6D00),
                const Color(0xFFE65100),
              ]
            : [
                const Color(0xFFB388FF),
                const Color(0xFF7C4DFF),
                const Color(0xFF651FFF),
              ],
      ).createShader(Rect.fromCircle(center: Offset(bx - r * 0.3, by - r * 0.3), radius: r));

    canvas.drawCircle(Offset(bx, by), r, ballGradient);

    // Ball highlight
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.6),
          Colors.transparent,
        ],
      ).createShader(Offset(bx - r * 0.3, by - r * 0.3) & const Size(8, 8));
    canvas.drawCircle(Offset(bx - r * 0.2, by - r * 0.2), r * 0.4, highlightPaint);

    // Fireball ring
    if (state.fireballTimer > 0) {
      final ringPaint = Paint()
        ..color = const Color(0xFFFF6D00).withOpacity(0.5 + sin(state.ball.trail.length * 0.5) * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(Offset(bx, by), r + 3, ringPaint);
    }
  }

  void _drawPaddle(Canvas canvas) {
    final rect = state.paddle.rect;

    // Shadow
    final shadowPaint = Paint()
      ..color = const Color(0xFF7C4DFF).withOpacity(0.3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.translate(0, 2), const Radius.circular(7)),
      shadowPaint,
    );

    // Paddle body with gradient
    final gradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          const Color(0xFF651FFF),
          const Color(0xFF7C4DFF),
          const Color(0xFFB388FF),
        ],
      ).createShader(rect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(7)),
      gradient,
    );

    // Edge glow
    final edgePaint = Paint()
      ..color = const Color(0xFFB388FF).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(7)),
      edgePaint,
    );

    // Center marker
    final centerPaint = Paint()
      ..color = Colors.white.withOpacity(0.3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(state.paddle.x, state.paddle.y), width: 20, height: 4),
        const Radius.circular(2),
      ),
      centerPaint,
    );
  }

  void _drawPowerUps(Canvas canvas) {
    for (final pu in state.powerUps) {
      if (pu.collected) continue;
      final pulse = 1.0 + sin(pu.animTime) * 0.15;

      // Glow
      final glowPaint = Paint()
        ..color = pu.color.withOpacity(0.3);
      canvas.drawCircle(Offset(pu.x, pu.y), 18 * pulse, glowPaint);

      // Body
      canvas.save();
      canvas.translate(pu.x, pu.y);
      canvas.scale(pulse);

      final bgPaint = Paint()
        ..color = pu.color.withOpacity(0.9);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-12, -12, 24, 24),
          const Radius.circular(5),
        ),
        bgPaint,
      );

      // Icon label (text)
      final tp = TextPainter(
        text: TextSpan(
          text: pu.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
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

  void _drawParticles(Canvas canvas) {
    for (final p in state.particles) {
      final alpha = (1.0 - p.progress);
      final particlePaint = Paint()
        ..color = p.color.withOpacity(alpha);
      final radius = p.radius * (0.5 + 0.5 * (1.0 - p.progress));
      canvas.drawCircle(Offset(p.x, p.y), radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant BounceGamePainter oldDelegate) => true;
}
