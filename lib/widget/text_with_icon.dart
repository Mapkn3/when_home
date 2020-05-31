import 'package:flutter/material.dart';

class TextWithIcon extends StatelessWidget {
  TextWithIcon({
    @required this.text,
    @required this.icon,
  })  : assert(text != null),
        assert(icon != null);

  final Text text;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Flex(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        direction: Axis.horizontal,
        children: [
          icon,
          text,
        ],
      ),
    );
  }
}
