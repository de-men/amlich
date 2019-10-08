import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:licham/main_bloc.dart';
import 'package:licham/main_event.dart';
import 'package:licham/main_view.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print(error);
  }
}

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  DateTime date = _getDate(Uri.base.queryParameters);
  runApp(
    BlocProvider<MainBloc>(
      builder: (context) {
        return MainBloc(date)
          ..dispatch(AppStarted());
      },
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  Widget build(ct) {
    return MaterialApp(
      theme: _buildDarkTheme(),
      title: "Âm Lịch",
      home: MainView(),
    );
  }
}

DateTime _getDate(Map<String, String> queryParameters) {
  final date = queryParameters['date'];
  try {
    return DateFormat("dd-MM-yyyy", "en_US").parse(date);
  } on Exception {
    return DateTime.now();
  }
}

ThemeData _buildDarkTheme() {
  const Color primaryColor = Color(0xFF0175c2);
  const Color secondaryColor = Color(0xFF13B9FD);
  final ColorScheme colorScheme = const ColorScheme.dark().copyWith(
    primary: primaryColor,
    secondary: secondaryColor,
  );
  return ThemeData(
    brightness: Brightness.dark,
    accentColorBrightness: Brightness.dark,
    primaryColor: primaryColor,
    primaryColorDark: const Color(0xFF0050a0),
    primaryColorLight: secondaryColor,
    buttonColor: primaryColor,
    indicatorColor: Colors.white,
    toggleableActiveColor: const Color(0xFF6997DF),
    accentColor: secondaryColor,
    canvasColor: const Color(0xFF202124),
    scaffoldBackgroundColor: const Color(0xFF202124),
    backgroundColor: const Color(0xFF202124),
    errorColor: const Color(0xFFB00020),
    buttonTheme: ButtonThemeData(
      colorScheme: colorScheme,
      textTheme: ButtonTextTheme.primary,
    ),
  );
}
