import 'package:flutter/material.dart';

class WidgetWithAction extends StatelessWidget {
  WidgetWithAction({
    @required this.widget,
    @required this.callback,
  })  : assert(widget != null),
        assert(callback != null);

  final Widget widget;
  final void Function() callback;

  @override
  Widget build(BuildContext context) {
    IconButton actionButton = IconButton(
      icon: Icon(Icons.edit),
      onPressed: callback,
    );
    Widget fakeButton = ConstrainedBox(
      constraints: const BoxConstraints(
          minWidth: kMinInteractiveDimension,
          minHeight: kMinInteractiveDimension),
      child: Padding(
        padding: actionButton.padding,
        child: SizedBox(
          height: actionButton.iconSize,
          width: actionButton.iconSize,
        ),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        fakeButton,
        widget,
        actionButton,
      ],
    );
  }
}
