import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

double getQuarterOfScreen(BuildContext context) =>
    MediaQuery.of(context).copyWith().size.height / 4;

String formatTimeOfDay(BuildContext context, TimeOfDay time) =>
    MaterialLocalizations.of(context)
        .formatTimeOfDay(time, alwaysUse24HourFormat: true);

String formatDateTime(BuildContext context, DateTime date) =>
    formatTimeOfDay(context, TimeOfDay.fromDateTime(date));

String getFullDateTime(DateTime date) {
  String year = date.year.toString();
  String month = formatTwoDigitZeroPad(date.month);
  String day = formatTwoDigitZeroPad(date.day);
  String hour = formatTwoDigitZeroPad(date.hour);
  String minute = formatTwoDigitZeroPad(date.minute);
  String second = formatTwoDigitZeroPad(date.second);
  return '$day.$month.$year $hour:$minute:$second';
}

String getShortDateOfDateTime(DateTime date) {
  String month = formatTwoDigitZeroPad(date.month);
  String day = formatTwoDigitZeroPad(date.day);
  return '$day.$month';
}

String getTimeOfDateTime(DateTime date) {
  String hour = formatTwoDigitZeroPad(date.hour);
  String minute = formatTwoDigitZeroPad(date.minute);
  String second = formatTwoDigitZeroPad(date.second);
  return '$hour:$minute:$second';
}

String getTimeWithShortDateOfDateTime(DateTime date) =>
    '${getTimeOfDateTime(date)} (${getShortDateOfDateTime(date)})';

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

Duration toDuration(TimeOfDay timeOfDay) =>
    Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute);

TimeOfDay toTimeOfDay(Duration duration) =>
    TimeOfDay(hour: duration.inHours % 24, minute: duration.inMinutes % 60);

Future<TimeOfDay> getTimeFromModalBottomSheet(BuildContext context,
    {TimeOfDay initTime}) async {
  TimeOfDay time = initTime ?? TimeOfDay.now();
  String result = await showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                CupertinoButton(
                    child: Text('Cancel'),
                    onPressed: () => Navigator.pop(context, '_getTime_cancel')),
                Spacer(),
                CupertinoButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.pop(context, '_getTime_ok'),
                ),
              ],
            ),
            Container(
              height: getQuarterOfScreen(context),
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

Widget underlineWidget(BuildContext context,
        {@required Widget child}) =>
    Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: Theme.of(context).textTheme.body1.color))),
        child: child);