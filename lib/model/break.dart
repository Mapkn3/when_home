import 'package:json_annotation/json_annotation.dart';
import 'package:when_home/model/date_time_interval.dart';

part 'break.g.dart';

@JsonSerializable()
class Break {
  DateTimeInterval interval;
  String description = "Test description";

  Break({this.interval});

  factory Break.fromJson(Map<String, dynamic> json) => _$BreakFromJson(json);

  Map<String, dynamic> toJson() => _$BreakToJson(this);
}
