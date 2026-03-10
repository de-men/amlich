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
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainState();
}

class _MainState extends State<MainView> {
  static const List<Choice> choices = <Choice>[
    Choice(title: 'Hôm Nay', icon: Icons.calendar_today),
    Choice(title: 'Tìm Ngày Dương', icon: CustomIcons.sun),
    Choice(title: 'Tìm Ngày Âm', icon: CustomIcons.moon),
  ];
  DateTime? _solar = DateTime.now();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final mainBloc = BlocProvider.of<MainBloc>(context);
    return BlocListener<MainBloc, MainState>(
      listener: (context, state) {
        if (state is MainFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<MainBloc, MainState>(
        buildWhen: (previousState, currentState) => currentState is DateUpdate,
        builder: (context, state) {
          if (state is DateUpdate) {
            _solar = state.solar;
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  mainBloc.monthYearFormat.format(_solar!).toUpperCase(),
                ),
                centerTitle: true,
                actions: <Widget>[
                  PopupMenuButton<Choice>(
                    onSelected: (choice) async {
                      switch (choices.indexOf(choice)) {
                        case 0:
                          mainBloc.add(const TodaySelected());
                        case 1:
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _solar,
                            firstDate: DateTime(1),
                            lastDate: DateTime(3000),
                          );
                          mainBloc.add(SolarSelected(solar: picked));
                        case 2:
                          if (!context.mounted) return;
                          await showDialog<void>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Ngày Âm'),
                                content: Form(
                                  key: _formKey,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  child: TextFormField(
                                    keyboardType: TextInputType.datetime,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Ngày/Tháng/Năm',
                                    ),
                                    validator: _validateNgayThangNam,
                                    onSaved: (value) {
                                      Navigator.pop(context);
                                      mainBloc.add(LunarSelected(lunar: value));
                                    },
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('DISAGREE'),
                                  ),
                                  TextButton(
                                    onPressed: _handleSubmitted,
                                    child: const Text('AGREE'),
                                  ),
                                ],
                              );
                            },
                          );
                      }
                    },
                    itemBuilder: (context) {
                      return choices.map((choice) {
                        return PopupMenuItem<Choice>(
                          value: choice,
                          child: ListTile(
                            leading: Icon(choice.icon),
                            title: Text(choice.title!),
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
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () {
                              mainBloc.add(const PreviousSelected());
                            },
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Text(
                                '${_solar!.day}',
                                style: Theme.of(context).textTheme.displayLarge,
                              ),
                              Text(
                                mainBloc.weekFormat.format(_solar!),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () {
                              mainBloc.add(const NextSelected());
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(thickness: 8),
                    SizedBox(
                      height:
                          (constraints.maxHeight - constraints.minHeight) * 0.4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                'Tháng ${state.lunar!.canChiMonth}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                'Ngày ${state.lunar!.canChiDay}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                'Năm ${state.lunar!.canchiYear}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                '${state.lunar!.monthString}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${state.lunar!.day}',
                                style:
                                    Theme.of(context).textTheme.displayMedium,
                              ),
                              Text(
                                'Năm ${state.lunar!.year}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: state.lunar!.hours!
                                .map<Text>(
                                  (hour) => Text(
                                    hour,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: FloatingActionButton(
                onPressed: _openCalendar,
                child: const Icon(CustomIcons.calendarPlusO),
              ),
              bottomNavigationBar: BottomAppBar(
                shape: const CircularNotchedRectangle(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(CustomIcons.downCircled2),
                      onPressed: _openDownload,
                    ),
                    IconButton(
                      icon: const Icon(CustomIcons.githubCircled),
                      onPressed: _openGithub,
                    ),
                  ],
                ),
              ),
            );
          }
          return const LoadingIndicator();
        },
      ),
    );
  }

  void _openCalendar() {
    open(
      'https://calendar.google.com/calendar/r?cid=demen.org_4jc7p02lkoire319rabglmfifo@group.calendar.google.com',
    );
  }

  void _openDownload() {
    open(
      'https://calendar.google.com/calendar/ical/demen.org_4jc7p02lkoire319rabglmfifo%40group.calendar.google.com/public/basic.ics',
    );
  }

  void _openGithub() {
    open('https://github.com/de-men/amlich');
  }

  String? _validateNgayThangNam(String? value) {
    if (value!.isEmpty) return 'Cần nhập ngày âm';
    final nameExp = RegExp(
      r'^(?:31([/\-.])(?:0?[13578]|1[02])\1|(?:29|30)(/)(?:0?[13-9]|1[0-2])\2)(?:1[6-9]|[2-9]\d)?\d{2}$|^29([/\-.])0?2\3(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:16|[2468][048]|[3579][26])00)$|^(?:0?[1-9]|1\d|2[0-8])([/\-.])(?:0?[1-9]|1[0-2])\4(?:1[6-9]|[2-9]\d)?\d{2}$',
    );
    if (!nameExp.hasMatch(value)) return 'Nhập theo Ngày/Tháng/Năm';
    return null;
  }

  void _handleSubmitted() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
    }
  }
}
