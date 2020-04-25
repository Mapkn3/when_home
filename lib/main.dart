import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:when_home/model/break.dart';
import 'package:when_home/model/date_time_interval.dart';
import 'package:when_home/model/time_sheet.dart';

import 'util.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  GetIt.I.registerSingleton<SharedPreferences>(sharedPreferences);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'When home',
      home: TimesScreen(title: 'Когда домой?'),
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
    );
  }
}

class TimesScreen extends StatefulWidget {
  TimesScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _TimesScreenState createState() => _TimesScreenState();
}

class _TimesScreenState extends State<TimesScreen> {
  TimeSheet timeSheet;
  bool isWork = true;
  SharedPreferences prefs = GetIt.I.get<SharedPreferences>();

  TimeSheet loadTimeSheet() {
    DateTime date = DateTime.now();
    DateTime defaultArrivalTime = DateTime(date.year, date.month, date.day);
    String timeSheetJson = prefs.getString('timesheet') ??
        '''{
        "workDuration": ${Duration(hours: 8).inMilliseconds},
        "arrivalTime": "${defaultArrivalTime.toString()}",
        "breaks": []
      }''';
    Map timeSheetMap = jsonDecode(timeSheetJson);
    return TimeSheet.fromJson(timeSheetMap);
  }

  void saveTimeSheet() {
    prefs.setString('timesheet', jsonEncode(timeSheet));
  }

  void validateTimeSheet(TimeSheet timeSheet) {
    var now = DateTime.now();
    var departureTime =
        timeSheet.arrivalTime.add(timeSheet.getTotalLunchTime());
    if (now.difference(timeSheet.arrivalTime).inDays > 0 &&
        now.isAfter(departureTime)) {
      timeSheet.arrivalTime = now;
      timeSheet.lastBreakStartTime = null;
      timeSheet.breaks = [];
    }
  }

  Widget getPopupMenuButton() {
    return PopupMenuButton<String>(
        onSelected: (String result) {
          switch (result) {
            case '_PopupMenuItem_SetWorkDayDuration':
              getTimeFromModalBottomSheet(context,
                  initTime: toDateTime(timeSheet.workDuration))
                  .then((DateTime time) => setState(() {
                timeSheet.workDuration = toDuration(time);
                saveTimeSheet();
              }));
              break;
          }
        },
        itemBuilder: (BuildContext context) =>
        <PopupMenuEntry<String>>[
          const PopupMenuItem(
              value: '_PopupMenuItem_SetWorkDayDuration',
              child: Text('Длительность рабочего дня'))
        ]);
  }

  Widget buildListTile(Break _break, int index) {
    DateTimeInterval interval = _break.interval;
    Widget title = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
            child: Container(
              child: Text(
                '${timeWithShortDate.format(interval.begin)}',
                textAlign: TextAlign.center,
              ),
            ),
            flex: 2),
        Expanded(
          child: Container(
            alignment: Alignment.center,
            child: Text(
              '-',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
            child: Container(
              child: Text(
                '${timeWithShortDate.format(interval.end)}',
                textAlign: TextAlign.center,
              ),
            ),
            flex: 2),
      ],
    );
    Widget subtitle = Container(
      child: Text(
        'Длительность: ${formatFullDuration(interval.duration())}',
        textAlign: TextAlign.center,
      ),
    );
    Widget trailing = GestureDetector(
      child: Icon(Icons.info_outline),
      onTap: () =>
      {
        showDialog(
          context: context,
          builder: (_) =>
              AlertDialog(
                title: Text('Break Description'),
                content: Text(_break.description),
              ),
        )
        /*showModalBottomSheet(
          context: context,
          builder: (BuildContext builder) {
            return Container(
              height: getNPartOfScreen(context, 7),
              child: Center(
                child: Text(_break.description),
              ),
            );
          },
        ),*/
      },
    );
    Widget listTile = ListTile(
      title: title,
      subtitle: subtitle,
      trailing: trailing,
    );
    return Dismissible(
      key: Key(listTile.toString()),
      child: listTile,
      onDismissed: (direction) =>
          setState(() {
            timeSheet.breaks.removeAt(index);
            saveTimeSheet();
          }),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Icon(Icons.delete),
        ),
      ),
      direction: DismissDirection.endToStart,
    );
  }

  showLunchTimesList() {
    const noData = Center(child: Text('Отсутствует информация по перерывам'));
    Widget content = noData;
    if (timeSheet.breaks != null) {
      final Iterable<Widget> items = timeSheet.breaks
          .asMap()
          .entries
          .map((var entry) => buildListTile(entry.value, entry.key));
      final List<Widget> divided =
      ListTile.divideTiles(context: context, tiles: items).toList();
      final list = ListView(
        children: divided,
      );
      content = list;
    }
    Widget info = dividerBorder(
      context,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(flex: 2),
          Icon(Icons.info_outline),
          Text(' - описание'),
          Spacer(),
          Icon(Icons.arrow_back),
          Text(' - удаление'),
          Spacer(flex: 2),
        ],
      ),
    );
    Widget lastBreakStartAt = Row();
    if (timeSheet.lastBreakStartTime != null) {
      var startTime = timeWithShortDate.format(timeSheet.lastBreakStartTime);
      lastBreakStartAt = dividerBorder(
        context,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Время начала перерыва: $startTime'),
          ],
        ),
      );
    }
    showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              info,
              lastBreakStartAt,
              Container(
                child: content,
                height: getNPartOfScreen(context, 7) * 3,
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle mainTextStyle = Theme
        .of(context)
        .textTheme
        .headline;
    timeSheet = loadTimeSheet();
    validateTimeSheet(timeSheet);
    String currentState = isWork ? 'На перерыв' : 'К работе';

    DateTime departureDateTime = timeSheet.arrivalTime
        .add(timeSheet.workDuration)
        .add(timeSheet.getTotalLunchTime());
    int dayOverflow =
        departureDateTime
            .difference(timeSheet.arrivalTime)
            .inDays;

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
            isWork ? timeSheet.startBreak() : timeSheet.endBreak();
            saveTimeSheet();
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
              underlineWidget(
                context,
                child: GestureDetector(
                  child: Text(
                    shortTimeWithShortDate.format(timeSheet.arrivalTime),
                  ),
                  onTap: () {
                    getTimeFromModalBottomSheet(context,
                        initTime: timeSheet.arrivalTime)
                        .then((DateTime time) => setState(() {
                      timeSheet.arrivalTime = time;
                      saveTimeSheet();
                    }));
                  },
                ),
              ),
              Spacer(),
              Text('перерыв занял'),
              underlineWidget(
                context,
                child: GestureDetector(
                  child:
                  Text(formatFullDuration(timeSheet.getTotalLunchTime())),
                  onLongPress: showLunchTimesList,
                ),
              ),
              Spacer(flex: 2),
              Text(
                  'можно уйти ${dayOverflow > 0 ? '${'после' * (dayOverflow - 1)}завтра' : ''} в ${shortTimeWithShortDate.format(departureDateTime)}'),
              Spacer(flex: 5),
            ],
          ),
        ),
      ),
    );
  }
}
