// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'break.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Break _$BreakFromJson(Map<String, dynamic> json) {
  return Break(
    interval: json['interval'] == null
        ? null
        : DateTimeInterval.fromJson(json['interval'] as Map<String, dynamic>),
  )..description = json['description'] as String;
}

Map<String, dynamic> _$BreakToJson(Break instance) => <String, dynamic>{
      'interval': instance.interval,
      'description': instance.description,
    };
