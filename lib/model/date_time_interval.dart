import 'package:json_annotation/json_annotation.dart';
import 'package:when_home/util.dart';

part 'date_time_interval.g.dart';

@JsonSerializable()
class DateTimeInterval {
  DateTime begin;
  DateTime end;

  DateTimeInterval({this.begin, this.end});

  Duration duration() => end.difference(begin);

  factory DateTimeInterval.fromJson(Map<String, dynamic> json) =>
      _$DateTimeIntervalFromJson(json);

  Map<String, dynamic> toJson() => _$DateTimeIntervalToJson(this);

  @override
  String toString() =>
      '${dateWithTime.format(begin)} - ${dateWithTime.format(begin)}';
}
