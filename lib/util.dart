import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

String formatTimeOfDay(BuildContext context, TimeOfDay time) {
  return MaterialLocalizations.of(context)
      .formatTimeOfDay(time, alwaysUse24HourFormat: true);
}

String formatDateTime(BuildContext context, DateTime date) {
  return formatTimeOfDay(context, TimeOfDay.fromDateTime(date));
}

String formatDuration(Duration duration) {
  int days = duration.inDays;
  String hours = duration.inHours.remainder(24).toString().padLeft(2, '0');
  String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  return '${days > 0 ? '${duration.inDays} д. ' : ''}$hours:$minutes';
}

Future<TimeOfDay> getTimeFromModalBottomSheet(BuildContext context,
    {TimeOfDay initTime}) async {
  TimeOfDay time = initTime ?? TimeOfDay.now();
  String result = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext builder) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 1.0, horizontal: 4.0),
                        child: OutlineButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.pop(context, '_getTime_cancel');
                            }))),
                Expanded(
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 1.0, horizontal: 4.0),
                        child: OutlineButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.pop(context, '_getTime_ok');
                            })))
              ],
            ),
            Container(
              height: MediaQuery.of(context).copyWith().size.height / 4,
              child: CupertinoDatePicker(
                initialDateTime:
                    DateTime(1969, 1, 1, initTime.hour, initTime.minute),
                onDateTimeChanged: (DateTime value) {
                  time = TimeOfDay.fromDateTime(value);
                },
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
              ),
            )
          ],
        );
      });
  switch (result) {
    case '_getTime_ok':
      {
        return time;
      }
    case '_getTime_cancel':
    default:
      {
        return initTime;
      }
  }
}
