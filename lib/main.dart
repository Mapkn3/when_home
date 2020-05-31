import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/break.dart';
import 'model/date_time_interval.dart';
import 'model/time_sheet.dart';
import 'util.dart';
import 'widget/text_with_icon.dart';

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
  final textEditingController = TextEditingController();
  Stream<Duration> clock = Stream.empty();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  TimeSheet loadTimeSheet() {
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
    String timeSheetJson = prefs.getString('timesheet') ?? defaultTimeSheet;
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
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem(
                value: '_PopupMenuItem_SetWorkDayDuration',
                child: Text('Длительность рабочего дня'),
              )
            ]);
  }

  Widget buildListTile(int index) {
    Break _break = timeSheet.breaks[index];
    DateTimeInterval interval = _break.interval;
    Widget title = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${timeWithShortDate.format(interval.begin)}'),
        Icon(Icons.remove),
        Text('${timeWithShortDate.format(interval.end)}'),
      ],
    );
    Widget subtitle = Text(
      'Длительность: ${formatFullDuration(interval.duration())}',
      textAlign: TextAlign.center,
    );
    Widget trailing = GestureDetector(
      child: Icon(Icons.info_outline),
      onTap: () {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) {
            textEditingController.text = timeSheet.breaks[index].description;
            return AlertDialog(
              title: Text('Описание'),
              content: TextField(
                controller: textEditingController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              actions: [
                FlatButton(
                  onPressed: () {
                    textEditingController.clear();
                    Navigator.pop(context);
                  },
                  child: Text('Отмена'),
                ),
                FlatButton(
                  onPressed: () {
                    timeSheet.breaks[index].description =
                        textEditingController.text;
                    saveTimeSheet();
                    textEditingController.clear();
                    Navigator.pop(context);
                  },
                  child: Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
    Widget listTile = Card(
      child: ListTile(
        title: title,
        subtitle: subtitle,
        trailing: trailing,
      ),
    );
    return Dismissible(
      key: Key(listTile.toString()),
      child: listTile,
      onDismissed: (direction) => setState(() {
        timeSheet.breaks.remove(_break);
        saveTimeSheet();
      }),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Icon(Icons.delete),
          ),
        ),
      ),
      direction: DismissDirection.endToStart,
    );
  }

  showBreakTimesList() {
    loadTimeSheet();
    Widget descriptionTooltip = TextWithIcon(
      icon: Icon(Icons.info_outline),
      text: Text(' - описание'),
    );

    Widget removeTooltip = TextWithIcon(
      icon: Icon(Icons.arrow_back),
      text: Text(' - удаление'),
    );
    const noData = Center(child: Text('Отсутствует информация по перерывам'));
    Widget content = timeSheet.breaks.isNotEmpty
        ? ListView.builder(
            itemCount: timeSheet.breaks.length,
            itemBuilder: (BuildContext context, int index) =>
                buildListTile(index),
          )
        : noData;
    Widget controlPanel = Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          descriptionTooltip,
          removeTooltip,
          Spacer(),
          IconButton(
            icon: Icon(Icons.alarm_add),
            onPressed: () {},
          ),
        ],
      ),
    );
    double borderRadiusValue = 24.0;
    Widget header = Container(
      constraints: BoxConstraints.tightFor(height: borderRadiusValue),
      child: Center(
        child: Container(
          constraints: BoxConstraints.tight(
            Size(MediaQuery.of(context).size.width / 6, 4.0),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2.0),
            color: Colors.white70,
          ),
        ),
      ),
    );
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(borderRadiusValue),
        ),
      ),
      builder: (BuildContext builder) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            header,
            Container(
              child: content,
              height: getNPartOfScreen(context, 7) * 3,
            ),
            Divider(
              height: 0,
            ),
            controlPanel,
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    TextStyle mainTextStyle = Theme.of(context).textTheme.headline;
    timeSheet = loadTimeSheet();
    validateTimeSheet(timeSheet);
    String currentState = isWork ? 'На перерыв' : 'К работе';

    DateTime departureDateTime = timeSheet.arrivalTime
        .add(timeSheet.workDuration)
        .add(timeSheet.getTotalLunchTime());
    int dayOverflow =
        departureDateTime.difference(timeSheet.arrivalTime).inDays;

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
            if (isWork) {
              clock = Stream.periodic(Duration(seconds: 1), (tick) {
                if (this.timeSheet.lastBreakStartTime != null) {
                  return this
                      .timeSheet
                      .lastBreakStartTime
                      .add(Duration(seconds: tick + 1))
                      .difference(this.timeSheet.lastBreakStartTime);
                } else {
                  return Duration();
                }
              });
            }
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
              textWithAction(
                shortTimeWithShortDate.format(timeSheet.arrivalTime),
                callback: () {
                  getTimeFromModalBottomSheet(context,
                          initTime: timeSheet.arrivalTime)
                      .then((DateTime time) => setState(() {
                            timeSheet.arrivalTime = time;
                            saveTimeSheet();
                          }));
                },
              ),
              Spacer(),
              Text('общее время перерывов'),
              textWithAction(
                formatFullDuration(timeSheet.getTotalLunchTime()),
                callback: showBreakTimesList,
              ),
              StreamBuilder(
                stream: clock,
                builder: (context, snapshot) {
                  String duration = '';
                  if (snapshot.hasData && snapshot.data.inSeconds > 0) {
                    duration = '+ ${formatFullDuration(snapshot.data)}';
                  }
                  return Text(duration);
                },
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
