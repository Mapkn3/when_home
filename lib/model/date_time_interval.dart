import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:when_home/util.dart';

part 'date_time_interval.g.dart';

@JsonSerializable()
class DateTimeInterval {
  DateTime begin;
  DateTime end;

  DateTimeInterval({@required this.begin, @required this.end});

  Duration get duration => end.difference(begin);

  factory DateTimeInterval.fromJson(Map<String, dynamic> json) =>
      _$DateTimeIntervalFromJson(json);

  Map<String, dynamic> toJson() => _$DateTimeIntervalToJson(this);

  @override
  String toString() =>
      '${dateWithTime.format(begin)} - ${dateWithTime.format(end)}';
}
