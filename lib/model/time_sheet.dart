import 'package:json_annotation/json_annotation.dart';
import 'package:when_home/model/break.dart';
import 'package:when_home/model/date_time_interval.dart';

part 'time_sheet.g.dart';

@JsonSerializable()
class TimeSheet {
  Duration workDuration;
  DateTime arrivalTime;
  List<Break> breaks;
  DateTime lastBreakStartTime;

  TimeSheet({this.workDuration, this.arrivalTime, this.breaks});

  Duration getTotalLunchTime() {
    Duration lunchTime = Duration.zero;
    breaks
        ?.map((_break) => _break.interval.duration())
        ?.forEach((time) => lunchTime += time);
    return lunchTime;
  }

  void addBreak(Duration duration) {
    DateTime end = DateTime.now();
    DateTime begin = end.subtract(duration);
    breaks.add(Break(
      interval: DateTimeInterval(begin: begin, end: end),
    ));
  }

  void startBreak() {
    lastBreakStartTime = DateTime.now();
  }

  void endBreak() {
    if (lastBreakStartTime != null) {
      DateTime now = DateTime.now();
      breaks ??= new List();
      breaks.add(Break(
        interval: DateTimeInterval(begin: lastBreakStartTime, end: now),
      ));
      lastBreakStartTime = null;
    }
  }

  factory TimeSheet.fromJson(Map<String, dynamic> json) =>
      _$TimeSheetFromJson(json);

  Map<String, dynamic> toJson() => _$TimeSheetToJson(this);
}