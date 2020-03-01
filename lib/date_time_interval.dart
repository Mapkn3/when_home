import 'util.dart';

class DateTimeInterval {
  DateTime begin;
  DateTime end;

  DateTimeInterval({this.begin, this.end});

  Duration duration() => end.difference(begin);

  DateTimeInterval.fromJson(Map<String, dynamic> json)
      : begin = DateTime.tryParse(json['begin']),
        end = DateTime.tryParse(json['end']);

  Map<String, dynamic> toJson() =>
      {'begin': begin.toString(), 'end': end.toString()};

  @override
  String toString() => '${getFullDateTime(begin)} - ${getFullDateTime(begin)}';
}
