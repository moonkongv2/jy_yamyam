import 'package:flutter/animation.dart';

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 160);
  static const normal = Duration(milliseconds: 260);
  static const slow = Duration(milliseconds: 420);

  static const curve = Curves.easeOutCubic;
  static const playfulCurve = Curves.easeOutBack;
}
