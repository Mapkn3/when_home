import 'package:json_annotation/json_annotation.dart';
import 'package:tuple/tuple.dart';

@JsonSerializable()
class Timesheet {
  Duration workDuration;
  DateTime arrivalTime;
  List<Tuple2<DateTime, DateTime>> lunchTimes;
  DateTime lastLunchStartTime;

  Timesheet({this.workDuration, this.arrivalTime, this.lunchTimes});

  Duration getTotalLunchTime() {
    Duration lunchTime = Duration.zero;
    lunchTimes
        .map((pair) => pair.item2.difference(pair.item1))
        .forEach((time) => lunchTime += time);
    return lunchTime;
  }

  void addLunch(Duration duration) {
    DateTime end = DateTime.now();
    DateTime begin = end.subtract(duration);
    lunchTimes.add(Tuple2(begin, end));
  }

  void startLunch() {
    lastLunchStartTime = DateTime.now();
  }

  void endLunch() {
    if (lastLunchStartTime != null) {
      DateTime now = DateTime.now();
      lunchTimes.add(Tuple2(lastLunchStartTime, now));
      lastLunchStartTime = null;
    }
  }

  factory Timesheet.fromJson(Map<String, dynamic> json) {
    List<Tuple2<DateTime, DateTime>> lunches = [];
    new List<String>.from(json['lunchTimes']).forEach((str) {
      List<DateTime> times = str.split('~')
          .map((s) => DateTime.tryParse(s))
          .toList(growable: false);
      lunches.add(new Tuple2<DateTime, DateTime>(times[0], times[1]));
    });
    Timesheet timesheet = Timesheet(
        workDuration: Duration(milliseconds: json['workDuration']),
        arrivalTime: DateTime.tryParse(json['arrivalTime']),
        lunchTimes: lunches
    );
    if (json['lastLunchStartTime'] != null) {
      timesheet.lastLunchStartTime =
          DateTime.tryParse(json['lastLunchStartTime']);
    }
    return timesheet;
  }

  Map<String, dynamic> toJson() {
    List<String> lunchTimeList = lunchTimes
        .map((tuple) => '${tuple.item1.toString()}~${tuple.item2.toString()}')
        .toList();
    return {
      'workDuration': workDuration.inMilliseconds,
      'arrivalTime': arrivalTime.toString(),
      'lunchTimes': lunchTimeList,
      'lastLunchStartTime': lastLunchStartTime?.toString()
    };
  }
}
