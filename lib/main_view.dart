import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:licham/js/window.dart';
import 'package:licham/main_bloc.dart';
import 'package:licham/main_state.dart';
import 'package:licham/widget/my_flutter_app_icons.dart';

class MainView extends StatefulWidget {
  @override
  State<MainView> createState() => _MainState();
}

class _MainState extends State<MainView> {
  @override
  Widget build(BuildContext context) {
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
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Title'),
            ),
            body: Text('Body'),
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
