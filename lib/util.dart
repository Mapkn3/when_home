import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      builder: (BuildContext builder) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                CupertinoButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      return Navigator.pop(context, cancel);
                    }),
                Spacer(),
                CupertinoButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.pop(context, ok),
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

Widget underlineWidget(BuildContext context, {@required Widget child}) =>
    Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).textTheme.body1.color,
            ),
          ),
        ),
        child: child);
