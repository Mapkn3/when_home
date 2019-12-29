import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

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

  @override
  Widget build(BuildContext context) {
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
      body: DefaultTextStyle(
          style: Theme.of(context).textTheme.display1,
          textAlign: TextAlign.center,
          softWrap: true,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Spacer(flex: 5),
                Text('прибыл на работу'),
                GestureDetector(
                  child: Text(
                    MaterialLocalizations.of(context)
                        .formatTimeOfDay(_time, alwaysUse24HourFormat: true),
                  ),
                  onTap: () {
                    _getTime(_time).then((TimeOfDay time) {
                      setState(() {
                        _time = time;
                      });
                    });
                  },
                ),
                Spacer(),
                Text('обед занял'),
                GestureDetector(
                  child: Text(
                    MaterialLocalizations.of(context)
                        .formatTimeOfDay(_lunch, alwaysUse24HourFormat: true),
                  ),
                  onTap: () {
                    _getTime(_lunch).then((TimeOfDay time) {
                      setState(() {
                        _lunch = time;
                      });
                    });
                  },
                ),
                Spacer(),
                Text(
                    'можно уйти ${dayOverflow > 0 ? '${dayOverflow > 1 ? 'после' : ''}завтра' : ''} в ${MaterialLocalizations.of(context).formatTimeOfDay(departureTime, alwaysUse24HourFormat: true)}'),
                Spacer(flex: 5),
              ],
            ),
          )),
    );
  }
}
