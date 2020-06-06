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

  Duration getTotalBreakDuration() {
    Duration breakTime = Duration.zero;
    breaks
        ?.map((_break) => _break.interval.duration())
        ?.forEach((time) => breakTime += time);
    return breakTime;
  }

  bool isEmptyBreaks() {
    return breaks.isEmpty;
  }

  int countOfBreaks() {
    return breaks.length;
  }

  void removeBreak(Break b) {
    assert(b != null);
    breaks.remove(b);
  }

  void addBreakByDateTimeInterval(DateTimeInterval interval) {
    assert(interval != null);
    breaks.add(Break(interval: interval));
  }

  void addBreakByDuration(Duration duration) {
    assert(duration != null);
    DateTime end = DateTime.now();
    DateTime begin = end.subtract(duration);
    this.addBreakByDateTimeInterval(DateTimeInterval(begin: begin, end: end));
  }

  void startBreak() {
    lastBreakStartTime = DateTime.now();
  }

  void stopBreak() {
    if (lastBreakStartTime != null) {
      DateTime now = DateTime.now();
      breaks ??= new List();
      this.addBreakByDateTimeInterval(
          DateTimeInterval(begin: lastBreakStartTime, end: now));
      lastBreakStartTime = null;
    }
  }

  bool isBreakTime() {
    return lastBreakStartTime != null;
  }

  factory TimeSheet.fromJson(Map<String, dynamic> json) =>
      _$TimeSheetFromJson(json);

  Map<String, dynamic> toJson() => _$TimeSheetToJson(this);
}
