// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'date_time_interval.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DateTimeInterval _$DateTimeIntervalFromJson(Map<String, dynamic> json) {
  return DateTimeInterval(
    begin:
        json['begin'] == null ? null : DateTime.parse(json['begin'] as String),
    end: json['end'] == null ? null : DateTime.parse(json['end'] as String),
  );
}

Map<String, dynamic> _$DateTimeIntervalToJson(DateTimeInterval instance) =>
    <String, dynamic>{
      'begin': instance.begin?.toIso8601String(),
      'end': instance.end?.toIso8601String(),
    };
