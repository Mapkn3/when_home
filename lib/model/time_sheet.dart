import 'package:json_annotation/json_annotation.dart';
import 'package:when_home/model/break.dart';
import 'package:when_home/model/date_time_interval.dart';
import 'package:when_home/util.dart';

part 'time_sheet.g.dart';

@JsonSerializable()
class TimeSheet {
  Duration workDuration;
  DateTime arrivalTime;
  List<Break> breaks;
  DateTime lastBreakStartTime;

  TimeSheet({this.workDuration, this.arrivalTime, this.breaks});

  Duration get totalBreakDuration {
    Duration breakTime = Duration.zero;
    breaks
        ?.map((_break) => _break.interval.duration)
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
    DateTimeInterval currentInterval;
    if (breaks.isEmpty) {
      breaks.add(Break(interval: interval));
    } else {
      for (int i = 0; i < breaks.length; i++) {
        currentInterval = breaks[i].interval;
        bool beginIsBeforeBegin =
            interval.begin.isBefore(currentInterval.begin);
        bool endIsBeforeBegin = interval.end.isBefore(currentInterval.begin);
        bool beginIsAfterEnd = interval.begin.isAfter(currentInterval.end);
        bool endIsAfterEnd = interval.end.isAfter(currentInterval.end);
        if (beginIsBeforeBegin && endIsBeforeBegin) {
          breaks.insert(i, Break(interval: interval));
          break;
        }
        if (beginIsBeforeBegin && !endIsBeforeBegin) {
          currentInterval.begin = interval.begin;
        }
        if (!beginIsAfterEnd && endIsAfterEnd) {
          currentInterval.end = interval.end;
        }
      }
      if (interval.begin.isAfter(breaks.last.interval.end)) {
        breaks.add(Break(interval: interval));
      }
    }
    int i = 1;
    Break prev;
    Break current;
    while (i < breaks.length) {
      prev = breaks[i - 1];
      current = breaks[i];
      if (prev.interval.end.isBefore(current.interval.begin)) {
        i++;
      } else {
        prev.interval.end = current.interval.end;
        prev.description =
            mergeString(prev.description, current.description, '\n');
        breaks.removeAt(i);
      }
    }
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
      breaks ??= [];
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
