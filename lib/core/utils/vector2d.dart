import 'package:flutter/material.dart';
import 'dart:math' as math;

class Vector2d {
  final double x;
  final double y;
  
  const Vector2d(this.x, this.y);
  
  Vector2d operator-(Vector2d other) => Vector2d(x - other.x, y - other.y);
  
  @override
  String toString() => 'Vector2d($x, $y)';
}
