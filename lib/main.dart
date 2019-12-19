import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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
  int _lunch = 0;

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

  @override
  Widget build(BuildContext context) {
    TextStyle _textStyle = Theme.of(context).textTheme.display1;
    TimeOfDay arrivalTime = _time;
    TimeOfDay departureTime = _time.replacing(hour: _time.hour + 8, minute: _time.minute + _lunch);
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
              style: _textStyle,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  MaterialLocalizations.of(context)
                      .formatTimeOfDay(arrivalTime, alwaysUse24HourFormat: true),
                  style: _textStyle,
                ),
                IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: _getTime,
                ),
              ],
            ),
            Text(
              'я потратил на обед',
              style: _textStyle,
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [WhitelistingTextInputFormatter(new RegExp('[0-9]+'))],
              onChanged: (input) => setState(() {
                if (input != null && input.trim() != '') {
                  _lunch = num.tryParse(input);
                }
              }),
            ),
            Text(
              'значит уйду в',
              style: _textStyle,
            ),
            Text(
              MaterialLocalizations.of(context)
                  .formatTimeOfDay(departureTime, alwaysUse24HourFormat: true),
              style: _textStyle,
            ),
          ],
        ),
      ),
    );
  }
}
