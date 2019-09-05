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
  DateTime _solar = DateTime.now();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
            _solar = state.solar;
            return Scaffold(
              appBar: AppBar(
                title:
                    Text(mainBloc.monthYearFormat.format(_solar).toUpperCase()),
                centerTitle: true,
                actions: <Widget>[
                  // overflow menu
                  PopupMenuButton<Choice>(
                    onSelected: (choice) async {
                      switch (choices.indexOf(choice)) {
                        case 0: // Today
                          mainBloc.dispatch(TodaySelected());
                          break;
                        case 1: // Solar
                          final DateTime picked = await showDatePicker(
                            context: context,
                            initialDate: _solar,
                            firstDate: DateTime(1),
                            lastDate: DateTime(3000),
                          );
                          mainBloc.dispatch(SolarSelected(solar: picked));
                          break;
                        case 2: // Lunar
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Ngày Âm'),
                                  content: Form(
                                    key: _formKey,
                                    autovalidate: true,
                                    child: TextFormField(
                                      keyboardType: TextInputType.datetime,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Ngày/Tháng/Năm',
                                      ),
                                      maxLines: 1,
                                      validator: _validateNgayThangNam,
                                      onSaved: (value) {
                                        Navigator.pop(context);
                                        mainBloc.dispatch(LunarSelected(lunar: value));
                                      },
                                    ),
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: const Text('DISAGREE'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    FlatButton(
                                      child: const Text('AGREE'),
                                      onPressed: _handleSubmitted,
                                    ),
                                  ],
                                );
                              }).then<void>((value) {
                            // The value passed to Navigator.pop() or null.
                            if (value != null) {
                              print('You selected: $value');
                            }
                          });
                          break;
                      }
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
                                    '${_solar.day}',
                                    style: Theme.of(context).textTheme.display4,
                                  ),
                                  Text(
                                    mainBloc.weekFormat.format(_solar),
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

  String _validateNgayThangNam(String value) {
    if (value.isEmpty) return 'Cần nhập ngày âm';
    final RegExp nameExp = RegExp(
        r'^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/)(?:0?[13-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$');
    if (!nameExp.hasMatch(value)) return 'Nhập theo Ngày/Tháng/Năm';
    return null;
  }

  void _handleSubmitted() {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
    }
  }
}
