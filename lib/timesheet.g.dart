// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timesheet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Timesheet _$TimesheetFromJson(Map<String, dynamic> json) {
  return Timesheet(
    workDuration: json['workDuration'] == null
        ? null
        : Duration(microseconds: json['workDuration'] as int),
    arrivalTime: json['arrivalTime'] == null
        ? null
        : DateTime.parse(json['arrivalTime'] as String),
    lunchTimes: (json['lunchTimes'] as List)
        ?.map((e) => e == null
            ? null
            : DateTimeInterval.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  )..lastLunchStartTime = json['lastLunchStartTime'] == null
      ? null
      : DateTime.parse(json['lastLunchStartTime'] as String);
}

Map<String, dynamic> _$TimesheetToJson(Timesheet instance) => <String, dynamic>{
      'workDuration': instance.workDuration?.inMicroseconds,
      'arrivalTime': instance.arrivalTime?.toIso8601String(),
      'lunchTimes': instance.lunchTimes,
      'lastLunchStartTime': instance.lastLunchStartTime?.toIso8601String(),
    };
