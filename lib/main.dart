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
      themeMode: ThemeMode.dark,
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

  void loadTimesheet() {
    DateTime date = DateTime.now();
    DateTime defaultArrivalTime = DateTime(date.year, date.month, date.day);
    String timesheetJson = prefs.getString('timesheet') ??
        '''{
        "workDuration": ${Duration(hours: 8).inMilliseconds},
        "arrivalTime": "${defaultArrivalTime.toString()}",
        "lunchTimes": []
      }''';
    Map timesheetMap = jsonDecode(timesheetJson);
    timesheet = Timesheet.fromJson(timesheetMap);
  }

  void saveTimesheet() {
    prefs.setString('timesheet', jsonEncode(timesheet));
  }

  @override
  Widget build(BuildContext context) {
    TextStyle mainTextStyle = Theme.of(context).textTheme.display1;
    TextStyle buttonTextStyle =
        Theme.of(context).textTheme.button.copyWith(fontSize: 16);
    loadTimesheet();

    DateTime departureDateTime =
        timesheet.arrivalTime.add(timesheet.getTotalLunchTime());
    int dayOverflow =
        departureDateTime.difference(timesheet.arrivalTime).inDays;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          PopupMenuButton<String>(
              onSelected: (String result) {
                switch (result) {
                  case '_PopupMenuItem_SetWorkDayDuration':
                    getTimeFromModalBottomSheet(context,
                            initTime: TimeOfDay(
                                hour: timesheet.workDuration.inHours,
                                minute: timesheet.workDuration.inMinutes))
                        .then((TimeOfDay time) {
                      setState(() {
                        timesheet.workDuration =
                            Duration(hours: time.hour, minutes: time.minute);
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
                  ]),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          label: Text(isWork ? 'На перерыв' : 'К работе'),
          icon: Icon(isWork ? Icons.free_breakfast : Icons.work),
          onPressed: () async {
            if (isWork) {
              timesheet.startLunch();
            } else {
              timesheet.endLunch();
            }
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
                      border: Border(
                          bottom: BorderSide(color: mainTextStyle.color))),
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
                                DateTime arrivalTime = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    time.hour,
                                    time.minute);
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
                      border: Border(
                          bottom: BorderSide(color: mainTextStyle.color))),
                  child: GestureDetector(
                    child: Text(formatDuration(timesheet.getTotalLunchTime())),
                    onTap: () {
                      getTimeFromModalBottomSheet(context,
                              initTime: TimeOfDay(hour: 0, minute: 0))
                          .then((TimeOfDay time) {
                        setState(() {
                          timesheet.addLunch(
                              Duration(hours: time.hour, minutes: time.minute));
                          saveTimesheet();
                        });
                      });
                    },
                    onLongPress: () async {
                      var startLunchTime = '00:00';
                      var endLunchTime = '00:00';
                      if (timesheet.lunchTimes.length > 0) {
                        if (timesheet.lastLunchStartTime != null) {
                          startLunchTime =
                              timesheet.lunchTimes.last.item1.toString();
                          endLunchTime =
                              timesheet.lunchTimes.last.item2.toString();
                        } else {
                          startLunchTime =
                              timesheet.lastLunchStartTime.toString();
                          endLunchTime = '-';
                        }
                      }
                      showModalBottomSheet<String>(
                          context: context,
                          builder: (BuildContext builder) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                        child: RaisedButton(
                                            child: Text('На перерыв',
                                                textAlign: TextAlign.center,
                                                style: buttonTextStyle),
                                            onPressed: () =>
                                                setState(() {
                                                  timesheet.startLunch();
                                                  saveTimesheet();
                                                }))),
                                    Expanded(
                                        child: RaisedButton(
                                            child: Text('К работе',
                                                textAlign: TextAlign.center,
                                                style: buttonTextStyle),
                                            onPressed: () =>
                                                setState(() {
                                                  timesheet.endLunch();
                                                  saveTimesheet();
                                                }))),
                                  ],
                                ),
                                Text(
                                    'Время убытия на перерыв: $startLunchTime'),
                                Text(
                                    'Время прибытия с перерыва: $endLunchTime'),
                              ],
                            );
                          });
                    },
                  ),
                ),
                Spacer(flex: 2),
                Text('text' * -1),
                Text(
                    'можно уйти ${dayOverflow > 0 ? '${'после' * (dayOverflow - 1)}завтра' : ''} в ${formatDateTime(context, departureDateTime)}'),
                Spacer(flex: 5),
              ],
            ),
          )),
    );
  }
}
