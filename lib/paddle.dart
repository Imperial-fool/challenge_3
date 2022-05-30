import 'package:flutter/widgets.dart';
import 'dart:math' as math;

class paddle extends StatelessWidget {
  const paddle(this.x, this.y, this.color, this.size, {Key? key})
      : super(key: key);
  final x;
  final y;
  final size;
  final color;
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment(x, y),
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.rectangle, color: color),
          width: MediaQuery.of(context).size.width * 0.1 * size,
          height: 25,
        ));
  }
}
