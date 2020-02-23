class DateTimeInterval {
  DateTime begin;
  DateTime end;

  DateTimeInterval({this.begin, this.end});

  DateTimeInterval.fromJson(Map<String, dynamic> json)
      : begin = DateTime.tryParse(json['begin']),
        end = DateTime.tryParse(json['end']);

  Map<String, dynamic> toJson() =>
      {'begin': begin.toString(), 'end': end.toString()};
}
