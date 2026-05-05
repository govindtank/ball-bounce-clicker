import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/constants/app_constants.dart';

class ParticleEffect extends StatefulWidget {
  final Offset position;
  final VoidCallback? onComplete;
  
  const ParticleEffect({
    super.key,
    required this.position,
    this.onComplete,
  });
  
  @override
  State<ParticleEffect> createState() => _ParticleEffectState();
}

class _ParticleEffectState extends State<ParticleEffect> 
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  late List<_ParticleData> particles;
  late List<_ParticleData> burstParticles;
  
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    particles = List.generate(12, (i) {
      final angle = (i / 12) * 2 * math.pi;
      final speed = 150.0 + _random.nextDouble() * 100;
      return _ParticleData(
        angle: angle,
        speed: speed,
        size: 6.0 + _random.nextDouble() * 4,
        color: _getParticleColor(i),
      );
    });
    
    burstParticles = List.generate(16, (i) {
      final angle = (i / 16) * 2 * math.pi + 0.2;
      final speed = 80.0 + _random.nextDouble() * 60;
      return _ParticleData(
        angle: angle,
        speed: speed,
        size: 3.0 + _random.nextDouble() * 3,
        color: _getParticleColor(i, secondary: true),
      );
    });
    
    _controller.forward();
    _fadeController.forward();
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  Color _getParticleColor(int index, {bool secondary = false}) {
    final colors = secondary 
        ? [AppConstants.glowCyan, AppConstants.accentColor, Colors.white]
        : [AppConstants.glowPurple, AppConstants.glowPink, AppConstants.glowCyan];
    return colors[index % colors.length];
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        listenable: _fadeController,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: ParticlePainter(
              position: widget.position,
              particles: particles,
              burstParticles: burstParticles,
              progress: _controller.value,
              fadeProgress: _fadeController.value,
            ),
          );
        },
      ),
    );
  }
}

class _ParticleData {
  final double angle;
  final double speed;
  final double size;
  final Color color;
  
  _ParticleData({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });
}

class ParticlePainter extends CustomPainter {
  final Offset position;
  final List<_ParticleData> particles;
  final List<_ParticleData> burstParticles;
  final double progress;
  final double fadeProgress;

  ParticlePainter({
    required this.position,
    required this.particles,
    required this.burstParticles,
    required this.progress,
    required this.fadeProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = 1.0 - (progress * 0.5);
    
    for (final particle in particles) {
      final distance = particle.speed * progress;
      final x = position.dx + math.cos(particle.angle) * distance;
      final y = position.dy + math.sin(particle.angle) * distance;
      
      final glowPaint = Paint()
        ..color = particle.color.withOpacity(opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(x, y), particle.size * 2, glowPaint);
      
      final corePaint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), particle.size, corePaint);
      
      final centerPaint = Paint()
        ..color = Colors.white.withOpacity(opacity * 0.8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), particle.size * 0.4, centerPaint);
    }
    
    for (final particle in burstParticles) {
      final distance = particle.speed * progress * 1.2;
      final x = position.dx + math.cos(particle.angle) * distance;
      final y = position.dy + math.sin(particle.angle) * distance;
      
      final paint = Paint()
        ..color = particle.color.withOpacity(opacity * 0.7)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), particle.size * 0.6, paint);
    }
    
    final rippleRadius = 30.0 + (progress * 80);
    final ripplePaint = Paint()
      ..color = AppConstants.accentColor.withOpacity((1 - progress) * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(position, rippleRadius, ripplePaint);
    
    final ripple2Radius = 20.0 + (progress * 60);
    final ripple2Paint = Paint()
      ..color = AppConstants.glowPink.withOpacity((1 - progress) * 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(position, ripple2Radius, ripple2Paint);
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.fadeProgress != fadeProgress;
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
