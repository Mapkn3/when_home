import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:when_home/model/break.dart';
import 'package:when_home/model/date_time_interval.dart';
import 'package:when_home/model/time_sheet.dart';

class TimeSheetService {
  SharedPreferences _prefs;
  TimeSheet _timeSheet;

  TimeSheetService() : _prefs = GetIt.I.get<SharedPreferences>();

  void saveTimeSheet() {
    _prefs.setString('timeSheet', jsonEncode(_timeSheet));
  }

  void loadTimeSheet() {
    DateTime date = DateTime.now();
    DateTime defaultArrivalTime = DateTime(date.year, date.month, date.day);
    Duration defaultWorkDuration = Duration(hours: 8);
    String defaultTimeSheet = '''
    {
        "workDuration": ${defaultWorkDuration.inMicroseconds},
        "arrivalTime": "${defaultArrivalTime.toIso8601String()}",
        "breaks": []
    }
    ''';
    String timeSheetJson = _prefs.getString('timeSheet') ?? defaultTimeSheet;
    Map timeSheetMap = jsonDecode(timeSheetJson);
    _timeSheet = TimeSheet.fromJson(timeSheetMap);
    prepareTimeSheet();
  }

  void prepareTimeSheet() {
    DateTime now = DateTime.now();
    Duration totalBreakTime = _timeSheet.totalBreakDuration;
    DateTime departureTime = _timeSheet.arrivalTime.add(totalBreakTime);
    if (now.difference(_timeSheet.arrivalTime).inDays > 0 &&
        now.isAfter(departureTime)) {
      _timeSheet.arrivalTime = now;
      _timeSheet.lastBreakStartTime = null;
      _timeSheet.breaks = [];
    }
  }

  Duration get workDuration => _timeSheet.workDuration;

  set workDuration(Duration workDuration) {
    _timeSheet.workDuration = workDuration;
    saveTimeSheet();
  }

  Break getBreakByIndex(int index) {
    assert(index >= 0 && index < _timeSheet.breaks.length);
    return _timeSheet.breaks[index];
  }

  String getBreakDescriptionByIndex(int index) {
    assert(index >= 0 && index < _timeSheet.breaks.length);
    return _timeSheet.breaks[index].description;
  }

  void setBreakDescriptionByIndex(int index, String description) {
    assert(index >= 0 && index < _timeSheet.breaks.length);
    _timeSheet.breaks[index].description = description;
  }

  void removeBreak(Break b) {
    _timeSheet.removeBreak(b);
  }

  bool isEmptyBreaks() {
    return _timeSheet.isEmptyBreaks();
  }

  int countOfBreaks() {
    return _timeSheet.countOfBreaks();
  }

  void addBreakByDateTimeInterval(DateTimeInterval interval) {
    _timeSheet.addBreakByDateTimeInterval(interval);
  }

  DateTime getArrivalTime() {
    return _timeSheet.arrivalTime;
  }

  void setArrivalTime(DateTime arrivalTime) {
    _timeSheet.arrivalTime = arrivalTime;
  }

  DateTime calculateDepartureDateTime() {
    return _timeSheet.arrivalTime
        .add(_timeSheet.workDuration)
        .add(_timeSheet.totalBreakDuration);
  }

  bool isBreakTime() {
    return _timeSheet.isBreakTime();
  }

  void startBreak() {
    _timeSheet.startBreak();
  }

  void stopBreak() {
    _timeSheet.stopBreak();
  }

  Duration getTotalBreakDuration() {
    return _timeSheet.totalBreakDuration;
  }
}
