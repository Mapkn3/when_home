import 'package:json_annotation/json_annotation.dart';
import 'package:when_home/date_time_interval.dart';

part 'timesheet.g.dart';

@JsonSerializable()
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

  factory Timesheet.fromJson(Map<String, dynamic> json) =>
      _$TimesheetFromJson(json);

  Map<String, dynamic> toJson() => _$TimesheetToJson(this);
}
