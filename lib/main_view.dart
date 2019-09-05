import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:licham/choice.dart';
import 'package:licham/js/window.dart';
import 'package:licham/main_bloc.dart';
import 'package:licham/main_event.dart';
import 'package:licham/main_state.dart';
import 'package:licham/widget/loading_indicator.dart';
import 'package:licham/widget/my_flutter_app_icons.dart';

class MainView extends StatefulWidget {
  @override
  State<MainView> createState() => _MainState();
}

class _MainState extends State<MainView> {
  static const List<Choice> choices = const <Choice>[
    const Choice(title: 'Hôm Nay', icon: Icons.calendar_today),
    const Choice(title: 'Tìm Ngày Dương', icon: CustomIcons.sun),
    const Choice(title: 'Tìm Ngày Âm', icon: CustomIcons.moon),
  ];

  @override
  Widget build(BuildContext context) {
    final mainBloc = BlocProvider.of<MainBloc>(context);
    return BlocListener<MainBloc, MainState>(
      listener: (context, state) {
        if (state is MainFailure) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<MainBloc, MainState>(
        condition: (previousState, currentState) => currentState is DateUpdate,
        builder: (context, state) {
          print('_buildTitle $state');
          if (state is DateUpdate) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                    mainBloc.monthYearFormat.format(state.solar).toUpperCase()),
                centerTitle: true,
                actions: <Widget>[
                  // overflow menu
                  PopupMenuButton<Choice>(
                    onSelected: (choice) => {
                      if (choices.indexOf(choice) == 0)
                        {mainBloc.dispatch(TodaySelected())}
                    },
                    itemBuilder: (BuildContext context) {
                      return choices.map((Choice choice) {
                        return PopupMenuItem<Choice>(
                          value: choice,
                          child: ListTile(
                            leading: Icon(choice.icon),
                            title: Text(choice.title),
                          ),
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
              body: LayoutBuilder(
                  builder: (context, constraints) => Column(
                        children: <Widget>[
                          Expanded(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.chevron_left),
                                onPressed: () {
                                  mainBloc.dispatch(PreviousSelected());
                                },
                              ),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Text(
                                    '${state.solar.day}',
                                    style: Theme.of(context).textTheme.display4,
                                  ),
                                  Text(
                                    mainBloc.weekFormat.format(state.solar),
                                    style: Theme.of(context).textTheme.title,
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.chevron_right),
                                onPressed: () {
                                  mainBloc.dispatch(NextSelected());
                                },
                              ),
                            ],
                          )),
                          Divider(thickness: 8),
                          SizedBox(
                            height: (constraints.maxHeight -
                                    constraints.minHeight) *
                                0.4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      'Tháng ${state.lunar.canChiMonth}',
                                      style: Theme.of(context).textTheme.body1,
                                    ),
                                    Text(
                                      'Ngày ${state.lunar.canChiDay}',
                                      style: Theme.of(context).textTheme.body1,
                                    ),
                                    Text(
                                      'Năm ${state.lunar.canchiYear}',
                                      style: Theme.of(context).textTheme.body1,
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      '${state.lunar.monthString}',
                                      style: Theme.of(context).textTheme.title,
                                    ),
                                    Text(
                                      '${state.lunar.day}',
                                      style:
                                          Theme.of(context).textTheme.display2,
                                    ),
                                    Text(
                                      'Năm ${state.lunar.year}',
                                      style: Theme.of(context).textTheme.title,
                                    ),
                                  ],
                                ),
                                Text(
                                  'Giờ Hoàng Đạo\n${state.lunar.hours}',
                                  style: Theme.of(context).textTheme.body1,
                                ),
                              ],
                            ),
                          )
                        ],
                      )),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: FloatingActionButton(
                child: Icon(CustomIcons.calendar_plus_o),
                onPressed: _openCalendar,
              ),
              bottomNavigationBar: BottomAppBar(
                shape: CircularNotchedRectangle(),
                notchMargin: 4.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(CustomIcons.down_circled2),
                      onPressed: _openDownload,
                    ),
                    IconButton(
                      icon: Icon(CustomIcons.github_circled),
                      onPressed: _openGithub,
                    )
                  ],
                ),
              ),
            );
          }
          return LoadingIndicator();
        },
      ),
    );
  }

  _openCalendar() {
    open(
        'https://calendar.google.com/calendar/r?cid=demen.org_4jc7p02lkoire319rabglmfifo@group.calendar.google.com');
  }

  _openDownload() {
    open(
        'https://calendar.google.com/calendar/ical/demen.org_4jc7p02lkoire319rabglmfifo%40group.calendar.google.com/public/basic.ics');
  }

  _openGithub() {
    const url = 'https://github.com/de-men/amlich';
    open(url);
  }
}
