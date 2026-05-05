import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class BallWidget extends StatefulWidget {
  final Offset position;
  final double velocityX;
  final double velocityY;
  final int ballId;
  
  const BallWidget({
    super.key,
    required this.position,
    required this.velocityX,
    required this.velocityY,
    required this.ballId,
  });
  
  @override
  State<BallWidget> createState() => _BallWidgetState();
}

class _BallWidgetState extends State<BallWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double positionX = 0;
  double positionY = 0;
  bool isAnimating = true;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 16), // ~60fps
    );
    
    positionX = widget.position.dx - AppConstants.ballRadius;
    positionY = widget.position.dy - AppConstants.ballRadius;
    
    _updatePosition();
  }
  
  @override
  void didUpdateWidget(BallWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePosition();
  }
  
  void _updatePosition() {
    positionX = widget.position.dx - AppConstants.ballRadius;
    positionY = widget.position.dy - AppConstants.ballRadius;
    
    // Apply velocity for continuous movement
    if (isAnimating) {
      positionX += widget.velocityX;
      positionY += widget.velocityY;
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(positionX, positionY),
      child: Container(
        width: AppConstants.ballRadius * 2,
        height: AppConstants.ballRadius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF9B6AFF),
              Color(0xFF7C4DFF),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.4),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }
}

// Vector2d class for physics calculations
class Vector2d {
  final double x;
  final double y;
  
  const Vector2d(this.x, this.y);
  
  Vector2d operator-(Vector2d other) => Vector2d(x - other.x, y - other.y);
  
  @override
  String toString() => 'Vector2d($x, $y)';
}
