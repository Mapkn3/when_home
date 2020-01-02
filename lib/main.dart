import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

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
  TimeOfDay _time = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _lunch = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _workDayDuration = TimeOfDay(hour: 8, minute: 0);

  String formatTimeOfDay(BuildContext context, TimeOfDay time) {
    return MaterialLocalizations.of(context)
        .formatTimeOfDay(time, alwaysUse24HourFormat: true);
  }

  Future<TimeOfDay> _getTime(TimeOfDay initTime) async {
    TimeOfDay time = initTime;
    String result = await showModalBottomSheet<String>(
        context: context,
        builder: (BuildContext builder) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 1.0, horizontal: 4.0),
                          child: OutlineButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.pop(context, '_getTime_cancel');
                              }))),
                  Expanded(
                      child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 1.0, horizontal: 4.0),
                          child: OutlineButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.pop(context, '_getTime_ok');
                              })))
                ],
              ),
              Container(
                height: MediaQuery.of(context).copyWith().size.height / 4,
                child: CupertinoDatePicker(
                  initialDateTime:
                      DateTime(1969, 1, 1, initTime.hour, initTime.minute),
                  onDateTimeChanged: (DateTime value) {
                    time = TimeOfDay.fromDateTime(value);
                  },
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                ),
              )
            ],
          );
        });
    switch (result) {
      case '_getTime_ok':
        {
          return time;
        }
      case '_getTime_cancel':
      default:
        {
          return initTime;
        }
    }
  }

  Future<bool> checkIsLunchStartToday() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime startLunchTime =
        DateTime.tryParse(prefs.getString('startLunchTime'));
    DateTime now = DateTime.now();
    return now.year == startLunchTime.year &&
        now.month == startLunchTime.month &&
        now.day == startLunchTime.day;
  }

  void updateLunchTimeIfPossible() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime startLunchTime =
        DateTime.tryParse(prefs.getString('startLunchTime'));
    DateTime endLunchTime = DateTime.tryParse(prefs.getString('endLunchTime'));
    if (startLunchTime != null &&
        endLunchTime != null &&
        startLunchTime.isBefore(endLunchTime)) {
      Duration lunchTime = endLunchTime.difference(startLunchTime);
      if (lunchTime.inDays == 0) {
        int lunchHour = lunchTime.inHours;
        int lunchMinute = lunchTime.inMinutes % 60;
        setState(() {
          _lunch = TimeOfDay(hour: lunchHour, minute: lunchMinute);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    checkIsLunchStartToday().then((bool isToday) {
      if (isToday) {
        updateLunchTimeIfPossible();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle mainTextStyle = Theme.of(context).textTheme.display1;
    TextStyle buttonTextStyle =
        Theme.of(context).textTheme.button.copyWith(fontSize: 16);
    int departureHour = _time.hour + _lunch.hour + _workDayDuration.hour;
    int departureMinute =
        _time.minute + _lunch.minute + _workDayDuration.minute;
    int dayOverflow = departureHour ~/ 24;
    departureHour += departureMinute ~/ 60;
    departureMinute = departureMinute % 60;
    departureHour = departureHour % 24;
    TimeOfDay departureTime =
        TimeOfDay(hour: departureHour, minute: departureMinute);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          PopupMenuButton<String>(
              onSelected: (String result) {
                switch (result) {
                  case '_PopupMenuItem_SetWorkDayDuration':
                    _getTime(_workDayDuration).then((TimeOfDay time) {
                      setState(() {
                        _workDayDuration = time;
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
      body: DefaultTextStyle(
          style: mainTextStyle,
          textAlign: TextAlign.center,
          softWrap: true,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Spacer(flex: 5),
                Text('прибыл на работу'),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: mainTextStyle.color))),
                  child: GestureDetector(
                    child: Text(
                      formatTimeOfDay(context, _time),
                    ),
                    onTap: () {
                      _getTime(_time).then((TimeOfDay time) {
                        setState(() {
                          _time = time;
                        });
                      });
                    },
                  ),
                ),
                Spacer(),
                Text('обед занял'),
                /*Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: mainTextStyle.color))),
                  child: GestureDetector(
                    child: Text(formatTimeOfDay(context, _lunch)),
                    onTap: () {
                      _getTime(_lunch).then((TimeOfDay time) {
                        setState(() {
                          _lunch = time;
                        });
                      });
                    },
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).copyWith().size.width * 0.75,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                            child: OutlineButton(
                                child: Text('Ушёл на обед',
                                    textAlign: TextAlign.center,
                                    style: buttonTextStyle),
                                onPressed: () async {
                                  DateTime startLunchTime = DateTime.now();
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setString('startLunchTime',
                                      startLunchTime.toString());
                                  updateLunchTimeIfPossible();
                                })),
                        Expanded(
                            child: OutlineButton(
                                child: Text('Пришёл с обеда',
                                    textAlign: TextAlign.center,
                                    style: buttonTextStyle),
                                onPressed: () async {
                                  DateTime endLunchTime = DateTime.now();
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString(
                                      'endLunchTime', endLunchTime.toString());
                                  updateLunchTimeIfPossible();
                                })),
                    ],
                  ),
                ),*/
                Container(
                    width: MediaQuery
                        .of(context)
                        .copyWith()
                        .size
                        .width * 0.9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                            child: OutlineButton(
                                child: Text('Ушёл на обед',
                                    textAlign: TextAlign.center,
                                    style: buttonTextStyle),
                                onPressed: () async {
                                  DateTime startLunchTime = DateTime.now();
                                  SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                                  prefs.setString('startLunchTime',
                                      startLunchTime.toString());
                                  updateLunchTimeIfPossible();
                                })),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: mainTextStyle.color))),
                            child: GestureDetector(
                              child: Text(formatTimeOfDay(context, _lunch)),
                              onTap: () {
                                _getTime(_lunch).then((TimeOfDay time) {
                                  setState(() {
                                    _lunch = time;
                                  });
                                });
                              },
                            ),
                          ),
                        ),
                        Expanded(
                            child: OutlineButton(
                                child: Text('Пришёл с обеда',
                                    textAlign: TextAlign.center,
                                    style: buttonTextStyle),
                                onPressed: () async {
                                  DateTime endLunchTime = DateTime.now();
                                  SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                                  await prefs.setString(
                                      'endLunchTime', endLunchTime.toString());
                                  updateLunchTimeIfPossible();
                                })),
                      ],
                    )),
                Spacer(flex: 2),
                Text(
                    'можно уйти ${dayOverflow > 0 ? '${'после' *
                        (dayOverflow - 1)}завтра' : ''} в ${formatTimeOfDay(
                        context, departureTime)}'),
                Spacer(flex: 5),
              ],
            ),
          )),
    );
  }
}
