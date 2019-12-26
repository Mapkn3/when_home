import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'When home',
      theme: ThemeData.dark(),
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

  void _getTime() async {
    TimeOfDay selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },
    );
    setState(() {
      if (selectedTime != null) {
        _time = selectedTime;
      }
    });
  }

  Widget _lunchTimePicker() {
    return CupertinoDatePicker(
      initialDateTime: DateTime(1969, 1, 1, _lunch.hour, _lunch.minute),
      onDateTimeChanged: (DateTime value) {
        setState(() {
          _lunch = TimeOfDay.fromDateTime(value);
        });
      },
      use24hFormat: true,
      mode: CupertinoDatePickerMode.time,
      backgroundColor: CupertinoDynamicColor.resolve(
          CupertinoColors.systemBackground, context),
    );
  }

  @override
  Widget build(BuildContext context) {
    TimeOfDay arrivalTime = _time;
    int departureHour = _time.hour + _lunch.hour + 8;
    int departureMinute = _time.minute + _lunch.minute;
    int dayOverflow = departureHour ~/ 24;
    departureHour += departureMinute ~/ 60;
    departureMinute = departureMinute % 60;
    departureHour = departureHour % 24;
    TimeOfDay departureTime =
        _time.replacing(hour: departureHour, minute: departureMinute);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'я пришёл на работу в',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  MaterialLocalizations.of(context).formatTimeOfDay(arrivalTime,
                      alwaysUse24HourFormat: true),
                ),
                IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: _getTime,
                ),
              ],
            ),
            Text(
              'я потратил на обед',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  MaterialLocalizations.of(context).formatTimeOfDay(
                      TimeOfDay(hour: _lunch.hour, minute: _lunch.minute),
                      alwaysUse24HourFormat: true),
                ),
                IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: () {
                    showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext builder) {
                          return Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  CupertinoButton(
                                      child: Text('Cancel'), onPressed: null),
                                  CupertinoButton(
                                      child: Text('OK'), onPressed: null)
                                ],
                              ),
                              Container(
                                height: MediaQuery.of(context)
                                        .copyWith()
                                        .size
                                        .height /
                                    4,
                                child: _lunchTimePicker(),
                              ),
                            ],
                          );
                        });
                  },
                ),
              ],
            ),
            Text(
              'значит уйду ${dayOverflow > 0 ? '${dayOverflow > 1 ? 'после' : ''}завтра' : ''} в',
              softWrap: true,
            ),
            Text(
              MaterialLocalizations.of(context)
                  .formatTimeOfDay(departureTime, alwaysUse24HourFormat: true),
            ),
          ],
        ),
      ),
    );
  }
}
