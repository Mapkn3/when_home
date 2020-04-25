// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_sheet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeSheet _$TimeSheetFromJson(Map<String, dynamic> json) {
  return TimeSheet(
    workDuration: json['workDuration'] == null
        ? null
        : Duration(microseconds: json['workDuration'] as int),
    arrivalTime: json['arrivalTime'] == null
        ? null
        : DateTime.parse(json['arrivalTime'] as String),
    breaks: (json['breaks'] as List)
        ?.map(
            (e) => e == null ? null : Break.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  )..lastBreakStartTime = json['lastBreakStartTime'] == null
      ? null
      : DateTime.parse(json['lastBreakStartTime'] as String);
}

Map<String, dynamic> _$TimeSheetToJson(TimeSheet instance) => <String, dynamic>{
      'workDuration': instance.workDuration?.inMicroseconds,
      'arrivalTime': instance.arrivalTime?.toIso8601String(),
      'breaks': instance.breaks,
      'lastBreakStartTime': instance.lastBreakStartTime?.toIso8601String(),
    };
