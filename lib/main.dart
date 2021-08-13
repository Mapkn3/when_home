import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:when_home/service/time_sheet_service.dart';

import 'model/break.dart';
import 'model/date_time_interval.dart';
import 'util.dart';
import 'widget/text_with_icon.dart';
import 'widget/widget_with_action.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  GetIt.I.registerSingleton<SharedPreferences>(sharedPreferences);
  TimeSheetService timeSheetService = new TimeSheetService();
  GetIt.I.registerSingleton<TimeSheetService>(timeSheetService);

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
  bool isWork = true;
  TimeSheetService _timeSheetService = GetIt.I.get<TimeSheetService>();
  final textEditingController = TextEditingController();
  Stream<Duration> clock = Stream.empty();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  Widget getPopupMenuButton() {
    return PopupMenuButton<String>(
        onSelected: (String result) {
          switch (result) {
            case '_PopupMenuItem_SetWorkDayDuration':
              getTimeFromModalBottomSheet(context,
                      initTime: toDateTime(_timeSheetService.workDuration))
                  .then((DateTime time) => setState(() {
                        _timeSheetService.workDuration = toDuration(time);
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

  void refreshBreaksModalBottomSheet() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    showBreakTimesList();
  }

  Widget buildListTile(int index) {
    Break _break = _timeSheetService.getBreakByIndex(index);
    DateTimeInterval interval = _break.interval;
    Widget description = _break.description.isEmpty
        ? Container()
        : Flex(
            direction: Axis.vertical,
            children: [
              Text(
                _break.description,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Divider(),
            ],
          );
    Widget timeInterval = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${timeWithShortDate.format(interval.begin)}'),
        Icon(Icons.remove),
        Text('${timeWithShortDate.format(interval.end)}'),
      ],
    );
    Widget title = Column(
      children: <Widget>[
        description,
        timeInterval,
      ],
    );
    Widget subtitle = Text(
      'Длительность: ${formatFullDuration(interval.duration)}',
      textAlign: TextAlign.center,
    );
    Widget trailing = GestureDetector(
      child: Icon(Icons.info_outline),
      onTap: () {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            textEditingController.text =
                _timeSheetService.getBreakDescriptionByIndex(index);
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              title: Text('Описание'),
              content: TextField(
                controller: textEditingController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(border: UnderlineInputBorder()),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    textEditingController.clear();
                    Navigator.pop(context);
                  },
                  child: Text('Отмена'),
                ),
                TextButton(
                  onPressed: () {
                    _timeSheetService.setBreakDescriptionByIndex(
                        index, textEditingController.text);
                    _timeSheetService.saveTimeSheet();
                    textEditingController.clear();
                    Navigator.pop(context);
                    refreshBreaksModalBottomSheet();
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
      margin: EdgeInsets.all(2.0),
      child: ListTile(
        title: title,
        subtitle: subtitle,
        trailing: trailing,
      ),
    );
    return Dismissible(
      key: Key(listTile.toString()),
      child: listTile,
      onDismissed: (direction) => _timeSheetService.removeBreak(_break),
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

  showBreakTimesList() async {
    _timeSheetService.loadTimeSheet();
    Widget descriptionTooltip = TextWithIcon(
      icon: Icon(Icons.info_outline),
      text: Text('- описание'),
    );

    Widget removeTooltip = TextWithIcon(
      icon: Icon(Icons.arrow_back),
      text: Text('- удаление'),
    );
    const noData = Center(child: Text('Отсутствует информация по перерывам'));
    Widget content = _timeSheetService.isEmptyBreaks()
        ? noData
        : ListView.builder(
            itemCount: _timeSheetService.countOfBreaks(),
            itemBuilder: (BuildContext context, int index) =>
                buildListTile(index),
          );
    Widget controlPanel = Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          descriptionTooltip,
          removeTooltip,
          Spacer(),
          IconButton(
            icon: Icon(Icons.alarm_add),
            onPressed: () {
              getDateTimeInterval(context).then(
                (interval) {
                  if (interval != null) {
                    setState(() {
                      _timeSheetService.addBreakByDateTimeInterval(interval);
                    });
                    _timeSheetService.saveTimeSheet();
                    refreshBreaksModalBottomSheet();
                  }
                },
              );
            },
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
          children: <Widget>[
            header,
            Flexible(
              child: content,
            ),
            Divider(
              height: 0,
            ),
            controlPanel,
          ],
        );
      },
    ).whenComplete(() {
      setState(() {
        _timeSheetService.saveTimeSheet();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle mainTextStyle = Theme.of(context).textTheme.headline5;
    _timeSheetService.loadTimeSheet();
    String currentState = isWork ? 'На перерыв' : 'К работе';

    DateTime departureDateTime = _timeSheetService.calculateDepartureDateTime();
    int dayOverflow =
        departureDateTime.difference(_timeSheetService.getArrivalTime()).inDays;

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
                int currentBreakDurationInSeconds =
                    this._timeSheetService.isBreakTime() ? tick + 1 : 0;
                return Duration(seconds: currentBreakDurationInSeconds);
              });
            }
            isWork
                ? _timeSheetService.startBreak()
                : _timeSheetService.stopBreak();
            _timeSheetService.saveTimeSheet();
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
              WidgetWithAction(
                widget: Text(shortTimeWithShortDate
                    .format(_timeSheetService.getArrivalTime())),
                callback: () {
                  getTimeFromModalBottomSheet(context,
                          initTime: _timeSheetService.getArrivalTime())
                      .then((DateTime time) => setState(() {
                            _timeSheetService.setArrivalTime(time);
                            _timeSheetService.saveTimeSheet();
                          }));
                },
              ),
              Spacer(),
              Text('общее время перерывов'),
              WidgetWithAction(
                widget: Text(formatFullDuration(
                    _timeSheetService.getTotalBreakDuration())),
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
