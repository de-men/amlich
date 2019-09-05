import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:licham/js/window.dart';
import 'package:licham/main_bloc.dart';
import 'package:licham/main_state.dart';
import 'package:licham/widget/loading_indicator.dart';
import 'package:licham/widget/my_flutter_app_icons.dart';

class MainView extends StatefulWidget {
  @override
  State<MainView> createState() => _MainState();
}

class _MainState extends State<MainView> {
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
      child: Scaffold(
        appBar: AppBar(
          title: _buildTitle(mainBloc),
          centerTitle: true,
        ),
        body: _buildBody(mainBloc),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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

  BlocBuilder _buildTitle(MainBloc bloc) {
    return BlocBuilder<MainBloc, MainState>(
      condition: (previousState, currentState) => currentState is SolarUpdate,
      builder: (context, state) {
        print('_buildTitle $state');
        if (state is SolarUpdate) {
          return Text(bloc.monthYearFormat.format(state.date).toUpperCase());
        }
        return Text("Today");
      },
    );
  }

  BlocBuilder _buildBody(MainBloc bloc) {
    return BlocBuilder<MainBloc, MainState>(
      builder: (context, state) {
        print('_buildBody $state');
        if (state is MainUninitialized) {
          return LoadingIndicator();
        }
        if (state is SolarUpdate) {
          return LayoutBuilder(
              builder: (context, constraints) => Column(
                    children: <Widget>[
                      Expanded(child: _buildSolar(bloc)),
                      Divider(thickness: 8),
                      SizedBox(
                        height:
                            (constraints.maxHeight - constraints.minHeight) *
                                0.4,
                        child: Text(''),
                      )
                    ],
                  ));
        }
        return Text("Body");
      },
    );
  }

  BlocBuilder _buildSolar(MainBloc bloc) {
    return BlocBuilder<MainBloc, MainState>(
      condition: (previousState, currentState) => currentState is SolarUpdate,
      builder: (context, state) {
        print('_buildSolar $state');
        if (state is SolarUpdate) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                '${state.date.day}',
                style: Theme.of(context).textTheme.display4,
              ),
              Text(
                bloc.weekFormat.format(state.date),
                style: Theme.of(context).textTheme.title,
              ),
            ],
          );
        }
        return Text("Body");
      },
    );
  }
}
