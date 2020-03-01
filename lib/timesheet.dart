import 'package:when_home/date_time_interval.dart';

class Timesheet {
  Duration workDuration;
  DateTime arrivalTime;
  List<DateTimeInterval> lunchTimes;
  DateTime lastLunchStartTime;

  Timesheet({this.workDuration, this.arrivalTime, this.lunchTimes});

  Duration getTotalLunchTime() {
    Duration lunchTime = Duration.zero;
    lunchTimes
        ?.map((interval) => interval.duration())
        ?.forEach((time) => lunchTime += time);
    return lunchTime;
  }

  void addLunch(Duration duration) {
    DateTime end = DateTime.now();
    DateTime begin = end.subtract(duration);
    lunchTimes.add(DateTimeInterval(begin: begin, end: end));
  }

  void startLunch() {
    lastLunchStartTime = DateTime.now();
  }

  void endLunch() {
    if (lastLunchStartTime != null) {
      DateTime now = DateTime.now();
      lunchTimes.add(DateTimeInterval(begin: lastLunchStartTime, end: now));
      lastLunchStartTime = null;
    }
  }

  Timesheet.fromJson(Map<String, dynamic> json)
      : workDuration = Duration(milliseconds: json['workDuration']),
        arrivalTime = DateTime.tryParse(json['arrivalTime']),
        lunchTimes = List.from(json['lunchTimes']
            .map((intervalJson) => DateTimeInterval.fromJson(intervalJson))),
        lastLunchStartTime =
            DateTime.tryParse(json['lastLunchStartTime'] ?? '');

  Map<String, dynamic> toJson() {
    return {
      'workDuration': workDuration.inMilliseconds,
      'arrivalTime': arrivalTime.toString(),
      'lunchTimes': lunchTimes,
      'lastLunchStartTime': lastLunchStartTime?.toString()
    };
  }
}
