import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:when_home/model.dart';

import 'util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GetIt.I.registerSingleton<SharedPreferences>(
      await SharedPreferences.getInstance());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'When home',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
      home: MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timesheet timesheet;
  bool isWork = true;
  SharedPreferences prefs = GetIt.I.get<SharedPreferences>();

  Timesheet loadTimesheet() {
    DateTime date = DateTime.now();
    DateTime defaultArrivalTime = DateTime(date.year, date.month, date.day);
    String timesheetJson = prefs.getString('timesheet') ??
        '''{
        "workDuration": ${Duration(hours: 8).inMilliseconds},
        "arrivalTime": "${defaultArrivalTime.toString()}",
        "lunchTimes": []
      }''';
    Map timesheetMap = jsonDecode(timesheetJson);
    return Timesheet.fromJson(timesheetMap);
  }

  void saveTimesheet() {
    prefs.setString('timesheet', jsonEncode(timesheet));
  }

  void validateTimesheet(Timesheet timesheet) {
    var now = DateTime.now();
    var departureTime =
        timesheet.arrivalTime.add(timesheet.getTotalLunchTime());
    if (now.difference(timesheet.arrivalTime).inDays > 0 &&
        now.isAfter(departureTime)) {
      timesheet.arrivalTime = now;
      timesheet.lastLunchStartTime = null;
      timesheet.lunchTimes = [];
    }
  }

  Widget getPopupMenuButton() {
    return PopupMenuButton<String>(
        onSelected: (String result) {
          switch (result) {
            case '_PopupMenuItem_SetWorkDayDuration':
              getTimeFromModalBottomSheet(context,
                      initTime: toTimeOfDay(timesheet.workDuration))
                  .then((TimeOfDay time) {
                setState(() {
                  timesheet.workDuration = toDuration(time);
                  saveTimesheet();
                });
              });
              break;
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem(
                  value: '_PopupMenuItem_SetWorkDayDuration',
                  child: Text('Длительность рабочего дня'))
            ]);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle mainTextStyle = Theme.of(context).textTheme.headline;
    timesheet = loadTimesheet();
    validateTimesheet(timesheet);
    String currentState = isWork ? 'На перерыв' : 'К работе';

    DateTime departureDateTime = timesheet.arrivalTime
        .add(timesheet.workDuration)
        .add(timesheet.getTotalLunchTime());
    int dayOverflow =
        departureDateTime.difference(timesheet.arrivalTime).inDays;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          getPopupMenuButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          label: Text(currentState),
          icon: Icon(isWork ? Icons.free_breakfast : Icons.work),
          onPressed: () {
            isWork ? timesheet.startLunch() : timesheet.endLunch();
            saveTimesheet();
            setState(() {
              isWork = !isWork;
            });
          }),
      body: DefaultTextStyle(
        style: mainTextStyle,
        textAlign: TextAlign.center,
        softWrap: true,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Spacer(flex: 5),
              Text('прибытие на работу'),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: mainTextStyle.color))),
                child: GestureDetector(
                  child: Text(
                    formatDateTime(context, timesheet.arrivalTime),
                  ),
                  onTap: () {
                    getTimeFromModalBottomSheet(context,
                            initTime:
                                TimeOfDay.fromDateTime(timesheet.arrivalTime))
                        .then((TimeOfDay time) => setState(() {
                              DateTime date = DateTime.now();
                              DateTime arrivalTime = DateTime(date.year,
                                  date.month, date.day, time.hour, time.minute);
                              timesheet.arrivalTime = arrivalTime;
                              saveTimesheet();
                            }));
                  },
                ),
              ),
              Spacer(),
              Text('перерыв занял'),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: mainTextStyle.color))),
                child: GestureDetector(
                  child: Text(formatDuration(timesheet.getTotalLunchTime())),
                  onLongPress: () async {
                    var startLunchTime = '00:00';
                    var endLunchTime = '00:00';
                    if (timesheet.lunchTimes.length > 0) {
                      if (timesheet.lastLunchStartTime == null) {
                        startLunchTime = formatDateTime(
                            context, timesheet.lunchTimes.last.begin);
                        endLunchTime = formatDateTime(
                            context, timesheet.lunchTimes.last.end);
                      } else {
                        startLunchTime = formatDateTime(
                            context, timesheet.lastLunchStartTime);
                        endLunchTime = '-';
                      }
                    }
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext builder) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text('Время убытия на перерыв: $startLunchTime'),
                              Text('Время прибытия с перерыва: $endLunchTime'),
                            ],
                          );
                        });
                  },
                ),
              ),
              Spacer(flex: 2),
              Text(
                  'можно уйти ${dayOverflow > 0 ? '${'после' * (dayOverflow - 1)}завтра' : ''} в ${formatDateTime(context, departureDateTime)}'),
              Spacer(flex: 5),
            ],
          ),
        ),
      ),
    );
  }
}
