import 'package:flutter/widgets.dart';
import 'dart:math' as math;

class ball extends StatelessWidget {
  const ball(this.x, this.y, this.color, {Key? key}) : super(key: key);
  final x;
  final y;
  final color;
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment(x, y),
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          width: 20,
          height: 20,
        ));
  }
}
