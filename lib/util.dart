import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'model/date_time_interval.dart';

String _datePattern = 'dd.MM.yyyy';
String _shortDatePattern = 'dd.MM';
DateFormat date = DateFormat(_datePattern);
DateFormat shortDate = DateFormat(_shortDatePattern);
DateFormat time = DateFormat.Hms();
DateFormat shortTime = DateFormat.Hm();
DateFormat dateWithTime = date.add_Hms();
DateFormat timeWithShortDate = time.addPattern('($_shortDatePattern)');
DateFormat shortTimeWithShortDate =
    shortTime.addPattern('($_shortDatePattern)');

double getNPartOfScreen(BuildContext context, double part) =>
    MediaQuery.of(context).copyWith().size.height / part;

double getQuarterOfScreen(BuildContext context) => getNPartOfScreen(context, 4);

String formatDuration(Duration duration) {
  int days = duration.inDays;
  String hours = duration.inHours.remainder(24).toString().padLeft(2, '0');
  String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  return '${days > 0 ? '${duration.inDays} д. ' : ''}$hours:$minutes';
}

String formatFullDuration(Duration duration) {
  int days = duration.inDays;
  String hours = formatTwoDigitZeroPad(duration.inHours.remainder(24));
  String minutes = formatTwoDigitZeroPad(duration.inMinutes.remainder(60));
  String seconds = formatTwoDigitZeroPad(duration.inSeconds.remainder(60));
  return '${days > 0 ? '${duration.inDays} д. ' : ''}$hours:$minutes:$seconds';
}

String formatTwoDigitZeroPad(int number) {
  assert(0 <= number && number < 100);
  return (number < 10) ? '0$number' : '$number';
}

Duration toDuration(DateTime dateTime) =>
    Duration(hours: dateTime.hour, minutes: dateTime.minute);

DateTime toDateTime(Duration duration) {
  DateTime now = DateTime.now();
  return DateTime(now.year, now.month, now.day).add(duration);
}

Future<DateTime> getTimeFromModalBottomSheet(BuildContext context,
    {DateTime initTime}) async {
  const ok = '_getTime_ok';
  const cancel = '_getTime_cancel';
  DateTime time = initTime ?? DateTime.now();
  final result = await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext builder) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                FlatButton(
                  child: Text('ОК'),
                  onPressed: () => Navigator.pop(context, ok),
                ),
                Spacer(),
                FlatButton(
                  child: Text('Отмена'),
                  onPressed: () => Navigator.pop(context, cancel),
                ),
              ],
            ),
            Container(
              height: getQuarterOfScreen(context),
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: Theme.of(context).brightness,
                ),
                child: CupertinoDatePicker(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  initialDateTime: initTime,
                  onDateTimeChanged: (DateTime value) => time = value,
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                ),
              ),
            )
          ],
        );
      });
  switch (result) {
    case ok:
      return time;
    case cancel:
    default:
      return initTime;
  }
}

Future<DateTimeInterval> getDateTimeInterval(BuildContext context) async {
  DateTime now = DateTime.now();
  DateTime begin = DateTime(now.year, now.month, now.day);
  DateTime end = DateTime(now.year, now.month, now.day);

  const ok = '_getInterval_ok';
  const cancel = '_getInterval_cancel';
  final result = await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext builder) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                FlatButton(
                  child: Text('ОК'),
                  onPressed: () {
                    if (begin.isAfter(end) || begin.isAtSameMomentAs(end)) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(
                              24.0,
                              20.0,
                              24.0,
                              8.0,
                            ),
                            content: Text(
                              'Время начала должно быть раньше времени окончания',
                            ),
                            actions: [
                              IconButton(
                                icon: Icon(Icons.check),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      Navigator.pop(context, ok);
                    }
                  },
                ),
                Spacer(),
                FlatButton(
                  child: Text('Отмена'),
                  onPressed: () => Navigator.pop(context, cancel),
                ),
              ],
            ),
            Container(
              height: getQuarterOfScreen(context),
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: CupertinoTheme.brightnessOf(context),
                ),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: CupertinoDatePicker(
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        initialDateTime: begin,
                        onDateTimeChanged: (DateTime value) => begin = value,
                        mode: CupertinoDatePickerMode.time,
                        use24hFormat: true,
                      ),
                    ),
                    Icon(
                      Icons.remove,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    Flexible(
                      child: CupertinoDatePicker(
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        initialDateTime: end,
                        onDateTimeChanged: (DateTime value) => end = value,
                        mode: CupertinoDatePickerMode.time,
                        use24hFormat: true,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      });
  switch (result) {
    case ok:
      return DateTimeInterval(begin: begin, end: end);
    case cancel:
    default:
      return null;
  }
}

mergeString(String first, String second, String separator) {
  String s1 = first ?? '';
  String s2 = second ?? '';
  String sep = separator ?? ' ';
  return s1 + (s1.isNotEmpty && s2.isNotEmpty ? sep : '') + s2;
}
