import 'package:flutter/material.dart';

class Underline extends StatelessWidget {
  Underline({
    @required this.child,
    this.color,
  }) : assert(child != null);

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: color ?? Theme.of(context).textTheme.headline5.color,
          ),
        ),
      ),
      child: child,
    );
  }
}
